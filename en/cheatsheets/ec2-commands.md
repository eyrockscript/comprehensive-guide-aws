# Cheatsheet: EC2 CLI Commands

## Basic Information

```bash
# List instances
aws ec2 describe-instances
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# Filter by state
aws ec2 describe-instances \
    --filters Name=instance-state-name,Values=running

# Filter by tag
aws ec2 describe-instances \
    --filters Name=tag:Environment,Values=Production
```

## Create and Manage Instances

```bash
# Launch instance
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --count 1 \
    --instance-type t3.micro \
    --key-name MyKeyPair \
    --security-group-ids sg-903004f8 \
    --subnet-id subnet-6e7f829e \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WebServer}]'

# Stop instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Start stopped instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Terminate instance
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Reboot instance
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0
```

## AMIs and Snapshots

```bash
# Create AMI
aws ec2 create-image \
    --instance-id i-1234567890abcdef0 \
    --name "WebServer-v1.0" \
    --description "AMI for web server"

# Create EBS snapshot
aws ec2 create-snapshot \
    --volume-id vol-1234567890abcdef0 \
    --description "Snapshot for data volume"

# List own AMIs
aws ec2 describe-images --owners self

# Copy AMI to another region
aws ec2 copy-image \
    --source-image-id ami-12345678 \
    --source-region us-east-1 \
    --region us-west-2 \
    --name "WebServer-v1.0-Copy"
```

## Security Groups

```bash
# Create security group
aws ec2 create-security-group \
    --group-name WebServer-SG \
    --description "SG for web servers"

# Add inbound rule (HTTP)
aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Add inbound rule (SSH from specific IP)
aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.0/32

# Remove rule
aws ec2 revoke-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.0/32

# View security group rules
aws ec2 describe-security-groups --group-ids sg-903004f8
```

## Key Pairs

```bash
# Create key pair
aws ec2 create-key-pair \
    --key-name MyKeyPair \
    --query 'KeyMaterial' \
    --output text > MyKeyPair.pem

chmod 400 MyKeyPair.pem

# Import existing key pair
aws ec2 import-key-pair \
    --key-name MyImportedKey \
    --public-key-material fileb://~/.ssh/id_rsa.pub

# List key pairs
aws ec2 describe-key-pairs

# Delete key pair
aws ec2 delete-key-pair --key-name MyKeyPair
```

## EBS Volumes

```bash
# Create volume
aws ec2 create-volume \
    --volume-type gp3 \
    --size 100 \
    --availability-zone us-east-1a

# Attach volume to instance
aws ec2 attach-volume \
    --volume-id vol-1234567890abcdef0 \
    --instance-id i-1234567890abcdef0 \
    --device /dev/sdf

# Detach volume
aws ec2 detach-volume --volume-id vol-1234567890abcdef0

# Modify volume (expand)
aws ec2 modify-volume \
    --volume-id vol-1234567890abcdef0 \
    --size 200

# Delete volume
aws ec2 delete-volume --volume-id vol-1234567890abcdef0
```

## Elastic IPs

```bash
# Allocate Elastic IP
aws ec2 allocate-address --domain vpc

# Associate with instance
aws ec2 associate-address \
    --instance-id i-1234567890abcdef0 \
    --allocation-id eipalloc-12345678

# Release Elastic IP
aws ec2 release-address --allocation-id eipalloc-12345678
```

## Tags

```bash
# Add tags
aws ec2 create-tags \
    --resources i-1234567890abcdef0 \
    --tags Key=Environment,Value=Production Key=Owner,Value=DevOps

# Remove tags
aws ec2 delete-tags \
    --resources i-1234567890abcdef0 \
    --tags Key=Owner

# Search by tags
aws ec2 describe-instances \
    --filters Name=tag:Environment,Values=Production
```

## Auto Scaling

```bash
# Create Launch Template
aws ec2 create-launch-template \
    --launch-template-name WebServerTemplate \
    --launch-template-data '{
        "ImageId": "ami-0c55b159cbfafe1f0",
        "InstanceType": "t3.micro",
        "KeyName": "MyKeyPair",
        "SecurityGroupIds": ["sg-903004f8"]
    }'

# Create Auto Scaling Group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name WebApp-ASG \
    --launch-template LaunchTemplateName=WebServerTemplate,Version='$Latest' \
    --min-size 1 \
    --max-size 5 \
    --desired-capacity 2 \
    --vpc-zone-identifier "subnet-6e7f829e"
```

## User Data (Startup Script)

```bash
# Create instance with user data
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --instance-type t3.micro \
    --user-data file://startup-script.sh

# View instance user data
aws ec2 describe-instance-attribute \
    --instance-id i-1234567890abcdef0 \
    --attribute userData \
    --query UserData.Value \
    --output text | base64 -d
```

## SSH Connection

```bash
# Get public IP
aws ec2 describe-instances \
    --instance-ids i-1234567890abcdef0 \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text

# Connect SSH
ssh -i MyKeyPair.pem ec2-user@<public-ip>

# Windows (PowerShell)
ssh -i "$env:USERPROFILE\.ssh\MyKeyPair.pem" ec2-user@<public-ip>
```

## Quick Tips

| Task | Command |
|------|---------|
| Start instance | `aws ec2 start-instances --instance-ids <id>` |
| Stop instance | `aws ec2 stop-instances --instance-ids <id>` |
| View IPs | `aws ec2 describe-instances --query ...` |
| Change type | `aws ec2 modify-instance-attribute ...` |
| View logs | `aws ec2 get-console-output --instance-id <id>` |
