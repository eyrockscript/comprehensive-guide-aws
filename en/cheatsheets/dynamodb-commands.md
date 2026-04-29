# Cheatsheet: DynamoDB CLI Commands

## Basic CRUD Operations

### Create Table

```bash
# Simple table with partition key
aws dynamodb create-table \
    --table-name Users \
    --attribute-definitions AttributeName=user_id,AttributeType=S \
    --key-schema AttributeName=user_id,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST

# Table with composite key (partition + sort)
aws dynamodb create-table \
    --table-name Orders \
    --attribute-definitions \
        AttributeName=user_id,AttributeType=S \
        AttributeName=order_id,AttributeType=S \
    --key-schema \
        AttributeName=user_id,KeyType=HASH \
        AttributeName=order_id,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST

# Table with provisioned capacity
aws dynamodb create-table \
    --table-name Products \
    --attribute-definitions AttributeName=product_id,AttributeType=S \
    --key-schema AttributeName=product_id,KeyType=HASH \
    --billing-mode PROVISIONED \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Table with global secondary index (GSI)
aws dynamodb create-table \
    --table-name Employees \
    --attribute-definitions \
        AttributeName=department,AttributeType=S \
        AttributeName=employee_id,AttributeType=S \
        AttributeName=email,AttributeType=S \
    --key-schema \
        AttributeName=department,KeyType=HASH \
        AttributeName=employee_id,KeyType=RANGE \
    --global-secondary-indexes \
        'IndexName=EmailIndex,KeySchema=[{AttributeName=email,KeyType=HASH}],Projection={ProjectionType=ALL},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}' \
    --billing-mode PROVISIONED \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### Insert Items

```bash
# Insert simple item
aws dynamodb put-item \
    --table-name Users \
    --item '{
        "user_id": {"S": "user-001"},
        "name": {"S": "John Doe"},
        "email": {"S": "john@example.com"},
        "age": {"N": "30"},
        "active": {"BOOL": true},
        "interests": {"SS": ["technology", "sports", "music"]}
    }'

# Insert with condition (don't overwrite if exists)
aws dynamodb put-item \
    --table-name Users \
    --item '{
        "user_id": {"S": "user-002"},
        "name": {"S": "Jane Smith"}
    }' \
    --condition-expression "attribute_not_exists(user_id)"
```

### Get Items

```bash
# Get by primary key
aws dynamodb get-item \
    --table-name Users \
    --key '{"user_id": {"S": "user-001"}}'

# Get with projection (specific fields only)
aws dynamodb get-item \
    --table-name Users \
    --key '{"user_id": {"S": "user-001"}}' \
    --projection-expression "name, email"

# Get with strong consistency
aws dynamodb get-item \
    --table-name Users \
    --key '{"user_id": {"S": "user-001"}}' \
    --consistent-read
```

### Update Items

```bash
# Update specific attribute
aws dynamodb update-item \
    --table-name Users \
    --key '{"user_id": {"S": "user-001"}}' \
    --update-expression "SET age = :age" \
    --expression-attribute-values '{":age": {"N": "31"}}'

# Increment numeric value
aws dynamodb update-item \
    --table-name Products \
    --key '{"product_id": {"S": "prod-001"}}' \
    --update-expression "SET stock = stock - :quantity" \
    --expression-attribute-values '{":quantity": {"N": "1"}}'

# Add to list
aws dynamodb update-item \
    --table-name Users \
    --key '{"user_id": {"S": "user-001"}}' \
    --update-expression "SET interests = list_append(interests, :new)" \
    --expression-attribute-values '{":new": {"L": [{"S": "travel"}]}}'

# Remove attribute
aws dynamodb update-item \
    --table-name Users \
    --key '{"user_id": {"S": "user-001"}}' \
    --update-expression "REMOVE age"

# Conditional update
aws dynamodb update-item \
    --table-name Products \
    --key '{"product_id": {"S": "prod-001"}}' \
    --update-expression "SET price = :new_price" \
    --condition-expression "price = :current_price" \
    --expression-attribute-values '{
        ":new_price": {"N": "99.99"},
        ":current_price": {"N": "120.00"}
    }'
```

### Delete Items

```bash
# Delete by key
aws dynamodb delete-item \
    --table-name Users \
    --key '{"user_id": {"S": "user-001"}}'

# Conditional delete
aws dynamodb delete-item \
    --table-name Products \
    --key '{"product_id": {"S": "prod-001"}}' \
    --condition-expression "stock = :stock" \
    --expression-attribute-values '{":stock": {"N": "0"}}'
```

## Queries and Scans

### Query (Key Search)

```bash
# Query by partition key
aws dynamodb query \
    --table-name Orders \
    --key-condition-expression "user_id = :uid" \
    --expression-attribute-values '{":uid": {"S": "user-001"}}'

# Query with range (between)
aws dynamodb query \
    --table-name Orders \
    --key-condition-expression "user_id = :uid AND order_id BETWEEN :start AND :end" \
    --expression-attribute-values '{
        ":uid": {"S": "user-001"},
        ":start": {"S": "2024-01-01"},
        ":end": {"S": "2024-12-31"}
    }'

# Query with descending order
aws dynamodb query \
    --table-name Orders \
    --key-condition-expression "user_id = :uid" \
    --expression-attribute-values '{":uid": {"S": "user-001"}}' \
    --scan-index-forward false \
    --limit 10

# Query on secondary index
aws dynamodb query \
    --table-name Employees \
    --index-name EmailIndex \
    --key-condition-expression "email = :email" \
    --expression-attribute-values '{":email": {"S": "john@company.com"}}'
```

### Scan (Full Table Scan)

```bash
# Full scan
aws dynamodb scan \
    --table-name Users

# Scan with filter
aws dynamodb scan \
    --table-name Users \
    --filter-expression "age > :age" \
    --expression-attribute-values '{":age": {"N": "25"}}'

# Paginated scan
aws dynamodb scan \
    --table-name Users \
    --limit 100

# Scan with projection
aws dynamodb scan \
    --table-name Users \
    --projection-expression "user_id, name"
```

## Batch Operations

```bash
# Batch Get
aws dynamodb batch-get-item \
    --request-items '{
        "Users": {
            "Keys": [
                {"user_id": {"S": "user-001"}},
                {"user_id": {"S": "user-002"}},
                {"user_id": {"S": "user-003"}}
            ]
        }
    }'

# Batch Write (put + delete)
aws dynamodb batch-write-item \
    --request-items '{
        "Users": [
            {
                "PutRequest": {
                    "Item": {
                        "user_id": {"S": "user-004"},
                        "name": {"S": "Carlos Ruiz"}
                    }
                }
            },
            {
                "DeleteRequest": {
                    "Key": {
                        "user_id": {"S": "user-005"}
                    }
                }
            }
        ]
    }'
```

## Table Management

```bash
# List tables
aws dynamodb list-tables

# Describe table
aws dynamodb describe-table --table-name Users

# Update throughput
aws dynamodb update-table \
    --table-name Products \
    --provisioned-throughput ReadCapacityUnits=10,WriteCapacityUnits=10

# Enable TTL
aws dynamodb update-time-to-live \
    --table-name Sessions \
    --time-to-live-specification Enabled=true,AttributeName=expires_at

# Describe TTL
aws dynamodb describe-time-to-live --table-name Sessions

# Create global secondary index
aws dynamodb update-table \
    --table-name Orders \
    --attribute-definitions AttributeName=status,AttributeType=S \
    --global-secondary-index-updates '{
        "Create": {
            "IndexName": "StatusIndex",
            "KeySchema": [{"AttributeName": "status", "KeyType": "HASH"}],
            "Projection": {"ProjectionType": "ALL"},
            "ProvisionedThroughput": {
                "ReadCapacityUnits": 5,
                "WriteCapacityUnits": 5
            }
        }
    }'

# Delete secondary index
aws dynamodb update-table \
    --table-name Orders \
    --global-secondary-index-updates '{
        "Delete": {"IndexName": "StatusIndex"}
    }'

# Enable Point-in-Time Recovery
aws dynamodb update-continuous-backups \
    --table-name Users \
    --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true

# Delete table
aws dynamodb delete-table --table-name Users
```

## Transactions

```bash
# TransactWrite (multiple atomic operations)
aws dynamodb transact-write-items \
    --transact-items '{
        "TransactItems": [
            {
                "Put": {
                    "TableName": "Orders",
                    "Item": {
                        "user_id": {"S": "user-001"},
                        "order_id": {"S": "order-001"},
                        "total": {"N": "100.00"}
                    }
                }
            },
            {
                "Update": {
                    "TableName": "Products",
                    "Key": {"product_id": {"S": "prod-001"}},
                    "UpdateExpression": "SET stock = stock - :quantity",
                    "ExpressionAttributeValues": {":quantity": {"N": "1"}}
                }
            }
        ]
    }'

# TransactGet
aws dynamodb transact-get-items \
    --transact-items '{
        "TransactItems": [
            {
                "Get": {
                    "TableName": "Users",
                    "Key": {"user_id": {"S": "user-001"}}
                }
            },
            {
                "Get": {
                    "TableName": "Orders",
                    "Key": {
                        "user_id": {"S": "user-001"},
                        "order_id": {"S": "order-001"}
                    }
                }
            }
        ]
    }'
```

## Backups and Restoration

```bash
# Create on-demand backup
aws dynamodb create-backup \
    --table-name Users \
    --backup-name users-backup-2024

# List backups
aws dynamodb list-backups

# Describe backup
aws dynamodb describe-backup --backup-arn arn:aws:dynamodb:us-east-1:123456789012:table/Users/backup/12345678-1234-1234-1234-123456789012

# Restore from backup
aws dynamodb restore-table-from-backup \
    --target-table-name Users-Restored \
    --backup-arn arn:aws:dynamodb:us-east-1:123456789012:table/Users/backup/12345678-1234-1234-1234-123456789012

# Export to S3
aws dynamodb export-table-to-point-in-time \
    --table-arn arn:aws:dynamodb:us-east-1:123456789012:table/Users \
    --s3-bucket my-exports-bucket \
    --s3-prefix dynamodb/ \
    --export-format DYNAMODB_JSON

# Import from S3
aws dynamodb import-table \
    --s3-bucket-source S3Bucket=my-exports-bucket,S3KeyPrefix=dynamodb/ \
    --input-format DYNAMODB_JSON \
    --table-name Users-Imported
```

## Quick Tips

| Task | Command |
|------|---------|
| Create table | `aws dynamodb create-table --table-name <name> --attribute-definitions ... --key-schema ...` |
| Insert item | `aws dynamodb put-item --table-name <name> --item '<json>'` |
| Get item | `aws dynamodb get-item --table-name <name> --key '<json>'` |
| Query | `aws dynamodb query --table-name <name> --key-condition-expression ...` |
| Scan | `aws dynamodb scan --table-name <name>` |
| Delete item | `aws dynamodb delete-item --table-name <name> --key '<json>'` |
| Describe table | `aws dynamodb describe-table --table-name <name>` |
| List tables | `aws dynamodb list-tables` |

## Performance Tips

```bash
# Use parallel scan for large volumes
aws dynamodb scan \
    --table-name Users \
    --segment 0 \
    --total-segments 4

# Query is more efficient than Scan
# Always design Access Patterns first
# Use ProjectionExpression to reduce transferred data
# Prefer on-demand billing for variable loads
```
