# Laboratorio 05: Contenedores con ECS

## 🎯 Objetivo del Laboratorio

Crear un cluster ECS con AWS Fargate, desplegar una aplicación containerizada y configurar un Application Load Balancer para distribuir el tráfico.

**Tiempo estimado:** 75 minutos
**Nivel:** Intermedio
**Costo:** Dentro del Free Tier (ECR tiene 500MB/mes gratis, Fargate incluye tareas pequeñas)

---

## 📋 Prerrequisitos

- Laboratorio 01 completado (cuenta AWS con usuario IAM)
- Laboratorio 04 completado (VPC con subredes públicas)
- Docker instalado localmente (opcional, para construir imágenes)
- AWS CLI instalado y configurado

---

## 🚀 Paso 1: Crear Repositorio ECR

### 1.1 Acceder al Servicio ECR

1. Inicia sesión en la Consola de AWS
2. En la barra de búsqueda, escribe "ECR"
3. Selecciona "Elastic Container Registry"
4. Asegúrate de estar en la región **us-east-1**

### 1.2 Crear Repositorio Privado

1. Clic en "Create repository"
2. Configura:

**General settings:**
```
Visibility: Private
Repository name: lab-ecs-app
```

**Image tag mutability:**
```
Tag immutability: ENABLED (recomendado para producción)
```

**Encryption:**
```
Encryption: AES-256 (default)
```

3. Clic en "Create repository"

### 1.3 Crear Repositorio para Nginx (Load Balancer)

1. Clic en "Create repository" nuevamente
2. Configura:
```
Repository name: lab-ecs-nginx
Tag immutability: ENABLED
```
3. Clic en "Create repository"

---

## 📦 Paso 2: Crear Imagen Docker y Subir a ECR

### 2.1 Crear Dockerfile de la Aplicación

En tu máquina local, crea una carpeta para el proyecto:

```bash
mkdir lab-ecs-app && cd lab-ecs-app
```

Crea el archivo `app.py`:

```python
from flask import Flask, jsonify
import os
import socket

app = Flask(__name__)

@app.route('/')
def hello():
    return jsonify({
        'message': '¡Hola desde AWS ECS Fargate!',
        'hostname': socket.gethostname(),
        'version': '1.0.0'
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
```

Crea el archivo `requirements.txt`:

```
Flask==2.3.3
gunicorn==21.2.0
```

Crea el archivo `Dockerfile`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
```

### 2.2 Autenticar Docker con ECR

1. En la consola ECR, selecciona tu repositorio `lab-ecs-app`
2. Clic en "View push commands"
3. Ejecuta el primer comando en tu terminal local:

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS \
  --password-stdin [TU-ACCOUNT-ID].dkr.ecr.us-east-1.amazonaws.com
```

### 2.3 Construir y Subir Imagen

En tu terminal local, en la carpeta del proyecto:

```bash
# Construir la imagen
docker build -t lab-ecs-app .

# Etiquetar la imagen
docker tag lab-ecs-app:latest \
  [TU-ACCOUNT-ID].dkr.ecr.us-east-1.amazonaws.com/lab-ecs-app:latest

# Subir la imagen
docker push [TU-ACCOUNT-ID].dkr.ecr.us-east-1.amazonaws.com/lab-ecs-app:latest
```

Verifica en la consola ECR que la imagen aparece en el repositorio.

---

## 🏗️ Paso 3: Crear Cluster ECS

### 3.1 Acceder al Servicio ECS

1. En la barra de búsqueda, escribe "ECS"
2. Selecciona "Elastic Container Service"

### 3.2 Crear Cluster

1. Clic en "Create Cluster"
2. Selecciona "Networking only (Fargate)"
3. Clic en "Next step"

4. Configura:

**Cluster configuration:**
```
Cluster name: lab-ecs-cluster
```

**Infrastructure:**
```
☑️ Create VPC (déjalo marcado si no tienes VPC, o usa la del Lab 04)
```

5. Clic en "Create"

---

## 📝 Paso 4: Crear Task Definition

### 4.1 Configurar Task Definition

1. En ECS, ve a "Task definitions" en el menú lateral
2. Clic en "Create new task definition"
3. Selecciona "Fargate" → "Next step"

4. Configura:

**Task definition name:**
```
Name: lab-task-definition
```

**Infrastructure requirements:**
```
Task size:
  CPU: 0.5 vCPU
  Memory: 1 GB
```

**Task execution role:**
```
Task execution role: Create new role (ecsTaskExecutionRole)
```

### 4.2 Configurar Container

1. En "Container details":

```
Name: lab-app-container
Image URI: [TU-ACCOUNT-ID].dkr.ecr.us-east-1.amazonaws.com/lab-ecs-app:latest
Container port: 5000
Protocol: TCP
```

2. Configuración de logs:
```
Log configuration:
  ☑️ Use log collection (FireLens or awslogs)
  Log driver: awslogs
  Log options:
    awslogs-group: /ecs/lab-ecs-app
    awslogs-region: us-east-1
    awslogs-stream-prefix: ecs
```

3. Variables de entorno (opcional):
```
Key: PORT
Value: 5000
```

4. Clic en "Create"

---

## 🌐 Paso 5: Configurar Application Load Balancer

### 5.1 Crear Target Group

1. Ve al servicio EC2
2. En el panel izquierdo, ve a "Target Groups"
3. Clic en "Create target group"
4. Configura:

**Basic configuration:**
```
Target type: IP addresses
Target group name: lab-ecs-tg
Protocol: HTTP
Port: 5000
VPC: lab-vpc (la del Lab 04, o la que creaste)
```

**Health checks:**
```
Health check path: /health
Protocol: HTTP
```

5. Clic en "Create target group"

### 5.2 Crear Application Load Balancer

1. En EC2, ve a "Load Balancers"
2. Clic en "Create load balancer"
3. Selecciona "Application Load Balancer"
4. Clic en "Create"

5. Configura:

**Basic configuration:**
```
Load balancer name: lab-ecs-alb
Scheme: Internet-facing
IP address type: IPv4
```

**Network mapping:**
```
VPC: lab-vpc
Mappings:
  ☑️ us-east-1a (selecciona las subredes públicas)
  ☑️ us-east-1b
```

**Security groups:**
```
Security groups: Create new security group
  Name: lab-alb-sg
  Inbound rules:
    - HTTP (80) from Anywhere
    - HTTPS (443) from Anywhere
```

**Listeners and routing:**
```
Protocol: HTTP
Port: 80
Default action: Forward to → lab-ecs-tg
```

6. Clic en "Create load balancer"

---

## 🚀 Paso 6: Crear ECS Service

### 6.1 Crear el Service

1. Vuelve al servicio ECS
2. Selecciona tu cluster "lab-ecs-cluster"
3. Ve a la pestaña "Services"
4. Clic en "Create"

5. Configura:

**Environment:**
```
Compute options: Launch type
Launch type: FARGATE
```

**Deployment configuration:**
```
Application type: Service
Task definition: lab-task-definition
  Revision: 1 (Latest)
Service name: lab-ecs-service
Desired tasks: 2
```

**Networking:**
```
VPC: lab-vpc
Subnets:
  ☑️ lab-vpc-subnet-private1-us-east-1a
  ☑️ lab-vpc-subnet-private2-us-east-1b

Security group: Create new
  Name: lab-ecs-service-sg
  Inbound rules:
    - Custom TCP (5000) from lab-alb-sg
```

**Load balancing:**
```
☑️ Use load balancing
Load balancer type: Application Load Balancer
Load balancer: lab-ecs-alb
Listener: 80:HTTP
Target group: lab-ecs-tg
```

6. Clic en "Create"

### 6.2 Verificar el Despliegue

1. Espera unos minutos a que las tareas se inicien
2. Ve a la pestaña "Tasks" del servicio
3. Verifica que las tareas estén en estado "RUNNING"
4. Si hay errores, revisa los logs en CloudWatch

---

## 🧪 Paso 7: Probar la Aplicación

### 7.1 Obtener la URL del Load Balancer

1. Ve a EC2 → Load Balancers
2. Selecciona "lab-ecs-alb"
3. Copia el "DNS name"
   - Ejemplo: `lab-ecs-alb-123456789.us-east-1.elb.amazonaws.com`

### 7.2 Probar la Aplicación

```bash
# Probar endpoint principal
curl http://lab-ecs-alb-xxx.us-east-1.elb.amazonaws.com/

# Respuesta esperada:
# {
#   "hostname": "ip-10-0-x-x.ec2.internal",
#   "message": "¡Hola desde AWS ECS Fargate!",
#   "version": "1.0.0"
# }

# Probar health check
curl http://lab-ecs-alb-xxx.us-east-1.elb.amazonaws.com/health

# Hacer múltiples requests para ver el balanceo
for i in {1..5}; do
  curl -s http://lab-ecs-alb-xxx.us-east-1.elb.amazonaws.com/ | grep hostname
done
```

### 7.3 Probar en Navegador

1. Abre tu navegador
2. Navega a: `http://lab-ecs-alb-xxx.us-east-1.elb.amazonaws.com/`
3. Recarga varias veces y observa cómo cambia el hostname (balanceo de carga)

---

## 📊 Paso 8: Configurar Auto Scaling

### 8.1 Crear Auto Scaling Policy

1. En ECS, selecciona tu cluster
2. Ve a la pestaña "Services"
3. Selecciona tu servicio "lab-ecs-service"
4. Clic en "Update"

5. Ve a la sección "Service auto scaling"
6. Configura:

```
☑️ Service auto scaling
Minimum number of tasks: 1
Desired number of tasks: 2
Maximum number of tasks: 5
```

7. Clic en "Add scaling policy"

**Policy 1: Scale Up**
```
Policy name: scale-up
Policy type: Step scaling
Alarm name: cpu-above-70
Metric: CPU Utilization
Statistic: Average
Period: 60 seconds
Threshold: > 70
Evaluation periods: 1

Step adjustments:
  When >= 70: Add 1 task
  When >= 85: Add 2 tasks
```

**Policy 2: Scale Down**
```
Policy name: scale-down
Policy type: Step scaling
Alarm name: cpu-below-30
Metric: CPU Utilization
Statistic: Average
Period: 60 seconds
Threshold: < 30
Evaluation periods: 2

Step adjustments:
  When < 30: Remove 1 task
```

8. Clic en "Update"

---

## 🎯 Bonus: Pipeline de CI/CD con CodePipeline

### 9.1 Crear Pipeline Simple

1. Ve al servicio CodePipeline
2. Clic en "Create pipeline"
3. Configura:

**Pipeline settings:**
```
Pipeline name: lab-ecs-pipeline
Service role: New service role
Role name: AWSCodePipelineServiceRole-us-east-1-lab-ecs-pipeline
```

**Source:**
```
Source provider: GitHub (Version 2)
Connection: Crear conexión con GitHub
Repository: tu-usuario/tu-repo
Branch: main
Output artifact format: CodePipeline default
```

**Build:**
```
Build provider: AWS CodeBuild
Region: US East (N. Virginia)
Project name: Crear proyecto
  Project name: lab-ecs-build
  Environment: Managed image
  OS: Amazon Linux 2
  Runtime: Standard
  Image: aws/codebuild/standard:5.0
  
  Buildspec:
    version: 0.2
    phases:
      pre_build:
        commands:
          - echo Logging in to Amazon ECR...
          - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      build:
        commands:
          - echo Build started on `date`
          - echo Building the Docker image...
          - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
          - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
      post_build:
        commands:
          - echo Build completed on `date`
          - echo Pushing the Docker image...
          - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
          - printf '[{"name":"lab-app-container","imageUri":"%s"}]' $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG > imagedefinitions.json
    artifacts:
      files: imagedefinitions.json
```

**Deploy:**
```
Deploy provider: Amazon ECS
Cluster name: lab-ecs-cluster
Service name: lab-ecs-service
Image definitions file: imagedefinitions.json
```

4. Clic en "Create pipeline"

---

## ✅ Verificación

- [ ] Repositorio ECR creado exitosamente
- [ ] Imagen Docker construida y subida a ECR
- [ ] Cluster ECS Fargate creado
- [ ] Task Definition configurada con contenedor de aplicación
- [ ] Target Group creado para el balanceo de carga
- [ ] Application Load Balancer configurado y accesible
- [ ] ECS Service creado con 2 tareas deseadas
- [ ] Tareas en estado "RUNNING"
- [ ] Aplicación accesible a través del ALB
- [ ] Balanceo de carga funcionando (hostname cambia en cada request)
- [ ] Auto Scaling configurado (opcional)
- [ ] Logs visibles en CloudWatch

---

## 🧹 Limpieza

### Eliminar en Orden

1. **Eliminar ECS Service:**
   - ECS → Clusters → lab-ecs-cluster → Services
   - Selecciona lab-ecs-service → Delete
   - Espera a que se eliminen las tareas

2. **Eliminar Task Definition:**
   - ECS → Task definitions
   - Selecciona lab-task-definition
   - Actions → Deregister (para cada revisión)

3. **Eliminar Cluster:**
   - ECS → Clusters
   - Selecciona lab-ecs-cluster → Delete

4. **Eliminar Load Balancer:**
   - EC2 → Load Balancers
   - Selecciona lab-ecs-alb → Actions → Delete

5. **Eliminar Target Groups:**
   - EC2 → Target Groups
   - Selecciona lab-ecs-tg → Actions → Delete

6. **Eliminar Imágenes ECR:**
   - ECR → Repositorios
   - Selecciona cada repositorio
   - Elimina todas las imágenes

7. **Eliminar Repositorios ECR:**
   - Selecciona repositorios → Delete

8. **Eliminar Security Groups:**
   - EC2 → Security Groups
   - Elimina: lab-ecs-service-sg, lab-alb-sg

9. **Eliminar Logs CloudWatch:**
   - CloudWatch → Log Groups
   - Elimina /ecs/lab-ecs-app

10. **Eliminar CodePipeline (si lo creaste):**
    - CodePipeline → Pipelines
    - Selecciona lab-ecs-pipeline → Delete

---

## 📚 Recursos Adicionales

- [Guía de Usuario de ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [Guía de Usuario de ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html)
- [Fargate Getting Started](https://docs.aws.amazon.com/AmazonECS/latest/userguide/getting-started-fargate.html)
- [Application Load Balancers](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [ECS Auto Scaling](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-auto-scaling.html)

---

## 🎯 Siguiente Laboratorio

→ [Lab 06: Serverless con Lambda](lab-06-serverless-lambda.md)

---

*Última actualización: Abril 2025*
