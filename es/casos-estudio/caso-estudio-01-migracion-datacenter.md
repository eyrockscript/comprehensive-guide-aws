# Caso de Estudio: Migración de Datacenter Legacy a AWS

> **Empresa:** FinTech Global Payments  
> **Industria:** Servicios Financieros  
> **Duración:** 18 meses  
> **Equipo:** 12 ingenieros cloud, 4 arquitectos, 6 especialistas en migración

---

## Situación Inicial

### Contexto del Negocio

FinTech Global Payments procesaba $2,500 millones anuales en transacciones a través de una infraestructura on-premises distribuida en tres datacenters regionales. Con 15 años de crecimiento orgánico, la infraestructura había acumulado:

- **450 servidores físicos** (HP ProLiant, Dell PowerEdge de generaciones variadas)
- **80 VMs en VMware vSphere** con versiones desactualizadas
- **120 bases de datos** (Oracle, SQL Server, MySQL) en configuraciones heterogéneas
- **Red SAN de 500TB** con capacidad al 87%
- **Contratos de co-location** que expiraban en 18 meses

### Dolor del Negocio

| Problema | Impacto | Costo Anual |
|----------|---------|-------------|
| Failovers manuales (4 horas promedio) | Downtime crítico 12x/año | $3.2M pérdida operativa |
| Renovación hardware (ciclo 4 años) | CAPEX anticipado | $8.5M inversión |
| Licencias Oracle per-socket | Costos crecientes | $2.1M/año |
| Tickets de infraestructura (340/mes) | Velocidad de desarrollo lenta | $1.8M en retrasos |
| Compliance PCI-DSS on-premises | Auditorías complejas | $800K auditoría |

**Total costo de oportunidad: $16.4M/año**

### Objetivos de Migración

1. **Eliminar 100% de datacenters físicos** antes del vencimiento de contratos
2. **Reducir downtime de 99.5% a 99.99%** (de 43.8h a 52.6m/año)
3. **Disminuir TCO de infraestructura 35%** en 3 años
4. **Enable DevOps:** Reducir time-to-market de 6 meses a 2 semanas
5. **Modernizar stack tecnológico:** Containerización, microservicios, CI/CD

---

## Arquitectura Legacy

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATACENTER PRINCIPAL (Nueva York)             │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Web Tier   │  │   App Tier   │  │    DB Tier   │          │
│  │  (12 VMs)    │  │  (28 VMs)    │  │  (8 Oracle   │          │
│  │  IIS/Apache  │  │  Java/.NET   │  │   RAC nodes) │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
└─────────┼─────────────────┼─────────────────┼──────────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
┌───────────────────────────┼───────────────────────────────────┐
│         DR SITE (Chicago) │                                     │
│  ┌────────────────────────┴────────────────────────┐             │
│  │        Oracle DataGuard (async)              │             │
│  │        RPO: 1 hora | RTO: 4 horas             │             │
│  └───────────────────────────────────────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

### Inventario de Aplicaciones

| Categoría | Cantidad | Críticas | Complejidad |
|-----------|----------|----------|-------------|
| Core Banking | 8 | 5 | Alta |
| Payment Processing | 12 | 8 | Crítica |
| Customer Portal | 4 | 2 | Media |
| Reporting/Analytics | 15 | 1 | Baja |
| Internal Tools | 23 | 0 | Baja |
| **Total** | **62 aplicaciones** | | |

---

## Estrategia de Migración

### Framework: 7 Rs Adaptado

```
┌─────────────────────────────────────────────────────────────────┐
│                     ESTRATEGIA 7 RS                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Retire      (8 apps) ──────────────────────── 12%              │
│      └─ Aplicaciones obsoletas, duplicadas o sin uso            │
│                                                                  │
│   Retain      (5 apps) ─────────────────────── 8%              │
│      └─ Mainframe core-banking (dependencia hardware especial)  │
│                                                                  │
│   Rehost      (25 apps) ────────────────────── 40%             │
│      └─ Lift-and-shift rápido con AWS MGN                       │
│                                                                  │
│   Replatform  (15 apps) ────────────────────── 24%              │
│      └─ Migrar a RDS, Lambda, containerizar                     │
│                                                                  │
│   Refactor    (6 apps) ─────────────────────── 10%              │
│      └─ Reescritura completa a microservicios serverless        │
│                                                                  │
│   Repurchase  (3 apps) ─────────────────────── 5%              │
│      └─ Reemplazar con SaaS (ServiceNow, Workday)              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Fases de Migración

#### Fase 1: Fundación (Meses 1-3)

**Landing Zone Setup**

```yaml
# Estructura de cuentas AWS (Account-per-Workload)
Organization:
  Master Account:
    - Billing consolidation
    - SCPs (Service Control Policies)
    
  Security Account:
    - GuardDuty master
    - Security Hub
    - CloudTrail centralized
    
  Shared Services:
    - Directory Service (Microsoft AD)
    - Transit Gateway
    - Route 53 Resolver
    
  Workload Accounts:
    - Production (PCI-DSS compliant)
    - Staging (replica de prod, scaled down)
    - Development (developer sandboxes)
    - DR (cross-region replication)
```

**Network Foundation**

```
┌─────────────────────────────────────────────────────────────────┐
│                      NETWORK ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   On-Premises                    AWS Cloud                      │
│   ┌──────────┐                   ┌──────────────────────┐        │
│   │ Corporate │◄────────────────►│   Transit Gateway    │        │
│   │   LAN    │    Direct Connect│   (us-east-1)        │        │
│   └────┬─────┘   + VPN Backup   └──────────┬───────────┘        │
│        │                                    │                    │
│        │         ┌──────────────────────────┼────────────────┐   │
│        │         │                          │                │   │
│        │    ┌────┴────┐              ┌─────┴────┐     ┌────┴──┐│
│        │    │   VPC   │              │   VPC    │     │ VPC   ││
│        │    │  Prod   │              │  Staging │     │  Dev  ││
│        │    │/24      │              │/22      │     │/16    ││
│        │    └─────────┘              └──────────┘     └───────┘│
│        │                                                          │
│   ┌────┴────┐              Cross-Region Peering                  │
│   │   DR    │◄──────────────────────────────────────────►┌───────┐│
│   │ Datacenter│  Oracle DataGuard (mantenido temporal)   │ VPC   ││
│   │ ( Chicago)│                                          │  DR   ││
│   └─────────┘                                            │/24   ││
│                                                          │ us-w ││
│                                                          └───────┘│
└─────────────────────────────────────────────────────────────────┘
```

**Seguridad y Compliance**

- **PCI-DSS Level 1:** Configuración de VPC aislada para datos de tarjetas
- **AWS Config Rules:** 47 reglas de compliance automatizadas
- **AWS Certificate Manager:** SSL/TLS para todos los endpoints
- **AWS Secrets Manager:** Rotación automática de credenciales

#### Fase 2: Migración Pilot (Meses 4-6)

**Aplicación Piloto: Customer Portal**

La aplicación de portal de clientes fue seleccionada como piloto por:
- Baja criticidad de negocio (no transaccional)
- Arquitectura estándar (3-tier)
- Buena cobertura de tests
- Equipo receptivo al cambio

**Proceso de Migración:**

1. **Assessment con AWS MGN (Migration Hub)**
   ```
   Dependency Mapping:
   - Web Servers: 2 VMs (Windows 2012, IIS)
   - App Servers: 4 VMs (Windows 2016, .NET Framework 4.7)
   - Database: 1 VM (SQL Server 2016)
   - Dependencies: Active Directory, internal APIs
   ```

2. **Replication con AWS Application Migration Service**
   ```bash
   # Agent de replicación instalado en cada VM source
   # Replicación continua de bloques a EBS volumes
   # RPO: 5 minutos durante migración
   ```

3. **Cutover Plan**
   ```
   Pre-cutover (D-7):
   - Testing en staging VPC
   - Performance baseline establecido
   - Runbook documentado
   
   Cutover (D-Day):
   - Ventana de mantenimiento: 4 horas (domingo 2-6 AM)
   - Final sync + DNS switch
   - Smoke tests automatizados
   - Rollback plan verificado
   
   Post-cutover:
   - Monitoreo intensivo 72h
   - Optimización de costos (Reserved Instances)
   ```

**Resultado del Piloto:**
- Tiempo de migración: 3.5 horas (vs 4 planificadas)
- Zero rollback necesario
- Performance: 15% mejor que on-prem
- Aprendizajes documentados para waves posteriores

#### Fase 3: Migración a Escala (Meses 7-14)

**Wave Planning**

| Wave | Apps | Estrategia | Timeline | Dependencias |
|------|------|------------|----------|--------------|
| 1 | 8 | Rehost | Mes 7-8 | Piloto completado |
| 2 | 12 | Rehost+Replatform | Mes 8-10 | Wave 1 estable |
| 3 | 15 | Replatform | Mes 10-12 | RDS foundation |
| 4 | 10 | Refactor | Mes 12-14 | Microservices platform |
| 5 | 4 | Retain+Repurchase | Mes 14-16 | Contract renewals |

**Ejemplo: Migración Payment Processing (Wave 2)**

```
┌─────────────────────────────────────────────────────────────────┐
│              ARQUITECTURA ANTES (On-Premises)                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Load Balancer ──► 4x App Servers ──► Oracle RAC (4 nodes)     │
│   (F5 Big-IP)        (Java/Spring)      (Active-Active)        │
│                                           15TB storage           │
│   Peak: 2,500 TPS                                               │
│   Latencia p95: 450ms                                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              ARQUITECTURA DESPUÉS (AWS)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ALB ──► ECS Fargate ──► ElastiCache ──► Aurora PostgreSQL    │
│         │    (auto-scale)   (Redis)         (Multi-AZ)        │
│         │                                                        │
│         └─► API Gateway ──► Lambda (fraud check)                │
│                                                                  │
│   Peak: 8,500 TPS (+240% capacidad)                             │
│   Latencia p95: 85ms (-81%)                                      │
│   Costo: -40% vs on-prem equivalente                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**AWS Services Utilizados:**

- **Application Migration Service:** 25 servidores rehosteados
- **Database Migration Service:** 45 bases de datos migradas
- **S3 + Snowball:** 180TB de archivos históricos
- **AWS Migration Hub:** Tracking centralizado de progreso

#### Fase 4: Modernización (Meses 12-16)

**Replatforming a Serverless**

Aplicaciones críticas reescritas a microservicios:

```yaml
# Ejemplo: Servicio de notificaciones
Architecture:
  Ingress:
    - API Gateway (throttling: 10k req/s)
    
  Compute:
    - Lambda (Python 3.9, 512MB RAM)
    - EventBridge para orquestación
    
  Data:
    - DynamoDB (on-demand capacity)
    - SQS (dead-letter queues)
    
  Integration:
    - SNS (multi-channel: SMS, Email, Push)
    - SES para emails transaccionales
    
  Monitoring:
    - CloudWatch Logs Insights
    - X-Ray distributed tracing
    
  Security:
    - Cognito (user pools)
    - WAF (rate limiting)
    
Results:
  Cost: $0.12 por 1,000 notificaciones
  Latency: 45ms promedio
  Availability: 99.999% (5x9)
```

---

## Arquitectura Final

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS ORGANIZATION                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Security Account          Shared Services                     │
│   ┌────────────────┐        ┌────────────────┐                │
│   │ GuardDuty      │        │ Transit Gateway│◄────┐         │
│   │ Security Hub   │        │ Route 53       │     │         │
│   │ Config Rules   │        │ Directory Serv │     │         │
│   └────────────────┘        └────────────────┘     │         │
│                                                    │         │
│   Production Account                               │         │
│   ┌──────────────────────────────────────────────────────┐   │
│   │  VPC (10.0.0.0/16)                                   │   │
│   │  ┌─────────────┬─────────────┬───────────────────┐   │   │
│   │  │   Public    │  Private    │     Database      │   │   │
│   │  │   Subnets   │  Subnets    │     Subnets       │   │   │
│   │  │             │             │                   │   │   │
│   │  │  ALB        │  ECS/EKS    │  Aurora           │   │   │
│   │  │  CloudFront │  Lambda     │  ElastiCache      │   │   │
│   │  │  WAF        │  EC2 (legacy)│  MSK (Kafka)     │   │   │
│   │  └─────────────┴─────────────┴───────────────────┘   │   │
│   │                                                      │   │
│   │  Multi-AZ: us-east-1a, 1b, 1c                        │   │
│   └──────────────────────────────────────────────────────┘   │
│                                                    │         │
│   DR Account (us-west-2)  ◄────────────────────────┘         │
│   ┌──────────────────────────────────────────────────────┐   │
│   │  VPC (10.1.0.0/16) - Aurora Global, S3 CRR         │   │
│   └──────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Resultados y Métricas

### KPIs de Negocio

| Métrica | Before | After | Mejora |
|---------|--------|-------|--------|
| **Availability** | 99.5% | 99.99% | +0.49% |
| **Downtime anual** | 43.8 horas | 52.6 minutos | -98% |
| **Time-to-Market** | 6 meses | 2 semanas | -92% |
| **Costo de infraestructura** | $16.4M/año | $10.2M/año | -38% |
| **TCO 3 años** | $52M | $31M | -40% |

### Métricas Técnicas

```
┌─────────────────────────────────────────────────────────────────┐
│                    TECHNICAL ACHIEVEMENTS                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Performance                                                     │
│  ├── Latency p95: 450ms → 85ms (-81%)                           │
│  ├── Throughput: 2,500 → 8,500 TPS (+240%)                      │
│  └── Concurrency: 10K → 100K usuarios simultáneos               │
│                                                                  │
│  Escalabilidad                                                   │
│  ├── Auto-scaling: 0 → 15 min (vs 3 semanas procurement)      │
│  ├── Database: Vertical → Horizontal (Aurora auto-scaling)      │
│  └── Storage: 500TB → 2PB (S3 + Intelligent Tiering)           │
│                                                                  │
│  Seguridad                                                       │
│  ├── Vulnerabilidades críticas: 47 → 0                          │
│  ├── PCI compliance: Manual → Automated (AWS Config)          │
│  └── Encryption: Parcial → 100% (at-rest + in-transit)          │
│                                                                  │
│  Operaciones                                                     │
│  ├── Deployments/mes: 4 → 340 (+8,400%)                         │
│  ├── Lead time: 3 semanas → 2.5 horas                          │
│  ├── Rollback time: 4 horas → 5 minutos                         │
│  └── MTTR: 180 min → 8 min                                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Costos AWS (Annual)

| Servicio | Costo Mensual | Costo Anual | % Total |
|----------|---------------|-------------|---------|
| EC2 + EBS | $285,000 | $3,420,000 | 33% |
| RDS/Aurora | $195,000 | $2,340,000 | 23% |
| S3 | $45,000 | $540,000 | 5% |
| Data Transfer | $85,000 | $1,020,000 | 10% |
| Lambda/Serverless | $35,000 | $420,000 | 4% |
| Support (Enterprise) | $75,000 | $900,000 | 9% |
| Other (CloudWatch, etc) | $130,000 | $1,560,000 | 15% |
| **Total** | **$850,000** | **$10,200,000** | **100%** |

**Ahorro vs on-premises:** $6.2M/año (38%)

---

## Lecciones Aprendidas

### Lo Que Funcionó Bien

1. **Account-per-Workload Strategy**
   - Aislamiento de blast radius
   - Billing granular por equipo
   - SCPs por entorno (dev/staging/prod)

2. **Migration Hub Centralizado**
   - Visibilidad real-time de progreso
   - Identificación temprana de bloqueos
   - Reporting ejecutivo automatizado

3. **Equipo de Enablement**
   - Cloud Center of Excellence (CCoE)
   - Guilds de práctica (DevOps, Security)
   - Training: 40 horas/ingeniero (AWS certs)

4. **Automatización desde el día 1**
   - Infrastructure as Code (Terraform)
   - CI/CD pipelines (CodePipeline)
   - Compliance as Code (AWS Config)

### Desafíos y Soluciones

| Desafío | Impacto | Solución |
|---------|---------|----------|
| Oracle → PostgreSQL | 3 apps con stored procedures complejas | AWS SCT + manual refactoring (6 semanas adicionales) |
| Latencia cross-AZ | 15% performance degradation | Aurora Global + ElastiCache cluster mode |
| Data residency | Requisito regulatorio | Outposts para workloads específicas |
| Costo egress | $85K/mes inesperado | Direct Connect + VPC endpoints |
| Legacy auth (AD) | Dependencia crítica | Managed AD + trust relationships |

### Recomendaciones

> **Para migraciones enterprise similares:**

1. **Involucrar a seguridad desde el día 1** - Compliance delayed, project delayed
2. **Planificar 6 meses de runbook refinement** - Documentación viviente
3. **Budget 20% buffer para refactoring** - Siempre hay más technical debt de lo visible
4. **Establish Cloud FinOps team** - Cost optimization es continuo, no one-time
5. **Retener expertise legacy** - Algunos sistemas requieren conocimiento tribal

---

## Recursos Adicionales

- **AWS Migration Whitepaper:** https://docs.aws.amazon.com/whitepapers/latest/aws-migration-whitepaper/
- **Migration Hub:** https://aws.amazon.com/migration-hub/
- **Well-Architected Framework:** https://aws.amazon.com/architecture/well-architected/

---

*Caso de estudio preparado para fines educativos. Datos anonimizados basados en migraciones reales enterprise.*

*Última actualización: Abril 2025*
