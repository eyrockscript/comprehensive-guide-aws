# Laboratorio 7: Gestión de Identidad y Acceso (IAM)

## Objetivo
Implementar políticas IAM seguras siguiendo el principio de privilegio mínimo.

## Duración Estimada
45-60 minutos

## Escenario
Empresa con 3 equipos: Desarrollo, QA y Producción. Cada equipo necesita permisos diferenciados.

## Instrucciones

### Paso 1: Crear Estructura de Usuarios y Grupos
```bash
# Crear grupos
aws iam create-group --group-name Developers
aws iam create-group --group-name QA-Team
aws iam create-group --group-name Production-Ops

# Crear usuarios
aws iam create-user --user-name dev-user-01
aws iam create-user --user-name qa-user-01
aws iam create-user --user-name prod-user-01

# Agregar usuarios a grupos
aws iam add-user-to-group --group-name Developers --user-name dev-user-01
aws iam add-user-to-group --group-name QA-Team --user-name qa-user-01
aws iam add-user-to-group --group-name Production-Ops --user-name prod-user-01
```

### Paso 2: Crear Políticas Personalizadas

**Política Developers** (`dev-policy.json`):
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ec2:Describe*",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ],
    "Resource": "*",
    "Condition": {"StringEquals": {"ec2:ResourceTag/Environment": "dev"}}
  }]
}
```

**Política Production** (`prod-policy.json`):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "cloudwatch:Get*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": "ec2:TerminateInstances",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {"ec2:ResourceTag/Critical": "false"}
      }
    }
  ]
}
```

```bash
aws iam create-policy \
    --policy-name DeveloperPolicy \
    --policy-document file://dev-policy.json

aws iam attach-group-policy \
    --group-name Developers \
    --policy-arn arn:aws:iam::xxx:policy/DeveloperPolicy
```

### Paso 3: Configurar MFA
```bash
# Habilitar MFA para usuarios
aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name dev-user-01-mfa \
    --outfile qr-code.png

# Requerir MFA para acciones sensibles
```

### Paso 4: Crear Roles para Servicios

**Rol EC2 para S3**:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
```

```bash
aws iam create-role \
    --role-name EC2-S3-Access-Role \
    --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
    --role-name EC2-S3-Access-Role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

### Paso 5: Configurar AWS Organizations (Simulado)
```bash
# Estructura de SCP (Service Control Policies)
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": "s3:DeleteBucket",
    "Resource": "*",
    "Condition": {"StringNotEquals": {"aws:PrincipalTag/Admin": "true"}}
  }]
}
```

## Pruebas
1. Simular acceso con IAM Policy Simulator
2. Verificar permisos con AWS CLI:
```bash
aws sts get-caller-identity
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::xxx:user/dev-user-01 \
    --action-names s3:GetObject s3:DeleteBucket
```

## Retos Adicionales
1. Implementar cross-account access
2. Configurar SAML/SSO integration
3. Crear políticas basadas en recursos
4. Implementar permission boundaries

## Auditoría
```bash
# Generar reporte de accesos
aws iam generate-credential-report
aws iam get-credential-report --query Content --output text | base64 -d

# Revisar políticas no utilizadas
aws iam list-policies --scope Local
```

## Limpieza
1. Desasociar y eliminar políticas personalizadas
2. Eliminar usuarios y grupos
3. Eliminar roles
