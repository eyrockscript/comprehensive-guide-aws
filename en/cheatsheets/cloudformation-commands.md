# Cheatsheet: CloudFormation CLI Commands

## Create Stacks

```bash
# Create basic stack
aws cloudformation create-stack \
    --stack-name my-application \
    --template-body file://template.yaml \
    --tags Key=Environment,Value=Production

# Create with parameters
aws cloudformation create-stack \
    --stack-name my-application \
    --template-body file://template.yaml \
    --parameters \
        ParameterKey=InstanceType,ParameterValue=t3.micro \
        ParameterKey=KeyName,ParameterValue=my-key \
    --tags Key=Environment,Value=Production Key=Team,Value=DevOps

# Create with parameters file
aws cloudformation create-stack \
    --stack-name my-application \
    --template-body file://template.yaml \
    --parameters file://parameters.json

# Create with IAM capabilities
aws cloudformation create-stack \
    --stack-name my-application \
    --template-body file://template.yaml \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM

# Create with transform capabilities (SAM)
aws cloudformation create-stack \
    --stack-name my-lambda-app \
    --template-body file://template.yaml \
    --capabilities CAPABILITY_AUTO_EXPAND

# Create from S3
aws cloudformation create-stack \
    --stack-name my-application \
    --template-url https://s3.amazonaws.com/my-bucket/templates/template.yaml
```

## Update Stacks

```bash
# Update stack
aws cloudformation update-stack \
    --stack-name my-application \
    --template-body file://template.yaml \
    --parameters file://parameters.json

# Change rollback policy
aws cloudformation update-stack \
    --stack-name my-application \
    --template-body file://template.yaml \
    --rollback-configuration RollbackTriggers=[{Arn:arn:aws:sns:us-east-1:123456789012:my-topic,Type:ARN}]

# Update only parameters
aws cloudformation update-stack \
    --stack-name my-application \
    --use-previous-template \
    --parameters \
        ParameterKey=InstanceType,ParameterValue=t3.small \
        ParameterKey=KeyName,UsePreviousValue=true
```

## Create Changes (Change Sets)

```bash
# Create change set
aws cloudformation create-change-set \
    --stack-name my-application \
    --template-body file://template-v2.yaml \
    --change-set-name update-v2 \
    --parameters file://parameters.json

# Create change set for new stack
aws cloudformation create-change-set \
    --stack-name my-application-v2 \
    --template-body file://template.yaml \
    --change-set-name initial-creation \
    --change-set-type CREATE

# Describe change set
aws cloudformation describe-change-set \
    --stack-name my-application \
    --change-set-name update-v2

# List change sets
aws cloudformation list-change-sets --stack-name my-application

# Execute change set
aws cloudformation execute-change-set \
    --stack-name my-application \
    --change-set-name update-v2

# Delete change set
aws cloudformation delete-change-set \
    --stack-name my-application \
    --change-set-name update-v2
```

## Monitor Stacks

```bash
# Describe stack
aws cloudformation describe-stacks --stack-name my-application

# Describe with query
aws cloudformation describe-stacks \
    --stack-name my-application \
    --query 'Stacks[0].Outputs'

# List stacks
aws cloudformation list-stacks

# List active stacks
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE

# List stack resources
aws cloudformation list-stack-resources --stack-name my-application

# Describe specific resource
aws cloudformation describe-stack-resource \
    --stack-name my-application \
    --logical-resource-id MyEC2Instance

# View stack events
aws cloudformation describe-stack-events \
    --stack-name my-application \
    --query 'StackEvents[?ResourceStatus==`CREATE_COMPLETE`].[LogicalResourceId,ResourceStatus,Timestamp]'

# Monitor in real-time
aws cloudformation describe-stack-events \
    --stack-name my-application \
    --query 'StackEvents[].{Resource:LogicalResourceId,Status:ResourceStatus,Time:Timestamp}' \
    --output table
```

## Manage Stacks

```bash
# Delete stack
aws cloudformation delete-stack --stack-name my-application

# Delete with resource retention
aws cloudformation delete-stack \
    --stack-name my-application \
    --retain-resources MyEC2Instance

# Cancel update in progress
aws cloudformation cancel-update-stack --stack-name my-application

# Stop stack set operation
aws cloudformation stop-stack-set-operation \
    --stack-set-name my-stack-set \
    --operation-id operation-001

# Continue rollback (if failed)
aws cloudformation continue-update-rollback --stack-name my-application
```

## Stack Sets

```bash
# Create stack set
aws cloudformation create-stack-set \
    --stack-set-name my-stack-set \
    --template-body file://template.yaml \
    --parameters ParameterKey=Environment,ParameterValue=Production

# Create instances in accounts/regions
aws cloudformation create-stack-instances \
    --stack-set-name my-stack-set \
    --accounts 123456789012 123456789013 \
    --regions us-east-1 us-west-2

# Update stack set
aws cloudformation update-stack-set \
    --stack-set-name my-stack-set \
    --template-body file://template-v2.yaml

# Delete instances
aws cloudformation delete-stack-instances \
    --stack-set-name my-stack-set \
    --accounts 123456789012 \
    --regions us-west-2 \
    --no-retain-stacks

# Delete stack set
aws cloudformation delete-stack-set --stack-set-name my-stack-set

# Describe operation
aws cloudformation describe-stack-set-operation \
    --stack-set-name my-stack-set \
    --operation-id operation-001
```

## Validate and Preview

```bash
# Validate template
aws cloudformation validate-template --template-body file://template.yaml

# Validate from S3
aws cloudformation validate-template \
    --template-url https://s3.amazonaws.com/my-bucket/templates/template.yaml

# Estimate costs (requires template with Metadata)
aws cloudformation estimate-template-cost \
    --template-body file://template.yaml \
    --parameters ParameterKey=InstanceType,ParameterValue=t3.micro

# Detect drift
aws cloudformation detect-stack-drift --stack-name my-application

# Describe drift
aws cloudformation describe-stack-drift-detection-status \
    --stack-drift-detection-id 12345678-1234-1234-1234-123456789012

# Detect resource drift
aws cloudformation detect-stack-resource-drift \
    --stack-name my-application \
    --logical-resource-id MyEC2Instance
```

## Exports and Imports

```bash
# List exports
aws cloudformation list-exports

# List with filter
aws cloudformation list-exports --query 'Exports[?Name==`VPCId`].Value'

# List imports of an export
aws cloudformation list-imports --export-name VPCId
```

## Stack Policy

```bash
# Create stack policy
aws cloudformation set-stack-policy \
    --stack-name my-application \
    --stack-policy-body file://stack-policy.json

# Deny all updates (stack policy example)
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

# Allow update with override during update-stack
aws cloudformation update-stack \
    --stack-name my-application \
    --template-body file://template.yaml \
    --stack-policy-during-update-body file://allow-update-policy.json
```

## Waiters

```bash
# Wait for stack to complete
aws cloudformation wait stack-create-complete --stack-name my-application
aws cloudformation wait stack-update-complete --stack-name my-application
aws cloudformation wait stack-delete-complete --stack-name my-application

# In scripts
aws cloudformation create-stack \
    --stack-name my-application \
    --template-body file://template.yaml

aws cloudformation wait stack-create-complete \
    --stack-name my-application

echo "Stack created successfully"
```

## Tags and Metadata

```bash
# Update tags
aws cloudformation update-stack \
    --stack-name my-application \
    --use-previous-template \
    --tags \
        Key=Environment,Value=Staging \
        Key=UpdatedBy,Value=DevOps

# List resources with tags
aws cloudformation list-stack-resources \
    --stack-name my-application \
    --query 'StackResourceSummaries[].{Resource:LogicalResourceId,Type:ResourceType}'
```

## Example: Basic Template

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Basic EC2 Instance'

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
    Description: Key pair name

Resources:
  MyInstance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0c55b159cbfafe1f0
      InstanceType: !Ref InstanceType
      KeyName: !Ref KeyName
      Tags:
        - Key: Name
          Value: MyServer

Outputs:
  InstanceId:
    Description: Instance ID
    Value: !Ref MyInstance
  PublicIP:
    Description: Public IP
    Value: !GetAtt MyInstance.PublicIp
```

## Example: Parameters File

```json
[
  {
    "ParameterKey": "InstanceType",
    "ParameterValue": "t3.small"
  },
  {
    "ParameterKey": "KeyName",
    "ParameterValue": "my-ssh-key"
  },
  {
    "ParameterKey": "Environment",
    "ParameterValue": "production"
  }
]
```

## Useful Commands

```bash
# Get stack outputs
aws cloudformation describe-stacks \
    --stack-name my-application \
    --query 'Stacks[0].Outputs[?OutputKey==`InstanceId`].OutputValue' \
    --output text

# Search stacks by tag
aws cloudformation list-stacks \
    --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
    | jq '.StackSummaries[] | select(.Tags[]? | .Key=="Environment" and .Value=="Production")'

# Get stack template
aws cloudformation get-template --stack-name my-application

# Resources summary
aws cloudformation list-stack-resources \
    --stack-name my-application \
    --query 'StackResourceSummaries[].{Logical:LogicalResourceId,Physical:PhysicalResourceId,Type:ResourceType,Status:ResourceStatus}'
```

## Quick Tips

| Task | Command |
|------|---------|
| Create stack | `aws cloudformation create-stack --stack-name <name> --template-body file://template.yaml` |
| Update stack | `aws cloudformation update-stack --stack-name <name> --template-body file://template.yaml` |
| Delete stack | `aws cloudformation delete-stack --stack-name <name>` |
| View status | `aws cloudformation describe-stacks --stack-name <name> --query 'Stacks[0].StackStatus'` |
| Validate template | `aws cloudformation validate-template --template-body file://template.yaml` |
| Create change set | `aws cloudformation create-change-set --stack-name <name> --change-set-name <name>` |
| View events | `aws cloudformation describe-stack-events --stack-name <name>` |

## Best Practices

```bash
# Always use change sets for production
aws cloudformation create-change-set \
    --stack-name my-application \
    --template-body file://template.yaml \
    --change-set-name change-$(date +%Y%m%d-%H%M%S)

# Review before executing
aws cloudformation describe-change-set \
    --stack-name my-application \
    --change-set-name change-20240101-120000

# Execute only after review
aws cloudformation execute-change-set \
    --stack-name my-application \
    --change-set-name change-20240101-120000
```
