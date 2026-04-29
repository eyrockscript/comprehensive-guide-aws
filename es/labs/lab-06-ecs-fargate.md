# Laboratorio 6: Contenedores con ECS y Fargate

## Objetivo
Desplegar una aplicación containerizada usando ECS con launch type Fargate.

## Duración Estimada
75-90 minutos

## Arquitectura
```
Internet → ALB → ECS Service → Fargate Tasks
```

## Instrucciones

### Paso 1: Crear ECR Repository
```bash
aws ecr create-repository \
    --repository-name webapp \
    --image-scanning-configuration scanOnPush=true

# Login y push de imagen
aws ecr get-login-password | docker login --username AWS --password-stdin xxx.dkr.ecr.region.amazonaws.com

docker build -t webapp:latest .
docker tag webapp:latest xxx.dkr.ecr.region.amazonaws.com/webapp:latest
docker push xxx.dkr.ecr.region.amazonaws.com/webapp:latest
```

### Paso 2: Crear Cluster ECS
```bash
aws ecs create-cluster \
    --cluster-name LabCluster \
    --capacity-providers FARGATE FARGATE_SPOT \
    --default-capacity-provider-strategy \
        capacityProvider=FARGATE,weight=1,base=1 \
        capacityProvider=FARGATE_SPOT,weight=4
```

### Paso 3: Crear Task Definition
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

### Paso 4: Crear Application Load Balancer
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

### Paso 5: Crear ECS Service
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

### Paso 6: Configurar Auto Scaling
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

## Pruebas
1. Verificar tasks en ejecución
2. Probar health checks del ALB
3. Simular carga y verificar auto-scaling

## Retos Adicionales
1. Implementar rolling deployments
2. Configurar Service Discovery
3. Usar capacity providers mixtos
4. Implementar circuit breaker

## Limpieza
1. Eliminar servicio ECS
2. Eliminar task definitions
3. Eliminar ALB y target groups
4. Eliminar cluster ECS
5. Eliminar repositorio ECR
