# Guía de Certificaciones AWS

> **Ruta completa de certificación desde Cloud Practitioner hasta Specialty**

---

## Niveles de Certificación

```
┌─────────────────────────────────────────────────────────────────┐
│                     AWS CERTIFICATION PATH                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐                                               │
│  │   CLOUD      │  Fundamentos de AWS                          │
│  │  PRACTITIONER│                                              │
│  └──────┬───────┘                                               │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────────────────────────┐                   │
│  │              ASSOCIATE                   │                   │
│  │  ┌──────────┬──────────┬────────────┐   │                   │
│  │  │Solutions │Developer │ SysOps      │   │                   │
│  │  │Architect │         │Administrator│   │                   │
│  │  └────┬─────┴────┬─────┴─────┬──────┘   │                   │
│  └───────┼──────────┼──────────┼──────────┘                   │
│          │          │          │                               │
│          └──────────┴──────────┘                               │
│                     │                                          │
│                     ▼                                          │
│  ┌──────────────────────────────────────────┐                  │
│  │            PROFESSIONAL                  │                  │
│  │  ┌────────────────┬──────────────────┐    │                  │
│  │  │ Solutions      │ DevOps           │    │                  │
│  │  │ Architect      │ Engineer         │    │                  │
│  │  └────────────────┴──────────────────┘    │                  │
│  └──────────────────────────────────────────┘                  │
│                                                                 │
│  ┌──────────────────────────────────────────┐                   │
│  │              SPECIALTY                   │                   │
│  │  Security | ML | Database | Network     │                   │
│  │  SAP on AWS | Alexa | Data Analytics    │                   │
│  └──────────────────────────────────────────┘                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Cloud Practitioner (Fundacional)

### Descripción
Certificación de entrada que demuestra comprensión de los fundamentos de la nube AWS.

### Público Objetivo
- Profesionales de ventas
- Marketing técnico
- Gestores de proyectos
- Ejecutivos
- Candidatos a roles técnicos

### Temario
| Dominio | Peso |
|---------|------|
| Conceptos de Cloud | 24% |
| Seguridad y Compliance | 30% |
| Tecnología | 30% |
| Facturación y Pricing | 16% |

### Recursos de Estudio
- **Curso oficial**: AWS Cloud Practitioner Essentials (6 horas)
- **Práctica**: Cloud Quest
- **Whitepapers**: Overview of AWS, AWS Well-Architected Framework
- **Costo del examen**: $100 USD

### Consejos
- Enfócate en conceptos, no en implementación técnica
- Entiende el modelo de responsabilidad compartida
- Domina los servicios principales por nombre y función

---

## Associate Level

### Solutions Architect

**Rol**: Diseña sistemas distribuidos escalables y resilientes en AWS.

**Temario**:
| Dominio | Peso |
|---------|------|
| Diseño de Arquitecturas Resilientes | 26% |
| Diseño de Arquitecturas de Alto Rendimiento | 24% |
| Diseño de Arquitecturas Seguras | 30% |
| Diseño Costo-Optimizado | 20% |

**Recursos**:
- AWS Solutions Architect Learning Path
- Hands-on Labs
- Arquitecturas de referencia AWS
- **Costo**: $150 USD

### Developer

**Rol**: Desarrolla y mantiene aplicaciones en AWS.

**Temario**:
| Dominio | Peso |
|---------|------|
| Desarrollo con AWS Services | 30% |
| Seguridad | 26% |
| Despliegue | 24% |
| Troubleshooting y Optimización | 20% |

**Habilidades clave**:
- SDKs de AWS (boto3, AWS SDK for JavaScript)
- CI/CD (CodePipeline, CodeBuild)
- API Gateway, Lambda, DynamoDB
- Serverless frameworks

### SysOps Administrator

**Rol**: Opera, gestiona y monitoriza sistemas en AWS.

**Temario**:
| Dominio | Peso |
|---------|------|
| Monitoreo y Reporting | 20% |
| Alta Disponibilidad | 16% |
| Deployment y Provisioning | 16% |
| Almacenamiento y Data Management | 18% |
| Seguridad y Compliance | 16% |
| Networking | 14% |

**Habilidades clave**:
- CloudWatch, CloudTrail
- Systems Manager
- CloudFormation
- VPC networking

---

## Professional Level

### Solutions Architect Professional

**Prerrequisito**: Solutions Architect Associate

**Temario**:
| Dominio | Peso |
|---------|------|
| Diseño para Requisitos Complejos | 26% |
| Diseño de Nuevas Soluciones | 29% |
| Migración de Planning | 15% |
| Costo-Control y Optimización | 15% |
| Mejora Continua | 15% |

**Escenarios complejos**:
- Multi-region architectures
- Hybrid cloud designs
- Microservices at scale
- Data lake implementations
- Disaster recovery strategies

### DevOps Engineer Professional

**Prerrequisito**: Developer Associate o SysOps Administrator Associate

**Temario**:
| Dominio | Peso |
|---------|------|
| SDLC Automation | 22% |
| Configuration Management | 19% |
| Monitoreo y Logging | 19% |
| Policies y Standards | 14% |
| Incident Response | 18% |
| High Availability | 16% |

**Herramientas principales**:
- CodePipeline, CodeBuild, CodeDeploy
- CloudFormation, Terraform
- ECS, EKS, Lambda
- CloudWatch, X-Ray

---

## Specialty Certifications

### AWS Certified Security – Specialty

**Enfoque**: Seguridad avanzada en AWS

**Dominios**:
- Incident Response (12%)
- Logging y Monitoring (20%)
- Infrastructure Security (26%)
- Identity y Access Management (20%)
- Data Protection (22%)

**Servicios clave**:
- KMS, Secrets Manager
- GuardDuty, Security Hub
- WAF, Shield
- CloudTrail, Config

### AWS Certified Machine Learning – Specialty

**Enfoque**: ML y AI en AWS

**Dominios**:
- Ingeniería de Datos (20%)
- Exploración de Datos (24%)
- Modeling (36%)
- ML Implementation y Operations (20%)

**Servicios**:
- SageMaker, Comprehend
- Rekognition, Polly
- Kinesis, Glue

### AWS Certified Database – Specialty

**Enfoque**: Bases de datos en AWS

**Dominios**:
- Workload-Specific Database Design (26%)
- Deployment y Migration (24%)
- Management y Operations (25%)
- Monitoring y Troubleshooting (15%)
- Database Security (10%)

### AWS Certified Advanced Networking – Specialty

**Enfoque**: Redes complejas en AWS

**Dominios**:
- Network Design (24%)
- Network Implementation (28%)
- Network Management y Operation (26%)
- Network Security, Compliance, Governance (22%)

### AWS Certified: SAP on AWS – Specialty

**Enfoque**: Workloads SAP en AWS

**Dominios**:
- SAP Workload Design (25%)
- SAP Worklift Migration (30%)
- SAP Operation y Maintenance (25%)
- SAP Disaster Recovery (20%)

### AWS Certified Alexa Skill Builder – Specialty

**Enfoque**: Desarrollo de skills para Alexa

**Dominios**:
- Voice-First Design Practices (14%)
- Skill Design (24%)
- Skill Architecture (14%)
- Alexa Skills Kit (ASk) Development (38%)
- Maintenance, Refactoring, Operations (10%)

---

## Preparación Efectiva

### Cronograma de Estudio Sugerido

| Certificación | Horas Estudio | Experiencia Prev |
|---------------|---------------|------------------|
| Cloud Practitioner | 20-30 | 0-6 meses |
| Solutions Architect Associate | 60-80 | 6-12 meses |
| Developer Associate | 50-70 | 6-12 meses |
| SysOps Administrator | 70-90 | 12+ meses |
| Solutions Architect Professional | 80-120 | 2+ años |
| DevOps Engineer Professional | 80-120 | 2+ años |
| Specialty | 60-100 | Varies |

### Recursos Recomendados

**Cursos Oficiales**:
- AWS Skill Builder (free tier disponible)
- AWS Classroom Training
- AWS Workshops (hands-on)

**Práctica**:
- AWS Free Tier
- Qwiklabs
- CloudAcademy
- A Cloud Guru

**Documentación**:
- AWS Whitepapers
- AWS FAQs por servicio
- AWS Architecture Center

**Práctica de Exámenes**:
- Official AWS Practice Exams
- Whizlabs
- Tutorials Dojo

### Tips para el Examen

1. **Lee cuidadosamente**: Muchas preguntas tienen pistas en el enunciado
2. **Elimina respuestas obvias**: Descarta opciones claramente incorrectas
3. **Prioriza**: "Más seguro" vs "Más barato" según el contexto
4. **Servicios gestionados**: Preferir servicios gestionados sobre self-managed
5. **Multi-AZ**: Siempre considerar alta disponibilidad
6. **Costo-optimización**: No olvides el factor costo en soluciones

### Después del Examen

**Digital Badge**:
- Comparte en LinkedIn
- Añade a tu email signature
- Actualiza tu CV

**Recertificación**:
- Associate: 3 años
- Professional: 3 años
- Specialty: 3 años

**Próximos pasos**:
- Aplica tus conocimientos en proyectos reales
- Considera la siguiente certificación
- Comparte tu experiencia con la comunidad

---

## Mapa de Contenidos

### Cloud Practitioner → Contenido de este repo
- [C1: Fundamentos de AWS](../es/whitepapers/c1-fundamentos-de-aws-y-computacion-en-la-nube.md)
- [C2: Servicios de Cómputo](../es/whitepapers/c2-servicios-de-computo-en-aws.md)
- [C3: Almacenamiento](../es/whitepapers/c3-almacenamiento-y-bases-de-datos-en-aws.md)

### Solutions Architect Associate → Contenido avanzado
- [C4: Redes](../es/whitepapers/c4-redes-y-entrega-de-contenido-en-aws.md)
- [C5: Seguridad](../es/whitepapers/c5-seguridad-y-cumplimiento-en-aws.md)
- [C9: Arquitecturas](../es/whitepapers/c9-arquitecturas-de-referencia-y-casos-de-uso-en-aws.md)

### Professional → Contenido especializado
- [C6: Integración](../es/whitepapers/c6-servicios-de-integracion-y-orquestacion-en-aws.md)
- [C7: Monitoreo](../es/whitepapers/c7-monitoreo-y-gestion-en-aws.md)
- [C10: Costos](../es/whitepapers/c10-estrategias-de-costos-en-aws.md)

---

*Última actualización: Abril 2025*
