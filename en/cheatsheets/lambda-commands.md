# Cheatsheet: Lambda CLI Commands

## Create Lambda Functions

### Basic Function (Node.js)

```bash
# Create function with inline code
aws lambda create-function \
    --function-name my-function-node \
    --runtime nodejs18.x \
    --handler index.handler \
    --role arn:aws:iam::123456789012:role/lambda-execution-role \
    --zip-file fileb://function.zip

# Create function with environment variables
aws lambda create-function \
    --function-name my-function-env \
    --runtime nodejs18.x \
    --handler index.handler \
    --role arn:aws:iam::123456789012:role/lambda-execution-role \
    --zip-file fileb://function.zip \
    --environment Variables={ENV=production,DEBUG=false} \
    --timeout 30 \
    --memory-size 512
```

### Python Function

```bash
aws lambda create-function \
    --function-name my-function-python \
    --runtime python3.11 \
    --handler lambda_function.handler \
    --role arn:aws:iam::123456789012:role/lambda-execution-role \
    --zip-file fileb://function.zip \
    --description "Python processing function"
```

### Function with VPC

```bash
aws lambda create-function \
    --function-name my-function-vpc \
    --runtime python3.11 \
    --handler lambda_function.handler \
    --role arn:aws:iam::123456789012:role/lambda-vpc-role \
    --zip-file fileb://function.zip \
    --vpc-config SubnetIds=subnet-12345678,subnet-87654321,SecurityGroupIds=sg-12345678
```

## Manage Functions

```bash
# List functions
aws lambda list-functions

# List with pagination
aws lambda list-functions --max-items 50

# Get function details
aws lambda get-function --function-name my-function-node

# Get configuration
aws lambda get-function-configuration --function-name my-function-node

# Update code
aws lambda update-function-code \
    --function-name my-function-node \
    --zip-file fileb://function-v2.zip

# Update configuration
aws lambda update-function-configuration \
    --function-name my-function-node \
    --timeout 60 \
    --memory-size 1024 \
    --environment Variables={ENV=staging,DEBUG=true}

# Delete function
aws lambda delete-function --function-name my-function-node
```

## Invoke Functions

```bash
# Synchronous invocation
aws lambda invoke \
    --function-name my-function-node \
    --payload '{"name":"John","id":123}' \
    response.json

# Asynchronous invocation
aws lambda invoke \
    --function-name my-function-node \
    --invocation-type Event \
    --payload '{"action":"process"}' \
    /dev/null

# Invoke with logs
aws lambda invoke \
    --function-name my-function-node \
    --log-type Tail \
    --payload '{"test":true}' \
    response.json \
    --query 'LogResult' --output text | base64 -d
```

## Versions and Aliases

```bash
# Publish version
aws lambda publish-version \
    --function-name my-function-node \
    --description "Stable version v1.0"

# List versions
aws lambda list-versions-by-function \
    --function-name my-function-node

# Create alias
aws lambda create-alias \
    --function-name my-function-node \
    --name prod \
    --function-version 1 \
    --description "Production environment"

# Create alias with routing (canary)
aws lambda create-alias \
    --function-name my-function-node \
    --name beta \
    --function-version 2 \
    --routing-config AdditionalVersionWeights={1=0.1}

# Update alias
aws lambda update-alias \
    --function-name my-function-node \
    --name prod \
    --function-version 2

# Delete alias
aws lambda delete-alias \
    --function-name my-function-node \
    --name beta
```

## Permissions (Resource Policy)

```bash
# Allow invocation from S3
aws lambda add-permission \
    --function-name my-function-node \
    --statement-id s3-invoke \
    --action lambda:InvokeFunction \
    --principal s3.amazonaws.com \
    --source-arn arn:aws:s3:::my-bucket

# Allow invocation from API Gateway
aws lambda add-permission \
    --function-name my-function-node \
    --statement-id apigateway-invoke \
    --action lambda:InvokeFunction \
    --principal apigateway.amazonaws.com \
    --source-arn "arn:aws:execute-api:us-east-1:123456789012:abc123/*/POST/process"

# Allow invocation from SNS
aws lambda add-permission \
    --function-name my-function-node \
    --statement-id sns-invoke \
    --action lambda:InvokeFunction \
    --principal sns.amazonaws.com \
    --source-arn arn:aws:sns:us-east-1:123456789012:my-topic

# View policy
aws lambda get-policy --function-name my-function-node

# Remove permission
aws lambda remove-permission \
    --function-name my-function-node \
    --statement-id s3-invoke
```

## Event Source Mapping (Triggers)

```bash
# Create mapping with SQS
aws lambda create-event-source-mapping \
    --function-name my-function-node \
    --event-source-arn arn:aws:sqs:us-east-1:123456789012:my-queue \
    --batch-size 10

# Create mapping with DynamoDB Streams
aws lambda create-event-source-mapping \
    --function-name my-function-node \
    --event-source-arn arn:aws:dynamodb:us-east-1:123456789012:table/my-table/stream/2024-01-01T00:00:00.000 \
    --starting-position LATEST \
    --batch-size 100

# Create mapping with Kinesis
aws lambda create-event-source-mapping \
    --function-name my-function-node \
    --event-source-arn arn:aws:kinesis:us-east-1:123456789012:stream/my-stream \
    --starting-position TRIM_HORIZON \
    --batch-size 500

# List mappings
aws lambda list-event-source-mappings \
    --function-name my-function-node

# Update mapping
aws lambda update-event-source-mapping \
    --uuid 12345678-1234-1234-1234-123456789012 \
    --batch-size 50 \
    --maximum-batching-window-in-seconds 30

# Delete mapping
aws lambda delete-event-source-mapping \
    --uuid 12345678-1234-1234-1234-123456789012
```

## Layers

```bash
# Publish layer
aws lambda publish-layer-version \
    --layer-name my-library \
    --description "Common libraries" \
    --license-info "MIT" \
    --zip-file fileb://layer.zip \
    --compatible-runtimes nodejs18.x nodejs20.x

# List layers
aws lambda list-layers

# List layer versions
aws lambda list-layer-versions --layer-name my-library

# Get layer details
aws lambda get-layer-version \
    --layer-name my-library \
    --version-number 1

# Add layer to function
aws lambda update-function-configuration \
    --function-name my-function-node \
    --layers arn:aws:lambda:us-east-1:123456789012:layer:my-library:1

# Delete layer version
aws lambda delete-layer-version \
    --layer-name my-library \
    --version-number 1
```

## Concurrency and Provisioned Concurrency

```bash
# Set reserved concurrency
aws lambda put-function-concurrency \
    --function-name my-function-node \
    --reserved-concurrent-executions 100

# Remove reserved concurrency
aws lambda delete-function-concurrency \
    --function-name my-function-node

# Set provisioned concurrency
aws lambda put-provisioned-concurrency-config \
    --function-name my-function-node \
    --qualifier prod \
    --provisioned-concurrent-executions 50

# Get provisioned concurrency config
aws lambda get-provisioned-concurrency-config \
    --function-name my-function-node \
    --qualifier prod

# Delete provisioned concurrency
aws lambda delete-provisioned-concurrency-config \
    --function-name my-function-node \
    --qualifier prod
```

## Logs and Monitoring

```bash
# View logs in CloudWatch (requires awslogs or similar)
aws logs tail /aws/lambda/my-function-node --follow

# Invocation statistics
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Invocations \
    --dimensions Name=FunctionName,Value=my-function-node \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Sum

# Errors
aws cloudwatch get-metric-statistics \
    --namespace AWS/Lambda \
    --metric-name Errors \
    --dimensions Name=FunctionName,Value=my-function-node \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Sum
```

## Tags

```bash
# Add tags
aws lambda tag-resource \
    --resource arn:aws:lambda:us-east-1:123456789012:function:my-function-node \
    --tags Environment=production,Team=backend,Project=ecommerce

# List tags
aws lambda list-tags \
    --resource arn:aws:lambda:us-east-1:123456789012:function:my-function-node

# Remove tags
aws lambda untag-resource \
    --resource arn:aws:lambda:us-east-1:123456789012:function:my-function-node \
    --tag-keys Team
```

## Quick Tips

| Task | Command |
|------|---------|
| View functions | `aws lambda list-functions` |
| Invoke function | `aws lambda invoke --function-name <name> --payload '{}' response.json` |
| View logs | `aws logs tail /aws/lambda/<function-name>` |
| Publish version | `aws lambda publish-version --function-name <name>` |
| Create alias | `aws lambda create-alias --function-name <name> --name prod --function-version 1` |
| Update code | `aws lambda update-function-code --function-name <name> --zip-file fileb://function.zip` |

## Example: Package and Deploy

```bash
# Project structure
# my-project/
# ├── index.js
# └── package.json

# Install dependencies
npm install

# Create deployment package
zip -r function.zip index.js node_modules/

# Deploy
aws lambda update-function-code \
    --function-name my-function-node \
    --zip-file fileb://function.zip

# Clean up
rm function.zip
```

## Example: Python Function with Dependencies

```bash
# Structure
# project/
# ├── lambda_function.py
# └── requirements.txt

# Create package directory
mkdir package
pip install -r requirements.txt -t package/

# Copy source code
cp lambda_function.py package/

# Create ZIP
cd package && zip -r ../function.zip . && cd ..

# Deploy
aws lambda update-function-code \
    --function-name my-function-python \
    --zip-file fileb://function.zip
```
