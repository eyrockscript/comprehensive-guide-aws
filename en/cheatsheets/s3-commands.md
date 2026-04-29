# Cheatsheet: S3 CLI Commands

## Basic Operations

```bash
# Create bucket
aws s3 mb s3://my-example-bucket

# Create bucket in specific region
aws s3 mb s3://my-example-bucket --region eu-west-1

# List buckets
aws s3 ls

# List bucket contents
aws s3 ls s3://my-example-bucket

# List with prefix
aws s3 ls s3://my-example-bucket/folder/

# List recursively
aws s3 ls s3://my-example-bucket --recursive
```

## Upload Files

```bash
# Upload a file
aws s3 cp file.txt s3://my-example-bucket/

# Upload with different name
aws s3 cp file.txt s3://my-example-bucket/renamed.txt

# Upload directory recursively
aws s3 cp ./my-folder s3://my-example-bucket/ --recursive

# Upload with metadata
aws s3 cp file.txt s3://my-example-bucket/ \
    --metadata "author=John,project=Demo"

# Sync directory (only changes)
aws s3 sync ./my-folder s3://my-example-bucket/

# Sync excluding patterns
aws s3 sync ./my-folder s3://my-example-bucket/ \
    --exclude "*.tmp" --exclude "*.log"
```

## Download Files

```bash
# Download a file
aws s3 cp s3://my-example-bucket/file.txt ./

# Download entire directory
aws s3 cp s3://my-example-bucket/my-folder ./ --recursive

# Sync download
aws s3 sync s3://my-example-bucket/ ./local-backup/
```

## Copy Between Buckets

```bash
# Copy between buckets
aws s3 cp s3://source-bucket/file.txt s3://destination-bucket/

# Copy with recursive
aws s3 cp s3://source-bucket/folder/ s3://destination-bucket/folder/ --recursive
```

## Delete Files

```bash
# Delete a file
aws s3 rm s3://my-example-bucket/file.txt

# Delete directory recursively
aws s3 rm s3://my-example-bucket/folder/ --recursive

# Delete bucket (must be empty)
aws s3 rb s3://my-example-bucket

# Force delete (empty and delete)
aws s3 rb s3://my-example-bucket --force
```

## Presign URLs

```bash
# Generate temporary URL (3600 seconds default)
aws s3 presign s3://my-example-bucket/file.txt

# URL with custom expiration
aws s3 presign s3://my-example-bucket/file.txt \
    --expires-in 3600  # 1 hour in seconds

# For PUT (upload)
aws s3 presign s3://my-example-bucket/file.txt \
    --method put \
    --expires-in 600
```

## Website Hosting

```bash
# Configure bucket for website
aws s3api put-bucket-website \
    --bucket my-example-bucket \
    --website-configuration file://website-config.json

# website-config.json:
{
  "IndexDocument": {"Suffix": "index.html"},
  "ErrorDocument": {"Key": "error.html"}
}

# Set public policy
aws s3api put-bucket-policy \
    --bucket my-example-bucket \
    --policy file://policy.json
```

## Versioning

```bash
# Enable versioning
aws s3api put-bucket-versioning \
    --bucket my-example-bucket \
    --versioning-configuration Status=Enabled

# Suspend versioning
aws s3api put-bucket-versioning \
    --bucket my-example-bucket \
    --versioning-configuration Status=Suspended

# List versions
aws s3api list-object-versions \
    --bucket my-example-bucket \
    --prefix file.txt

# Download specific version
aws s3api get-object \
    --bucket my-example-bucket \
    --key file.txt \
    --version-id abc123def456 \
    file-version.txt
```

## Lifecycle

```bash
# Configure lifecycle rules
aws s3api put-bucket-lifecycle-configuration \
    --bucket my-example-bucket \
    --lifecycle-configuration file://lifecycle.json

# lifecycle.json:
{
  "Rules": [{
    "ID": "MoveToIA",
    "Status": "Enabled",
    "Filter": {"Prefix": "logs/"},
    "Transitions": [{
      "Days": 30,
      "StorageClass": "STANDARD_IA"
    }],
    "Expiration": {"Days": 365}
  }]
}
```

## Encryption

```bash
# Configure default encryption (SSE-S3)
aws s3api put-bucket-encryption \
    --bucket my-example-bucket \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }]
    }'

# With KMS
aws s3api put-bucket-encryption \
    --bucket my-example-bucket \
    --server-side-encryption-configuration '{
      "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "aws:kms",
          "KMSMasterKeyID": "arn:aws:kms:region:account:key/12345"
        }
      }]
    }'
```

## Logging

```bash
# Enable logging
aws s3api put-bucket-logging \
    --bucket my-example-bucket \
    --bucket-logging-status file://logging-config.json

# logging-config.json:
{
  "LoggingEnabled": {
    "TargetBucket": "my-logs-bucket",
    "TargetPrefix": "s3-logs/"
  }
}
```

## Replication

```bash
# Configure replication
aws s3api put-bucket-replication \
    --bucket my-source-bucket \
    --replication-configuration file://replication.json \
    --token <token>
```

## Quick Tips

| Task | Command |
|------|---------|
| Upload file | `aws s3 cp local s3://bucket/` |
| Download file | `aws s3 cp s3://bucket/ local` |
| Sync | `aws s3 sync source destination` |
| Delete all | `aws s3 rm s3://bucket/ --recursive` |
| Temporary URL | `aws s3 presign s3://bucket/file` |

## Useful Shortcuts

```bash
# View bucket size
aws s3 ls s3://my-example-bucket --recursive --human-readable --summarize

# Copy only new files
aws s3 sync . s3://my-example-bucket/ --size-only

# Include/exclude patterns
aws s3 sync . s3://my-example-bucket/ --include "*.jpg" --exclude "*.tmp"
```
