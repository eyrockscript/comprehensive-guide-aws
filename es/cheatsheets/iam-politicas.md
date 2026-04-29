# Cheatsheet: Políticas IAM de AWS

## Estructura Base de Política

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["servicio:accion"],
      "Resource": "arn:aws:servicio:region:cuenta:recurso"
    }
  ]
}
```

## Políticas Comunes

### Acceso Solo Lectura a S3

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::mi-bucket-ejemplo",
        "arn:aws:s3:::mi-bucket-ejemplo/*"
      ]
    }
  ]
}
```

### Acceso Completo a EC2 en Desarrollo

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:ResourceTag/Environment": "Development"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    }
  ]
}
```

### Acceso a RDS Solo desde VPC Específica

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:Describe*",
        "rds:List*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:CreateDBInstance",
        "rds:ModifyDBInstance"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:VpcSourceIp": "10.0.0.0/16"
        }
      }
    }
  ]
}
```

## Políticas de Confianza (Trust Policy)

### Rol para Servicio EC2

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Rol para Lambda

```json
{
  "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }
```

### Rol para Usuario Específico

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:user/usuario-ejemplo"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "Bool": {
          "aws:MultiFactorAuthPresent": "true"
        }
      }
    }
  ]
}
```

## Condiciones (Conditions)

### Restricción por IP

```json
{
  "Effect": "Deny",
  "Action": "s3:*",
  "Resource": "*",
  "Condition": {
    "NotIpAddress": {
      "aws:SourceIp": ["203.0.113.0/24", "198.51.100.0/24"]
    }
  }
}
```

### Requerir MFA

```json
{
  "Effect": "Deny",
  "Action": "s3:DeleteBucket",
  "Resource": "*",
  "Condition": {
    "BoolIfExists": {
      "aws:MultiFactorAuthPresent": "false"
    }
  }
}
```

### Restricción Horaria

```json
{
  "Effect": "Allow",
  "Action": "ec2:*",
  "Resource": "*",
  "Condition": {
    "DateGreaterThan": {
      "aws:CurrentTime": "2024-01-01T00:00:00Z"
    },
    "DateLessThan": {
      "aws:CurrentTime": "2024-12-31T23:59:59Z"
    }
  }
}
```

### Solo Región Específica

```json
{
  "Effect": "Deny",
  "Action": "*",
  "Resource": "*",
  "Condition": {
    "StringNotEquals": {
      "aws:RequestedRegion": ["us-east-1", "us-west-2"]
    }
  }
}
```

## Políticas de Bucket S3

### Bucket Público de Solo Lectura

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mi-bucket-publico/*"
    }
  ]
}
```

### Bucket con Acceso por Organización

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::mi-bucket",
        "arn:aws:s3:::mi-bucket/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:PrincipalOrgID": "o-xxxxxxxxxx"
        }
      }
    }
  ]
}
```

### Bucket con Encripción Requerida

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::mi-bucket-ejemplo/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
```

## Políticas de KMS

### Acceso a Clave KMS

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
    }
  ]
}
```

## SCP (Service Control Policies)

### Bloquear Eliminación de Buckets

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "s3:DeleteBucket",
      "Resource": "*"
    }
  ]
}
```

### Solo Servicios Aprobados

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "NotAction": [
        "s3:*",
        "ec2:*",
        "iam:*",
        "organizations:*"
      ],
      "Resource": "*"
    }
  ]
}
```

### Restricción de Regiones

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": ["us-east-1", "eu-west-1"]
        },
        "ArnNotLike": {
          "aws:PrincipalARN": "arn:aws:iam::*:role/AdminRole"
        }
      }
    }
  ]
}
```

## Permission Boundaries

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "ec2:*",
        "rds:*"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Environment": "Development"
        }
      }
    },
    {
      "Effect": "Deny",
      "Action": [
        "s3:DeleteBucket",
        "ec2:DeleteVpc",
        "rds:DeleteDBInstance"
      ],
      "Resource": "*"
    }
  ]
}
```

## Referencias Rápidas

| Elemento | Descripción |
|----------|-------------|
| `*` | Comodín para todos |
| `?` | Comodín para uno |
| `Principal` | Quien puede acceder |
| `Action` | Qué puede hacer |
| `Resource` | Sobre qué recursos |
| `Condition` | Cuándo aplicar |
| `Effect` | Allow o Deny |

## Comandos CLI Útiles

```bash
# Crear política
aws iam create-policy \
    --policy-name MiPolitica \
    --policy-document file://politica.json

# Adjuntar política a usuario
aws iam attach-user-policy \
    --user-name usuario \
    --policy-arn arn:aws:iam::aws:policy/ReadOnlyAccess

# Ver políticas adjuntas
aws iam list-attached-user-policies --user-name usuario

# Simular política
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::123456789012:user/usuario \
    --action-names s3:GetObject s3:DeleteBucket
```
