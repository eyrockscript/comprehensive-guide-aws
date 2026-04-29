# Lab 2: EC2 with Auto Scaling and Load Balancer

## Objective
Deploy a scalable web application using EC2, Auto Scaling, and Application Load Balancer.

## Estimated Duration
60-90 minutes

## Architecture
```
Internet → ALB → Auto Scaling Group → EC2 Instances
```

## Instructions

### Step 1: Create Security Groups
```bash
# ALB Security Group
aws ec2 create-security-group \
    --group-name ALB-SG \
    --description "Security group for ALB" \
    --vpc-id vpc-xxxxx

# EC2 Security Group (reference to ALB)
aws ec2 create-security-group \
    --group-name EC2-SG \
    --description "Security group for EC2 instances" \
    --vpc-id vpc-xxxxx
```

### Step 2: Create Launch Template
```json
{
  "ImageId": "ami-0c55b159cbfafe1f0",
  "InstanceType": "t3.micro",
  "SecurityGroupIds": ["sg-xxxxx"],
  "UserData": "base64-encoded-script",
  "TagSpecifications": [{
    "ResourceType": "instance",
    "Tags": [{"Key": "Name", "Value": "WebServer"}]
  }]
}
```

### Step 3: Create Application Load Balancer
1. Type: Application Load Balancer
2. Scheme: Internet-facing
3. Listener: HTTP:80
4. Health check: /health

### Step 4: Create Auto Scaling Group
```bash
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name WebApp-ASG \
    --launch-template LaunchTemplateId=lt-xxxxx \
    --min-size 2 \
    --max-size 6 \
    --desired-capacity 2 \
    --vpc-zone-identifier "subnet-xxxxx,subnet-yyyyy" \
    --target-group-arns arn:aws:elasticloadbalancing:...
```

### Step 5: Configure Scaling Policies
```bash
# Target Tracking Scaling
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name WebApp-ASG \
    --policy-name TargetTrackingPolicy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration file://config.json
```

## Testing
1. Verify ALB health checks
2. Simulate load with Apache Bench:
```bash
ab -n 10000 -c 100 http://alb-dns-name/
```
3. Observe auto-scaling in CloudWatch

## Additional Challenges
1. Configure SSL/TLS with ACM
2. Implement blue/green deployment
3. Add CloudFront in front of ALB

## Cleanup
Delete in order:
1. Auto Scaling Group
2. Load Balancer
3. Launch Template
4. Security Groups
