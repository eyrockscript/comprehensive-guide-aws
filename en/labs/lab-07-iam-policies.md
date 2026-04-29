# Lab 7: Identity and Access Management (IAM)

## Objective
Implement secure IAM policies following the principle of least privilege.

## Estimated Duration
45-60 minutes

## Scenario
Company with 3 teams: Development, QA, and Production. Each team needs differentiated permissions.

## Instructions

### Step 1: Create User and Group Structure
```bash
# Create groups
aws iam create-group --group-name Developers
aws iam create-group --group-name QA-Team
aws iam create-group --group-name Production-Ops

# Create users
aws iam create-user --user-name dev-user-01
aws iam create-user --user-name qa-user-01
aws iam create-user --user-name prod-user-01

# Add users to groups
aws iam add-user-to-group --group-name Developers --user-name dev-user-01
aws iam add-user-to-group --group-name QA-Team --user-name qa-user-01
aws iam add-user-to-group --group-name Production-Ops --user-name prod-user-01
```

### Step 2: Create Custom Policies

**Developers Policy** (`dev-policy.json`):
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ec2:Describe*",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ],
    "Resource": "*",
    "Condition": {"StringEquals": {"ec2:ResourceTag/Environment": "dev"}}
  }]
}
```

**Production Policy** (`prod-policy.json`):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "cloudwatch:Get*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Deny",
      "Action": "ec2:TerminateInstances",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {"ec2:ResourceTag/Critical": "false"}
      }
    }
  ]
}
```

```bash
aws iam create-policy \
    --policy-name DeveloperPolicy \
    --policy-document file://dev-policy.json

aws iam attach-group-policy \
    --group-name Developers \
    --policy-arn arn:aws:iam::xxx:policy/DeveloperPolicy
```

### Step 3: Configure MFA
```bash
# Enable MFA for users
aws iam create-virtual-mfa-device \
    --virtual-mfa-device-name dev-user-01-mfa \
    --outfile qr-code.png

# Require MFA for sensitive actions
```

### Step 4: Create Service Roles

**EC2 Role for S3**:
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
```

```bash
aws iam create-role \
    --role-name EC2-S3-Access-Role \
    --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
    --role-name EC2-S3-Access-Role \
    --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

### Step 5: Configure AWS Organizations (Simulated)
```bash
# SCP structure (Service Control Policies)
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": "s3:DeleteBucket",
    "Resource": "*",
    "Condition": {"StringNotEquals": {"aws:PrincipalTag/Admin": "true"}}
  }]
}
```

## Testing
1. Simulate access with IAM Policy Simulator
2. Verify permissions with AWS CLI:
```bash
aws sts get-caller-identity
aws iam simulate-principal-policy \
    --policy-source-arn arn:aws:iam::xxx:user/dev-user-01 \
    --action-names s3:GetObject s3:DeleteBucket
```

## Additional Challenges
1. Implement cross-account access
2. Configure SAML/SSO integration
3. Create resource-based policies
4. Implement permission boundaries

## Audit
```bash
# Generate access report
aws iam generate-credential-report
aws iam get-credential-report --query Content --output text | base64 -d

# Review unused policies
aws iam list-policies --scope Local
```

## Cleanup
1. Detach and delete custom policies
2. Delete users and groups
3. Delete roles
