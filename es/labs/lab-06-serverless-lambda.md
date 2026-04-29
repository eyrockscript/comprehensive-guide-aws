# Laboratorio 06: Serverless con Lambda

## 🎯 Objetivo del Laboratorio

Crear funciones Lambda, configurar triggers con API Gateway y DynamoDB, y construir una API REST serverless completa.

**Tiempo estimado:** 75 minutos  
**Nivel:** Intermedio  
**Costo:** Dentro del Free Tier (1M requests Lambda gratis, 25GB DynamoDB gratis)

---

## 📋 Prerrequisitos

- Laboratorio 01 completado (cuenta AWS configurada)
- AWS CLI instalado y configurado
- Opcional: Python 3.x instalado localmente

---

## 🚀 Paso 1: Crear Tabla DynamoDB

### 1.1 Acceder al Servicio DynamoDB

1. Inicia sesión en la Consola de AWS
2. En la barra de búsqueda, escribe "DynamoDB"
3. Selecciona el servicio DynamoDB
4. Asegúrate de estar en la región **us-east-1**

### 1.2 Crear Tabla

1. Clic en "Create table"
2. Configura:

**Table details:**
```
Table name: lab-tasks-table
Partition key: taskId (String)
Sort key: createdAt (String) - Opcional
```

**Table settings:**
```
☑️ Customize settings
Table class: DynamoDB Standard
Capacity mode: On-demand (recomendado para desarrollo)
```

**Secondary indexes:**
```
Clic en "Create global secondary index"
Index name: status-index
Partition key: status (String)
Sort key: dueDate (String)
```

3. Clic en "Create table"

---

## 📝 Paso 2: Crear Función Lambda - Crear Tarea

### 2.1 Acceder al Servicio Lambda

1. En la barra de búsqueda, escribe "Lambda"
2. Selecciona el servicio Lambda

### 2.2 Crear Función

1. Clic en "Create function"
2. Selecciona "Author from scratch"
3. Configura:

**Basic information:**
```
Function name: lab-create-task
Runtime: Python 3.11
Architecture: x86_64
```

**Permissions:**
```
Execution role: Create a new role with basic Lambda permissions
Role name: lab-lambda-execution-role
```

4. Clic en "Create function"

### 2.3 Configurar Código

1. En la pestaña "Code", reemplaza el contenido con:

```python
import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('lab-tasks-table')

def lambda_handler(event, context):
    try:
        # Parsear el body de la request
        body = json.loads(event['body'])
        
        # Crear item
        task_id = str(uuid.uuid4())
        task = {
            'taskId': task_id,
            'title': body.get('title', ''),
            'description': body.get('description', ''),
            'status': body.get('status', 'pending'),
            'dueDate': body.get('dueDate', ''),
            'createdAt': datetime.now().isoformat(),
            'updatedAt': datetime.now().isoformat()
        }
        
        # Guardar en DynamoDB
        table.put_item(Item=task)
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Task created successfully',
                'task': task
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }
```

2. Clic en "Deploy"

### 2.4 Configurar Permisos IAM

1. Ve a la pestaña "Configuration" → "Permissions"
2. Clic en el link del rol "lab-lambda-execution-role"
3. En IAM, ve a "Permissions" → "Add permissions" → "Attach policies"
4. Busca y selecciona "AmazonDynamoDBFullAccess"
5. Clic en "Attach policies"

---

## 📋 Paso 3: Crear Función Lambda - Listar Tareas

### 3.1 Crear Función

1. Vuelve a Lambda → "Create function"
2. Configura:

```
Function name: lab-list-tasks
Runtime: Python 3.11
```

3. Clic en "Create function"

### 3.2 Configurar Código

```python
import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('lab-tasks-table')

def lambda_handler(event, context):
    try:
        # Scan de la tabla (para producción usar query con índices)
        response = table.scan()
        tasks = response.get('Items', [])
        
        # Manejar paginación si hay más items
        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            tasks.extend(response['Items'])
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'tasks': tasks,
                'count': len(tasks)
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }
```

3. Clic en "Deploy"

4. Añade permiso DynamoDB al rol IAM (mismo proceso que antes)

---

## 🔍 Paso 4: Crear Función Lambda - Obtener Tarea

### 4.1 Crear Función

```
Function name: lab-get-task
Runtime: Python 3.11
```

### 4.2 Código

```python
import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('lab-tasks-table')

def lambda_handler(event, context):
    try:
        # Obtener taskId de los path parameters
        task_id = event['pathParameters']['taskId']
        
        response = table.get_item(
            Key={'taskId': task_id}
        )
        
        task = response.get('Item')
        
        if not task:
            return {
                'statusCode': 404,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Task not found'
                })
            }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(task)
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }
```

---

## 🔄 Paso 5: Crear Función Lambda - Actualizar Tarea

### 5.1 Crear Función

```
Function name: lab-update-task
Runtime: Python 3.11
```

### 5.2 Código

```python
import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('lab-tasks-table')

def lambda_handler(event, context):
    try:
        task_id = event['pathParameters']['taskId']
        body = json.loads(event['body'])
        
        # Construir expresión de actualización
        update_expression = "set updatedAt = :updatedAt"
        expression_values = {':updatedAt': datetime.now().isoformat()}
        
        if 'title' in body:
            update_expression += ", title = :title"
            expression_values[':title'] = body['title']
        
        if 'description' in body:
            update_expression += ", description = :description"
            expression_values[':description'] = body['description']
        
        if 'status' in body:
            update_expression += ", status = :status"
            expression_values[':status'] = body['status']
        
        if 'dueDate' in body:
            update_expression += ", dueDate = :dueDate"
            expression_values[':dueDate'] = body['dueDate']
        
        response = table.update_item(
            Key={'taskId': task_id},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_values,
            ReturnValues="ALL_NEW"
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Task updated successfully',
                'task': response['Attributes']
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }
```

---

## 🗑️ Paso 6: Crear Función Lambda - Eliminar Tarea

### 6.1 Crear Función

```
Function name: lab-delete-task
Runtime: Python 3.11
```

### 6.2 Código

```python
import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('lab-tasks-table')

def lambda_handler(event, context):
    try:
        task_id = event['pathParameters']['taskId']
        
        # Verificar que existe antes de eliminar
        response = table.get_item(Key={'taskId': task_id})
        
        if 'Item' not in response:
            return {
                'statusCode': 404,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Task not found'
                })
            }
        
        # Eliminar
        table.delete_item(Key={'taskId': task_id})
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Task deleted successfully',
                'taskId': task_id
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }
```

---

## 🌐 Paso 7: Configurar API Gateway

### 7.1 Crear API REST

1. Busca "API Gateway" en la consola
2. Clic en "Create API"
3. Selecciona "REST API" → "Build"
4. Configura:

```
API name: lab-tasks-api
Endpoint type: Regional
```

5. Clic en "Create API"

### 7.2 Crear Recurso /tasks

1. En el "Resources" panel, clic en "/" (root)
2. Clic en "Create resource"
3. Configura:

```
Resource name: tasks
Resource path: /tasks
```

4. Clic en "Create resource"

### 7.3 Crear Endpoint GET /tasks

1. Selecciona el recurso "/tasks"
2. Clic en "Create method"
3. Selecciona "GET"
4. Configura:

```
Integration type: Lambda function
Lambda function: lab-list-tasks
Use default timeout: ✓
```

5. Clic en "Save"
6. Confirma el diálogo de permisos ("OK")

### 7.4 Crear Endpoint POST /tasks

1. Selecciona "/tasks"
2. Clic en "Create method"
3. Selecciona "POST"
4. Lambda function: "lab-create-task"
5. Clic en "Save"

### 7.5 Crear Recurso con Path Parameter

1. Selecciona "/tasks"
2. Clic en "Create resource"
3. Configura:

```
Resource name: task
Resource path: {taskId}
```

4. Clic en "Create resource"

### 7.6 Crear Endpoints para /tasks/{taskId}

Para el recurso "{taskId}", crea tres métodos:

**GET /tasks/{taskId}:**
- Lambda: lab-get-task

**PUT /tasks/{taskId}:**
- Lambda: lab-update-task

**DELETE /tasks/{taskId}:**
- Lambda: lab-delete-task

### 7.7 Habilitar CORS

1. Selecciona "/tasks"
2. Clic en "Actions" → "Enable CORS"
3. Configura:

```
Access-Control-Allow-Headers: Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token
Access-Control-Allow-Methods: GET,POST,PUT,DELETE,OPTIONS
Access-Control-Allow-Origin: *
```

4. Clic en "Enable CORS and replace existing CORS headers"

5. Repite para "/tasks/{taskId}"

### 7.8 Desplegar API

1. Clic en "Actions" → "Deploy API"
2. Selecciona "[New Stage]"
3. Stage name: `prod`
4. Clic en "Deploy"

5. Copia la "Invoke URL"
   - Ejemplo: `https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod`

---

## 🧪 Paso 8: Probar la API

### 8.1 Crear Tarea (POST)

```bash
# Crear tarea
curl -X POST https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Aprender AWS Lambda",
    "description": "Completar el laboratorio de Lambda",
    "status": "pending",
    "dueDate": "2025-05-01"
  }'

# Respuesta esperada:
# {
#   "message": "Task created successfully",
#   "task": {
#     "taskId": "uuid-generado",
#     "title": "Aprender AWS Lambda",
#     ...
#   }
# }
```

### 8.2 Listar Tareas (GET)

```bash
# Listar todas las tareas
curl https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/tasks

# Respuesta esperada:
# {
#   "tasks": [...],
#   "count": 1
# }
```

### 8.3 Obtener Tarea Específica (GET)

```bash
# Usa el taskId de la creación anterior
curl https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/tasks/TASK-ID-AQUI
```

### 8.4 Actualizar Tarea (PUT)

```bash
curl -X PUT https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/tasks/TASK-ID \
  -H "Content-Type: application/json" \
  -d '{
    "status": "completed"
  }'
```

### 8.5 Eliminar Tarea (DELETE)

```bash
curl -X DELETE https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/tasks/TASK-ID
```

---

## 📊 Paso 9: Monitoreo con CloudWatch

### 9.1 Ver Logs de Lambda

1. Ve a CloudWatch → Logs → Log groups
2. Busca los grupos: `/aws/lambda/lab-*`
3. Explora los logs de cada función

### 9.2 Crear Dashboard

1. CloudWatch → Dashboards → Create dashboard
2. Nombre: `lab-lambda-dashboard`
3. Añade widgets:
   - Lambda invocations
   - Lambda errors
   - Lambda duration
   - DynamoDB read/write capacity

### 9.3 Configurar Alarmas

1. CloudWatch → Alarms → Create alarm
2. Métrica: Lambda Errors
3. Condición: Greater than 5
4. Notificación: Email (via SNS)

---

## 🎯 Bonus: Triggers Adicionales

### 10.1 Trigger S3 (Procesamiento de Archivos)

Crea una Lambda que se ejecute cuando se sube un archivo a S3:

```python
import json
import boto3

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        print(f"Archivo subido: {key} en bucket {bucket}")
        
        # Procesar archivo aquí
    
    return {
        'statusCode': 200,
        'body': json.dumps('Archivo procesado')
    }
```

### 10.2 Trigger EventBridge (Programado)

1. Lambda → "lab-scheduled-task"
2. Clic en "Add trigger"
3. Selecciona "EventBridge (CloudWatch Events)"
4. Rule type: Schedule expression
5. Expression: `rate(1 hour)` o `cron(0 12 * * ? *)`

### 10.3 Trigger SNS (Notificaciones)

1. SNS → Create topic → `lab-notifications`
2. Lambda → Add trigger → SNS
3. Selecciona el topic

---

## ✅ Verificación

- [ ] Tabla DynamoDB creada con índices
- [ ] Función Lambda "create-task" creada y configurada
- [ ] Función Lambda "list-tasks" creada y configurada
- [ ] Función Lambda "get-task" creada y configurada
- [ ] Función Lambda "update-task" creada y configurada
- [ ] Función Lambda "delete-task" creada y configurada
- [ ] API Gateway REST API creada
- [ ] Endpoints configurados: GET, POST, PUT, DELETE
- [ ] CORS habilitado
- [ ] API desplegada en stage 'prod'
- [ ] POST /tasks funciona correctamente
- [ ] GET /tasks funciona correctamente
- [ ] GET /tasks/{taskId} funciona correctamente
- [ ] PUT /tasks/{taskId} funciona correctamente
- [ ] DELETE /tasks/{taskId} funciona correctamente
- [ ] Logs visibles en CloudWatch

---

## 🧹 Limpieza

### Eliminar en Orden

1. **Eliminar API Gateway:**
   - API Gateway → lab-tasks-api → Actions → Delete

2. **Eliminar Funciones Lambda:**
   - Lambda → selecciona cada función → Actions → Delete

3. **Eliminar Roles IAM:**
   - IAM → Roles → lab-lambda-execution-role → Delete

4. **Vaciar y Eliminar Tabla DynamoDB:**
   - DynamoDB → Tables → lab-tasks-table
   - Clic en "Delete"
   - Escribe el nombre para confirmar

5. **Eliminar CloudWatch Logs:**
   - CloudWatch → Log Groups
   - Selecciona `/aws/lambda/lab-*` → Delete

6. **Eliminar Alarmas y Dashboards:**
   - CloudWatch → Alarms → Delete
   - CloudWatch → Dashboards → Delete

---

## 📚 Recursos Adicionales

- [Guía de Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [Guía de API Gateway](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html)
- [Guía de DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html)
- [Serverless Patterns](https://serverlessland.com/patterns)
- [Lambda Limits](https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html)

---

## 🎯 Siguiente Laboratorio

→ [Lab 07: IA/ML con SageMaker](lab-07-ia-sagemaker-basico.md)

---

*Última actualización: Abril 2025*
