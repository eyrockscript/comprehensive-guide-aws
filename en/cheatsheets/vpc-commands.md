# Cheatsheet: VPC and Networking CLI Commands

## Create VPC

```bash
# Create basic VPC
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=MyVPC}]'

# Create VPC with DNS enabled
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --enable-dns-support \
    --enable-dns-hostnames \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=MyVPC-Prod}]'

# Describe VPC
aws ec2 describe-vpcs --vpc-ids vpc-12345678

# Describe own VPCs
aws ec2 describe-vpcs --filters Name=owner-id,Values=123456789012
```

## Subnets

```bash
# Create public subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-1a}]'

# Create private subnet
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-1a}]'

# Enable auto-assign public IPs in subnet
aws ec2 modify-subnet-attribute \
    --subnet-id subnet-12345678 \
    --map-public-ip-on-launch

# Describe subnets
aws ec2 describe-subnets --filters Name=vpc-id,Values=vpc-12345678

# Delete subnet
aws ec2 delete-subnet --subnet-id subnet-12345678
```

## Internet Gateway

```bash
# Create Internet Gateway
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=MyIGW}]'

# Attach to VPC
aws ec2 attach-internet-gateway \
    --internet-gateway-id igw-12345678 \
    --vpc-id vpc-12345678

# Describe IGWs
aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=vpc-12345678

# Detach from VPC
aws ec2 detach-internet-gateway \
    --internet-gateway-id igw-12345678 \
    --vpc-id vpc-12345678

# Delete IGW
aws ec2 delete-internet-gateway --internet-gateway-id igw-12345678
```

## NAT Gateway

```bash
# Create Elastic IP for NAT
aws ec2 allocate-address --domain vpc

# Create NAT Gateway
aws ec2 create-nat-gateway \
    --subnet-id subnet-12345678 \
    --allocation-id eipalloc-12345678 \
    --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=NAT-1a}]'

# Wait for availability
aws ec2 describe-nat-gateways --nat-gateway-ids nat-12345678

# Delete NAT Gateway
aws ec2 delete-nat-gateway --nat-gateway-id nat-12345678

# Release Elastic IP
aws ec2 release-address --allocation-id eipalloc-12345678
```

## Route Tables

```bash
# Create route table
aws ec2 create-route-table \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Public-RT}]'

# Add route to Internet Gateway (public route)
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id igw-12345678

# Add route to NAT Gateway (private route)
aws ec2 create-route \
    --route-table-id rtb-87654321 \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id nat-12345678

# Associate route table to subnet
aws ec2 associate-route-table \
    --route-table-id rtb-12345678 \
    --subnet-id subnet-12345678

# Create route to peering connection
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 172.16.0.0/16 \
    --vpc-peering-connection-id pcx-12345678

# Create route to Transit Gateway
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 192.168.0.0/16 \
    --transit-gateway-id tgw-12345678

# Describe route tables
aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-12345678

# Delete route
aws ec2 delete-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0

# Delete route table
aws ec2 delete-route-table --route-table-id rtb-12345678
```

## Security Groups

```bash
# Create security group
aws ec2 create-security-group \
    --group-name WebServer-SG \
    --description "Security group for web servers" \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=WebServer-SG}]'

# Add inbound rule - HTTP
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Add inbound rule - HTTPS
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# Add inbound rule - SSH from specific IP
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.10/32

# Add inbound rule from another security group
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 3306 \
    --source-group sg-87654321

# Add outbound rule
aws ec2 authorize-security-group-egress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# Describe security groups
aws ec2 describe-security-groups --filters Name=vpc-id,Values=vpc-12345678

# Remove inbound rule
aws ec2 revoke-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.10/32

# Delete security group
aws ec2 delete-security-group --group-id sg-12345678
```

## Network ACLs

```bash
# Create Network ACL
aws ec2 create-network-acl \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=network-acl,Tags=[{Key=Name,Value=NACL-Public}]'

# Add inbound rule
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow \
    --ingress

# Add inbound rule - HTTPS
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 110 \
    --protocol tcp \
    --port-range From=443,To=443 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow \
    --ingress

# Add outbound rule
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol -1 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow \
    --egress

# Associate NACL to subnet
aws ec2 replace-network-acl-association \
    --association-id aclassoc-12345678 \
    --network-acl-id acl-12345678

# Describe NACLs
aws ec2 describe-network-acls --filters Name=vpc-id,Values=vpc-12345678

# Delete rule
aws ec2 delete-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --ingress
```

## VPC Peering

```bash
# Create peering connection
aws ec2 create-vpc-peering-connection \
    --vpc-id vpc-12345678 \
    --peer-vpc-id vpc-87654321 \
    --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=Peer-Prod-Dev}]'

# Accept peering (different account)
aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id pcx-12345678

# Describe peering connections
aws ec2 describe-vpc-peering-connections --filters Name=requester-vpc-info.vpc-id,Values=vpc-12345678

# Reject peering
aws ec2 reject-vpc-peering-connection --vpc-peering-connection-id pcx-12345678

# Delete peering
aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id pcx-12345678
```

## VPC Endpoints

```bash
# Create Gateway Endpoint for S3
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.s3 \
    --vpc-endpoint-type Gateway \
    --route-table-ids rtb-12345678 rtb-87654321

# Create Interface Endpoint for SSM
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.ssm \
    --vpc-endpoint-type Interface \
    --subnet-ids subnet-12345678 subnet-87654321 \
    --security-group-ids sg-12345678

# Describe endpoints
aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values=vpc-12345678

# Delete endpoint
aws ec2 delete-vpc-endpoints --vpc-endpoint-ids vpce-12345678
```

## VPC Flow Logs

```bash
# Create flow log to CloudWatch
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-12345678 \
    --traffic-type ALL \
    --log-destination-type cloud-watch-logs \
    --log-group-name /aws/vpc/flowlogs \
    --deliver-logs-permission-arn arn:aws:iam::123456789012:role/FlowLogRole

# Create flow log to S3
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-12345678 \
    --traffic-type REJECT \
    --log-destination-type s3 \
    --log-destination arn:aws:s3:::my-logs-bucket/vpc-flowlogs/

# Describe flow logs
aws ec2 describe-flow-logs --filter Name=resource-id,Values=vpc-12345678

# Delete flow log
aws ec2 delete-flow-logs --flow-log-id fl-12345678
```

## Elastic IPs

```bash
# Allocate Elastic IP
aws ec2 allocate-address --domain vpc

# Allocate from address pool
aws ec2 allocate-address --domain vpc --address 203.0.113.5

# Associate with instance
aws ec2 associate-address \
    --instance-id i-1234567890abcdef0 \
    --allocation-id eipalloc-12345678

# Associate with network interface
aws ec2 associate-address \
    --network-interface-id eni-12345678 \
    --allocation-id eipalloc-12345678

# Describe addresses
aws ec2 describe-addresses

# Disassociate
aws ec2 disassociate-address --association-id eipassoc-12345678

# Release
aws ec2 release-address --allocation-id eipalloc-12345678
```

## Quick Tips

| Task | Command |
|------|---------|
| Create VPC | `aws ec2 create-vpc --cidr-block 10.0.0.0/16` |
| Create subnet | `aws ec2 create-subnet --vpc-id <vpc> --cidr-block 10.0.1.0/24` |
| Create IGW | `aws ec2 create-internet-gateway` |
| Attach IGW | `aws ec2 attach-internet-gateway --internet-gateway-id <igw> --vpc-id <vpc>` |
| Create NAT Gateway | `aws ec2 create-nat-gateway --subnet-id <subnet> --allocation-id <eip>` |
| Create route | `aws ec2 create-route --route-table-id <rtb> --destination-cidr-block 0.0.0.0/0 --gateway-id <igw>` |
| Create SG | `aws ec2 create-security-group --group-name <name> --vpc-id <vpc>` |
| Add SG rule | `aws ec2 authorize-security-group-ingress --group-id <sg> ...` |

## Basic VPC Architecture

```
VPC (10.0.0.0/16)
├── IGW (Internet Gateway)
├── Public Subnet (10.0.1.0/24) - AZ 1a
│   └── NAT Gateway
├── Public Subnet (10.0.2.0/24) - AZ 1b
├── Private Subnet (10.0.3.0/24) - AZ 1a
└── Private Subnet (10.0.4.0/24) - AZ 1b

Route Tables:
- Public RT: 0.0.0.0/0 → IGW
- Private RT: 0.0.0.0/0 → NAT Gateway
```
