# Laboratorio 10: Mensajería con SQS y SNS

## Objetivo
Implementar patrones de mensajería asíncrona usando SQS y SNS.

## Duración Estimada
60 minutos

## Arquitectura
```
Publisher → SNS Topic → [SQS Queue 1, SQS Queue 2, Lambda, Email]
```

## Instrucciones

### Paso 1: Crear Colas SQS
```bash
# Cola estándar
aws sqs create-queue \
    --queue-name orders-queue \
    --attributes '{
        "VisibilityTimeout": "300",
        "MessageRetentionPeriod": "86400",
        "DelaySeconds": "0",
        "ReceiveMessageWaitTimeSeconds": "20"
    }'

# Cola FIFO (para orden garantizado)
aws sqs create-queue \
    --queue-name payments-queue.fifo \
    --attributes '{
        "FifoQueue": "true",
        "ContentBasedDeduplication": "true"
    }'

# Dead Letter Queue
aws sqs create-queue --queue-name orders-dlq
```

### Paso 2: Configurar DLQ
```bash
# Obtener ARN de la DLQ
DLQ_URL=$(aws sqs get-queue-url --queue-name orders-dlq --query QueueUrl --output text)
DLQ_ARN=$(aws sqs get-queue-attributes --queue-url $DLQ_URL --attribute-names QueueArn --query Attributes.QueueArn --output text)

# Configurar redrive policy en cola principal
aws sqs set-queue-attributes \
    --queue-url $(aws sqs get-queue-url --queue-name orders-queue --query QueueUrl --output text) \
    --attributes '{
        "RedrivePolicy": "{\"deadLetterTargetArn\":\"'$DLQ_ARN'\",\"maxReceiveCount\":3}"
    }'
```

### Paso 3: Crear Tema SNS
```bash
aws sns create-topic --name orders-topic

aws sns set-topic-attributes \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --attribute-name DisplayName \
    --attribute-value Orders
```

### Paso 4: Suscribir Destinos al Tema
```bash
# Suscribir cola SQS
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:us-east-1:xxx:orders-queue

# Suscribir función Lambda
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --protocol lambda \
    --notification-endpoint arn:aws:lambda:us-east-1:xxx:function:process-order

# Suscribir email (requiere confirmación)
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --protocol email \
    --notification-endpoint admin@example.com
```

### Paso 5: Configurar Filtros de Mensajes
```bash
# Agregar filtro a suscripción SQS
aws sns set-subscription-attributes \
    --subscription-arn arn:aws:sns:us-east-1:xxx:orders-topic:subscription-id \
    --attribute-name FilterPolicy \
    --attribute-value '{"orderType": ["express", "priority"]}'
```

### Paso 6: Crear Función Lambda Procesadora
```python
import json
import boto3

def lambda_handler(event, context):
    for record in event['Records']:
        # Procesar mensaje de SQS
        message = json.loads(record['body'])
        print(f"Processing order: {message['orderId']}")
        
        # Lógica de negocio aquí
        process_order(message)
        
    return {
        'statusCode': 200,
        'body': json.dumps('Orders processed successfully')
    }

def process_order(order):
    # Implementar lógica de procesamiento
    pass
```

### Paso 7: Publicar Mensajes
```bash
# Publicar a SNS
aws sns publish \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --message '{"orderId": "12345", "orderType": "express", "amount": 99.99}' \
    --message-attributes 'orderType={DataType=String,StringValue=express}'

# Enviar directamente a SQS
aws sqs send-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/xxx/orders-queue \
    --message-body '{"orderId": "67890", "status": "pending"}' \
    --delay-seconds 300

# Enviar a cola FIFO
aws sqs send-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/xxx/payments-queue.fifo \
    --message-body '{"paymentId": "pay-123", "amount": 50.00}' \
    --message-group-id payment-group-1 \
    --message-deduplication-id payment-123
```

### Paso 8: Consumir Mensajes
```bash
# Recibir mensajes
aws sqs receive-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/xxx/orders-queue \
    --max-number-of-messages 10 \
    --visibility-timeout 300 \
    --wait-time-seconds 20

# Eliminar mensajes procesados
aws sqs delete-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/xxx/orders-queue \
    --receipt-handle <receipt-handle>
```

## Pruebas
1. Publicar mensajes al tema SNS
2. Verificar llegada a todas las suscripciones
3. Simular fallas y verificar DLQ
4. Probar ordenamiento FIFO

## Retos Adicionales
1. Implementar SQS Extended Client para mensajes grandes
2. Configurar Event Source Mapping para Lambda
3. Usar Step Functions para orquestación
4. Implementar message replay con S3

## Monitoreo
```bash
# Ver métricas de SQS
aws cloudwatch get-metric-statistics \
    --namespace AWS/SQS \
    --metric-name ApproximateNumberOfMessagesVisible \
    --dimensions Name=QueueName,Value=orders-queue \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Average
```

## Limpieza
1. Eliminar suscripciones SNS
2. Eliminar tema SNS
3. Purgar y eliminar colas SQS
4. Eliminar Lambda function
