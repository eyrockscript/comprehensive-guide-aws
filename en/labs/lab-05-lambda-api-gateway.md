# Lab 5: Serverless API with Lambda and API Gateway

## Objective
Create a serverless REST API using Lambda, API Gateway, and DynamoDB.

## Estimated Duration
60-75 minutes

## Architecture
```
Client → API Gateway → Lambda → DynamoDB
```

## Instructions

### Step 1: Create DynamoDB Table
```bash
aws dynamodb create-table \
    --table-name Tasks \
    --attribute-definitions AttributeName=id,AttributeType=S \
    --key-schema AttributeName=id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --tags Key=Environment,Value=Lab
```

### Step 2: Create IAM Role for Lambda
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

### Step 3: Create Lambda Functions
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

### Step 4: Create API Gateway
```bash
aws apigateway create-rest-api \
    --name 'TasksAPI' \
    --description 'API for task management'

# Create resources and methods
aws apigateway create-resource \
    --rest-api-id abc123 \
    --parent-id xyz789 \
    --path-part tasks
```

### Step 5: Deploy API
```bash
aws apigateway create-deployment \
    --rest-api-id abc123 \
    --stage-name prod
```

## Testing
```bash
# Create task
curl -X POST https://xxx.execute-api.region.amazonaws.com/prod/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Complete lab", "status": "pending"}'

# Get tasks
curl https://xxx.execute-api.region.amazonaws.com/prod/tasks
```

## Additional Challenges
1. Add authentication with Cognito
2. Implement request validation
3. Configure throttling and usage plans
4. Implement caching
5. Use Step Functions for complex flows

## Monitoring
```bash
# View Lambda metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Duration \
    --dimensions Name=FunctionName,Value=GetTasks \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Average
```

## Cleanup
1. Delete API Gateway
2. Delete Lambda functions
3. Delete DynamoDB table
4. Delete IAM role
