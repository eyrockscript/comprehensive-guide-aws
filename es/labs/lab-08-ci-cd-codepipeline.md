# Laboratorio 08: CI/CD con CodePipeline

## 🎯 Objetivo del Laboratorio

Construir un pipeline de CI/CD completo usando AWS CodePipeline, CodeBuild y CodeDeploy para automatizar el despliegue de una aplicación web cada vez que hay cambios en el código fuente.

**Tiempo estimado:** 90 minutos  
**Nivel:** Intermedio  
**Costo:** Dentro del Free Tier (CodePipeline gratis, CodeBuild incluye 100 min/mes)

---

## 📋 Prerrequisitos

- Laboratorio 01 completado (cuenta AWS configurada)
- Laboratorio 02 completado (EC2 básico) o Laboratorio 05 completado (ECS)
- Cuenta de GitHub o CodeCommit configurada
- Aplicación para desplegar (usaremos una app Node.js simple)

---

## 🏗️ Arquitectura del Pipeline

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌──────────────┐
│   Source    │───→│    Build     │───→│    Test     │───→│   Deploy     │
│  (GitHub)   │    │ (CodeBuild)  │    │ (CodeBuild) │    │ (ECS/EC2)    │
└─────────────┘    └──────────────┘    └──────────────┘    └──────────────┘
        │                   │                    │                  │
        └───────────────────┴────────────────────┴──────────────────┘
                                  │
                          (CodePipeline)
```

---

## 🚀 Paso 1: Preparar la Aplicación

### 1.1 Crear Repositorio en GitHub

1. Inicia sesión en tu cuenta de GitHub
2. Clic en el botón "+" → "New repository"
3. Configura:
   ```
   Repository name: aws-lab-cicd-app
   Description: Aplicación de ejemplo para laboratorio CI/CD en AWS
   Visibility: Public (o Private si prefieres)
   Initialize with README: ✅ Sí
   ```
4. Clic en "Create repository"

### 1.2 Crear la Aplicación Node.js

En tu máquina local, crea la estructura del proyecto:

```bash
mkdir aws-lab-cicd-app && cd aws-lab-cicd-app
git init
git remote add origin https://github.com/tu-usuario/aws-lab-cicd-app.git
```

Crea el archivo `package.json`:

```json
{
  "name": "aws-lab-cicd-app",
  "version": "1.0.0",
  "description": "Aplicación de ejemplo para CI/CD en AWS",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "jest --coverage",
    "test:unit": "jest --testPathPattern=unit",
    "test:integration": "jest --testPathPattern=integration",
    "build": "echo 'Build completado - no se requiere compilación'",
    "lint": "eslint ."
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "eslint": "^8.50.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

Crea el archivo `index.js`:

```javascript
const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;
const VERSION = process.env.APP_VERSION || '1.0.0';

// Middleware
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: VERSION,
    uptime: process.uptime()
  });
});

// API endpoint principal
app.get('/api/info', (req, res) => {
  res.json({
    app: 'AWS Lab CI/CD App',
    version: VERSION,
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

// Endpoint para demostrar deployment
app.get('/', (req, res) => {
  res.json({
    message: '¡Hola desde AWS CI/CD Pipeline!',
    version: VERSION,
    timestamp: new Date().toISOString(),
    deployedBy: 'AWS CodePipeline'
  });
});

// Iniciar servidor solo si no estamos en modo test
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
    console.log(`📦 Versión: ${VERSION}`);
    console.log(`🌍 Entorno: ${process.env.NODE_ENV || 'development'}`);
  });
}

module.exports = app;
```

Crea el archivo `__tests__/unit/app.test.js`:

```javascript
const request = require('supertest');
const app = require('../../index');

describe('Unit Tests - App Endpoints', () => {
  test('GET /health should return healthy status', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);

    expect(response.body.status).toBe('healthy');
    expect(response.body).toHaveProperty('timestamp');
    expect(response.body).toHaveProperty('version');
    expect(response.body).toHaveProperty('uptime');
  });

  test('GET /api/info should return app info', async () => {
    const response = await request(app)
      .get('/api/info')
      .expect(200);

    expect(response.body.app).toBe('AWS Lab CI/CD App');
    expect(response.body).toHaveProperty('version');
    expect(response.body).toHaveProperty('environment');
  });

  test('GET / should return welcome message', async () => {
    const response = await request(app)
      .get('/')
      .expect(200);

    expect(response.body.message).toContain('AWS CI/CD Pipeline');
    expect(response.body.deployedBy).toBe('AWS CodePipeline');
  });
});

describe('Unit Tests - Environment Variables', () => {
  const OLD_ENV = process.env;

  beforeEach(() => {
    jest.resetModules();
    process.env = { ...OLD_ENV };
  });

  afterAll(() => {
    process.env = OLD_ENV;
  });

  test('should use default port when PORT is not set', () => {
    delete process.env.PORT;
    const app = require('../../index');
    expect(app).toBeDefined();
  });

  test('should use default version when APP_VERSION is not set', () => {
    delete process.env.APP_VERSION;
    const app = require('../../index');
    expect(app).toBeDefined();
  });
});
```

Crea el archivo `__tests__/integration/api.test.js`:

```javascript
const request = require('supertest');
const app = require('../../index');

describe('Integration Tests - API', () => {
  test('GET /health should respond within 100ms', async () => {
    const start = Date.now();
    await request(app).get('/health');
    const duration = Date.now() - start;
    expect(duration).toBeLessThan(100);
  });

  test('All endpoints should return JSON', async () => {
    const endpoints = ['/', '/health', '/api/info'];
    
    for (const endpoint of endpoints) {
      const response = await request(app)
        .get(endpoint)
        .expect('Content-Type', /json/)
        .expect(200);
      
      expect(response.body).toBeInstanceOf(Object);
    }
  });

  test('Response should include timestamp', async () => {
    const response = await request(app).get('/');
    const timestamp = new Date(response.body.timestamp);
    expect(timestamp).toBeInstanceOf(Date);
    expect(isNaN(timestamp)).toBe(false);
  });
});
```

Crea el archivo `Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias de producción
RUN npm ci --only=production

# Copiar código fuente
COPY . .

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# Cambiar a usuario no-root
USER nextjs

# Exponer puerto
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Comando de inicio
CMD ["npm", "start"]
```

Crea el archivo `.dockerignore`:

```
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.nyc_output
coverage
.circleci
.github
```

### 1.3 Subir Código a GitHub

```bash
# Añadir todos los archivos
git add .

# Commit inicial
git commit -m "Initial commit: Aplicación Node.js para lab CI/CD"

# Subir a GitHub
git push -u origin main
```

Verifica que el código esté en tu repositorio de GitHub.

---

## 🔐 Paso 2: Configurar Permisos IAM

### 2.1 Crear Rol para CodePipeline

1. Ve al servicio IAM en la Consola de AWS
2. Ve a "Roles" → "Create role"
3. Selecciona "CodePipeline" como servicio
4. Clic en "Next"
5. Políticas requeridas (busca y selecciona):
   - `AWSCodePipelineFullAccess`
   - `AmazonEC2FullAccess` (si despliegas a EC2)
   - `AmazonECS_FullAccess` (si despliegas a ECS)
   - `AWSCodeBuildAdminAccess`
   - `AWSCodeDeployFullAccess`
   - `AmazonS3FullAccess`
   - `AWSECRFullAccess` (para contenedores)
6. Nombre del rol: `LabCodePipelineRole`
7. Clic en "Create role"

### 2.2 Crear Rol para CodeBuild

1. Ve a IAM → "Roles" → "Create role"
2. Selecciona "CodeBuild" como servicio
3. Clic en "Next"
4. Políticas requeridas:
   - `AWSCodeBuildDeveloperAccess`
   - `AmazonEC2FullAccess`
   - `AmazonECS_FullAccess`
   - `AmazonS3FullAccess`
   - `AWSECRFullAccess`
   - `AmazonEC2ContainerRegistryFullAccess`
   - `CloudWatchLogsFullAccess`
5. Nombre del rol: `LabCodeBuildRole`
6. Clic en "Create role"

---

## 🏗️ Paso 3: Crear Bucket S3 para Artefactos

### 3.1 Crear Bucket

1. Ve al servicio S3
2. Clic en "Create bucket"
3. Configura:
   ```
   Bucket name: lab-codepipeline-artifacts-[tu-iniciales]-[fecha]
   Region: us-east-1
   ```
4. En "Block Public Access", mantén todo bloqueado (privado)
5. Clic en "Create bucket"

### 3.2 Configurar Lifecycle (Opcional)

Para ahorrar costos, elimina artefactos antiguos:

1. Ve al bucket → "Management" → "Lifecycle rules"
2. Clic en "Create lifecycle rule"
3. Configura:
   ```
   Rule name: delete-old-artifacts
   Rule scope: Apply to all objects
   Lifecycle rule actions:
     ✅ Expire current versions of objects
        - After 30 days from creation
   ```
4. Clic en "Create rule"

---

## 🔨 Paso 4: Crear Proyecto CodeBuild

### 4.1 Crear Proyecto de Build

1. Ve al servicio CodeBuild
2. Clic en "Create build project"
3. Configura:

**Project configuration:**
```
Project name: lab-app-build
Description: Build project para aplicación Node.js
```

**Source:**
```
Source provider: GitHub
   - Connect using OAuth (clic en "Connect to GitHub")
   - Selecciona tu repositorio: aws-lab-cicd-app
   
Buildspec: Use a buildspec file (buildspec.yml)
```

**Environment:**
```
Environment image: Managed image
Operating system: Amazon Linux 2
Runtime(s): Standard
Image: aws/codebuild/amazonlinux2-x86_64-standard:5.0

Environment type: Linux
Compute: 2 vCPUs, 4 GB RAM (build.general1.small)

Service role: Existing service role
Role name: LabCodeBuildRole
```

**Buildspec:**
```
Selecciona: Insert build commands
```

### 4.2 Configurar buildspec.yml Inline

Pega el siguiente buildspec:

```yaml
version: 0.2

env:
  variables:
    NODE_ENV: production
  parameter-store:
    APP_VERSION: /lab/app/version

phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - echo "Instalando dependencias..."
      - npm ci
      
  pre_build:
    commands:
      - echo "Ejecutando linting..."
      - npm run lint || echo "Linting warnings present"
      - echo "Ejecutando tests unitarios..."
      - npm run test:unit -- --coverage --coverageDirectory=coverage/unit
      - echo "Ejecutando tests de integración..."
      - npm run test:integration -- --coverage --coverageDirectory=coverage/integration
      
  build:
    commands:
      - echo "Compilando aplicación..."
      - npm run build
      - echo "Creando archivo de versión..."
      - echo "{ \"version\": \"$CODEBUILD_BUILD_NUMBER\", \"commit\": \"$CODEBUILD_RESOLVED_SOURCE_VERSION\", \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\" }" > version.json
      
  post_build:
    commands:
      - echo "Build completado en $(date)"
      - ls -la

cache:
  paths:
    - node_modules/**/*
    
artifacts:
  files:
    - index.js
    - package.json
    - package-lock.json
    - Dockerfile
    - version.json
    - '**/*.js'
    - 'node_modules/**/*'
  name: build-$(date +%Y-%m-%d-%H-%M-%S)-$CODEBUILD_BUILD_NUMBER
  discard-paths: no
```

4. Clic en "Create build project"

### 4.3 Crear Proyecto CodeBuild para Tests

Repite el proceso para un proyecto de tests:

```
Project name: lab-app-test
Source provider: GitHub
Selecciona tu repositorio
```

Buildspec para tests:

```yaml
version: 0.2

env:
  variables:
    NODE_ENV: test
    CI: true

phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - npm ci
      
  pre_build:
    commands:
      - echo "Verificando configuración..."
      - node --version
      - npm --version
      
  build:
    commands:
      - echo "Ejecutando todos los tests..."
      - npm test -- --coverage --coverageDirectory=coverage
      - echo "Generando reporte de cobertura..."
      
  post_build:
    commands:
      - echo "Tests completados"
      - echo "Cobertura disponible en coverage/lcov-report"

reports:
  coverage:
    files:
      - 'coverage/cobertura-coverage.xml'
    file-format: COBERTURAXML
    base-directory: .
  test:
    files:
      - 'junit.xml'
    file-format: JUNITXML
    base-directory: .
```

---

## 🚀 Paso 5: Crear Pipeline en CodePipeline

### 5.1 Iniciar Creación del Pipeline

1. Ve al servicio CodePipeline
2. Clic en "Create pipeline"
3. Configura:

**Step 1: Choose pipeline settings**
```
Pipeline name: lab-app-pipeline
Description: Pipeline CI/CD para aplicación Node.js

Service role: New service role
Role name: AWSCodePipelineServiceRole-us-east-1-lab-app-pipeline
Allow CodePipeline to create a service role: ✅

Execution mode: Queued (default)

Pipeline type: V2 (recomendado)
```

4. Clic en "Next"

### 5.2 Configurar Stage de Source

```
Source provider: GitHub (Version 2)

Connection: Clic en "Connect to GitHub"
   - Se abrirá ventana para autorizar AWS Connector
   - Selecciona tu cuenta de GitHub
   - Clic en "Connect"

Repository name: tu-usuario/aws-lab-cicd-app
Branch name: main

Output artifact format: CodePipeline default

Trigger: Start the pipeline on source code change (Webhook)
```

Clic en "Next"

### 5.3 Configurar Stage de Build

```
Build provider: AWS CodeBuild
Region: US East (N. Virginia)

Project name: lab-app-build

Build type: Single build

Environment variables (opcional):
   Name: NODE_ENV
   Value: production
   Type: Plaintext
```

Clic en "Next"

### 5.4 Configurar Stage de Deploy

Para este laboratorio, usaremos Amazon ECS. Si aún no tienes un cluster ECS:

**Opción A: Deploy a ECS (Recomendado)**
```
Deploy provider: Amazon ECS
Region: US East (N. Virginia)

Cluster name: lab-ecs-cluster (o crea uno nuevo)
Service name: lab-app-service
```

**Opción B: Deploy a S3 (Static Website)**
```
Deploy provider: Amazon S3
Bucket: [nombre-de-tu-bucket]
Extract file before deploy: ✅
```

**Opción C: Skip deploy (para pruebas)**
```
Deploy provider: Skip deploy stage
```

Clic en "Next"

### 5.5 Revisar y Crear Pipeline

1. Revisa todas las configuraciones
2. Clic en "Create pipeline"

El pipeline se ejecutará automáticamente. Espera a que complete la primera ejecución.

---

## 🧪 Paso 6: Agregar Stage de Aprobación Manual

### 6.1 Editar el Pipeline

1. En CodePipeline, selecciona tu pipeline
2. Clic en "Edit"
3. Entre el stage de Build y Deploy, clic en "+ Add stage"
4. Nombre del stage: `Approval`
5. Clic en "Add action group"

**Action name:** `ManualApproval`
**Action provider:** `Manual approval`
**Bucket:** Selecciona tu bucket de artefactos

Configura notificaciones SNS (opcional):
- Crea un topic SNS
- Añade tu email como suscriptor
- Selecciona el topic en "SNS Topic ARN"

Guarda los cambios.

---

## 📊 Paso 7: Monitorear y Gestionar el Pipeline

### 7.1 Ver Ejecuciones del Pipeline

1. Ve a CodePipeline → tu pipeline
2. Verás el historial de ejecuciones:
   - **Source:** Descargar código de GitHub
   - **Build:** Compilar y testear
   - **Approval:** Aprobación manual (si configuraste)
   - **Deploy:** Desplegar a ECS/S3

### 7.2 Ver Detalles de Cada Stage

Clic en cualquier stage para ver:
- Duración de la ejecución
- Logs de CodeBuild
- Errores si los hubo
- Artefactos generados

### 7.3 Reintentar Ejecuciones Fallidas

1. Selecciona la ejecución fallida
2. Clic en "Retry"
3. El pipeline reintentará desde el stage fallido

---

## 🔄 Paso 8: Probar el Pipeline

### 8.1 Hacer Cambios en el Código

En tu máquina local, modifica `index.js`:

```javascript
// Añade al final del archivo
app.get('/api/status', (req, res) => {
  res.json({
    status: 'operational',
    pipeline: 'AWS CodePipeline',
    deployment: 'automated',
    timestamp: new Date().toISOString()
  });
});
```

Crea un test para el nuevo endpoint en `__tests__/unit/status.test.js`:

```javascript
const request = require('supertest');
const app = require('../../index');

describe('GET /api/status', () => {
  test('should return operational status', async () => {
    const response = await request(app)
      .get('/api/status')
      .expect(200);

    expect(response.body.status).toBe('operational');
    expect(response.body.pipeline).toBe('AWS CodePipeline');
    expect(response.body).toHaveProperty('timestamp');
  });
});
```

### 8.2 Commit y Push

```bash
git add .
git commit -m "Add status endpoint with automated deployment"
git push origin main
```

### 8.3 Verificar Pipeline

1. Ve a CodePipeline y observa la nueva ejecución
2. Debería ver:
   - Source: ✅ Succeeded (obtiene el nuevo commit)
   - Build: ✅ Succeeded (compila y corre tests)
   - Approval: ⏸️ Waiting (si configuraste aprobación)
   - Deploy: 🔄 In Progress

3. Si tienes aprobación manual, aprueba el stage
4. Espera a que el deployment complete

### 8.4 Verificar el Despliegue

Accede a tu aplicación desplegada (URL del ALB, o endpoint ECS):

```bash
# Probar el nuevo endpoint
curl http://tu-alb-url/api/status

# Respuesta esperada:
# {
#   "status": "operational",
#   "pipeline": "AWS CodePipeline",
#   "deployment": "automated",
#   "timestamp": "2025-04-29T..."
# }
```

---

## 🎯 Bonus: Pipeline Avanzado con Múltiples Stages

### 9.1 Pipeline Multi-Stage

Crea un pipeline con stages adicionales:

```
Source → Build → Test → Security Scan → Approval → Deploy Staging → Test E2E → Deploy Production
```

### 9.2 Agregar Security Scanning

Añade un stage con CodeBuild para escaneo de seguridad:

**buildspec-security.yml:**

```yaml
version: 0.2

phases:
  install:
    commands:
      - npm install -g npm-audit-resolver
      
  build:
    commands:
      - echo "Escaneando vulnerabilidades..."
      - npm audit --json > audit-report.json || true
      - echo "Revisando dependencias obsoletas..."
      - npm outdated || true
      
artifacts:
  files:
    - audit-report.json
```

### 9.3 Deploy a Múltiples Entornos

Configura stages de deploy separados:

1. **Deploy Staging:** ECS cluster staging
2. **Run Tests:** Pruebas E2E contra staging
3. **Manual Approval:** Aprobación para producción
4. **Deploy Production:** ECS cluster production

### 9.4 Configurar Notificaciones

1. Ve a CodePipeline → Settings → Notifications
2. Clic en "Create notification rule"
3. Configura:
   ```
   Rule name: lab-pipeline-notifications
   Events:
     ⃞ Pipeline execution failed
     ⃞ Pipeline execution succeeded
     ⃞ Manual approval needed
     ⃞ Stage execution failed
   
   Target: SNS topic
   Topic: arn:aws:sns:us-east-1:...:lab-notifications
   ```

---

## ✅ Verificación

- [ ] Repositorio GitHub creado con aplicación Node.js
- [ ] Aplicación incluye tests unitarios e integración
- [ ] Dockerfile creado para contenerización
- [ ] Rol IAM `LabCodePipelineRole` creado con permisos adecuados
- [ ] Rol IAM `LabCodeBuildRole` creado con permisos adecuados
- [ ] Bucket S3 para artefactos creado
- [ ] Proyecto CodeBuild `lab-app-build` creado
- [ ] Proyecto CodeBuild `lab-app-test` creado (opcional)
- [ ] Pipeline CodePipeline creado con stages: Source → Build → Deploy
- [ ] Webhook de GitHub configurado y funcionando
- [ ] Primera ejecución del pipeline completada exitosamente
- [ ] Cambios en código activan ejecución automática del pipeline
- [ ] Artefactos de build guardados en S3
- [ ] Aplicación desplegada y accesible
- [ ] Nuevo endpoint `/api/status` funcionando después del deploy

---

## 🧹 Limpieza

### Eliminar Recursos en Orden

**IMPORTANTE:** Elimina en este orden para evitar errores.

1. **Eliminar Pipeline:**
   - CodePipeline → lab-app-pipeline
   - Clic en "Delete pipeline"
   - Escribe el nombre para confirmar

2. **Eliminar Proyectos CodeBuild:**
   - CodeBuild → Build projects
   - Selecciona: lab-app-build, lab-app-test
   - Actions → Delete

3. **Eliminar Rol de Servicio CodePipeline:**
   - IAM → Roles
   - Selecciona `LabCodePipelineRole` y `LabCodeBuildRole`
   - Delete

4. **Vaciar y Eliminar Bucket S3:**
   ```bash
   aws s3 rm s3://lab-codepipeline-artifacts-[tu-iniciales] --recursive
   aws s3 rb s3://lab-codepipeline-artifacts-[tu-iniciales]
   ```

5. **Eliminar Recursos ECS (si los creaste):**
   - ECS → Services → Eliminar service
   - ECS → Clusters → Eliminar cluster
   - ECR → Repositories → Eliminar imágenes y repositorio

6. **Eliminar Repositorio GitHub (opcional):**
   - Ve a tu repo en GitHub
   - Settings → Delete this repository

7. **Eliminar Conexión GitHub:**
   - CodePipeline → Settings → Connections
   - Selecciona la conexión → Delete

---

## 📚 Recursos Adicionales

- [Guía de CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html)
- [Guía de CodeBuild](https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html)
- [Guía de CodeDeploy](https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html)
- [AWS CI/CD Blog](https://aws.amazon.com/blogs/devops/category/continuous-integration/)
- [CodePipeline Actions Reference](https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html)
- [Ejemplos de Pipelines](https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials.html)

---

## 🎯 Siguiente Laboratorio

→ [Lab 09: Monitoreo con CloudWatch](lab-09-monitoreo-cloudwatch.md)

---

*Última actualización: Abril 2025*
