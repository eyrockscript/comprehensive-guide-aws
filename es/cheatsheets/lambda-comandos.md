# Cheatsheet: Comandos CLI de Lambda

## Crear Funciones Lambda

### Función Básica (Node.js)

```bash
# Crear función con código inline
aws lambda create-function \
    --function-name mi-funcion-node \
    --runtime nodejs18.x \
    --handler index.handler \
    --role arn:aws:iam::123456789012:role/lambda-execution-role \
    --zip-file fileb://function.zip

# Crear función con variables de entorno
aws lambda create-function \
    --function-name mi-funcion-env \
    --runtime nodejs18.x \
    --handler index.handler \
    --role arn:aws:iam::123456789012:role/lambda-execution-role \
    --zip-file fileb://function.zip \
    --environment Variables={ENV=production,DEBUG=false} \
    --timeout 30 \
    --memory-size 512
```

### Función Python

```bash
aws lambda create-function \
    --function-name mi-funcion-python \
    --runtime python3.11 \
    --handler lambda_function.handler \
    --role arn:aws:iam::123456789012:role/lambda-execution-role \
    --zip-file fileb://function.zip \
    --description "Función Python de procesamiento"
```

### Función con VPC

```bash
aws lambda create-function \
    --function-name mi-funcion-vpc \
    --runtime python3.11 \
    --handler lambda_function.handler \
    --role arn:aws:iam::123456789012:role/lambda-vpc-role \
    --zip-file fileb://function.zip \
    --vpc-config SubnetIds=subnet-12345678,subnet-87654321,SecurityGroupIds=sg-12345678
```

## Gestionar Funciones

```bash
# Listar funciones
aws lambda list-functions

# Listar con paginación
aws lambda list-functions --max-items 50

# Obtener detalles de función
aws lambda get-function --function-name mi-funcion-node

# Obtener configuración
aws lambda get-function-configuration --function-name mi-funcion-node

# Actualizar código
aws lambda update-function-code \
    --function-name mi-funcion-node \
    --zip-file fileb://function-v2.zip

# Actualizar configuración
aws lambda update-function-configuration \
    --function-name mi-funcion-node \
    --timeout 60 \
    --memory-size 1024 \
    --environment Variables={ENV=staging,DEBUG=true}

# Eliminar función
aws lambda delete-function --function-name mi-funcion-node
```

## Invocar Funciones

```bash
# Invocación sincrónica
aws lambda invoke \
    --function-name mi-funcion-node \
    --payload '{"name":"Juan","id":123}' \
    response.json

# Invocación asincrónica
aws lambda invoke \
    --function-name mi-funcion-node \
    --invocation-type Event \
    --payload '{"action":"process"}' \
    /dev/null

# Invocación con logs
aws lambda invoke \
    --function-name mi-funcion-node \
    --log-type Tail \
    --payload '{"test":true}' \
    response.json \
    --query 'LogResult' --output text | base64 -d
```

## Versiones y Aliases

```bash
# Publicar versión
aws lambda publish-version \
    --function-name mi-funcion-node \
    --description "Versión estable v1.0"

# Listar versiones
aws lambda list-versions-by-function \
    --function-name mi-funcion-node

# Crear alias
aws lambda create-alias \
    --function-name mi-funcion-node \
    --name prod \
    --function-version 1 \
    --description "Entorno de producción"

# Crear alias con routing (canary)
aws lambda create-alias \
    --function-name mi-funcion-node \
    --name beta \
    --function-version 2 \
    --routing-config AdditionalVersionWeights={1=0.1}

# Actualizar alias
aws lambda update-alias \
    --function-name mi-funcion-node \
    --name prod \
    --function-version 2

# Eliminar alias
aws lambda delete-alias \
    --function-name mi-funcion-node \
    --name beta
```

## Permisos (Resource Policy)

```bash
# Permitir invocación desde S3
aws lambda add-permission \
    --function-name mi-funcion-node \
    --statement-id s3-invoke \
    --action lambda:InvokeFunction \
    --principal s3.amazonaws.com \
    --source-arn arn:aws:s3:::mi-bucket

# Permitir invocación desde API Gateway
aws lambda add-permission \
    --function-name mi-funcion-node \
    --statement-id apigateway-invoke \
    --action lambda:InvokeFunction \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:us-east-1:123456789012:abc123/*/POST/procesar"

# Permitir invocación desde SNS
aws lambda add-permission \
    --function-name mi-funcion-node \
    --statement-id sns-invoke \
    --action lambda:InvokeFunction \
    --principal sns.amazonaws.com \
    --source-arn arn:aws:sns:us-east-1:123456789012:mi-topico

# Ver política
aws lambda get-policy --function-name mi-funcion-node

# Eliminar permiso
aws lambda remove-permission \
    --function-name mi-funcion-node \
    --statement-id s3-invoke
```

## Event Source Mapping (Triggers)

```bash
# Crear mapping con SQS
aws lambda create-event-source-mapping \
    --function-name mi-funcion-node \
    --event-source-arn arn:aws:sqs:us-east-1:123456789012:mi-cola \
    --batch-size 10

# Crear mapping con DynamoDB Streams
aws lambda create-event-source-mapping \
    --function-name mi-funcion-node \
    --event-source-arn arn:aws:dynamodb:us-east-1:123456789012:table/mi-tabla/stream/2024-01-01T00:00:00.000 \
    --starting-position LATEST \
    --batch-size 100

# Crear mapping con Kinesis
aws lambda create-event-source-mapping \
    --function-name mi-funcion-node \
    --event-source-arn arn:aws:kinesis:us-east-1:123456789012:stream/mi-stream \
    --starting-position TRIM_HORIZON \
    --batch-size 500

# Listar mappings
aws lambda list-event-source-mappings \
    --function-name mi-funcion-node

# Actualizar mapping
aws lambda update-event-source-mapping \
    --uuid 12345678-1234-1234-1234-123456789012 \
    --batch-size 50 \
    --maximum-batching-window-in-seconds 30

# Eliminar mapping
aws lambda delete-event-source-mapping \
    --uuid 12345678-1234-1234-1234-123456789012
```

## Capas (Layers)

```bash
# Publicar capa
aws lambda publish-layer-version \
    --layer-name mi-libreria \
    --description "Librerías comunes" \
    --license-info "MIT" \
    --zip-file fileb://layer.zip \
    --compatible-runtimes nodejs18.x nodejs20.x

# Listar capas
aws lambda list-layers

# Listar versiones de capa
aws lambda list-layer-versions --layer-name mi-libreria

# Obtener detalles de capa
aws lambda get-layer-version \
    --layer-name mi-libreria \
    --version-number 1

# Agregar capa a función
aws lambda update-function-configuration \
    --function-name mi-funcion-node \
    --layers arn:aws:lambda:us-east-1:123456789012:layer:mi-libreria:1

# Eliminar versión de capa
aws lambda delete-layer-version \
    --layer-name mi-libreria \
    --version-number 1
```

## Concurrency y Provisioned Concurrency

```bash
# Configurar concurrencia reservada
aws lambda put-function-concurrency \
    --function-name mi-funcion-node \
    --reserved-concurrent-executions 100

# Eliminar concurrencia reservada
aws lambda delete-function-concurrency \
    --function-name mi-funcion-node

# Configurar provisioned concurrency
aws lambda put-provisioned-concurrency-config \
    --function-name mi-funcion-node \
    --qualifier prod \
    --provisioned-concurrent-executions 50

# Obtener configuración de provisioned concurrency
aws lambda get-provisioned-concurrency-config \
    --function-name mi-funcion-node \
    --qualifier prod

# Eliminar provisioned concurrency
aws lambda delete-provisioned-concurrency-config \
    --function-name mi-funcion-node \
    --qualifier prod
```

## Logs y Monitoreo

```bash
# Ver logs en CloudWatch (requiere awslogs o similar)
aws logs tail /aws/lambda/mi-funcion-node --follow

# Estadísticas de invocación
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Invocations \
    --dimensions Name=FunctionName,Value=mi-funcion-node \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Sum

# Errores
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Errors \
    --dimensions Name=FunctionName,Value=mi-funcion-node \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Sum
```

## Tags

```bash
# Agregar tags
aws lambda tag-resource \
    --resource arn:aws:lambda:us-east-1:123456789012:function:mi-funcion-node \
    --tags Environment=production,Team=backend,Project=ecommerce

# Listar tags
aws lambda list-tags \
    --resource arn:aws:lambda:us-east-1:123456789012:function:mi-funcion-node

# Eliminar tags
aws lambda untag-resource \
    --resource arn:aws:lambda:us-east-1:123456789012:function:mi-funcion-node \
    --tag-keys Team
```

## Consejos Rápidos

| Tarea | Comando |
|-------|---------|
| Ver funciones | `aws lambda list-functions` |
| Invocar función | `aws lambda invoke --function-name <name> --payload '{}' response.json` |
| Ver logs | `aws logs tail /aws/lambda/<function-name>` |
| Publicar versión | `aws lambda publish-version --function-name <name>` |
| Crear alias | `aws lambda create-alias --function-name <name> --name prod --function-version 1` |
| Actualizar código | `aws lambda update-function-code --function-name <name> --zip-file fileb://function.zip` |

## Ejemplo: Empaquetar y Desplegar

```bash
# Estructura del proyecto
# mi-proyecto/
# ├── index.js
# └── package.json

# Instalar dependencias
npm install

# Crear paquete de despliegue
zip -r function.zip index.js node_modules/

# Desplegar
aws lambda update-function-code \
    --function-name mi-funcion-node \
    --zip-file fileb://function.zip

# Limpiar
rm function.zip
```

## Ejemplo: Función Python con Dependencias

```bash
# Estructura
# proyecto/
# ├── lambda_function.py
# └── requirements.txt

# Crear directorio de paquetes
mkdir package
pip install -r requirements.txt -t package/

# Copiar código fuente
cp lambda_function.py package/

# Crear ZIP
cd package && zip -r ../function.zip . && cd ..

# Desplegar
aws lambda update-function-code \
    --function-name mi-funcion-python \
    --zip-file fileb://function.zip
```
