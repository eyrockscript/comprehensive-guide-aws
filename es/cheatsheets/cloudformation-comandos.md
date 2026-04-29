# Cheatsheet: Comandos CLI de CloudFormation

## Crear Stacks

```bash
# Crear stack básico
aws cloudformation create-stack \
    --stack-name mi-aplicacion \
    --template-body file://template.yaml \
    --tags Key=Environment,Value=Production

# Crear con parámetros
aws cloudformation create-stack \
    --stack-name mi-aplicacion \
    --template-body file://template.yaml \
    --parameters \
        ParameterKey=InstanceType,ParameterValue=t3.micro \
        ParameterKey=KeyName,ParameterValue=mi-clave \
    --tags Key=Environment,Value=Production Key=Team,Value=DevOps

# Crear con archivo de parámetros
aws cloudformation create-stack \
    --stack-name mi-aplicacion \
    --template-body file://template.yaml \
    --parameters file://parameters.json

# Crear con capacidades IAM
aws cloudformation create-stack \
    --stack-name mi-aplicacion \
    --template-body file://template.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM

# Crear con capacidades para transforms (SAM)
aws cloudformation create-stack \
    --stack-name mi-lambda-app \
    --template-body file://template.yaml \
    --capabilities CAPABILITY_AUTO_EXPAND

# Crear desde S3
aws cloudformation create-stack \
    --stack-name mi-aplicacion \
    --template-url https://s3.amazonaws.com/mi-bucket/templates/template.yaml
```

## Actualizar Stacks

```bash
# Actualizar stack
aws cloudformation update-stack \
    --stack-name mi-aplicacion \
    --template-body file://template.yaml \
    --parameters file://parameters.json

# Cambiar política de rollback
aws cloudformation update-stack \
    --stack-name mi-aplicacion \
    --template-body file://template.yaml \
    --rollback-configuration RollbackTriggers=[{Arn:arn:aws:sns:us-east-1:123456789012:mi-topico,Type:ARN}]

# Actualizar solo parámetros
aws cloudformation update-stack \
    --stack-name mi-aplicacion \
    --use-previous-template \
    --parameters \
        ParameterKey=InstanceType,ParameterValue=t3.small \
        ParameterKey=KeyName,UsePreviousValue=true
```

## Crear Cambios (Change Sets)

```bash
# Crear change set
aws cloudformation create-change-set \
    --stack-name mi-aplicacion \
    --template-body file://template-v2.yaml \
    --change-set-name actualizacion-v2 \
    --parameters file://parameters.json

# Crear change set para stack nuevo
aws cloudformation create-change-set \
    --stack-name mi-aplicacion-v2 \
    --template-body file://template.yaml \
    --change-set-name creacion-inicial \
    --change-set-type CREATE

# Describir change set
aws cloudformation describe-change-set \
    --stack-name mi-aplicacion \
    --change-set-name actualizacion-v2

# Listar change sets
aws cloudformation list-change-sets --stack-name mi-aplicacion

# Ejecutar change set
aws cloudformation execute-change-set \
    --stack-name mi-aplicacion \
    --change-set-name actualizacion-v2

# Eliminar change set
aws cloudformation delete-change-set \
    --stack-name mi-aplicacion \
    --change-set-name actualizacion-v2
```

## Monitorear Stacks

```bash
# Describir stack
aws cloudformation describe-stacks --stack-name mi-aplicacion

# Describir con query
aws cloudformation describe-stacks \
    --stack-name mi-aplicacion \
    --query 'Stacks[0].Outputs'

# Listar stacks
aws cloudformation list-stacks

# Listar stacks activos
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE

# Listar recursos del stack
aws cloudformation list-stack-resources --stack-name mi-aplicacion

# Describir recurso específico
aws cloudformation describe-stack-resource \
    --stack-name mi-aplicacion \
    --logical-resource-id MiInstanciaEC2

# Ver eventos del stack
aws cloudformation describe-stack-events \
    --stack-name mi-aplicacion \
    --query 'StackEvents[?ResourceStatus==`CREATE_COMPLETE`].[LogicalResourceId,ResourceStatus,Timestamp]'

# Monitorear en tiempo real
aws cloudformation describe-stack-events \
    --stack-name mi-aplicacion \
    --query 'StackEvents[].{Resource:LogicalResourceId,Status:ResourceStatus,Time:Timestamp}' \
    --output table
```

## Gestionar Stacks

```bash
# Eliminar stack
aws cloudformation delete-stack --stack-name mi-aplicacion

# Eliminar con retención de recursos
aws cloudformation delete-stack \
    --stack-name mi-aplicacion \
    --retain-resources MiInstanciaEC2

# Cancelar update en progreso
aws cloudformation cancel-update-stack --stack-name mi-aplicacion

# Detener operación de stack
aws cloudformation stop-stack-set-operation \
    --stack-set-name mi-stack-set \
    --operation-id operacion-001

# Continuar rollback (si falló)
aws cloudformation continue-update-rollback --stack-name mi-aplicacion
```

## Stack Sets

```bash
# Crear stack set
aws cloudformation create-stack-set \
    --stack-set-name mi-stack-set \
    --template-body file://template.yaml \
    --parameters ParameterKey=Environment,ParameterValue=Production

# Crear instancias en cuentas/regiones
aws cloudformation create-stack-instances \
    --stack-set-name mi-stack-set \
    --accounts 123456789012 123456789013 \
    --regions us-east-1 us-west-2

# Actualizar stack set
aws cloudformation update-stack-set \
    --stack-set-name mi-stack-set \
    --template-body file://template-v2.yaml

# Eliminar instancias
aws cloudformation delete-stack-instances \
    --stack-set-name mi-stack-set \
    --accounts 123456789012 \
    --regions us-west-2 \
    --no-retain-stacks

# Eliminar stack set
aws cloudformation delete-stack-set --stack-set-name mi-stack-set

# Describir operación
aws cloudformation describe-stack-set-operation \
    --stack-set-name mi-stack-set \
    --operation-id operacion-001
```

## Validar y Previsualizar

```bash
# Validar template
aws cloudformation validate-template --template-body file://template.yaml

# Validar desde S3
aws cloudformation validate-template \
    --template-url https://s3.amazonaws.com/mi-bucket/templates/template.yaml

# Estimar costos (requiere template con Metadata)
aws cloudformation estimate-template-cost \
    --template-body file://template.yaml \
    --parameters ParameterKey=InstanceType,ParameterValue=t3.micro

# Detectar drift
aws cloudformation detect-stack-drift --stack-name mi-aplicacion

# Describir drift
aws cloudformation describe-stack-drift-detection-status \
    --stack-drift-detection-id 12345678-1234-1234-1234-123456789012

# Detectar drift de recurso
aws cloudformation detect-stack-resource-drift \
    --stack-name mi-aplicacion \
    --logical-resource-id MiInstanciaEC2
```

## Exports y Imports

```bash
# Listar exports
aws cloudformation list-exports

# Listar con filtro
aws cloudformation list-exports --query 'Exports[?Name==`VPCId`].Value'

# Listar imports de un export
aws cloudformation list-imports --export-name VPCId
```

## Políticas de Stack

```bash
# Crear stack policy
aws cloudformation set-stack-policy \
    --stack-name mi-aplicacion \
    --stack-policy-body file://stack-policy.json

# Denegar todas las actualizaciones (stack policy ejemplo)
# stack-policy.json:
{
  "Statement": [
    {
      "Effect": "Deny",
      "Action": "Update:*",
      "Principal": "*",
      "Resource": "*"
    }
  ]
}

# Permitir update con override durante update-stack
aws cloudformation update-stack \
    --stack-name mi-aplicacion \
    --template-body file://template.yaml \
    --stack-policy-during-update-body file://allow-update-policy.json
```

## Waiters

```bash
# Esperar a que stack se complete
aws cloudformation wait stack-create-complete --stack-name mi-aplicacion
aws cloudformation wait stack-update-complete --stack-name mi-aplicacion
aws cloudformation wait stack-delete-complete --stack-name mi-aplicacion

# En scripts
aws cloudformation create-stack \
    --stack-name mi-aplicacion \
    --template-body file://template.yaml

aws cloudformation wait stack-create-complete \
    --stack-name mi-aplicacion

echo "Stack creado exitosamente"
```

## Tags y Metadata

```bash
# Actualizar tags
aws cloudformation update-stack \
    --stack-name mi-aplicacion \
    --use-previous-template \
    --tags \
        Key=Environment,Value=Staging \
        Key=UpdatedBy,Value=DevOps

# Listar recursos con tags
aws cloudformation list-stack-resources \
    --stack-name mi-aplicacion \
    --query 'StackResourceSummaries[].{Resource:LogicalResourceId,Type:ResourceType}'
```

## Ejemplo: Template Básico

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'EC2 Instance básica'

Parameters:
  InstanceType:
    Type: String
    Default: t3.micro
    AllowedValues:
      - t3.micro
      - t3.small
      - t3.medium
  KeyName:
    Type: AWS::EC2::KeyPair::KeyName
    Description: Nombre de la key pair

Resources:
  MiInstancia:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0c55b159cbfafe1f0
      InstanceType: !Ref InstanceType
      KeyName: !Ref KeyName
      Tags:
        - Key: Name
          Value: MiServidor

Outputs:
  InstanceId:
    Description: ID de la instancia
    Value: !Ref MiInstancia
  PublicIP:
    Description: IP pública
    Value: !GetAtt MiInstancia.PublicIp
```

## Ejemplo: Archivo de Parámetros

```json
[
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t3.small"
  },
  {
    "ParameterKey": "KeyName",
    "ParameterValue": "mi-clave-ssh"
  },
  {
    "ParameterKey": "Environment",
    "ParameterValue": "production"
  }
]
```

## Comandos Útiles

```bash
# Obtener outputs del stack
aws cloudformation describe-stacks \
    --stack-name mi-aplicacion \
    --query 'Stacks[0].Outputs[?OutputKey==`InstanceId`].OutputValue' \
    --output text

# Buscar stacks por tag
aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
    | jq '.StackSummaries[] | select(.Tags[]? | .Key=="Environment" and .Value=="Production")'

# Obtener template del stack
aws cloudformation get-template --stack-name mi-aplicacion

# Resumen de recursos
aws cloudformation list-stack-resources \
    --stack-name mi-aplicacion \
    --query 'StackResourceSummaries[].{Logical:LogicalResourceId,Physical:PhysicalResourceId,Type:ResourceType,Status:ResourceStatus}'
```

## Consejos Rápidos

| Tarea | Comando |
|-------|---------|
| Crear stack | `aws cloudformation create-stack --stack-name <name> --template-body file://template.yaml` |
| Actualizar stack | `aws cloudformation update-stack --stack-name <name> --template-body file://template.yaml` |
| Eliminar stack | `aws cloudformation delete-stack --stack-name <name>` |
| Ver status | `aws cloudformation describe-stacks --stack-name <name> --query 'Stacks[0].StackStatus'` |
| Validar template | `aws cloudformation validate-template --template-body file://template.yaml` |
| Crear change set | `aws cloudformation create-change-set --stack-name <name> --change-set-name <name>` |
| Ver eventos | `aws cloudformation describe-stack-events --stack-name <name>` |

## Buenas Prácticas

```bash
# Siempre usar change sets para producción
aws cloudformation create-change-set \
    --stack-name mi-aplicacion \
    --template-body file://template.yaml \
    --change-set-name cambio-$(date +%Y%m%d-%H%M%S)

# Revisar antes de ejecutar
aws cloudformation describe-change-set \
    --stack-name mi-aplicacion \
    --change-set-name cambio-20240101-120000

# Ejecutar solo después de revisar
aws cloudformation execute-change-set \
    --stack-name mi-aplicacion \
    --change-set-name cambio-20240101-120000
```
