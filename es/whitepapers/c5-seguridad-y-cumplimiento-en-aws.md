# Capítulo 5: Seguridad y Cumplimiento en AWS

## Escenario Práctico: SecureFin Hardeniza su Cuenta AWS Post-Incidente

SecureFin, una fintech de mediano tamaño, sufrió un incidente de seguridad donde credenciales expuestas permitieron acceso no autorizado a su infraestructura AWS. Este capítulo documenta el proceso paso a paso de hardening implementado, con configuraciones reales que puedes aplicar inmediatamente.

```mermaid
flowchart LR
    subgraph "Antes del Incidente"
        A[Root keys expuestas] --> B[Acceso público S3]
        C[Usuarios IAM con AdminAccess] --> D[No CloudTrail]
    end
    
    subgraph "Después del Hardening"
        E[Organizations SCPs] --> F[CloudTrail centralizado]
        G[GuardDuty activado] --> H[Secrets Manager]
        I[Security Hub] --> J[KMS encryption]
    end
    
    style A fill:#ef4444
    style B fill:#ef4444
    style E fill:#22c55e
    style G fill:#22c55e
```

---

## Diagnóstico Inicial: Checklist de Seguridad

SecureFin comenzó auditando su cuenta con esta lista de verificación:

| Item | Estado Inicial | Riesgo |
|------|---------------|--------|
| Root user con access keys | ✅ Sí | CRÍTICO |
| MFA en root | ❌ No | ALTO |
| CloudTrail habilitado | ❌ No | CRÍTICO |
| GuardDuty activado | ❌ No | ALTO |
| S3 buckets públicos | ✅ 12 | CRÍTICO |
| Usuarios IAM con `*` | ✅ 8 | ALTO |
| Password policy débil | ✅ Sí | MEDIO |
| AWS Organizations | ❌ No | MEDIO |
| Secrets en código | ✅ Sí | CRÍTICO |

**Resultado:** 8 de 9 items críticos presentaban fallas.

---

## IAM: Usuarios vs Roles vs Políticas

### La Jerarquía de Acceso en AWS

```mermaid
flowchart TD
    A[IAM Entities] --> B[Usuarios]
    A --> C[Roles]
    A --> D[Grupos]
    
    B --> E[Credenciales permanentes]
    B --> F[Personas específicas]
    
    C --> G[Temporales - STS]
    C --> H[Services assume roles]
    C --> I[Cross-account access]
    
    E --> J[Políticas JSON]
    F --> J
    G --> J
    H --> J
    I --> J
    D --> J
    
    J --> K[Permisos efectivos]
```

### Decision Tree: ¿Usuario, Rol o Grupo?

```
¿Necesitas acceso programático/automatizado?
│
├─ SÍ → ¿Es para una persona o un servicio?
│   │
│   ├─ Persona → Usuario IAM con MFA obligatorio
│   │             └─ Asignar a Grupos funcionales
│   │
│   └─ Servicio → Rol IAM (EC2, Lambda, ECS)
│                 └─ Trust Policy específico
│
└─ NO → ¿Es acceso interactivo (console)?
    │
    ├─ SÍ → Usuario IAM + Grupos + MFA
    │
    └─ NO → ¿Cross-account o federado?
        │
        ├─ SÍ → Rol IAM con trust policy externo
        │
        └─ NO → Reconsiderar arquitectura
```

### Configuración Real: SecureFin

#### 1. Root Account Hardening

```bash
# PASO 1: Eliminar access keys de root (hacer desde console)
# Seguridad > Credenciales > Delete access keys

# PASO 2: Habilitar MFA hardware/virtual
aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name root-mfa \
    --outfile ./root-mfa-qr.png \
    --bootstrap-method QRCodePNG

# PASO 3: Activar MFA
aws iam enable-mfa-device \
    --user-name root \
    --serial-number arn:aws:iam::123456789012:mfa/root-mfa \
    --authentication-code1 123456 \
    --authentication-code2 654321
```

#### 2. Password Policy Enterprise

```json
{
    "MinimumPasswordLength": 16,
    "RequireSymbols": true,
    "RequireNumbers": true,
    "RequireUppercaseCharacters": true,
    "RequireLowercaseCharacters": true,
    "AllowUsersToChangePassword": true,
    "MaxPasswordAge": 90,
    "PasswordReusePrevention": 12,
    "HardExpiry": false
}
```

```bash
aws iam update-account-password-policy \
    --cli-input-json file://password-policy.json
```

#### 3. Estructura de Usuarios y Grupos

| Grupo | Permisos | Miembros |
|-------|----------|----------|
| `Administrators` | AdminAccess con MFA condición | 2 CTO, CISO |
| `Developers` | PowerUser + Deny IAM/Org | 12 devs |
| `ReadOnly` | ViewOnlyAccess | 5 analysts |
| `SecurityOps` | SecurityAudit + GuardDuty | 3 security |
| `Billing` | Billing + Cost Explorer | 2 finance |

```bash
# Crear grupos
aws iam create-group --group-name Administrators
aws iam create-group --group-name Developers

# Adjuntar políticas con MFA condition
aws iam put-group-policy \
    --group-name Administrators \
    --policy-name AdminAccessWithMFA \
    --policy-document '{
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Deny",
            "Action": "*",
            "Resource": "*",
            "Condition": {
                "BoolIfExists": {"aws:MultiFactorAuthPresent": "false"}
            }
        }]
    }'
```

#### 4. Roles para Servicios (Mejor Práctica)

**ANTES (incorrecto):** Usuarios IAM con access keys en EC2

```python
# ❌ MAL: Access keys hardcodeadas
AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
```

**DESPUÉS (correcto):** Roles IAM

```json
// Trust policy para EC2
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Principal": {"Service": "ec2.amazonaws.com"},
        "Action": "sts:AssumeRole"
    }]
}
```

```json
// Política de permisos mínimos
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "S3Access",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::securefin-app-bucket/*"
        },
        {
            "Sid": "CloudWatchLogs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:log-group:/aws/ec2/*"
        }
    ]
}
```

---

## Organización Multi-Cuenta con AWS Organizations

### Arquitectura de Cuentas SecureFin

```mermaid
flowchart TD
    subgraph "Organization SecureFin"
        A[Management Account]
        
        subgraph "Production OU"
            B[Prod-Workloads]
            C[Prod-Shared]
        end
        
        subgraph "Development OU" 
            D[Dev-Workloads]
            E[Dev-Shared]
        end
        
        subgraph "Security OU"
            F[Security-Audit]
            G[Log-Archive]
        end
        
        subgraph "Sandbox OU"
            H[Sandbox-01]
            I[Sandbox-02]
        end
    end
    
    A --> B
    A --> D
    A --> F
    A --> H
    
    style A fill:#fbbf24
    style F fill:#22c55e
    style G fill:#22c55e
```

### Service Control Policies (SCPs)

#### SCP 1: Prevenir Deletion de CloudTrail

```json
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "PreventCloudTrailDeletion",
        "Effect": "Deny",
        "Action": [
            "cloudtrail:DeleteTrail",
            "cloudtrail:StopLogging",
            "cloudtrail:UpdateTrail",
            "cloudtrail:PutEventSelectors"
        ],
        "Resource": "*",
        "Condition": {
            "StringNotLike": {
                "aws:PrincipalARN": [
                    "arn:aws:iam::*:role/SecurityAdminRole"
                ]
            }
        }
    }]
}
```

#### SCP 2: Restringir Regiones

```json
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "LimitRegions",
        "Effect": "Deny",
        "NotAction": [
            "iam:*",
            "organizations:*",
            "account:*",
            "support:*",
            "billing:*",
            "cur:*"
        ],
        "Resource": "*",
        "Condition": {
            "StringNotEquals": {
                "aws:RequestedRegion": [
                    "us-east-1",
                    "us-west-2",
                    "eu-west-1"
                ]
            }
        }
    }]
}
```

#### SCP 3: Prevenir Root Usage

```json
{
    "Version": "2012-10-17",
    "Statement": [{
        "Sid": "PreventRootUsage",
        "Effect": "Deny",
        "Action": "*",
        "Resource": "*",
        "Condition": {
            "StringLike": {
                "aws:PrincipalArn": [
                    "arn:aws:iam::*:root"
                ]
            }
        }
    }]
}
```

### Implementación Paso a Paso

```bash
# 1. Crear organización
aws organizations create-organization \
    --feature-set ALL

# 2. Crear OUs
aws organizations create-organizational-unit \
    --parent-id r-xxxx \
    --name "Production"

aws organizations create-organizational-unit \
    --parent-id r-xxxx \
    --name "Development"

aws organizations create-organizational-unit \
    --parent-id r-xxxx \
    --name "Security"

# 3. Crear cuentas
aws organizations create-account \
    --email "security+audit@securefin.com" \
    --account-name "Security-Audit" \
    --role-name "OrganizationAccountAccessRole"

aws organizations create-account \
    --email "logs+archive@securefin.com" \
    --account-name "Log-Archive" \
    --role-name "OrganizationAccountAccessRole"

# 4. Adjuntar SCPs
aws organizations attach-policy \
    --policy-id p-cloudtrail-protect \
    --target-id ou-production-xxxxx
```

---

## CloudTrail, GuardDuty y Security Hub en Acción

### Arquitectura de Logging Centralizado

```mermaid
flowchart LR
    subgraph "Todas las Cuentas"
        A[CloudTrail] --> B[S3 Bucket Central]
        C[Config] --> B
        D[VPC Flow Logs] --> B
    end
    
    subgraph "Cuenta Security"
        B --> E[S3 Glacier]
        B --> F[Athena Queries]
        G[GuardDuty] --> H[Security Hub]
        H --> I[EventBridge]
        I --> J[SNS → Slack]
    end
    
    style H fill:#22c55e
    style G fill:#22c55e
```

### CloudTrail: Configuración Multi-Cuenta

```yaml
# CloudFormation - Trail Organization
AWSTemplateFormatVersion: '2010-09-09'
Description: 'CloudTrail Organization Trail'

Resources:
  OrganizationTrail:
    Type: AWS::CloudTrail::Trail
    Properties:
      TrailName: SecureFin-Org-Trail
      S3BucketName: !Ref TrailBucket
      IsLogging: true
      IsMultiRegionTrail: true
      EnableLogFileValidation: true
      KMSKeyId: !Ref TrailKMSKey
      EventSelectors:
        - ReadWriteType: All
          IncludeManagementEvents: true
          DataResources:
            - Type: AWS::S3::Object
              Values:
                - arn:aws:s3:::
            - Type: AWS::Lambda::Function
              Values:
                - arn:aws:lambda
      
  TrailBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: securefin-cloudtrail-central-logs
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: aws:kms
              KMSMasterKeyID: !Ref TrailKMSKey
      LifecycleConfiguration:
        Rules:
          - Id: TransitionToGlacier
            Status: Enabled
            TransitionInDays: 90
            StorageClass: GLACIER
          - Id: DeleteOld
            Status: Enabled
            ExpirationInDays: 2555  # 7 años

  TrailBucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref TrailBucket
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Sid: AWSCloudTrailAclCheck
            Effect: Allow
            Principal:
              Service: cloudtrail.amazonaws.com
            Action: s3:GetBucketAcl
            Resource: !GetAtt TrailBucket.Arn
          - Sid: AWSCloudTrailWrite
            Effect: Allow
            Principal:
              Service: cloudtrail.amazonaws.com
            Action: s3:PutObject
            Resource: !Sub '${TrailBucket.Arn}/AWSLogs/*/*'
            Condition:
              StringEquals:
                s3:x-amz-acl: bucket-owner-full-control

  TrailKMSKey:
    Type: AWS::KMS::Key
    Properties:
      Description: KMS key for CloudTrail encryption
      EnableKeyRotation: true
      KeyPolicy:
        Version: '2012-10-17'
        Statement:
          - Sid: Enable IAM User Permissions
            Effect: Allow
            Principal:
              AWS: !Sub 'arn:aws:iam::${AWS::AccountId}:root'
            Action: 'kms:*'
            Resource: '*'
          - Sid: Allow CloudTrail to encrypt logs
            Effect: Allow
            Principal:
              Service: cloudtrail.amazonaws.com
            Action:
              - kms:GenerateDataKey*
              - kms:DescribeKey
            Resource: '*'
```

### GuardDuty: Detección de Amenazas

```bash
# Habilitar GuardDuty en todas las regiones
REGIONS=("us-east-1" "us-west-2" "eu-west-1")

for REGION in "${REGIONS[@]}"; do
    echo "Habilitando GuardDuty en $REGION..."
    aws guardduty create-detector \
        --enable \
        --finding-publishing-frequency FIFTEEN_MINUTES \
        --region $REGION
done

# Configurar SNS para alertas
aws sns create-topic --name guardduty-alerts
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:123456789012:guardduty-alerts \
    --protocol email \
    --notification-endpoint security@securefin.com
```

```yaml
# EventBridge Rule para GuardDuty
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  GuardDutyEventRule:
    Type: AWS::Events::Rule
    Properties:
      Name: GuardDuty-HighSeverity
      Description: "Alert on High and Critical GuardDuty findings"
      EventPattern:
        source:
          - aws.guardduty
        detail-type:
          - GuardDuty Finding
        detail:
          severity:
            - 7.0
            - 7.1
            - 7.2
            - 8.0
            - 8.1
            - 8.2
            - 8.3
            - 8.4
            - 8.5
            - 8.6
            - 8.7
            - 8.8
            - 8.9
      Targets:
        - Id: SNSAlert
          Arn: !Ref AlertTopic
          InputTransformer:
            InputPathsMap:
              account: "$.detail.accountId"
              region: "$.detail.region"
              severity: "$.detail.severity"
              type: "$.detail.type"
              description: "$.detail.description"
            InputTemplate: |
              "GuardDuty Alert: <type> detected in account <account> region <region>. Severity: <severity>. <description>"
```

### Security Hub: Visión Centralizada

```bash
# Habilitar Security Hub
aws securityhub enable-security-hub

# Habilitar estándares
aws securityhub enable-import-findings-for-product \
    --product-arn arn:aws:securityhub:us-east-1::product/aws/guardduty

# Habilitar standards
aws securityhub enable-standards \
    --standards-arn arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0

# Verificar controles fallidos
aws securityhub get-findings \
    --filters '{"SeverityLabel":[{"Value":"CRITICAL","Comparison":"EQUALS"}]}' \
    --sort-criteria '{"Field":"SeverityLabel","SortOrder":"DESC"}'
```

---

## Encriptación: KMS, SSL y Secrets Manager

### Jerarquía de Encriptación en AWS

```mermaid
flowchart TD
    A[KMS Customer Master Keys] --> B[Data Encryption Keys]
    B --> C[S3 Objects]
    B --> D[EBS Volumes]
    B --> E[RDS Databases]
    
    F[AWS Certificate Manager] --> G[ALB/CloudFront SSL]
    
    H[Secrets Manager] --> I[Database Credentials]
    H --> J[API Keys]
    H --> K[OAuth Tokens]
    
    style A fill:#22c55e
    style F fill:#22c55e
    style H fill:#22c55e
```

### KMS: Key Management

#### Estrategia de Keys SecureFin

| Key | Uso | Rotación |
|-----|-----|----------|
| `alias/securefin-s3` | Encriptación S3 buckets app | Anual |
| `alias/securefin-ebs` | Encriptación volúmenes EBS | Anual |
| `alias/securefin-rds` | Encriptación RDS | Anual |
| `alias/securefin-secrets` | Secrets Manager | Anual |
| `alias/securefin-cloudtrail` | Logs CloudTrail | Anual |

```json
// KMS Key Policy - SecureFin Standard
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::123456789012:root"
            },
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow S3 Service",
            "Effect": "Allow",
            "Principal": {
                "Service": "s3.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:GenerateDataKey*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "123456789012",
                    "kms:ViaService": "s3.us-east-1.amazonaws.com"
                }
            }
        },
        {
            "Sid": "Allow CloudWatch Logs",
            "Effect": "Allow",
            "Principal": {
                "Service": "logs.us-east-1.amazonaws.com"
            },
            "Action": [
                "kms:Encrypt*",
                "kms:Decrypt*",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Describe*"
            ],
            "Resource": "*",
            "Condition": {
                "ArnEquals": {
                    "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:us-east-1:123456789012:*"
                }
            }
        }
    ]
}
```

### S3: Encriptación Default

```bash
# Habilitar encriptación default en bucket
aws s3api put-bucket-encryption \
    --bucket securefin-app-data \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "aws:kms",
                "KMSMasterKeyID": "alias/securefin-s3"
            },
            "BucketKeyEnabled": true
        }]
    }'

# Bloquear acceso público
aws s3api put-public-access-block \
    --bucket securefin-app-data \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'
```

### Secrets Manager: Migración de Credenciales

```python
# ANTES: Credenciales hardcodeadas (como tenía SecureFin)
# database.py
DB_PASSWORD = "SuperSecretPassword123!"  # ❌ HORROR

# DESPUÉS: Secrets Manager
import boto3
import json
from botocore.exceptions import ClientError

def get_secret(secret_name: str, region: str = "us-east-1"):
    """Retrieve secret from AWS Secrets Manager."""
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region
    )
    
    try:
        response = client.get_secret_value(SecretId=secret_name)
        if 'SecretString' in response:
            return json.loads(response['SecretString'])
        return response['SecretBinary']
    except ClientError as e:
        raise Exception(f"Failed to retrieve secret: {e}")

# Uso
secret = get_secret("prod/securefin/database")
db_password = secret['password']
db_username = secret['username']
```

```bash
# Crear secret con rotación automática
aws secretsmanager create-secret \
    --name prod/securefin/database \
    --description "SecureFin production database credentials" \
    --secret-string '{
        "username": "app_user",
        "password": "auto-generated",
        "host": "securefin-db.cluster-xyz.us-east-1.rds.amazonaws.com",
        "port": "5432",
        "dbname": "securefin_prod"
    }'

# Configurar rotación automática (cada 30 días)
aws secretsmanager rotate-secret \
    --secret-id prod/securefin/database \
    --rotation-lambda-arn arn:aws:lambda:us-east-1:123456789012:function:securefin-db-rotation \
    --automatically-rotate-after-days 30
```

### SSL/TLS con Certificate Manager

```yaml
# CloudFormation - ALB con SSL
AWSTemplateFormatVersion: '2010-09-09'
Resources:
  SSLCertificate:
    Type: AWS::CertificateManager::Certificate
    Properties:
      DomainName: api.securefin.io
      SubjectAlternativeNames:
        - www.securefin.io
        - app.securefin.io
      ValidationMethod: DNS
      DomainValidationOptions:
        - DomainName: api.securefin.io
          HostedZoneId: !Ref HostedZoneId
      Tags:
        - Key: Environment
          Value: production
        - Key: Application
          Value: securefin-api

  ApplicationLoadBalancer:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
    Properties:
      Name: securefin-alb
      Scheme: internet-facing
      Type: application
      SecurityGroups:
        - !Ref ALBSecurityGroup
      Subnets:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2

  HTTPSListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      LoadBalancerArn: !Ref ApplicationLoadBalancer
      Port: 443
      Protocol: HTTPS
      Certificates:
        - CertificateArn: !Ref SSLCertificate
      SslPolicy: ELBSecurityPolicy-TLS13-1-2-2021-06
      DefaultActions:
        - Type: forward
          TargetGroupArn: !Ref TargetGroup

  # Redirect HTTP to HTTPS
  HTTPListener:
    Type: AWS::ElasticLoadBalancingV2::Listener
    Properties:
      LoadBalancerArn: !Ref ApplicationLoadBalancer
      Port: 80
      Protocol: HTTP
      DefaultActions:
        - Type: redirect
          RedirectConfig:
            Protocol: HTTPS
            Port: 443
            StatusCode: HTTP_301
```

---

## Checklist de Seguridad Implementable

### Fase 1: Foundation (Semana 1)

```markdown
## Semana 1: Fundamentos de Seguridad

### Root Account
- [ ] Eliminar access keys de root
- [ ] Habilitar MFA hardware en root
- [ ] Configurar email de contacto alternativo
- [ ] Configurar dirección física de contacto

### IAM Basics  
- [ ] Crear password policy fuerte (16+ chars)
- [ ] Crear grupos funcionales (Admin, Dev, ReadOnly)
- [ ] Crear usuarios individuales (NO shared accounts)
- [ ] Habilitar MFA para todos los usuarios
- [ ] Crear roles para servicios (EC2, Lambda)
- [ ] Eliminar usuarios con AdministratorAccess directo

### Logging
- [ ] Habilitar CloudTrail en todas las regiones
- [ ] Configurar S3 bucket para logs con encriptación
- [ ] Habilitar log file validation
- [ ] Configurar SNS para alertas de CloudTrail

### Alertas Base
- [ ] Configurar alarmas CloudWatch:
  - [ ] Root account usage
  - [ ] Console sign-in without MFA
  - [ ] IAM policy changes
  - [ ] CloudTrail changes
```

### Fase 2: Detección (Semana 2)

```markdown
## Semana 2: Detección y Monitoreo

### GuardDuty
- [ ] Habilitar en todas las regiones operativas
- [ ] Configurar SNS → Email para findings HIGH/CRITICAL
- [ ] Revisar finding history semanal

### Security Hub
- [ ] Habilitar Security Hub
- [ ] Habilitar CIS AWS Foundations Benchmark
- [ ] Revisar controles fallidos
- [ ] Plan de remediación para findings CRITICAL

### Config Rules
- [ ] Habilitar AWS Config en todas las regiones
- [ ] Configurar reglas:
  - [ ] s3-bucket-public-read-prohibited
  - [ ] s3-bucket-public-write-prohibited
  - [ ] s3-bucket-ssl-requests-only
  - [ ] ec2-imdsv2-check
  - [ ] iam-password-policy
  - [ ] iam-user-mfa-enabled
  - [ ] root-account-mfa-enabled
  - [ ] restricted-ssh
  - [ ] restricted-common-ports

### VPC Flow Logs
- [ ] Habilitar en todas las VPCs
- [ ] Enviar a S3 centralizado
- [ ] Configurar retención 1 año
```

### Fase 3: Data Protection (Semana 3)

```markdown
## Semana 3: Protección de Datos

### Encriptación en Reposo
- [ ] Identificar todos los buckets S3 con datos sensibles
- [ ] Habilitar default encryption con KMS
- [ ] Block public access en todos los buckets
- [ ] Encriptar volúmenes EBS (si aplica)
- [ ] Encriptar RDS (si aplica)
- [ ] Crear rotation schedule para KMS keys

### Secret Management
- [ ] Inventario de secretos hardcodeados
- [ ] Migrar a Secrets Manager
- [ ] Configurar rotación automática (90 días)
- [ ] Eliminar secretos de código fuente

### SSL/TLS
- [ ] Configurar ACM certificates para todos los dominios
- [ ] Forzar HTTPS en ALB/CloudFront
- [ ] Usar TLS 1.2+ mínimo
- [ ] Configurar HSTS headers
```

### Fase 4: Organizations (Semana 4)

```markdown
## Semana 4: Multi-Cuenta y Governance

### AWS Organizations
- [ ] Crear organización
- [ ] Crear OUs: Production, Development, Security, Sandbox
- [ ] Mover cuentas existentes a OUs apropiadas
- [ ] Crear cuentas dedicadas: Security, Logs

### SCPs
- [ ] SCP: Prevenir CloudTrail deletion
- [ ] SCP: Restringir regiones permitidas
- [ ] SCP: Prevenir root usage
- [ ] SCP: Requerir MFA para acciones críticas
- [ ] SCP: Prevenir dejar organización

### Cross-Account Access
- [ ] Configurar roles para cross-account access
- [ ] Documentar qué rol accede a qué cuenta
- [ ] Configurar External ID para 3rd party access
```

---

## Cumplimiento: SOC2 y PCI DSS Paso a Paso

### SOC2 Tipo II: Mapeo a Servicios AWS

```mermaid
flowchart LR
    subgraph "Principios Trust Services"
        A[Security] --> B[IAM + GuardDuty]
        C[Availability] --> D[CloudWatch + Auto Scaling]
        E[Processing Integrity] --> F[Config + CloudTrail]
        G[Confidentiality] --> H[KMS + Macie]
        I[Privacy] --> J[Cognito + Artifact]
    end
```

#### Controles SOC2 y AWS

| Control SOC2 | Servicio AWS | Implementación |
|--------------|--------------|----------------|
| CC6.1 - Logical Access | IAM + Identity Center | SSO con MFA, roles JIT |
| CC6.2 - Access Removal | IAM + Organizations | SCPs, access reviews |
| CC6.3 - Transmission Security | ACM + ALB | TLS 1.3, cert rotation |
| CC6.6 - Encryption | KMS + S3 + EBS | AES-256, key rotation |
| CC6.7 - Threat Detection | GuardDuty + Security Hub | 24/7 monitoring |
| CC7.2 - System Monitoring | CloudTrail + Config | Immutable logs |
| CC7.3 - Incident Detection | EventBridge + SNS | Alert automation |

#### Evidencia para Auditores

```bash
# Script de recolección de evidencia SOC2
#!/bin/bash

AUDIT_DATE=$(date +%Y-%m-%d)
OUTPUT_DIR="./soc2-evidence-$AUDIT_DATE"
mkdir -p $OUTPUT_DIR

# 1. IAM Users and MFA Status
echo "Recopilando IAM users..."
aws iam generate-credential-report
aws iam get-credential-report --query 'Content' --output text | base64 -d > $OUTPUT_DIR/iam-credential-report.csv

# 2. GuardDuty Findings (últimos 90 días)
echo "Recopilando GuardDuty findings..."
aws guardduty list-findings --query 'FindingIds[]' --output json > $OUTPUT_DIR/guardduty-findings.json

# 3. Security Hub Score
echo "Recopilando Security Hub score..."
aws securityhub get-findings --query 'Findings[?Compliance.Status==`FAILED`]' --output json > $OUTPUT_DIR/security-hub-failed.json

# 4. Config Compliance
echo "Recopilando Config compliance..."
aws config get-compliance-summary --output json > $OUTPUT_DIR/config-compliance.json

# 5. CloudTrail Status
echo "Verificando CloudTrail..."
aws cloudtrail describe-trails --output json > $OUTPUT_DIR/cloudtrail-status.json

# 6. S3 Public Access Blocks
echo "Verificando S3 buckets..."
aws s3api list-buckets --query 'Buckets[*].Name' --output json | \
    jq -r '.[]' | while read bucket; do
    aws s3api get-public-access-block --bucket $bucket 2>/dev/null | \
        jq --arg bucket "$bucket" '. + {bucket: $bucket}'
done > $OUTPUT_DIR/s3-public-access.json

echo "Evidencia guardada en $OUTPUT_DIR/"
```

### PCI DSS en AWS: Ambiente Cardholder Data (CDE)

```mermaid
flowchart TD
    subgraph "Network Segmentation"
        A[Internet] --> B[WAF + Shield]
        B --> C[DMZ - Public Subnet]
        C --> D[ALB - HTTPS]
        D --> E[App Tier - Private Subnet]
        E --> F[DB Tier - Isolated Subnet]
        
        G[Jump Host/Bastion] --> E
        G --> F
    end
    
    subgraph "PCI Controls"
        H[IAM - Least Privilege] --> I[Encryption TLS 1.2+]
        I --> J[KMS - AES-256]
        J --> K[CloudTrail - Audit]
        K --> L[GuardDuty - Monitor]
    end
```

#### Requisitos PCI DSS y AWS

| Requisito | Descripción | Implementación AWS |
|-----------|-------------|-------------------|
| 1.1 | Firewall configuration | Security Groups + NACLs |
| 2.1 | Vendor defaults changed | AWS Config rules |
| 3.4 | PAN storage encrypted | KMS + S3 SSE |
| 4.1 | Transmission encryption | ACM + TLS 1.2+ |
| 6.5 | Secure coding | CodeGuru + Inspector |
| 8.2 | Strong authentication | IAM password policy + MFA |
| 10.1 | Audit trails | CloudTrail + S3 |
| 10.2 | Audit trail coverage | CloudTrail data events |
| 11.2 | Vulnerability scans | Inspector |
| 11.3 | Penetration testing | 3rd party + AWS support |

#### Arquitectura PCI DSS Compliant

```yaml
# CloudFormation - VPC PCI DSS Compliant
AWSTemplateFormatVersion: '2010-09-09'
Description: 'PCI DSS Compliant VPC Architecture'

Parameters:
  Environment:
    Type: String
    Default: production
    AllowedValues: [production, staging]

Resources:
  # VPC con DNS logging
  PCIVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Sub 'pci-${Environment}'
        - Key: Compliance
          Value: PCI-DSS

  # Flow Logs para toda la VPC
  VPCFlowLog:
    Type: AWS::EC2::FlowLog
    Properties:
      ResourceId: !Ref PCIVPC
      ResourceType: VPC
      TrafficType: ALL
      LogDestinationType: s3
      LogDestination: !GetAtt FlowLogBucket.Arn

  FlowLogBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub 'pci-vpc-flowlogs-${AWS::AccountId}'
      BucketEncryption:
        ServerSideEncryptionConfiguration:
          - ServerSideEncryptionByDefault:
              SSEAlgorithm: aws:kms
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true
      LifecycleConfiguration:
        Rules:
          - Id: ArchiveToGlacier
            Status: Enabled
            TransitionInDays: 90
            StorageClass: GLACIER
          - Id: DeleteAfter7Years
            Status: Enabled
            ExpirationInDays: 2555

  # Public Subnets (DMZ)
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref PCIVPC
      CidrBlock: 10.0.1.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: false  # No auto-assign public IPs
      Tags:
        - Key: Name
          Value: !Sub 'pci-${Environment}-public-1'
        - Key: Type
          Value: DMZ

  # Private Subnets (App Tier)
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref PCIVPC
      CidrBlock: 10.0.10.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: !Sub 'pci-${Environment}-app-1'
        - Key: Type
          Value: Application

  # Isolated Subnets (DB Tier)
  DatabaseSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref PCIVPC
      CidrBlock: 10.0.100.0/24
      AvailabilityZone: !Select [0, !GetAZs '']
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: !Sub 'pci-${Environment}-db-1'
        - Key: Type
          Value: Database

  # Security Groups - Least Privilege
  WebSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Web tier - HTTPS only
      VpcId: !Ref PCIVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          SourceSecurityGroupId: !Ref ALBSecurityGroup
          Description: HTTPS from ALB only
      SecurityGroupEgress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          DestinationSecurityGroupId: !Ref AppSecurityGroup
      Tags:
        - Key: Name
          Value: !Sub 'pci-${Environment}-web-sg'

  ALBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: ALB - Public HTTPS
      VpcId: !Ref PCIVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
          Description: HTTPS from internet
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 10.0.0.0/16  # Only to VPC

  AppSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: App tier - internal only
      VpcId: !Ref PCIVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 8080
          ToPort: 8080
          SourceSecurityGroupId: !Ref WebSecurityGroup
      SecurityGroupEgress:
        - IpProtocol: tcp
          FromPort: 5432
          ToPort: 5432
          DestinationSecurityGroupId: !Ref DBSecurityGroup

  DBSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Database tier - app tier only
      VpcId: !Ref PCIVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 5432
          ToPort: 5432
          SourceSecurityGroupId: !Ref AppSecurityGroup
      SecurityGroupEgress: []  # No outbound

  # Network ACLs - Additional layer
  PublicNACL:
    Type: AWS::EC2::NetworkAcl
    Properties:
      VpcId: !Ref PCIVPC
      Tags:
        - Key: Name
          Value: !Sub 'pci-${Environment}-public-nacl'

  NACLOutboundRule:
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
      Egress: true

  NACLEgressDenyAll:
    Type: AWS::EC2::NetworkAclEntry
    Properties:
      NetworkAclId: !Ref PublicNACL
      RuleNumber: 200
      Protocol: -1
      CidrBlock: 0.0.0.0/0
      RuleAction: deny
      Egress: true
```

---

## Anti-Patrones y Soluciones

### Tabla de Anti-Patrones Comunes

| Anti-Patrón | Riesgo | Solución |
|-------------|--------|----------|
| Access keys en EC2 metadata | Credential exposure | Usar IAM Roles |
| Security Group 0.0.0.0/0 | Open to internet | CIDRs específicos |
| S3 bucket public-read | Data breach | Block public access |
| Root usage diario | Privilege escalation | IAM users con MFA |
| CloudTrail solo en 1 región | Audit gap | Multi-region trail |
| Secrets en variables de entorno | Credential leak | Secrets Manager |
| KMS key sin rotation | Key compromise | Automatic rotation |
| IAM policies con `*` | Over-permission | Principio mínimo |
| Sin GuardDuty | Threat blind | Habilitar en todas las regiones |
| No password policy | Weak passwords | Policy 16+ chars |

---

## Troubleshooting de Seguridad

### Problema: "Access Denied" en S3

```bash
# Diagnóstico paso a paso

# 1. Verificar permisos IAM
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::123456789012:user/myuser \
    --action-names s3:GetObject \
    --resource-arns arn:aws:s3:::my-bucket/my-file.txt

# 2. Verificar bucket policy
aws s3api get-bucket-policy --bucket my-bucket

# 3. Verificar ACLs
aws s3api get-bucket-acl --bucket my-bucket

# 4. Verificar public access block
aws s3api get-public-access-block --bucket my-bucket

# 5. Verificar encriptación (si aplica)
aws s3api get-bucket-encryption --bucket my-bucket

# 6. Verificar ownership
aws s3api get-bucket-ownership-controls --bucket my-bucket
```

### Problema: GuardDuty No Genera Findings

```bash
# Troubleshooting

# 1. Verificar detector activado
aws guardduty list-detectors --query 'DetectorIds'

# 2. Verificar publishing frequency
aws guardduty get-detector --detector-id <id> \
    --query 'FindingPublishingFrequency'

# 3. Verificar SNS topic subscriptions
aws sns list-subscriptions-by-topic \
    --topic-arn arn:aws:sns:us-east-1:123456789012:guardduty-alerts

# 4. Verificar EventBridge rules
aws events list-rules --name-prefix GuardDuty
```

### Problema: CloudTrail Logs No Llegan a S3

```bash
# Diagnóstico

# 1. Verificar trail status
aws cloudtrail describe-trails \
    --trail-name-list my-trail \
    --query 'trailList[0].IsLogging'

# 2. Verificar bucket policy
aws s3api get-bucket-policy --bucket my-trail-bucket

# 3. Verificar lifecycle (no expirados prematuramente)
aws s3api get-bucket-lifecycle-configuration --bucket my-trail-bucket

# 4. Verificar KMS permissions (si encrypted)
aws kms get-key-policy --key-id alias/my-key --policy-name default
```

---

## Ejercicio Práctico: Implementación en tu Cuenta

### Laboratorio: Hardening de Cuenta AWS

**Objetivo:** Implementar controles básicos de seguridad en una cuenta AWS de sandbox.

**Duración:** 2 horas

#### Parte 1: IAM (30 min)

```bash
# Tarea 1: Crear usuario administrativo con MFA
# 1. Crear usuario
aws iam create-user --user-name lab-admin

# 2. Asignar policy
aws iam attach-user-policy \
    --user-name lab-admin \
    --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# 3. Crear access keys
aws iam create-access-keys --user-name lab-admin

# 4. Configurar MFA (desde console, requiere virtual device)
# Console > IAM > Users > lab-admin > Security credentials > MFA

# Verificación: Intentar operación sin MFA (debe fallar con SCP)
```

#### Parte 2: Logging (30 min)

```bash
# Tarea 2: Configurar CloudTrail
# 1. Crear bucket para logs
aws s3 mb s3://lab-cloudtrail-logs-$(date +%s)

# 2. Configurar bucket policy para CloudTrail
aws s3api put-bucket-policy \
    --bucket lab-cloudtrail-logs-xxx \
    --policy file://cloudtrail-bucket-policy.json

# 3. Crear trail
aws cloudtrail create-trail \
    --name lab-trail \
    --s3-bucket-name lab-cloudtrail-logs-xxx \
    --is-multi-region-trail \
    --enable-log-file-validation

# 4. Habilitar logging
aws cloudtrail start-logging --name lab-trail

# Verificación: Crear un recurso y verificar logs en S3 después de 5 min
```

#### Parte 3: Detección (30 min)

```bash
# Tarea 3: Habilitar GuardDuty
# 1. Habilitar detector
aws guardduty create-detector --enable

# 2. Crear SNS topic para alertas
aws sns create-topic --name lab-guardduty-alerts
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:ACCOUNT:lab-guardduty-alerts \
    --protocol email \
    --notification-endpoint tu-email@example.com

# 3. Configurar EventBridge rule
aws events put-rule \
    --name GuardDuty-High-Findings \
    --event-pattern file://guardduty-event-pattern.json

# 4. Conectar rule a SNS
aws events put-targets \
    --rule GuardDuty-High-Findings \
    --targets Id=1,Arn=arn:aws:sns:us-east-1:ACCOUNT:lab-guardduty-alerts

# Verificación: Simular finding de prueba (requiere evento real o sample)
```

#### Parte 4: Data Protection (30 min)

```bash
# Tarea 4: Encriptar S3 bucket
# 1. Crear KMS key
aws kms create-key \
    --description "Lab encryption key" \
    --key-usage ENCRYPT_DECRYPT \
    --origin AWS_KMS

# 2. Crear alias
aws kms create-alias \
    --alias-name alias/lab-key \
    --target-key-id $(aws kms list-keys --query 'Keys[0].KeyId' --output text)

# 3. Crear bucket con encriptación
aws s3 mb s3://lab-encrypted-bucket-$(date +%s)

aws s3api put-bucket-encryption \
    --bucket lab-encrypted-bucket-xxx \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "aws:kms",
                "KMSMasterKeyID": "alias/lab-key"
            }
        }]
    }'

# 4. Subir archivo y verificar encriptación
aws s3 cp test.txt s3://lab-encrypted-bucket-xxx/
aws s3api head-object --bucket lab-encrypted-bucket-xxx --key test.txt

# Verificación: Confirmar ServerSideEncryption: aws:kms
```

### Criterios de Éxito

- [ ] Usuario administrativo creado con MFA
- [ ] CloudTrail habilitado y generando logs
- [ ] GuardDuty activo y configurado para alertas
- [ ] S3 bucket con encriptación KMS por default
- [ ] Bucket con block public access habilitado
- [ ] KMS key con rotación automática

---

## Referencias Rápidas

### Comandos IAM Útiles

```bash
# Listar usuarios sin MFA
aws iam generate-credential-report
aws iam get-credential-report --query 'Content' --output text | base64 -d | \
    awk -F',' 'NR>1 && $4=="true" && $8=="false" {print $1}'  # Console access sin MFA

# Listar access keys viejas (>90 días)
aws iam get-credential-report --query 'Content' --output text | base64 -d | \
    awk -F',' 'NR>1 && $10!="not_supported" && $10!="N/A" && $10!="no_information" \
    {cmd="date -d \"$10\" +%s"; cmd | getline date; close(cmd); \
    if (systime() - date > 7776000) print $1}'  # 90 días en segundos

# Listar policies con *
aws iam list-policies --scope Local --query 'Policies[*].Arn' --output text | \
    tr '\t' '\n' | while read policy; do
    aws iam get-policy-version --policy-arn $policy --version-id $(aws iam get-policy --policy-arn $policy --query 'Policy.DefaultVersionId' --output text) --query 'PolicyVersion.Document' --output json | grep -q '"\*"' && echo $policy
done
```

### Alertas CloudWatch Security

| Alarma | Métrica/Log Pattern | Severidad |
|--------|---------------------|-----------|
| Root account usage | CloudTrail: eventName=ConsoleLogin, userIdentity.type=Root | CRITICAL |
| IAM policy changes | CloudTrail: eventSource=iam.amazonaws.com, eventName=Put\|Create\|Delete*Policy | HIGH |
| S3 bucket policy public | CloudTrail: eventName=PutBucketPolicy + public indicator | CRITICAL |
| Console login sin MFA | CloudTrail: ConsoleLogin + MFA!=true | HIGH |
| Unauthorized API calls | CloudTrail: errorCode=AccessDenied | MEDIUM |
| GuardDuty high finding | GuardDuty finding severity>=7 | CRITICAL |

### Recursos Adicionales

- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [PCI DSS on AWS](https://docs.aws.amazon.com/architecture/whitepapers/compliance-pci-dss/)
- [SOC 2 on AWS](https://docs.aws.amazon.com/whitepapers/latest/soc-2-on-aws/)
- [AWS Security Incident Response Guide](https://docs.aws.amazon.com/security-incident-response/latest/guide/)
