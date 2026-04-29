# Case Study 4: LogisticsPro - Microservices Platform on ECS

## Executive Summary

**Company:** LogisticsPro  
**Industry:** Logistics / Supply Chain  
**Challenge:** Monolithic TMS couldn't scale to handle 10M+ daily shipments, 5-minute release cycles needed  
**Results:** 95% faster deployments, 60% infrastructure cost reduction, 99.99% availability across 8 regions

---

## The Challenge

### Business Context
LogisticsPro operated a legacy Transportation Management System (TMS) that had grown over 15 years into a 2-million-line monolith. As the company expanded to 50 countries and 10M+ daily shipments, the architecture couldn't keep pace:

**Key Pain Points:**
- **Deployment Risk:** Full system deploys every 2 weeks, 40% failure rate
- **Scaling Issues:** Peak loads required 3x over-provisioning
- **Development Bottleneck:** 40 developers on single codebase, constant merge conflicts
- **Technology Debt:** Java 6, Spring 2.x, Oracle 11g
- **Recovery Time:** 4-hour average incident recovery

### Technical Environment

```
Legacy Monolith Architecture:
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Load Balancer (F5)                                    │
└──────────────────────────────┬──────────────────────────────────────────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
       ┌──────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
       │  App Server │  │  App Server │  │  App Server │
       │  (Tomcat)   │  │  (Tomcat)   │  │  (Tomcat)   │
       │             │  │             │  │             │
       │ • Shipping  │  │ • Shipping  │  │ • Shipping  │
       │ • Tracking  │  │ • Tracking  │  │ • Tracking  │
       │ • Billing   │  │ • Billing   │  │ • Billing   │
       │ • Routing   │  │ • Routing   │  │ • Routing   │
       │ • Inventory │  │ • Inventory │  │ • Inventory │
       │ • Reports   │  │ • Reports   │  │ • Reports   │
       │ • API       │  │ • API       │  │ • API       │
       └──────┬──────┘  └──────┬──────┘  └──────┬──────┘
              │                │                │
              └────────────────┼────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │   Oracle RAC Cluster  │
                    │   (4-node, 20TB)      │
                    └───────────────────────┘
```

**Characteristics:**
- 2M lines of Java code
- 800+ database tables
- Shared-nothing sessions
- Synchronous everything
- Nightly batch jobs

---

## Microservices Architecture

### Target Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         Client Layer                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Web App    │  │  Mobile Apps │  │   Partner    │  │   Internal   │     │
│  │   (SPA)      │  │              │  │   APIs       │  │   Tools      │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼─────────────────┼─────────────────┼─────────────────┼───────────────┘
          │                 │                 │                 │
          └─────────────────┴─────────────────┴─────────────────┘
                            │
┌───────────────────────────▼────────────────────────────────────────────────────┐
│                      API Gateway Layer                                          │
│                                                                                 │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                    Amazon API Gateway                                   │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐ │  │
│  │  │  /shipments  │  │  /tracking   │  │  /billing    │  │  /routing   │ │  │
│  │  │  rate limit  │  │  caching     │  │  auth        │  │  throttling │ │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘ │  │
│  └─────────┼─────────────────┼─────────────────┼─────────────────┼────────┘  │
└────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────┘
             │                 │                 │                 │
┌────────────▼─────────────────▼─────────────────▼─────────────────▼─────────────┐
│                      Service Mesh (App Mesh)                                    │
│                                                                                 │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                    AWS App Mesh (Envoy Proxy)                           │  │
│  │                                                                         │  │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │  │
│  │   │  mTLS        │  │  Circuit     │  │  Retry       │  │  Timeout  │ │  │
│  │   │  encryption  │  │  Breaker     │  │  policies    │  │  config   │ │  │
│  │   └──────────────┘  └──────────────┘  └──────────────┘  └───────────┘ │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────┬─────────────────┬─────────────────┬───────────────────┘
                       │                 │                 │
┌──────────────────────▼─────────────────▼─────────────────▼───────────────────┐
│                      Microservices (ECS Fargate)                              │
│                                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Shipment   │  │   Tracking   │  │   Billing    │  │   Routing    │       │
│  │   Service    │  │   Service    │  │   Service    │  │   Service    │       │
│  │              │  │              │  │              │  │              │       │
│  │ • Create     │  │ • Status     │  │ • Calculate  │  │ • Optimize   │       │
│  │ • Update     │  │ • History    │  │ • Invoice    │  │ • ETA        │       │
│  │ • Cancel     │  │ • ETA        │  │ • Payment    │  │ • Re-route   │       │
│  │ • Validate   │  │ • Alerts     │  │ • Reports    │  │ • Cost       │       │
│  │   Replica: 5 │  │   Replica: 8 │  │   Replica: 3 │  │   Replica: 4 │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                 │                 │                 │                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Carrier    │  │   Customer   │  │   Pricing    │  │   Analytics  │       │
│  │   Service    │  │   Service    │  │   Service    │  │   Service    │       │
│  │   Replica: 4 │  │   Replica: 6 │  │   Replica: 2 │  │   Replica: 3 │       │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                                 │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │   Shared Services:                                                       │  │
│  │   • API Gateway (ingress)                                               │  │
│  │   • Service Discovery (Cloud Map)                                       │  │
│  │   • Config Management (Secrets Manager)                                  │  │
│  │   • Distributed Tracing (X-Ray)                                         │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└──────────────────────┬─────────────────┬─────────────────┬───────────────────┘
                       │                 │                 │
┌──────────────────────▼─────────────────▼─────────────────▼───────────────────┐
│                      Data Layer                                                 │
│                                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   DynamoDB   │  │   RDS        │  │   ElastiCache│  │   S3         │       │
│  │   (Shipments)│  │   (Billing)  │  │   (Sessions) │  │   (Docs)     │       │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                          │
│  │   MSK        │  │   SQS/SNS    │  │   OpenSearch │                          │
│  │   (Events)   │  │   (Queues)   │  │   (Search)   │                          │
│  └──────────────┘  └──────────────┘  └──────────────┘                          │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Service Decomposition Strategy

#### Domain-Driven Design (DDD)

| Service | Domain | Database | Team Size | Lines of Code |
|---------|--------|----------|-----------|---------------|
| **shipment-service** | Core domain | DynamoDB | 6 devs | 25K |
| **tracking-service** | Core domain | DynamoDB | 5 devs | 20K |
| **billing-service** | Supporting | RDS PostgreSQL | 4 devs | 18K |
| **routing-service** | Core domain | ElastiCache + S3 | 5 devs | 22K |
| **carrier-service** | Supporting | DynamoDB | 4 devs | 15K |
| **customer-service** | Supporting | RDS PostgreSQL | 3 devs | 12K |
| **pricing-service** | Supporting | DynamoDB | 3 devs | 10K |
| **analytics-service** | Supporting | S3 + Athena | 4 devs | 15K |

---

## Implementation

### Infrastructure as Code

```hcl
# Terraform: ECS Cluster Configuration
# modules/ecs/main.tf

# ECS Cluster
resource "aws_ecs_cluster" "logistics_pro" {
  name = "logistics-pro-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_exec.name
      }
    }
  }
}

# ECS Service: Shipment Service
resource "aws_ecs_service" "shipment" {
  name            = "shipment-service"
  cluster         = aws_ecs_cluster.logistics_pro.id
  task_definition = aws_ecs_task_definition.shipment.arn
  desired_count   = 5
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.shipment.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.shipment.arn
    container_name   = "shipment"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.https]
}

# Task Definition
resource "aws_ecs_task_definition" "shipment" {
  family                   = "shipment-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([{
    name  = "shipment"
    image = "${aws_ecr_repository.shipment.repository_url}:${var.image_tag}"
    
    portMappings = [{
      containerPort = 8080
      protocol      = "tcp"
    }]
    
    environment = [
      { name = "SERVICE_NAME", value = "shipment-service" },
      { name = "SERVICE_VERSION", value = var.image_tag },
      { name = "DYNAMODB_TABLE", value = aws_dynamodb_table.shipments.name },
      { name = "MSK_BROKERS", value = aws_msk_cluster.logistics.bootstrap_brokers }
    ]
    
    secrets = [
      { name = "DB_PASSWORD", valueFrom = aws_secretsmanager_secret.db_password.arn }
    ]
    
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.shipment.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 60
    }
  }])
}

# Auto-scaling
resource "aws_appautoscaling_target" "shipment" {
  max_capacity       = 20
  min_capacity       = 5
  resource_id        = "service/${aws_ecs_cluster.logistics_pro.name}/${aws_ecs_service.shipment.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "shipment_cpu" {
  name               = "shipment-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.shipment.resource_id
  scalable_dimension = aws_appautoscaling_target.shipment.scalable_dimension
  service_namespace  = aws_appautoscaling_target.shipment.service_namespace

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

### Service Mesh Configuration

```yaml
# App Mesh Service Definition
# mesh/shipment-service.yaml

apiVersion: appmesh.k8s.aws/v1beta2
kind: Mesh
metadata:
  name: logistics-pro-mesh
spec:
  namespaceSelector:
    matchLabels:
      mesh: logistics-pro

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
        port: 8080
        protocol: http
      healthCheck:
        healthyThreshold: 2
        intervalMillis: 5000
        path: /health
        port: 8080
        protocol: http
        timeoutMillis: 2000
        unhealthyThreshold: 3
      timeout:
        http:
          idle:
            unit: s
            value: 300
          perRequest:
            unit: s
            value: 30
  serviceDiscovery:
    awsCloudMap:
      namespaceName: logistics-pro.local
      serviceName: shipment-service
  backendDefaults:
    clientPolicy:
      tls:
        enforce: true
        mode: STRICT
        certificate:
          sds:
            secretName: shipment-service-cert

---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualService
metadata:
  name: tracking-service
  namespace: logistics
spec:
  awsName: tracking-service.logistics-pro.local
  provider:
    virtualRouter:
      virtualRouterRef:
        name: tracking-service-router

---
apiVersion: appmesh.k8s.aws/v1beta2
kind: VirtualRouter
metadata:
  name: tracking-service-router
  namespace: logistics
spec:
  listeners:
    - portMapping:
        port: 8080
        protocol: http
  routes:
    - name: tracking-route
      httpRoute:
        match:
          prefix: /tracking
        action:
          weightedTargets:
            - virtualNodeRef:
                name: tracking-service
              weight: 100
        retryPolicy:
          httpRetryEvents:
            - server-error
            - gateway-error
          maxRetries: 3
          perRetryTimeout:
            unit: s
            value: 10
```

### CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Deploy Microservice

on:
  push:
    branches: [main]
    paths:
      - 'services/shipment/**'
      - '.github/workflows/deploy.yml'

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: logistics-pro/shipment-service
  ECS_SERVICE: shipment-service
  ECS_CLUSTER: logistics-pro-cluster

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::ACCOUNT:role/GitHubActionsECSDeployRole
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build and Test
        working-directory: services/shipment
        run: |
          ./gradlew clean build
          ./gradlew test
          ./gradlew integrationTest

      - name: Security Scan
        uses: anchore/scan-action@v3
        with:
          image: ${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:${{ github.sha }}
          severity-cutoff: high

      - name: Build and Push Image
        working-directory: services/shipment
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}

      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster $ECS_CLUSTER \
            --service $ECS_SERVICE \
            --task-definition $ECS_SERVICE \
            --force-new-deployment

      - name: Smoke Tests
        run: |
          # Wait for deployment
          sleep 60
          # Run smoke tests
          curl -f https://api.logisticspro.com/shipments/health
          curl -f https://api.logisticspro.com/shipments/metrics
```

### Resilience Patterns

#### Circuit Breaker Pattern

```java
// Shipment Service with Resilience4j
@Component
public class TrackingServiceClient {
    
    private final CircuitBreaker circuitBreaker;
    private final Retry retry;
    private final WebClient webClient;
    
    public TrackingServiceClient(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder
            .baseUrl("http://tracking-service:8080")
            .build();
            
        this.circuitBreaker = CircuitBreaker.ofDefaults("tracking");
        this.retry = Retry.ofDefaults("tracking-retry");
    }
    
    public Mono<TrackingInfo> getTrackingInfo(String shipmentId) {
        return webClient.get()
            .uri("/tracking/{shipmentId}", shipmentId)
            .retrieve()
            .bodyToMono(TrackingInfo.class)
            .transformDeferred(RetryOperator.of(retry))
            .transformDeferred(CircuitBreakerOperator.of(circuitBreaker))
            .onErrorResume(CallNotPermittedException.class, e -> {
                // Fallback to cached data
                return getCachedTrackingInfo(shipmentId);
            })
            .onErrorResume(e -> {
                // Log error and return default
                log.error("Failed to get tracking for {}", shipmentId, e);
                return Mono.just(TrackingInfo.empty(shipmentId));
            });
    }
}

// Circuit Breaker Configuration
resilience4j.circuitbreaker:
  configs:
    default:
      slidingWindowSize: 10
      failureRateThreshold: 50
      waitDurationInOpenState: 10000
      permittedNumberOfCallsInHalfOpenState: 3
      slowCallRateThreshold: 80
      slowCallDurationThreshold: 2000
  instances:
    tracking:
      baseConfig: default
```

#### Saga Pattern for Distributed Transactions

```java
// Saga orchestration for shipment booking
@Component
public class ShipmentBookingSaga {
    
    private final StateMachine<SagaState, SagaEvent> stateMachine;
    
    public ShipmentBookingSaga() {
        this.stateMachine = StateMachineBuilder
            .newBuilder()
            .initialState(CREATED)
            
            // Step 1: Validate shipment
            .transition(CREATED, VALIDATING, VALIDATE_SHIPMENT)
            .onEntry(VALIDATING, ctx -> validateShipment(ctx.getShipment()))
            .transition(VALIDATING, VALIDATED, SHIPMENT_VALID)
            .transition(VALIDATING, FAILED, VALIDATION_FAILED)
            
            // Step 2: Calculate pricing
            .transition(VALIDATED, PRICING, CALCULATE_PRICE)
            .onEntry(PRICING, ctx -> calculatePricing(ctx.getShipment()))
            .transition(PRICING, PRICED, PRICE_CALCULATED)
            .transition(PRICING, FAILED, PRICING_FAILED, 
                ctx -> cancelShipmentValidation(ctx.getShipment()))
            
            // Step 3: Reserve capacity
            .transition(PRICED, RESERVING, RESERVE_CAPACITY)
            .onEntry(RESERVING, ctx -> reserveCapacity(ctx.getShipment()))
            .transition(RESERVING, RESERVED, CAPACITY_RESERVED)
            .transition(RESERVING, FAILED, RESERVATION_FAILED,
                ctx -> {
                    cancelShipmentValidation(ctx.getShipment());
                    releasePricingHold(ctx.getShipment());
                })
            
            // Step 4: Process payment
            .transition(RESERVED, PAYING, PROCESS_PAYMENT)
            .onEntry(PAYING, ctx -> processPayment(ctx.getShipment()))
            .transition(PAYING, PAID, PAYMENT_PROCESSED)
            .transition(PAYING, FAILED, PAYMENT_FAILED,
                ctx -> {
                    cancelShipmentValidation(ctx.getShipment());
                    releasePricingHold(ctx.getShipment());
                    releaseCapacity(ctx.getShipment());
                })
            
            // Complete
            .transition(PAID, COMPLETED, CONFIRM_BOOKING)
            .onEntry(COMPLETED, ctx -> sendConfirmation(ctx.getShipment()))
            
            .build();
    }
}

// AWS Step Functions for Saga implementation
{
  "Comment": "Shipment Booking Saga",
  "StartAt": "ValidateShipment",
  "States": {
    "ValidateShipment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account:function:validateShipment",
      "Next": "CalculatePricing",
      "Catch": [{
        "ErrorEquals": ["ValidationException"],
        "Next": "BookingFailed"
      }]
    },
    "CalculatePricing": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account:function:calculatePricing",
      "Next": "ReserveCapacity",
      "Catch": [{
        "ErrorEquals": ["PricingException"],
        "Next": "CompensateValidation"
      }]
    },
    "ReserveCapacity": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account:function:reserveCapacity",
      "Next": "ProcessPayment",
      "Catch": [{
        "ErrorEquals": ["ReservationException"],
        "Next": "CompensatePricing"
      }]
    },
    "ProcessPayment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account:function:processPayment",
      "Next": "SendConfirmation",
      "Catch": [{
        "ErrorEquals": ["PaymentException"],
        "Next": "CompensateReservation"
      }]
    },
    "SendConfirmation": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account:function:sendConfirmation",
      "End": true
    },
    "CompensateReservation": {
      "Type": "Parallel",
      "Branches": [
        {"StartAt": "ReleaseCapacity", "States": {...}},
        {"StartAt": "ReleasePricing", "States": {...}},
        {"StartAt": "CancelValidation", "States": {...}}
      ],
      "Next": "BookingFailed"
    },
    "BookingFailed": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:region:account:function:notifyBookingFailed",
      "End": true
    }
  }
}
```

---

## Results

### Deployment Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Deployment Frequency** | 1 every 2 weeks | 20/day | 280x faster |
| **Lead Time** | 3 weeks | 12 minutes | 99.7% faster |
| **Change Failure Rate** | 40% | 2% | 95% reduction |
| **Mean Recovery Time** | 4 hours | 5 minutes | 98% faster |
| **Rollback Time** | 2 hours | 30 seconds | 99.6% faster |

### Performance Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Response Time (p99)** | 2.5s | 180ms | 93% faster |
| **Throughput** | 2,000 TPS | 25,000 TPS | 12x higher |
| **Availability** | 99.5% | 99.99% | 10x better |
| **Cost per Transaction** | $0.08 | $0.012 | 85% reduction |

### Business Impact

| Outcome | Result |
|---------|--------|
| **New Feature Velocity** | 4x faster time-to-market |
| **System Reliability** | 99.99% uptime across 8 regions |
| **Cost Savings** | 60% infrastructure cost reduction |
| **Team Autonomy** | 8 independent teams, zero blockers |
| **Customer Satisfaction** | NPS increased from 42 to 68 |

---

*Last Updated: April 2025*
*AWS Well-Architected Framework Version: 2025*
