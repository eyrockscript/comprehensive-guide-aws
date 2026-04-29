# Caso de Estudio: Microservicios con Containers

> **Empresa:** LogisticsPro (Plataforma de logística)  
> **Industria:** Transporte / Supply Chain  
> **Duración:** 14 meses  
> **Equipo:** 18 developers, 4 DevOps, 3 arquitectos

---

## Situación Inicial

### Contexto

LogisticsPro operaba una plataforma monolítica Java/Spring que gestionaba:
- **50,000 envíos diarios** para 2,000 clientes B2B
- **Integraciones** con 150 carriers (DHL, FedEx, UPS, etc.)
- **Tracking en tiempo real** de 100,000+ dispositivos IoT

### Problemas del Monolito

```
┌─────────────────────────────────────────────────────────────────┐
│                     MONOLOTO LEGACY                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐  │
│   │              LogisticsPro Platform                       │  │
│   │                                                          │  │
│   │  ┌─────────┬─────────┬─────────┬─────────┬─────────┐     │  │
│   │  │  Auth   │Shipments│Carriers │Tracking │Billing │     │  │
│   │  │         │         │         │         │         │     │  │
│   │  │  50K    │  200K   │  150    │  100K   │  30K    │     │  │
│   │  │  LOC    │  LOC    │  LOC    │  LOC    │  LOC    │     │  │
│   │  └─────────┴─────────┴─────────┴─────────┴─────────┘     │  │
│   │                                                          │  │
│   │  Single MySQL DB: 800GB, 500 tables                       │  │
│   │                                                          │  │
│   └─────────────────────────────────────────────────────────┘  │
│                                                                  │
│   Problemas:                                                     │
│   • Deployments cada 2 semanas (miedo al cambio)                │
│   • Un módulo lento afecta todo el sistema                        │
│   • Escalado vertical limitado ($50K/mes en hardware)           │
│   • Teams bloqueados entre sí (merge conflicts constantes)      │
│   • 2 hours downtime/mes (SLA incumplido)                        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Drivers para Microservicios

1. **Escalado independiente:** Tracking necesita 10x que Billing
2. **Polyglot persistence:** Tiempo real (DynamoDB), analítica (Redshift)
3. **Team autonomy:** 6 equipos con autonomía de deploy
4. **Resiliencia:** Aislamiento de fallos

---

## Arquitectura de Microservicios

### Diagrama General

```
┌─────────────────────────────────────────────────────────────────┐
│                   MICROSERVICES PLATFORM                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐    │
│   │                 CLIENTS                                │    │
│   │  Web App  │  Mobile Apps  │  Partner APIs  │  IoT    │    │
│   └────────────────────┬──────────────────────────────────┘    │
│                        │                                         │
│                        ▼                                         │
│   ┌─────────────────────────────────────────────────────────┐    │
│   │           API GATEWAY (Kong/AWS API GW)               │    │
│   │  • Rate limiting: 10K req/min per client              │    │
│   │  • Authentication: JWT validation                   │    │
│   │  • Routing: /shipments/* → shipment-service         │    │
│   │  • Caching: 5 min for GET /tracking/*               │    │
│   └────────────────────┬──────────────────────────────────┘    │
│                        │                                         │
│                        ▼                                         │
│   ┌─────────────────────────────────────────────────────────┐    │
│   │              SERVICE MESH (AWS App Mesh)              │    │
│   │  • mTLS entre servicios                                 │    │
│   │  • Circuit breaker pattern                              │    │
│   │  • Distributed tracing (X-Ray)                          │    │
│   └────────────────────┬──────────────────────────────────┘    │
│                        │                                         │
│           ┌────────────┼────────────┬────────────┐             │
│           │            │            │            │             │
│           ▼            ▼            ▼            ▼             │
│   ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐   │
│   │  Shipment │ │  Tracking │ │  Carrier  │ │  Billing  │   │
│   │  Service  │ │  Service  │ │  Service  │ │  Service  │   │
│   │           │ │           │ │           │ │           │   │
│   │ ECS Fargate│ │ ECS Fargate│ │ ECS Fargate│ │ ECS Fargate│   │
│   │ 8 tasks   │ │ 20 tasks  │ │ 4 tasks   │ │ 3 tasks   │   │
│   │           │ │           │ │           │ │           │   │
│   │ Node.js   │ │ Go        │ │ Java      │ │ Python    │   │
│   └─────┬─────┘ └─────┬─────┘ └─────┬─────┘ └─────┬─────┘   │
│         │             │             │             │           │
│         └─────────────┴─────────────┴─────────────┘           │
│                           │                                    │
│           ┌───────────────┼───────────────┐                    │
│           │               │               │                    │
│           ▼               ▼               ▼                    │
│   ┌───────────┐   ┌───────────┐   ┌───────────┐              │
│   │  DynamoDB │   │   Kafka   │   │ PostgreSQL│              │
│   │ (shipments)│  │(events)   │   │ (billing) │              │
│   └───────────┘   └───────────┘   └───────────┘              │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐    │
│   │              SHARED SERVICES                            │    │
│   │  • Service Discovery (Cloud Map)                        │    │
│   │  • Config Management (Parameter Store)                  │    │
│   │  • Secrets (Secrets Manager)                          │    │
│   │  • Message Queue (SQS)                                  │    │
│   └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐    │
│   │              OBSERVABILITY                              │    │
│   │  • CloudWatch Logs (centralizado)                       │    │
│   │  • X-Ray (distributed tracing)                          │    │
│   │  • Prometheus + Grafana (métricas)                    │    │
│   │  • PagerDuty (alerting)                                 │    │
│   └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementación con ECS

### 1. Cluster Setup

```hcl
# terraform/ecs-cluster.tf
resource "aws_ecs_cluster" "logistics" {
  name = "logistics-pro-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = "/ecs/exec-logs"
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "logistics" {
  cluster_name = aws_ecs_cluster.logistics.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 1
    capacity_provider = "FARGATE"
  }

  default_capacity_provider_strategy {
    weight            = 3
    capacity_provider = "FARGATE_SPOT"
  }
}

# Auto-scaling target
resource "aws_appautoscaling_target" "shipment_service" {
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.logistics.name}/${aws_ecs_service.shipment.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "shipment_cpu" {
  name               = "shipment-cpu-auto-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.shipment_service.resource_id
  scalable_dimension = aws_appautoscaling_target.shipment_service.scalable_dimension
  service_namespace  = aws_appautoscaling_target.shipment_service.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = 70.0
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
```

### 2. Service Definitions

```json
{
  "family": "shipment-service",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::account:role/shipment-service-task-role",
  "containerDefinitions": [
    {
      "name": "shipment-api",
      "image": "logisticspro/shipment-service:v2.3.1",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "DB_TABLE",
          "value": "shipments"
        }
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:shipment-db-url"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/shipment-service",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "ulimits": [
        {
          "name": "nofile",
          "softLimit": 65536,
          "hardLimit": 65536
        }
      ]
    },
    {
      "name": "xray-daemon",
      "image": "amazon/aws-xray-daemon",
      "portMappings": [
        {
          "containerPort": 2000,
          "protocol": "udp"
        }
      ],
      "essential": false
    }
  ]
}
```

### 3. CI/CD Pipeline

```yaml
# buildspec.yml
version: 0.2

env:
  variables:
    AWS_DEFAULT_REGION: us-east-1
    ECR_REPO: logisticspro
    IMAGE_TAG: ${CODEBUILD_BUILD_NUMBER}
  secrets-manager:
    DOCKERHUB_TOKEN: dockerhub:credentials

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
      - docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_TOKEN
      - SERVICE_NAME=$(echo $CODEBUILD_BUILD_ID | cut -d'/' -f2)
      
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $SERVICE_NAME:$IMAGE_TAG -f services/$SERVICE_NAME/Dockerfile .
      - docker tag $SERVICE_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO/$SERVICE_NAME:$IMAGE_TAG
      - docker tag $SERVICE_NAME:$IMAGE_TAG $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO/$SERVICE_NAME:latest
      
      # Security scanning
      - echo Running security scan...
      - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock 
          aquasec/trivy image --exit-code 1 --severity HIGH,CRITICAL $SERVICE_NAME:$IMAGE_TAG
      
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO/$SERVICE_NAME:$IMAGE_TAG
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO/$SERVICE_NAME:latest
      
      # Update ECS service
      - echo Updating ECS service...
      - aws ecs update-service --cluster logistics-pro-cluster --service $SERVICE_NAME --force-new-deployment
      
      # Wait for deployment
      - echo Waiting for deployment to stabilize...
      - aws ecs wait services-stable --cluster logistics-pro-cluster --services $SERVICE_NAME

artifacts:
  files:
    - services/$SERVICE_NAME/task-definition.json
    - appspec.yml
```

### 4. Service Mesh Configuration

```yaml
# appmesh/shipment-service.yaml
apiVersion: appmesh.k8s.aws/v1beta2
kind: Mesh
metadata:
  name: logistics-mesh
spec:
  namespaceSelector:
    matchLabels:
      mesh: logistics

---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualNode
metadata:
  name: shipment-service
  namespace: logistics
spec:
  podSelector:
    matchLabels:
      app: shipment-service
  listeners:
    - portMapping:
        port: 3000
        protocol: http
      healthCheck:
        healthyThreshold: 2
        intervalMillis: 5000
        path: /health
        port: 3000
        protocol: http
        timeoutMillis: 2000
        unhealthyThreshold: 3
      timeout:
        http:
          perRequest:
            value: 30
            unit: s
  serviceDiscovery:
    awsCloudMap:
      namespaceName: logistics.local
      serviceName: shipment-service
  backendDefaults:
    clientPolicy:
      tls:
        enforce: true
        mode: STRICT
        certificate:
          acm:
            certificateArn: arn:aws:acm:region:account:certificate/cert-id

---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualService
metadata:
  name: shipment-service
  namespace: logistics
spec:
  awsName: shipment-service.logistics.local
  provider:
    virtualNode:
      virtualNodeRef:
        name: shipment-service
```

---

## Patrones Implementados

### 1. Circuit Breaker

```javascript
// tracking-service/circuit-breaker.js
const CircuitBreaker = require('opossum');
const axios = require('axios');

const carrierRequest = async (carrierId, trackingNumber) => {
  const response = await axios.get(
    `${process.env.CARRIER_SERVICE_URL}/api/v1/track`,
    { params: { carrierId, trackingNumber }, timeout: 5000 }
  );
  return response.data;
};

const breaker = new CircuitBreaker(carrierRequest, {
  timeout: 3000, // 3 seconds
  errorThresholdPercentage: 50,
  resetTimeout: 30000, // 30 seconds
  volumeThreshold: 10
});

breaker.fallback(() => ({
  status: 'unavailable',
  lastKnownLocation: null,
  estimatedDelivery: null,
  message: 'Carrier tracking temporarily unavailable'
}));

breaker.on('open', () => {
  console.error('Circuit breaker opened for carrier service');
  // Alert to CloudWatch
});

module.exports = breaker;
```

### 2. Saga Pattern

```python
# orchestrator/saga_shipment.py
import json
import boto3
from aws_xray_sdk.core import xray_recorder

stepfunctions = boto3.client('stepfunctions')

class CreateShipmentSaga:
    """
    Saga orchestration for shipment creation
    Compensating transactions on failure
    """
    
    def __init__(self):
        self.state_machine_arn = 'arn:aws:states:region:account:stateMachine:CreateShipmentSaga'
    
    @xray_recorder.capture('saga.execute')
    def execute(self, shipment_data):
        """
        Steps:
        1. Validate shipment
        2. Reserve inventory
        3. Create shipment record
        4. Notify carrier
        5. Send confirmation email
        
        On failure: execute compensations in reverse order
        """
        
        execution_input = {
            "shipment": shipment_data,
            "correlationId": shipment_data['requestId']
        }
        
        response = stepfunctions.start_execution(
            stateMachineArn=self.state_machine_arn,
            name=f"shipment-{shipment_data['id']}",
            input=json.dumps(execution_input)
        )
        
        return response['executionArn']

# Step Functions ASL definition
SAGA_DEFINITION = {
    "Comment": "Create Shipment Saga",
    "StartAt": "ValidateShipment",
    "States": {
        "ValidateShipment": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:validate-shipment",
            "Next": "ReserveInventory",
            "Catch": [{
                "ErrorEquals": ["States.ALL"],
                "Next": "ShipmentFailed"
            }]
        },
        "ReserveInventory": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:reserve-inventory",
            "Next": "CreateShipmentRecord",
            "Catch": [{
                "ErrorEquals": ["States.ALL"],
                "Next": "CompensateInventory"
            }]
        },
        "CreateShipmentRecord": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:create-shipment",
            "Next": "NotifyCarrier",
            "Catch": [{
                "ErrorEquals": ["States.ALL"],
                "Next": "CompensateShipment"
            }]
        },
        "NotifyCarrier": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:notify-carrier",
            "Next": "SendConfirmation",
            "Catch": [{
                "ErrorEquals": ["States.ALL"],
                "Next": "CompensateCarrier"
            }]
        },
        "SendConfirmation": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:send-confirmation",
            "Next": "ShipmentCreated"
        },
        "ShipmentCreated": {
            "Type": "Succeed",
            "OutputPath": "$.shipment"
        },
        "CompensateCarrier": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:cancel-carrier-notification",
            "Next": "CompensateShipment"
        },
        "CompensateShipment": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:delete-shipment",
            "Next": "CompensateInventory"
        },
        "CompensateInventory": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:region:account:function:release-inventory",
            "Next": "ShipmentFailed"
        },
        "ShipmentFailed": {
            "Type": "Fail",
            "Error": "ShipmentCreationFailed",
            "Cause": "Failed to create shipment"
        }
    }
}
```

### 3. Event Sourcing

```javascript
// event-store/dynamodb-event-store.js
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

class DynamoDBEventStore {
    constructor(tableName) {
        this.tableName = tableName;
    }
    
    async appendEvent(aggregateId, event) {
        const params = {
            TableName: this.tableName,
            Item: {
                aggregateId,
                sequenceNumber: event.sequenceNumber,
                eventType: event.type,
                eventData: JSON.stringify(event.data),
                metadata: {
                    timestamp: new Date().toISOString(),
                    service: event.service,
                    correlationId: event.correlationId
                },
                ttl: Math.floor(Date.now() / 1000) + (7 * 24 * 60 * 60) // 7 days
            },
            ConditionExpression: 'attribute_not_exists(aggregateId) OR sequenceNumber < :seq',
            ExpressionAttributeValues: {
                ':seq': event.sequenceNumber
            }
        };
        
        await dynamodb.put(params).promise();
        
        // Publish to EventBridge for projections
        const eventBridge = new AWS.EventBridge();
        await eventBridge.putEvents({
            Entries: [{
                Source: 'logistics.shipment',
                DetailType: event.type,
                Detail: JSON.stringify({
                    aggregateId,
                    ...event
                }),
                EventBusName: 'logistics-events'
            }]
        }).promise();
    }
    
    async getEvents(aggregateId, fromSequence = 0) {
        const params = {
            TableName: this.tableName,
            KeyConditionExpression: 'aggregateId = :id AND sequenceNumber >= :seq',
            ExpressionAttributeValues: {
                ':id': aggregateId,
                ':seq': fromSequence
            },
            ScanIndexForward: true
        };
        
        const result = await dynamodb.query(params).promise();
        return result.Items.map(item => ({
            type: item.eventType,
            sequenceNumber: item.sequenceNumber,
            data: JSON.parse(item.eventData),
            metadata: item.metadata
        }));
    }
    
    async getAggregate(aggregateId, reducer) {
        const events = await this.getEvents(aggregateId);
        return events.reduce(reducer, reducer.getInitialState());
    }
}

module.exports = DynamoDBEventStore;
```

---

## Resultados

### Métricas de Negocio

| Métrica | Monolito | Microservicios | Mejora |
|---------|----------|----------------|--------|
| Deploys/día | 0.5 | 45 | +8,900% |
| Lead time | 2 semanas | 2 horas | -99% |
| MTTR | 4 horas | 8 minutos | -97% |
| Escalabilidad | 2x | 10x | +400% |
| Costo infra | $50K/mes | $32K/mes | -36% |

### Métricas Técnicas

```
Servicio          │ Latencia p99 │ Throughput │ Uptime  │ Costo/mes
──────────────────┼──────────────┼────────────┼─────────┼──────────
Shipment Service  │     85ms     │  2,500/s   │ 99.99%  │   $1,200
Tracking Service  │     45ms     │  5,000/s   │ 99.99%  │   $2,800
Carrier Service   │    120ms     │    500/s   │ 99.95%  │     $800
Billing Service   │    200ms     │    200/s   │ 99.99%  │     $600
```

---

*Caso de estudio basado en migraciones reales a microservicios.*

*Última actualización: Abril 2025*
