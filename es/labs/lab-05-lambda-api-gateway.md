# Laboratorio 5: API Serverless con Lambda y API Gateway

## Objetivo
Crear una API REST serverless usando Lambda, API Gateway y DynamoDB.

## Duración Estimada
60-75 minutos

## Arquitectura
```
Cliente → API Gateway → Lambda → DynamoDB
```

## Instrucciones

### Paso 1: Crear Tabla DynamoDB
```bash
aws dynamodb create-table \
    --table-name Tasks \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --tags Key=Environment,Value=Lab
```

### Paso 2: Crear Rol IAM para Lambda
```bash
aws iam create-role \
    --role-name LambdaDynamoDBRole \
    --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
    --role-name LambdaDynamoDBRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy \
    --role-name LambdaDynamoDBRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
```

### Paso 3: Crear Funciones Lambda
**Lambda: GetTasks**
```python
import json
import boto3
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Tasks')

def lambda_handler(event, context):
    response = table.scan()
    return {
        'statusCode': 200,
        'headers': {'Access-Control-Allow-Origin': '*'},
        'body': json.dumps(response['Items'])
    }
```

**Lambda: CreateTask**
```python
import json
import boto3
import uuid

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Tasks')

def lambda_handler(event, context):
    task = json.loads(event['body'])
    task['id'] = str(uuid.uuid4())
    table.put_item(Item=task)
    return {
        'statusCode': 201,
        'headers': {'Access-Control-Allow-Origin': '*'},
        'body': json.dumps(task)
    }
```

### Paso 4: Crear API Gateway
```bash
aws apigateway create-rest-api \
    --name 'TasksAPI' \
    --description 'API for task management'

# Crear recursos y métodos
aws apigateway create-resource \
    --rest-api-id abc123 \
    --parent-id xyz789 \
    --path-part tasks
```

### Paso 5: Desplegar API
```bash
aws apigateway create-deployment \
    --rest-api-id abc123 \
    --stage-name prod
```

## Pruebas
```bash
# Crear tarea
curl -X POST https://xxx.execute-api.region.amazonaws.com/prod/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Complete lab", "status": "pending"}'

# Obtener tareas
curl https://xxx.execute-api.region.amazonaws.com/prod/tasks
```

## Retos Adicionales
1. Agregar autenticación con Cognito
2. Implementar validación de requests
3. Configurar throttling y usage plans
4. Implementar caching
5. Usar Step Functions para flujos complejos

## Monitoreo
```bash
# Ver métricas de Lambda
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Duration \
    --dimensions Name=FunctionName,Value=GetTasks \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Average
```

## Limpieza
1. Eliminar API Gateway
2. Eliminar funciones Lambda
3. Eliminar tabla DynamoDB
4. Eliminar rol IAM
