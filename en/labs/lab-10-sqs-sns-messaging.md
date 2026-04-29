# Lab 10: Messaging with SQS and SNS

## Objective
Implement asynchronous messaging patterns using SQS and SNS.

## Estimated Duration
60 minutes

## Architecture
```
Publisher → SNS Topic → [SQS Queue 1, SQS Queue 2, Lambda, Email]
```

## Instructions

### Step 1: Create SQS Queues
```bash
# Standard queue
aws sqs create-queue \
    --queue-name orders-queue \
    --attributes '{
        "VisibilityTimeout": "300",
        "MessageRetentionPeriod": "86400",
        "DelaySeconds": "0",
        "ReceiveMessageWaitTimeSeconds": "20"
    }'

# FIFO queue (for guaranteed ordering)
aws sqs create-queue \
    --queue-name payments-queue.fifo \
    --attributes '{
        "FifoQueue": "true",
        "ContentBasedDeduplication": "true"
    }'

# Dead Letter Queue
aws sqs create-queue --queue-name orders-dlq
```

### Step 2: Configure DLQ
```bash
# Get DLQ ARN
DLQ_URL=$(aws sqs get-queue-url --queue-name orders-dlq --query QueueUrl --output text)
DLQ_ARN=$(aws sqs get-queue-attributes --queue-url $DLQ_URL --attribute-names QueueArn --query Attributes.QueueArn --output text)

# Configure redrive policy on main queue
aws sqs set-queue-attributes \
    --queue-url $(aws sqs get-queue-url --queue-name orders-queue --query QueueUrl --output text) \
    --attributes '{
        "RedrivePolicy": "{\"deadLetterTargetArn\":\"'$DLQ_ARN'\",\"maxReceiveCount\":3}"
    }'
```

### Step 3: Create SNS Topic
```bash
aws sns create-topic --name orders-topic

aws sns set-topic-attributes \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --attribute-name DisplayName \
    --attribute-value Orders
```

### Step 4: Subscribe Destinations to Topic
```bash
# Subscribe SQS queue
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --protocol sqs \
    --notification-endpoint arn:aws:sqs:us-east-1:xxx:orders-queue

# Subscribe Lambda function
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --protocol lambda \
    --notification-endpoint arn:aws:lambda:us-east-1:xxx:function:process-order

# Subscribe email (requires confirmation)
aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --protocol email \
    --notification-endpoint admin@example.com
```

### Step 5: Configure Message Filters
```bash
# Add filter to SQS subscription
aws sns set-subscription-attributes \
    --subscription-arn arn:aws:sns:us-east-1:xxx:orders-topic:subscription-id \
    --attribute-name FilterPolicy \
    --attribute-value '{"orderType": ["express", "priority"]}'
```

### Step 6: Create Lambda Processor Function
```python
import json
import boto3

def lambda_handler(event, context):
    for record in event['Records']:
        # Process SQS message
        message = json.loads(record['body'])
        print(f"Processing order: {message['orderId']}")
        
        # Business logic here
        process_order(message)
        
    return {
        'statusCode': 200,
        'body': json.dumps('Orders processed successfully')
    }

def process_order(order):
    # Implement processing logic
    pass
```

### Step 7: Publish Messages
```bash
# Publish to SNS
aws sns publish \
    --topic-arn arn:aws:sns:us-east-1:xxx:orders-topic \
    --message '{"orderId": "12345", "orderType": "express", "amount": 99.99}' \
    --message-attributes 'orderType={DataType=String,StringValue=express}'

# Send directly to SQS
aws sqs send-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/xxx/orders-queue \
    --message-body '{"orderId": "67890", "status": "pending"}' \
    --delay-seconds 300

# Send to FIFO queue
aws sqs send-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/xxx/payments-queue.fifo \
    --message-body '{"paymentId": "pay-123", "amount": 50.00}' \
    --message-group-id payment-group-1 \
    --message-deduplication-id payment-123
```

### Step 8: Consume Messages
```bash
# Receive messages
aws sqs receive-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/xxx/orders-queue \
    --max-number-of-messages 10 \
    --visibility-timeout 300 \
    --wait-time-seconds 20

# Delete processed messages
aws sqs delete-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/xxx/orders-queue \
    --receipt-handle <receipt-handle>
```

## Testing
1. Publish messages to SNS topic
2. Verify arrival to all subscriptions
3. Simulate failures and verify DLQ
4. Test FIFO ordering

## Additional Challenges
1. Implement SQS Extended Client for large messages
2. Configure Event Source Mapping for Lambda
3. Use Step Functions for orchestration
4. Implement message replay with S3

## Monitoring
```bash
# View SQS metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/SQS \
    --metric-name ApproximateNumberOfMessagesVisible \
    --dimensions Name=QueueName,Value=orders-queue \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Average
```

## Cleanup
1. Delete SNS subscriptions
2. Delete SNS topic
3. Purge and delete SQS queues
4. Delete Lambda function
