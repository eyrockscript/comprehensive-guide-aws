# Laboratorio 2: EC2 con Auto Scaling y Load Balancer

## Objetivo
Desplegar una aplicación web escalable usando EC2, Auto Scaling y Application Load Balancer.

## Duración Estimada
60-90 minutos

## Arquitectura
```
Internet → ALB → Auto Scaling Group → EC2 Instances
```

## Instrucciones

### Paso 1: Crear Security Groups
```bash
# ALB Security Group
aws ec2 create-security-group \
    --group-name ALB-SG \
    --description "Security group for ALB" \
    --vpc-id vpc-xxxxx

# EC2 Security Group (referencia al ALB)
aws ec2 create-security-group \
    --group-name EC2-SG \
    --description "Security group for EC2 instances" \
    --vpc-id vpc-xxxxx
```

### Paso 2: Crear Launch Template
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

### Paso 3: Crear Application Load Balancer
1. Tipo: Application Load Balancer
2. Esquema: Internet-facing
3. Listener: HTTP:80
4. Health check: /health

### Paso 4: Crear Auto Scaling Group
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

### Paso 5: Configurar Scaling Policies
```bash
# Target Tracking Scaling
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name WebApp-ASG \
    --policy-name TargetTrackingPolicy \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration file://config.json
```

## Pruebas
1. Verificar health checks del ALB
2. Simular carga con Apache Bench:
```bash
ab -n 10000 -c 100 http://alb-dns-name/
```
3. Observar escalado automático en CloudWatch

## Retos Adicionales
1. Configurar SSL/TLS con ACM
2. Implementar blue/green deployment
3. Agregar CloudFront delante del ALB

## Limpieza
Eliminar en orden:
1. Auto Scaling Group
2. Load Balancer
3. Launch Template
4. Security Groups
