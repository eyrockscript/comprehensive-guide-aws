# Capítulo 5: Seguridad y Cumplimiento en AWS

## Resumen Ejecutivo

En la era digital actual, la seguridad en la nube se ha convertido en una prioridad estratégica para organizaciones de todos los tamaños. Amazon Web Services (AWS) ofrece un conjunto integral de servicios de seguridad y cumplimiento diseñados para proteger datos, aplicaciones e infraestructura en la nube. Este whitepaper explora los principales conceptos, servicios y mejores prácticas de seguridad en AWS, proporcionando una guía completa para implementar arquitecturas seguras y cumplir con requisitos regulatorios. Comprender estos aspectos es fundamental para cualquier organización que busque aprovechar los beneficios de la nube mientras mantiene una postura de seguridad robusta.

## Modelo de Responsabilidad Compartida

El modelo de responsabilidad compartida es un concepto fundamental para entender la seguridad en AWS.

### División de Responsabilidades

- **Responsabilidad de AWS:** Seguridad "DE" la nube
  - Infraestructura física (centros de datos)
  - Hardware y software de virtualización
  - Redes físicas y virtuales
  - Servicios gestionados como S3, DynamoDB, RDS

- **Responsabilidad del Cliente:** Seguridad "EN" la nube
  - Configuración de servicios AWS
  - Gestión de datos
  - Controles de acceso e identidad
  - Seguridad de aplicaciones
  - Configuración de sistemas operativos
  - Parches y actualizaciones

### Variaciones según el Servicio

El nivel de responsabilidad varía según el tipo de servicio:

- **IaaS (Ej. EC2):** Mayor responsabilidad del cliente
- **PaaS (Ej. Elastic Beanstalk):** Responsabilidad compartida
- **SaaS (Ej. WorkMail):** Mayor responsabilidad de AWS

## AWS Identity and Access Management (IAM)

IAM es el servicio fundamental para controlar el acceso seguro a recursos AWS.

### Componentes Principales

- **Usuarios:** Identidades para personas o servicios
- **Grupos:** Colecciones de usuarios para asignación de permisos
- **Roles:** Conjunto de permisos temporales asumibles
- **Políticas:** Documentos JSON que definen permisos
- **Proveedores de identidad:** Integración con directorios externos

### Prácticas Recomendadas

- **Privilegio mínimo:** Otorgar solo los permisos necesarios
- **MFA:** Implementar autenticación multifactor
- **Rotación de credenciales:** Cambio regular de contraseñas y claves
- **Análisis de acceso:** Revisión periódica de permisos
- **AWS Organizations:** Administración centralizada de múltiples cuentas
- **Políticas basadas en condiciones:** Restricciones adicionales (IP, hora, MFA)

### AWS IAM Identity Center (SSO)

Servicio para administrar centralmente el acceso a múltiples cuentas AWS y aplicaciones.

- Integración con proveedores de identidad corporativos
- Experiencia de inicio de sesión único
- Gestión centralizada de permisos
- Monitoreo de actividad de usuario

## Protección de Infraestructura

### VPC (Virtual Private Cloud) y Seguridad de Red

- **Grupos de seguridad:** Firewalls stateful a nivel de instancia
- **Network ACLs:** Firewalls stateless a nivel de subred
- **Route tables:** Control de tráfico entre subredes
- **Aislamiento de subredes:** Separación de recursos críticos
- **VPC Endpoints:** Acceso privado a servicios AWS
- **VPC Flow Logs:** Registro de tráfico IP para análisis

### AWS Shield y Protección DDoS

- **Shield Standard:** Protección básica gratuita
- **Shield Advanced:** Protección avanzada, equipo de respuesta
- **Prácticas DDoS resilientes:**
  - Arquitectura distribuida
  - Auto Scaling
  - CloudFront para absorción de ataques
  - Route 53 para DNS resiliente

### AWS WAF (Web Application Firewall)

- Protección contra vulnerabilidades web comunes (OWASP Top 10)
- Reglas personalizables y administradas
- Integración con CloudFront, ALB, API Gateway, AppSync
- Bot control y prevención de fraude

### AWS Network Firewall

- Firewall de red administrado para VPCs
- Inspección de tráfico con estado
- Filtrado de dominios y URLs
- Prevención de intrusiones
- Integración con servicios de terceros

## Protección de Datos

### Encriptación en AWS

- **En reposo:**
  - AWS KMS (Key Management Service)
  - CloudHSM (Hardware Security Module)
  - Encriptación a nivel de servicio (S3, EBS, RDS)

- **En tránsito:**
  - TLS/SSL
  - VPN
  - API endpoints HTTPS
  - AWS Certificate Manager

- **Gestión de claves:**
  - Rotación automática
  - Control de acceso granular
  - Auditoría de uso

### Amazon Macie

- Descubrimiento y clasificación de datos sensibles
- Alertas sobre configuraciones de acceso de riesgo
- Monitoreo continuo de datos en S3
- Informes detallados de exposición de datos

### AWS Config

- Evaluación, auditoría y registro de configuraciones
- Reglas de conformidad predefinidas y personalizadas
- Seguimiento de cambios históricos
- Remediación automática

## Detección de Amenazas y Respuesta a Incidentes

### Amazon GuardDuty

- Servicio de detección de amenazas continuo
- Análisis inteligente utilizando ML
- Monitorización de:
  - Logs de CloudTrail (API calls)
  - VPC Flow Logs (tráfico de red)
  - DNS logs (exfiltración de datos)
  - Actividad de Kubernetes

### AWS Security Hub

- Visión centralizada del estado de seguridad
- Agregación de alertas de múltiples servicios
- Comprobación automatizada de estándares:
  - AWS Foundational Security Best Practices
  - CIS AWS Foundations Benchmark
  - PCI DSS
- Flujos de trabajo de remediación

### Amazon Detective

- Análisis profundo de eventos de seguridad
- Visualizaciones interactivas de comportamiento
- Investigación de causas raíz
- Correlación de múltiples fuentes de datos

### AWS CloudTrail

- Registro y monitoreo de actividad de la cuenta
- Histórico de eventos de API
- Detección de actividad inusual
- Evidencia para cumplimiento y auditoría

## Gestión de Vulnerabilidades

### Amazon Inspector

- Evaluación automatizada de vulnerabilidades
- Escaneo de instancias EC2 y contenedores
- Análisis de configuración de red
- Priorización de hallazgos basada en criticidad

### AWS Systems Manager

- Gestión de parches a escala
- Inventario de software y configuración
- Automatización de tareas de seguridad
- Gestión de conformidad

## Gobernanza y Cumplimiento

### AWS Artifact

- Portal de conformidad y auditoría
- Acceso a certificaciones y documentación
- Reports de seguridad (SOC, PCI, ISO)
- Acuerdos de confidencialidad y uso

### AWS Audit Manager

- Mapeo de controles a estándares
- Recopilación continua de evidencia
- Informes para auditorías
- Marcos de cumplimiento predefinidos y personalizados

### Certificaciones y Programas de Conformidad

AWS mantiene numerosas certificaciones:
- SOC 1/2/3
- PCI DSS
- ISO 9001/27001/27017/27018
- FedRAMP
- HIPAA
- GDPR
- FIPS 140-2
- Y muchas más específicas por país e industria

## Seguridad de Aplicaciones

### AWS Secrets Manager

- Gestión centralizada de secretos
- Rotación automática programada
- Integración con RDS, DocumentDB, Redshift
- Control de acceso granular

### AWS Parameter Store

- Almacenamiento jerárquico de configuración
- Integración con KMS para cifrado
- Gestión de versiones
- Historial de cambios

### AWS Lambda Security

- Permisos basados en roles IAM
- Entorno aislado de ejecución
- Encriptación en tránsito y reposo
- VPC integration para mayor aislamiento

### Amazon Cognito

- Gestión de identidades para aplicaciones
- Autenticación y autorización
- Federación con proveedores sociales e empresariales
- Control de acceso basado en atributos
- Flujos de autenticación personalizables
- Protección contra credenciales comprometidas

### AWS Certificate Manager

- Aprovisionamiento y gestión de certificados SSL/TLS
- Renovación automática
- Integración con servicios AWS (CloudFront, ALB)
- Validación de dominio simplificada

## Arquitecturas de Seguridad

### Principios de Diseño Seguro

- **Defensa en profundidad:** Múltiples capas de control
- **Reducción de superficie de ataque:** Minimizar exposición
- **Principio de privilegio mínimo:** Solo permisos necesarios
- **Automatización de seguridad:** Controles programáticos
- **Diseño para fallos:** Asumir compromisos y planificar respuesta
- **Visibilidad total:** Logging y monitoreo omnipresente

### Patrones de Arquitectura Seguros

#### Perímetro de VPC Seguro

- Subredes públicas y privadas
- Bastion hosts para acceso administrativo
- WAF y Shield para protección perimetral
- Sistemas de inspección de tráfico

#### Microsegmentación

- Aislamiento a nivel de servicio/aplicación
- Grupos de seguridad restrictivos
- VPCs separadas para funciones críticas
- Control de flujo entre microservicios

#### Seguridad de Datos por Diseño

- Clasificación de datos implementada a nivel arquitectónico
- Cifrado por defecto
- Tokenización de información sensible
- Controles de acceso basados en atributos

## Operaciones de Seguridad en AWS

### Centro de Operaciones de Seguridad (SOC)

- Integración de herramientas AWS en SOC
- Automatización de respuesta a incidentes
- Playbooks y runbooks en AWS
- Simulaciones y ejercicios de seguridad

### DevSecOps

- Seguridad en el pipeline CI/CD
- Infrastructure as Code (IaC) seguro
- Escaneo automatizado de vulnerabilidades
- Pruebas de seguridad continuas

### Monitoreo y Gestión de Eventos de Seguridad

- Centralización de logs (CloudWatch, S3)
- Correlación de eventos (Security Hub)
- Alertas y notificaciones (SNS, EventBridge)
- Visualización y dashboards

## Frameworks y Estándares de Seguridad

### AWS Well-Architected Framework: Pilar de Seguridad

- **Gestión de identidad y acceso**
- **Controles de detección**
- **Protección de infraestructura**
- **Protección de datos**
- **Respuesta a incidentes**

### Cloud Adoption Framework (CAF): Perspectiva de Seguridad

- Gobernanza
- Gestión de riesgos
- Cumplimiento
- Gestión de identidades
- Detección y respuesta

### Marcos de Cumplimiento

- CIS AWS Foundations Benchmark
- NIST Cybersecurity Framework en AWS
- ISO 27001 en AWS
- Implementación de GDPR en AWS

## Estrategias de Seguridad Multi-Cuenta

### AWS Organizations

- Segregación de entornos
- Políticas de control de servicios (SCPs)
- Gestión centralizada de auditoría
- Consolidación de facturación

### Estructura de Cuentas Seguras

- Cuenta de gestión dedicada
- Cuentas separadas por función:
  - Seguridad y auditoría
  - Registros centralizados
  - Desarrollo, pruebas, producción
  - Cargas de trabajo por clasificación de datos

### AWS Control Tower

- Implementación de arquitecturas multi-cuenta
- Controles preventivos y de detección
- Dashboard centralizado de cumplimiento
- Governo automatizado

## Casos de Estudio y Escenarios

### Migración Segura a la Nube

- Evaluación de riesgos previa
- Estrategia de migración en fases
- Refactorización para seguridad nativa en nube
- Validación y pruebas continuas

### Respuesta a Incidentes en AWS

- Preparación: Templates y runbooks
- Detección: GuardDuty, CloudTrail, Security Hub
- Contención: IAM, grupos de seguridad, aislamiento
- Erradicación: Imágenes doradas, infraestructura inmutable
- Recuperación: Backups, AMIs, CloudFormation
- Lecciones aprendidas: Refinamiento de detección

### Cumplimiento PCI DSS en AWS

- Mapeo de requisitos PCI a controles AWS
- Segmentación de datos de tarjetas
- Logging y monitorización
- Gestión de vulnerabilidades
- Validación de cumplimiento

## Casos de Éxito en Implementación de Seguridad AWS

### Capital One: Respuesta a Breach y Fortalecimiento de Seguridad

**Situación:** Tras un incidente de seguridad en 2019, Capital One necesitaba reconstruir su postura de seguridad en la nube.

**Implementación:**
- Despliegue masivo de AWS GuardDuty en todas las cuentas
- Automatización de respuesta a incidentes con AWS Security Hub
- Segmentación de red con microsegmentación a nivel de aplicación
- Encriptación universal con AWS KMS

**Resultados:**
- Reducción del 90% en tiempo de detección de amenazas
- Automatización del 85% de respuestas a alertas de seguridad
- Cumplimiento de SOX, PCI DSS y otras regulaciones mejorado
- Certificación como referencia de seguridad en servicios financieros

**Lecciones Aprendidas:**
- Importancia de detectores de anomalías ML
- Necesidad de automatización en respuesta a incidentes
- Valor de centralización de logs y eventos

### Pfizer: Seguridad para Investigación Farmacéutica

**Situación:** Protección de datos de investigación clínica y propiedad intelectual en entorno multi-nube.

**Implementación:**
- Arquitectura Zero Trust con AWS PrivateLink
- Cifrado end-to-end con AWS KMS y CloudHSM
- IAM Identity Center para gestión centralizada
- AWS Config para auditoría continua de conformidad

**Resultados:**
- Cumplimiento FDA 21 CFR Part 11 validado
- Reducción de superficie de ataque en un 70%
- Tiempo de auditoría reducido de semanas a días
- Protección de datos de más de 100 ensayos clínicos activos

### Netflix: Seguridad a Escala Global

**Situación:** Proteger infraestructura que sirve contenido a 230M+ usuarios globalmente.

**Implementación:**
- Seguridad "shift-left" en pipelines CI/CD
- AWS WAF y Shield Advanced para protección DDoS
- Amazon Macie para descubrimiento de datos sensibles
- Automatización de remediación con AWS Config Rules

**Resultados:**
- Zero downtime por ataques DDoS en 5 años
- Detección automática de credenciales expuestas en S3
- 99.9% de vulnerabilidades remediadas automáticamente
- Estandarización de seguridad en 1000+ microservicios

## Templates Seguros de Infraestructura

### Template CloudFormation: VPC Segura con Seguridad por Defecto

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'VPC Enterprise Segura con Controles de Seguridad Avanzados'

Parameters:
  Environment:
    Type: String
    AllowedValues: [Production, Staging, Development]
    Default: Production
  VpcCidr:
    Type: String
    Default: 10.0.0.0/16

Resources:
  # VPC con Flow Logs habilitados
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCidr
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Ref Environment

  VPCFlowLog:
    Type: AWS::EC2::FlowLog
    Properties:
      DeliverCrossAccountRole: !Ref FlowLogRole
      LogDestinationType: cloud-watch-logs
      LogGroupName: !Ref VPCFlowLogGroup
      ResourceId: !Ref VPC
      ResourceType: VPC
      TrafficType: ALL

  VPCFlowLogGroup:
    Type: AWS::Logs::LogGroup
    Properties:
      LogGroupName: !Sub /aws/vpc/flowlogs/${Environment}
      RetentionInDays: 90

  FlowLogRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: vpc-flow-logs.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/CloudWatchLogsFullAccess

  # Security Groups restrictivos por defecto
  BastionSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Acceso SSH restringido a bastion hosts
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 10.0.0.0/8
          Description: SSH solo desde red corporativa
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 10.0.0.0/8

  WebTierSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Tier web - solo puertos necesarios
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          SourceSecurityGroupId: !Ref ALBSecurityGroup
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          SourceSecurityGroupId: !Ref ALBSecurityGroup
      SecurityGroupEgress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          DestinationSecurityGroupId: !Ref AppTierSecurityGroup

  ALBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Application Load Balancer
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0

  # NACLs restrictivas
  PublicNACL:
    Type: AWS::EC2::NetworkAcl
    Properties:
      VpcId: !Ref VPC
      Tags:
        - Key: Name
          Value: PublicSubnetNACL

  NACLEntryAllowHTTPS:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      NetworkAclId: !Ref PublicNACL
      RuleNumber: 100
      Protocol: 6
      PortRange:
        From: 443
        To: 443
      CidrBlock: 0.0.0.0/0
      RuleAction: allow

  NACLEntryDenyAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      NetworkAclId: !Ref PublicNACL
      RuleNumber: 200
      Protocol: -1
      CidrBlock: 0.0.0.0/0
      RuleAction: deny

  # VPC Endpoints privados
  S3VPCEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      VpcId: !Ref VPC
      ServiceName: !Sub com.amazonaws.${AWS::Region}.s3
      VpcEndpointType: Gateway
      RouteTableIds:
        - !Ref PrivateRouteTable

  CloudWatchLogsEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      VpcId: !Ref VPC
      ServiceName: !Sub com.amazonaws.${AWS::Region}.logs
      VpcEndpointType: Interface
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2
      SecurityGroupIds:
        - !Ref VPCEndpointSecurityGroup

  VPCEndpointSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security Group para VPC Endpoints
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: !Ref VpcCidr

Outputs:
  VPCId:
    Value: !Ref VPC
    Description: VPC ID
```

### Template Terraform: IAM Secure Roles

```hcl
# variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "allowed_services" {
  description = "Services allowed to assume role"
  type        = list(string)
  default     = ["ec2.amazonaws.com", "lambda.amazonaws.com"]
}

# main.tf
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM Role con privilegio mínimo
resource "aws_iam_role" "app_role" {
  name = "${var.environment}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = var.allowed_services
      }
      Action = "sts:AssumeRole"
      Condition = {
        StringEquals = {
          "aws:SourceAccount" = data.aws_caller_identity.current.account_id
        }
      }
    }]
  })

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Política inline con permisos mínimos
resource "aws_iam_role_policy" "app_policy" {
  name = "${var.environment}-app-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.environment}-data-bucket/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      }
    ]
  })
}

# KMS Key para encriptación
resource "aws_kms_key" "app_key" {
  description             = "KMS key para ${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow app role"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.app_role.arn
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      }
    ]
  })
}
```

## Árbol de Decisiones: Selección de Servicios de Seguridad

```
¿Necesita proteger datos sensibles en S3?
│
├─ SÍ → Implementar Amazon Macie
│   │
│   ├─ ¿Requiere clasificación automática?
│   │   ├─ SÍ → Macie con policies de discovery personalizadas
│   │   └─ NO → Configurar reglas de detección estándar
│   │
│   └─ ¿Necesita alertas en tiempo real?
│       ├─ SÍ → EventBridge → SNS → Email/Slack
│       └─ NO → Revisión periódica de reportes
│
├─ NO → Evaluar otros servicios
│   │
│   ├─ ¿Necesita detección de amenazas?
│   │   ├─ SÍ → Amazon GuardDuty
│   │   │   │
│   │   │   ├─ ¿Requiere integración con SIEM?
│   │   │   │   ├─ SÍ → Configurar exportación a S3 + SIEM connector
│   │   │   │   └─ NO → Usar Security Hub como centralizador
│   │   │   │
│   │   │   └─ ¿Tiene workloads Kubernetes?
│   │   │       ├─ SÍ → Habilitar EKS protection
│   │   │       └─ NO → Focus en EC2 y networking
│   │   │
│   │   └─ NO → Verificar monitoreo básico con CloudTrail
│   │
│   ├─ ¿Necesita protección DDoS?
│   │   ├─ SÍ → AWS Shield
│   │   │   │
│   │   │   ├─ ¿Es objetivo de ataques frecuentes?
│   │   │   │   ├─ SÍ → Shield Advanced + DRT
│   │   │   │   └─ NO → Shield Standard (incluido)
│   │   │   │
│   │   │   └─ ¿Requiere análisis forense?
│   │   │       ├─ SÍ → Shield Advanced con reports detallados
│   │   │       └─ NO → Standard + CloudFront
│   │   │
│   │   └─ NO → Verificar arquitectura distribuida
│   │
│   └─ ¿Necesita gestión de secretos?
│       ├─ SÍ → AWS Secrets Manager
│       │   │
│       │   ├─ ¿Requiere rotación automática?
│       │   │   ├─ SÍ → Configurar rotación con Lambda
│       │   │   └─ NO → Rotación manual documentada
│       │   │
│       │   └─ ¿Integración con RDS?
│       │       ├─ SÍ → RDS-Secrets Manager native integration
│       │       └─ NO → Secrets Manager standalone
│       │
│       └─ NO → Usar Parameter Store para config no sensible
│
└─ ¿Necesita auditoría de cumplimiento?
    ├─ SÍ → AWS Audit Manager
    │   │
    │   ├─ ¿Cuál framework?
    │   │   ├─ PCI DSS → Framework predefinido
    │   │   ├─ SOC 2 → Framework predefinido
    │   │   ├─ ISO 27001 → Framework predefinido
    │   │   └─ Custom → Crear framework propio
    │   │
    │   └─ ¿Necesita reportes automáticos?
    │       ├─ SÍ → Configurar assessment schedules
    │       └─ NO → Generación manual bajo demanda
    │
    └─ NO → AWS Config básico para compliance
```

### Matriz de Selección por Tipo de Protección

| Amenaza | Servicio Primario | Servicio Complementario | Implementación |
|---------|-------------------|------------------------|----------------|
| **Acceso no autorizado** | IAM | AWS Organizations SCPs | Rol-based, MFA obligatorio |
| **Exfiltración de datos** | VPC Flow Logs | GuardDuty | Monitoreo + ML detection |
| **Malware en instancias** | Inspector | Systems Manager Patch Manager | Scanning + auto-patching |
| **DDoS** | Shield Standard | WAF + CloudFront | Layer 3/4 + Layer 7 |
| **Inyección SQL** | WAF | RDS security groups | Rulesets + least privilege |
| **Credenciales expuestas** | Secrets Manager | Macie | Rotation + discovery |

## Calculadora de Costos de Seguridad AWS

### Costos por Servicio (Estimación Mensual)

| Servicio | Costo Base | Costo Variable | Ejemplo |
|----------|------------|----------------|---------|
| **GuardDuty** | $0 | $0.10-$4/GB analizado | 1TB logs = $100-400/mes |
| **Security Hub** | $0 | $0.0019 por check | 100 checks/día = $5.70/mes |
| **Inspector** | $0 | $0.12/instancia/scan | 100 instancias = $12/scan |
| **Macie** | $0 | $5/TB analizado | 10TB = $50/mes |
| **WAF** | $5/web ACL/mes | $0.60/rule + requests | 1 ACL + 10 rules = $11/mes |
| **Shield Advanced** | $3,000/mes | $0 | Protección DDoS ilimitada |
| **KMS** | $1/key/mes | $0.03/10,000 requests | 10 keys + 1M ops = $13/mes |
| **Secrets Manager** | $0.40/secret/mes | $0.05/10,000 API calls | 100 secrets = $40/mes |

### Escenarios de Costo Estimado

**Escenario Pequeño (Startup):**
```
GuardDuty: $50
Security Hub: $10
Inspector (mensual): $25
WAF: $15
KMS: $5
Secrets Manager: $20
Total: $125/mes
```

**Escenario Mediano (Empresa):**
```
GuardDuty: $500
Security Hub: $50
Inspector: $150
Macie: $200
WAF (múltiples): $100
Shield Standard: $0 (incluido)
KMS: $50
Secrets Manager: $200
Certificate Manager: $0
Total: $1,250/mes
```

**Escenario Enterprise:**
```
GuardDuty: $5,000
Security Hub: $500
Inspector: $1,000
Macie: $1,500
WAF + Shield Advanced: $3,500
Network Firewall: $500
KMS: $500
Secrets Manager: $1,000
Audit Manager: $500
Total: $14,000/mes
```

### ROI de Seguridad

```
Costo promedio de breach: $4.45 millones (IBM 2023)
Costo de seguridad AWS Enterprise: $168,000/año
ROI = (4,450,000 - 168,000) / 168,000 = 2,548%

Breakeven: Si la solución previene 1 breach cada 26 años, ya es rentable.
```

### Optimización de Costos de Seguridad

1. **Filtrado de logs:** No enviar todos los logs a GuardDuty, solo los críticos
2. **Sampling:** Usar sampling rate en Inspector para cargas grandes
3. **Regional:** Shield Advanced solo en regiones expuestas
4. **Aggregation:** Security Hub centralizado vs individual por cuenta
5. **Automation:** Auto-remediación reduce costos operativos

## Tendencias Futuras en Seguridad AWS

- **Zero Trust Architecture:** Evolución más allá del perímetro tradicional
- **Seguridad Serverless:** Controles adaptados a arquitecturas sin servidor
- **Machine Learning para Seguridad:** Detección avanzada de amenazas
- **IAM de próxima generación:** Control de acceso contextual y adaptativo
- **Security as Code:** Integración completa de seguridad en IaC
- **Edge Security:** Protección extendida a nivel de borde

## Conclusión

La seguridad en AWS es un proceso continuo que requiere una combinación de tecnologías, procesos y personas. El amplio conjunto de servicios de seguridad de AWS proporciona las herramientas necesarias para implementar arquitecturas seguras, pero la responsabilidad de configurar y utilizar estos servicios correctamente recae en los clientes, siguiendo el modelo de responsabilidad compartida.

Las organizaciones que adoptan un enfoque proactivo de seguridad, implementando las mejores prácticas y utilizando el conjunto completo de servicios de seguridad de AWS, pueden no solo proteger sus datos y aplicaciones, sino también acelerar la innovación al reducir la carga de la implementación y gestión de la infraestructura de seguridad.

La clave del éxito es integrar la seguridad desde el principio en todas las facetas de la estrategia de nube, creando una cultura de "seguridad por diseño" que permita a las organizaciones aprovechar los beneficios de la nube sin comprometer la protección de sus activos más valiosos.

## Referencias y Recursos Adicionales

- [AWS Security Documentation](https://docs.aws.amazon.com/security/)
- [AWS Security Blog](https://aws.amazon.com/blogs/security/)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)
- [AWS Compliance Programs](https://aws.amazon.com/compliance/programs/)
- [AWS Security Bulletins](https://aws.amazon.com/security/security-bulletins/)
- [AWS Well-Architected Framework: Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/)
