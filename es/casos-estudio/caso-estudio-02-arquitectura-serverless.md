# Caso de Estudio: Arquitectura Serverless para Startup

> **Empresa:** TaskFlow (SaaS de gestión de proyectos)  
> **Industria:** Software / Productivity  
> **Duración:** 6 meses desde MVP hasta escala  
> **Equipo:** 3 developers full-stack, 1 DevOps

---

## Situación Inicial

### Contexto

TaskFlow es una startup que lanzó un SaaS para gestión de tareas y proyectos. Iniciaron con una arquitectura monolítica tradicional:

- **Servidor:** VPS con Node.js/Express
- **Base de datos:** MongoDB en el mismo servidor
- **Frontend:** React estático servido desde CDN
- **Costo inicial:** $200/mes

### El Problema de Escalabilidad

Con el crecimiento de usuarios, enfrentaron:

| Métrica | Mes 1 | Mes 6 | Mes 12 |
|---------|-------|-------|--------|
| Usuarios | 500 | 8,000 | 45,000 |
| Requests/día | 10K | 200K | 1.5M |
| Costo infra | $200 | $450 | $2,800 |
| Uptime | 99.8% | 95.2% | 92.5% |

**Problemas críticos:**
- Database locking durante horas pico
- Deployments causaban downtime
- No autoscaling, over-provisioning constante
- Deuda técnica acumulada

### Decisión

Reescribir completamente en arquitectura serverless AWS para:
1. **Pay-per-use:** Cobrar solo por requests reales
2. **Auto-scaling:** De 0 a millones sin intervención
3. **Faster deployments:** Múltiples deploys diarios
4. **Focus en producto:** Menos ops, más features

---

## Arquitectura Serverless

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                    SERVERLESS ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Client Layer                                                   │
│   ┌─────────────────────────────────────────────────────┐      │
│   │  React SPA              Mobile Apps                │      │
│   │  (S3 + CloudFront)      (React Native)             │      │
│   │                         + Amplify                 │      │
│   └────────────────────┬────────────────────────────────┘      │
│                        │                                         │
│                        ▼                                         │
│   ┌─────────────────────────────────────────────────────┐      │
│   │                API GATEWAY (HTTP API)              │      │
│   │  ┌──────────────┬──────────────┬──────────────┐     │      │
│   │  │ /auth        │ /tasks       │ /projects    │     │      │
│   │  │ /users       │ /teams       │ /webhooks    │     │      │
│   │  └──────┬───────┘ └──────┬─────┘ └──────┬─────┘     │      │
│   └─────────┼───────────────┼──────────────┼───────────┘      │
│             │               │               │                  │
│             ▼               ▼               ▼                  │
│   ┌─────────────────────────────────────────────────────┐      │
│   │            LAMBDA LAYER (Business Logic)           │      │
│   │                                                      │      │
│   │  ┌───────────┐  ┌───────────┐  ┌───────────┐      │      │
│   │  │ auth-fn   │  │ tasks-fn  │  │ teams-fn  │      │      │
│   │  │ (Node 18) │  │ (Node 18) │  │ (Node 18) │      │      │
│   │  │ 512 MB    │  │ 512 MB    │  │ 512 MB    │      │      │
│   │  │ 3s timeout│  │ 10s       │  │ 3s        │      │      │
│   │  └───────────┘  └───────────┘  └───────────┘      │      │
│   │                                                      │      │
│   │  ┌───────────┐  ┌───────────┐  ┌───────────┐      │      │
│   │  │ webhook-fn│  │ notify-fn │  │ report-fn │      │      │
│   │  │ (Python)  │  │ (Node)    │  │ (Python)  │      │      │
│   │  └───────────┘  └───────────┘  └───────────┘      │      │
│   └─────────────────────────────────────────────────────┘      │
│                              │                                   │
│           ┌──────────────────┼──────────────────┐                │
│           │                  │                  │                │
│           ▼                  ▼                  ▼                │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│   │   DynamoDB   │  │    S3        │  │ EventBridge  │        │
│   │   (Tables)   │  │   (Storage)  │  │ (Orchestration│        │
│   │              │  │              │  │              │        │
│   │  Users       │  │  Attachments │  │  Scheduled   │        │
│   │  Tasks       │  │  Exports     │  │  Events      │        │
│   │  Projects    │  │  Backups     │  │  Webhooks    │        │
│   │  Teams       │  │              │  │              │        │
│   └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                  │
│   ┌─────────────────────────────────────────────────────┐      │
│   │              COGNITO (AuthN/AuthZ)                  │      │
│   │                                                      │      │
│   │  • User Pools (50,000+ users)                       │      │
│   │  • Identity Pools (IAM roles)                       │      │
│   │  • OAuth 2.0 / OIDC                                 │      │
│   │  • MFA support                                      │      │
│   │  • Social login (Google, Microsoft)                 │      │
│   └─────────────────────────────────────────────────────┘      │
│                                                                  │
│   ┌─────────────────────────────────────────────────────┐      │
│   │              INTEGRATION LAYER                      │      │
│   │                                                      │      │
│   │  ┌──────────────┐  ┌──────────────┐                │      │
│   │  │   SES        │  │   SNS        │                │      │
│   │  │   (Email)    │  │   (SMS)      │                │      │
│   │  └──────────────┘  └──────────────┘                │      │
│   │                                                      │      │
│   │  ┌──────────────┐  ┌──────────────┐                │      │
│   │  │   SQS        │  │ Step Functions│               │      │
│   │  │   (Queues)   │  │ (Workflows)  │                │      │
│   │  └──────────────┘  └──────────────┘                │      │
│   └─────────────────────────────────────────────────────┘      │
│                                                                  │
│   ┌─────────────────────────────────────────────────────┐      │
│   │              OBSERVABILITY                          │      │
│   │                                                      │      │
│   │  CloudWatch Logs  •  X-Ray Tracing  •  Alarms      │      │
│   └─────────────────────────────────────────────────────┘      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Componentes Detallados

### 1. API Gateway - HTTP API

```yaml
# template.yaml (SAM)
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Globals:
  Function:
    Timeout: 10
    MemorySize: 512
    Runtime: nodejs18.x
    Architectures:
      - x86_64
    Environment:
      Variables:
        TABLE_NAME: !Ref TasksTable
        LOG_LEVEL: INFO

Resources:
  # HTTP API
  TaskFlowApi:
    Type: AWS::Serverless::HttpApi
    Properties:
      Auth:
        Authorizers:
          CognitoAuthorizer:
            IdentitySource: $request.header.Authorization
            JwtConfiguration:
              issuer: !Sub https://cognito-idp.${AWS::Region}.amazonaws.com/${UserPoolId}
              audience:
                - !Ref UserPoolClient
        DefaultAuthorizer: CognitoAuthorizer
      CorsConfiguration:
        AllowOrigins:
          - "https://app.taskflow.com"
          - "http://localhost:3000"
        AllowMethods:
          - GET
          - POST
          - PUT
          - DELETE
          - PATCH
        AllowHeaders:
          - "*"
        MaxAge: 600

  # Auth Lambda
  AuthFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/auth/
      Handler: index.handler
      Events:
        Register:
          Type: HttpApi
          Properties:
            ApiId: !Ref TaskFlowApi
            Path: /auth/register
            Method: POST
            Auth:
              Authorizer: NONE
        Login:
          Type: HttpApi
          Properties:
            ApiId: !Ref TaskFlowApi
            Path: /auth/login
            Method: POST
            Auth:
              Authorizer: NONE
        Refresh:
          Type: HttpApi
          Properties:
            ApiId: !Ref TaskFlowApi
            Path: /auth/refresh
            Method: POST

  # Tasks Lambda
  TasksFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/tasks/
      Handler: index.handler
      Policies:
        - DynamoDBCrudPolicy:
            TableName: !Ref TasksTable
      Events:
        ListTasks:
          Type: HttpApi
          Properties:
            ApiId: !Ref TaskFlowApi
            Path: /tasks
            Method: GET
        CreateTask:
          Type: HttpApi
          Properties:
            ApiId: !Ref TaskFlowApi
            Path: /tasks
            Method: POST
        UpdateTask:
          Type: HttpApi
          Properties:
            ApiId: !Ref TaskFlowApi
            Path: /tasks/{id}
            Method: PUT
        DeleteTask:
          Type: HttpApi
          Properties:
            ApiId: !Ref TaskFlowApi
            Path: /tasks/{id}
            Method: DELETE
```

### 2. Lambda Functions - Best Practices

```javascript
// src/tasks/index.js
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

// Lambda Power Tuning: Memory vs Duration
// 512MB provides optimal cost/performance ratio for this workload

exports.handler = async (event) => {
    // Structured logging
    const requestId = event.requestContext?.requestId;
    console.log(JSON.stringify({
        level: 'INFO',
        requestId,
        path: event.rawPath,
        method: event.requestContext?.http?.method,
        timestamp: new Date().toISOString()
    }));
    
    try {
        const routeKey = `${event.requestContext.http.method} ${event.rawPath}`;
        
        switch (routeKey) {
            case 'GET /tasks':
                return await listTasks(event);
            case 'POST /tasks':
                return await createTask(event);
            case 'PUT /tasks/{id}':
                return await updateTask(event);
            case 'DELETE /tasks/{id}':
                return await deleteTask(event);
            default:
                return response(404, { error: 'Not found' });
        }
    } catch (error) {
        console.error(JSON.stringify({
            level: 'ERROR',
            requestId,
            error: error.message,
            stack: error.stack
        }));
        
        return response(500, { error: 'Internal server error' });
    }
};

async function listTasks(event) {
    // Get user from Cognito authorizer
    const userId = event.requestContext.authorizer.jwt.claims.sub;
    const { status, limit = '20', nextToken } = event.queryStringParameters || {};
    
    // Query with pagination
    const params = {
        TableName: process.env.TABLE_NAME,
        KeyConditionExpression: 'userId = :userId',
        ExpressionAttributeValues: {
            ':userId': userId
        },
        Limit: parseInt(limit),
        ScanIndexForward: false // Most recent first
    };
    
    if (status) {
        params.FilterExpression = '#status = :status';
        params.ExpressionAttributeNames = { '#status': 'status' };
        params.ExpressionAttributeValues[':status'] = status;
    }
    
    if (nextToken) {
        params.ExclusiveStartKey = JSON.parse(Buffer.from(nextToken, 'base64').toString());
    }
    
    const result = await dynamodb.query(params).promise();
    
    // Generate pagination token
    const paginationToken = result.LastEvaluatedKey 
        ? Buffer.from(JSON.stringify(result.LastEvaluatedKey)).toString('base64')
        : null;
    
    return response(200, {
        tasks: result.Items,
        nextToken: paginationToken,
        count: result.Count
    });
}

async function createTask(event) {
    const userId = event.requestContext.authorizer.jwt.claims.sub;
    const body = JSON.parse(event.body);
    
    // Validation
    if (!body.title || body.title.length > 200) {
        return response(400, { error: 'Title is required and must be under 200 characters' });
    }
    
    const taskId = `task_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const now = new Date().toISOString();
    
    const task = {
        userId,
        taskId,
        title: body.title,
        description: body.description || '',
        status: 'pending',
        priority: body.priority || 'medium',
        dueDate: body.dueDate || null,
        tags: body.tags || [],
        createdAt: now,
        updatedAt: now,
        ttl: body.dueDate ? Math.floor(new Date(body.dueDate).getTime() / 1000) + 86400 : null
    };
    
    await dynamodb.put({
        TableName: process.env.TABLE_NAME,
        Item: task,
        ConditionExpression: 'attribute_not_exists(taskId)' // Prevent overwrites
    }).promise();
    
    // Async: Publish event for notifications
    await publishEvent('TASK_CREATED', { userId, taskId, title: task.title });
    
    return response(201, { task });
}

async function publishEvent(eventType, data) {
    // Fire-and-forget event publishing
    // Failures are logged but don't block response
    const eventBridge = new AWS.EventBridge();
    try {
        await eventBridge.putEvents({
            Entries: [{
                Source: 'taskflow.tasks',
                DetailType: eventType,
                Detail: JSON.stringify(data),
                EventBusName: process.env.EVENT_BUS_NAME
            }]
        }).promise();
    } catch (err) {
        console.error('Failed to publish event:', err);
    }
}

function response(statusCode, body) {
    return {
        statusCode,
        headers: {
            'Content-Type': 'application/json',
            'X-Request-ID': crypto.randomUUID()
        },
        body: JSON.stringify(body)
    };
}
```

### 3. DynamoDB - Data Model

```javascript
// Single-table design for efficiency
// Primary patterns:
// 1. Get tasks by user (PK: userId, SK: taskId)
// 2. Get tasks by project (GSI1: projectId, SK: dueDate)
// 3. Get tasks by team (GSI2: teamId, SK: createdAt)

const tableSchema = {
    TableName: 'TaskFlow',
    KeySchema: [
        { AttributeName: 'PK', KeyType: 'HASH' },
        { AttributeName: 'SK', KeyType: 'RANGE' }
    ],
    AttributeDefinitions: [
        { AttributeName: 'PK', AttributeType: 'S' },
        { AttributeName: 'SK', AttributeType: 'S' },
        { AttributeName: 'GSI1PK', AttributeType: 'S' },
        { AttributeName: 'GSI1SK', AttributeType: 'S' },
        { AttributeName: 'GSI2PK', AttributeType: 'S' },
        { AttributeName: 'GSI2SK', AttributeType: 'S' }
    ],
    GlobalSecondaryIndexes: [
        {
            IndexName: 'GSI1',
            KeySchema: [
                { AttributeName: 'GSI1PK', KeyType: 'HASH' },
                { AttributeName: 'GSI1SK', KeyType: 'RANGE' }
            ],
            Projection: { ProjectionType: 'ALL' }
        },
        {
            IndexName: 'GSI2',
            KeySchema: [
                { AttributeName: 'GSI2PK', KeyType: 'HASH' },
                { AttributeName: 'GSI2SK', KeyType: 'RANGE' }
            ],
            Projection: { ProjectionType: 'ALL' }
        }
    ],
    BillingMode: 'PAY_PER_REQUEST', // Auto-scaling
    PointInTimeRecovery: { Enabled: true },
    SSESpecification: {
        SSEEnabled: true,
        SSEType: 'KMS'
    }
};

// Item examples:
const taskItem = {
    PK: 'USER#123',           // Partition Key
    SK: 'TASK#456',           // Sort Key
    GSI1PK: 'PROJECT#789',    // GSI for project queries
    GSI1SK: '2024-04-29',
    GSI2PK: 'TEAM#ABC',       // GSI for team queries
    GSI2SK: '2024-04-29T10:00:00Z',
    
    // Entity data
    title: 'Complete serverless migration',
    status: 'in_progress',
    priority: 'high',
    
    // TTL for auto-deletion of completed tasks
    ttl: 1714399200
};
```

### 4. Event-Driven Architecture

```yaml
# EventBridge rules
NotificationRules:
  TaskCreatedRule:
    Type: AWS::Events::Rule
    Properties:
      EventBusName: !Ref EventBus
      EventPattern:
        source:
          - taskflow.tasks
        detail-type:
          - TASK_CREATED
      Targets:
        - Id: NotificationFunction
          Arn: !GetAtt NotificationFunction.Arn
        - Id: AnalyticsQueue
          Arn: !GetAtt AnalyticsQueue.Arn

  DailyReportRule:
    Type: AWS::Events::Rule
    Properties:
      EventBusName: !Ref EventBus
      ScheduleExpression: cron(0 9 * * ? *) # 9 AM UTC daily
      Targets:
        - Id: ReportGenerator
          Arn: !GetAtt ReportFunction.Arn

# Step Functions for complex workflows
TaskAssignmentWorkflow:
  Type: AWS::StepFunctions::StateMachine
  Properties:
    RoleArn: !GetAtt StatesExecutionRole.Arn
    Definition:
      Comment: "Assign task to team member with approval"
      StartAt: "CreateAssignment"
      States:
        CreateAssignment:
          Type: Task
          Resource: !GetAtt CreateAssignmentFunction.Arn
          Next: "WaitForApproval"
          
        WaitForApproval:
          Type: Wait
          SecondsPath: "$.approvalTimeout"
          Next: "CheckApproval"
          
        CheckApproval:
          Type: Task
          Resource: !GetAtt CheckApprovalFunction.Arn
          Next: "ApprovalDecision"
          
        ApprovalDecision:
          Type: Choice
          Choices:
            - Variable: "$.approvalStatus"
              StringEquals: "approved"
              Next: "NotifyAssignee"
            - Variable: "$.approvalStatus"
              StringEquals: "rejected"
              Next: "NotifyManager"
          Default: "Escalate"
          
        NotifyAssignee:
          Type: Task
          Resource: !GetAtt SendNotificationFunction.Arn
          End: true
          
        NotifyManager:
          Type: Task
          Resource: !GetAtt SendNotificationFunction.Arn
          End: true
          
        Escalate:
          Type: Task
          Resource: !GetAtt EscalateFunction.Arn
          End: true
```

---

## CI/CD Pipeline

```yaml
# buildspec.yml
version: 0.2

phases:
  install:
    runtime-versions:
      nodejs: 18
    commands:
      - npm ci
      - pip install aws-sam-cli
      
  pre_build:
    commands:
      - npm run lint
      - npm run test:unit
      - sam validate
      
  build:
    commands:
      - sam build
      - npm run test:integration
      
  post_build:
    commands:
      - sam package --s3-bucket $ARTIFACT_BUCKET --output-template-file packaged.yaml
      - sam deploy --template-file packaged.yaml --stack-name taskflow-$ENV --capabilities CAPABILITY_IAM

artifacts:
  files:
    - packaged.yaml
    - swagger.yaml
```

---

## Resultados

### Métricas Post-Migración

| Métrica | Legacy | Serverless | Mejora |
|---------|--------|------------|--------|
| Costo mensual | $2,800 | $420 | -85% |
| Deploys/semana | 2 | 35 | +1,650% |
| Cold start | N/A | 150ms | - |
| Latencia p99 | 2.3s | 180ms | -92% |
| Uptime | 92.5% | 99.99% | +7.49% |
| Usuarios/soporte | 1,500 | 10,000 | +566% |

### Cost Breakdown (Monthly)

| Servicio | Costo |
|----------|-------|
| Lambda (2M requests) | $0.40 |
| API Gateway | $3.50 |
| DynamoDB | $45.00 |
| Cognito (50K users) | $275.00 |
| S3 + CloudFront | $42.00 |
| CloudWatch | $18.00 |
| Secrets Manager | $8.00 |
| **Total** | **$420** |

### Developer Experience

```
Deployment time:    3 min (vs 45 min antes)
Infrastructure:     Code (vs tickets)
Scaling:           Automatic (vs manual)
Debugging:         CloudWatch/X-Ray (vs SSH)
Local testing:      SAM local (vs staging)
```

---

## Lecciones Aprendidas

### 1. Lambda Cold Starts
- **Problema:** 800ms para invocaciones poco frecuentes
- **Solución:** Provisioned concurrency para endpoints críticos
- **Costo adicional:** $18/mes para 100 concurrentes

### 2. DynamoDB Hot Partitions
- **Problema:** Un usuario con 10K tareas causaba throttling
- **Solución:** Write sharding con suffixed keys
- **Resultado:** Throughput uniforme

### 3. API Gateway Latency
- **Problema:** 200ms adicionales vs ALB
- **Solución:** HTTP API en lugar de REST API
- **Mejora:** 60% más rápido, 70% más barato

### 4. Local Testing
- SAM CLI para local development
- DynamoDB Local para tests
- Step Functions Local para workflows

---

*Caso de estudio basado en migraciones reales de startups a serverless.*

*Última actualización: Abril 2025*
