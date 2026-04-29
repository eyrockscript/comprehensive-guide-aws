# Lab 6: Containers with ECS and Fargate

## Objective
Deploy a containerized application using ECS with Fargate launch type.

## Estimated Duration
75-90 minutes

## Architecture
```
Internet → ALB → ECS Service → Fargate Tasks
```

## Instructions

### Step 1: Create ECR Repository
```bash
aws ecr create-repository \
    --repository-name webapp \
    --image-scanning-configuration scanOnPush=true

# Login and push image
aws ecr get-login-password | docker login --username AWS --password-stdin xxx.dkr.ecr.region.amazonaws.com

docker build -t webapp:latest .
docker tag webapp:latest xxx.dkr.ecr.region.amazonaws.com/webapp:latest
docker push xxx.dkr.ecr.region.amazonaws.com/webapp:latest
```

### Step 2: Create ECS Cluster
```bash
aws ecs create-cluster \
    --cluster-name LabCluster \
    --capacity-providers FARGATE FARGATE_SPOT \
    --default-capacity-provider-strategy \
        capacityProvider=FARGATE,weight=1,base=1 \
        capacityProvider=FARGATE_SPOT,weight=4
```

### Step 3: Create Task Definition
```json
{
  "family": "webapp-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::xxx:role/ecsTaskExecutionRole",
  "containerDefinitions": [{
    "name": "webapp",
    "image": "xxx.dkr.ecr.region.amazonaws.com/webapp:latest",
    "portMappings": [{"containerPort": 80, "protocol": "tcp"}],
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/webapp",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }]
}
```

### Step 4: Create Application Load Balancer
```bash
aws elbv2 create-load-balancer \
    --name ecs-alb \
    --subnets subnet-xxxxx subnet-yyyyy \
    --security-groups sg-xxxxx \
    --type application

aws elbv2 create-target-group \
    --name ecs-targets \
    --protocol HTTP \
    --port 80 \
    --vpc-id vpc-xxxxx \
    --target-type ip
```

### Step 5: Create ECS Service
```bash
aws ecs create-service \
    --cluster LabCluster \
    --service-name webapp-service \
    --task-definition webapp-task:1 \
    --desired-count 2 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxx,subnet-yyyyy],securityGroups=[sg-xxxxx],assignPublicIp=DISABLED}" \
    --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:xxx,containerName=webapp,containerPort=80"
```

### Step 6: Configure Auto Scaling
```bash
aws ecs register-scalable-target \
    --service-namespace ecs \
    --resource-id service/LabCluster/webapp-service \
    --scalable-dimension ecs:service:DesiredCount \
    --min-capacity 2 \
    --max-capacity 10

aws ecs put-scaling-policy \
    --service-namespace ecs \
    --resource-id service/LabCluster/webapp-service \
    --scalable-dimension ecs:service:DesiredCount \
    --policy-name cpu-auto-scaling \
    --policy-type TargetTrackingScaling \
    --target-tracking-scaling-policy-configuration file://scaling-config.json
```

## Testing
1. Verify running tasks
2. Test ALB health checks
3. Simulate load and verify auto-scaling

## Additional Challenges
1. Implement rolling deployments
2. Configure Service Discovery
3. Use mixed capacity providers
4. Implement circuit breaker

## Cleanup
1. Delete ECS service
2. Delete task definitions
3. Delete ALB and target groups
4. Delete ECS cluster
5. Delete ECR repository
