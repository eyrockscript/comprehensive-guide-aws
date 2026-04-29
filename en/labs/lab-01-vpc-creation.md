# Lab 1: Creating a Basic VPC

## Objective
Create a complete VPC with public and private subnets, Internet and NAT gateways.

## Estimated Duration
45-60 minutes

## Prerequisites
- AWS account with console access
- Basic networking knowledge

## Instructions

### Step 1: Create the VPC
1. Go to VPC Dashboard
2. Click on "Create VPC"
3. Configure:
   - Name: `LabVPC`
   - CIDR: `10.0.0.0/16`
   - Enable DNS hostnames

### Step 2: Create Subnets
Create 4 subnets:

| Name | AZ | CIDR | Type |
|--------|-----|------|------|
| Public-1a | us-east-1a | 10.0.1.0/24 | Public |
| Public-1b | us-east-1b | 10.0.2.0/24 | Public |
| Private-1a | us-east-1a | 10.0.3.0/24 | Private |
| Private-1b | us-east-1b | 10.0.4.0/24 | Private |

### Step 3: Create Internet Gateway
```bash
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=LabIGW}]'
aws ec2 attach-internet-gateway --internet-gateway-id igw-xxxxx --vpc-id vpc-xxxxx
```

### Step 4: Configure Route Tables
- Public table: route to Internet Gateway
- Private table: route to NAT Gateway

### Step 5: Verify Connectivity
Launch test instances in each subnet and verify connectivity.

## Additional Challenges
1. Configure VPC Flow Logs
2. Create S3 Endpoint
3. Configure peering with another VPC

## Cleanup
Delete resources in reverse order:
1. Terminate instances
2. Delete NAT Gateway
3. Detach and delete Internet Gateway
4. Delete subnets
5. Delete VPC

## References
- [VPC Documentation](https://docs.aws.amazon.com/vpc/)
