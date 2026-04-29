# Caso de Estudio: Estrategia Multi-Región para Disaster Recovery

> **Empresa:** HealthFirst (Plataforma de salud digital)  
> **Industria:** Healthcare / Telemedicine  
> **Duración:** 8 meses  
> **Equipo:** 10 ingenieros cloud, 2 arquitectos de resiliencia, 1 compliance officer

---

## Situación Inicial

### Contexto Regulatorio

HealthFirst opera una plataforma de telemedicina con:
- **HIPAA Compliance:** Datos de salud protegidos (PHI)
- **Disponibilidad crítica:** Vidas dependen del sistema
- **RTO/RPO requeridos:** 1 hora / 15 minutos (acuerdo SLA con hospitales)
- **5 millones de pacientes** en 3 países

### Arquitectura Original (Single-Region)

```
┌─────────────────────────────────────────────────────────────────┐
│                   SINGLE-REGION (us-east-1)                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    Production VPC                       │   │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
│   │  │   ALB    │  │   ECS    │  │  Aurora  │              │   │
│   │  │          │  │ Cluster  │  │ Primary  │              │   │
│   │  │          │  │          │  │  (Multi  │              │   │
│   │  │          │  │  12      │  │   AZ)    │              │   │
│   │  │          │  │  tasks   │  │          │              │   │
│   │  └──────────┘  └──────────┘  └──────────┘              │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   Problemas:                                                     │
│   • 2017: S3 outage en us-east-1 afectó operación 4 horas        │
│   • 2020: AWS incident causó degradación de servicio             │
│   • No compliance con SLA de 99.99%                            │
│   • RPO actual: 6 horas (backups diarios) - NO ACEPTABLE         │
│   • RTO estimado: 8+ horas para restauración manual              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Objetivos del DR Strategy

| Objetivo | Valor |
|----------|-------|
| **RPO** | 15 minutos (máxima pérdida de datos aceptable) |
| **RTO** | 1 hora (tiempo máximo para recuperar servicio) |
| **RTO DNS** | 5 minutos (failover de tráfico) |
| **Availability** | 99.99% (52.6 minutos downtime/año) |
| **Costo DR** | < 15% del costo total de infraestructura |

---

## Arquitectura Multi-Región

### Diseño: Active-Active para Frontend, Active-Standby para Datos

```
┌─────────────────────────────────────────────────────────────────┐
│                   MULTI-REGION ARCHITECTURE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Primary Region (us-east-1)        DR Region (us-west-2)      │
│   ┌──────────────────────────┐      ┌──────────────────────────┐│
│   │    ROUTE 53              │      │    ROUTE 53              ││
│   │   Health Checks          │◄────►│   Health Checks          ││
│   │   Latency Routing        │      │   Latency Routing        ││
│   │   Failover Records       │      │   Failover Records       ││
│   └──────────┬───────────────┘      └───────────┬───────────┘│
│              │                                   │            │
│              ▼                                   ▼            │
│   ┌──────────────────────────┐      ┌──────────────────────────┐│
│   │    CLOUDFRONT           │      │    CLOUDFRONT           ││
│   │   Edge Locations         │      │   Edge Locations         ││
│   │   (Global)               │      │   (Global)               ││
│   └──────────┬───────────────┘      └───────────┬───────────┘│
│              │                                   │            │
│              ▼                                   ▼            │
│   ┌──────────────────────────┐      ┌──────────────────────────┐│
│   │    API GATEWAY           │      │    API GATEWAY           ││
│   │   Regional Endpoint      │      │   Regional Endpoint      ││
│   │   WAF Protection         │      │   WAF Protection         ││
│   └──────────┬───────────────┘      └───────────┬───────────┘│
│              │                                   │            │
│              ▼                                   ▼            │
│   ┌──────────────────────────┐      ┌──────────────────────────┐│
│   │    ECS FARGATE           │      │    ECS FARGATE           ││
│   │   ┌──────────────────┐   │      │   ┌──────────────────┐   ││
│   │   │ Microservices    │   │      │   │ Microservices    │   ││
│   │   │ (12 tasks active)│   │      │   │ (2 tasks standby)│   ││
│   │   └──────────────────┘   │      │   └──────────────────┘   ││
│   └──────────┬───────────────┘      └───────────┬───────────┘│
│              │                                   │            │
│              ▼                                   ▼            │
│   ┌──────────────────────────┐      ┌──────────────────────────┐│
│   │    AURORA GLOBAL         │      │    AURORA GLOBAL           ││
│   │   ┌──────────────────┐   │      │   ┌──────────────────┐   ││
│   │   │ Primary Cluster  │   │      │   │ Secondary        │   ││
│   │   │ - Writer         │   │      │   │ Cluster          │   ││
│   │   │ - 2 Readers      │   │◄────►│   │ - Read replica   │   ││
│   │   │ - RPO: 0         │   │      │   │ - Promotable     │   ││
│   │   └──────────────────┘   │      │   └──────────────────┘   ││
│   │                          │      │                          ││
│   │   DynamoDB Global Tables │      │   DynamoDB Global Tables ││
│   │   (Sessions, Caching)    │◄────►│   (Sessions, Caching)    ││
│   └──────────┬───────────────┘      └───────────┬───────────┘│
│              │                                   │            │
│              ▼                                   ▼            │
│   ┌──────────────────────────┐      ┌──────────────────────────┐│
│   │    ELASTICACHE           │      │    ELASTICACHE           ││
│   │   Redis Cluster Mode     │      │   Redis Cluster Mode     ││
│   │   (Cross-Zone)           │      │   (Cross-Zone)           ││
│   └──────────────────────────┘      └──────────────────────────┘│
│                                                                  │
│   Replication:                                                   │
│   • Aurora: Synchronous (0 RPO) within region                     │
│   • Aurora: Async to secondary (15 min RPO cross-region)         │
│   • DynamoDB: Global Tables (0 RPO)                              │
│   • S3: Cross-Region Replication (CRR)                           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Componentes del DR

### 1. Route 53 Health Checks y Failover

```hcl
# terraform/route53-dr.tf

# Health check for primary region endpoint
resource "aws_route53_health_check" "primary_endpoint" {
  fqdn              = "api-us-east.healthfirst.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30
  
  regions = ["us-east-1", "us-west-2", "eu-west-1"]
  
  tags = {
    Name = "Primary Region Health"
  }
}

# Health check for DR region endpoint
resource "aws_route53_health_check" "dr_endpoint" {
  fqdn              = "api-us-west.healthfirst.com"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30
  
  regions = ["us-east-1", "us-west-2", "eu-west-1"]
  
  tags = {
    Name = "DR Region Health"
  }
}

# Failover routing policy
resource "aws_route53_record" "api_failover" {
  zone_id = aws_route53_zone.healthfirst.zone_id
  name    = "api.healthfirst.com"
  type    = "A"
  
  failover_routing_policy {
    type = "PRIMARY"
  }
  
  alias {
    name                   = aws_lb.primary.dns_name
    zone_id                = aws_lb.primary.zone_id
    evaluate_target_health = true
  }
  
  health_check_id = aws_route53_health_check.primary_endpoint.id
  set_identifier  = "primary"
}

resource "aws_route53_record" "api_failover_secondary" {
  zone_id = aws_route53_zone.healthfirst.zone_id
  name    = "api.healthfirst.com"
  type    = "A"
  
  failover_routing_policy {
    type = "SECONDARY"
  }
  
  alias {
    name                   = aws_lb.dr.dns_name
    zone_id                = aws_lb.dr.zone_id
    evaluate_target_health = true
  }
  
  health_check_id = aws_route53_health_check.dr_endpoint.id
  set_identifier  = "secondary"
}

# Latency-based routing for normal operation
resource "aws_route53_record" "api_latency" {
  zone_id = aws_route53_zone.healthfirst.zone_id
  name    = "api-latency.healthfirst.com"
  type    = "A"
  
  latency_routing_policy {
    region = "us-east-1"
  }
  
  alias {
    name                   = aws_lb.primary.dns_name
    zone_id                = aws_lb.primary.zone_id
    evaluate_target_health = true
  }
  
  set_identifier = "us-east-1"
  health_check_id = aws_route53_health_check.primary_endpoint.id
}

resource "aws_route53_record" "api_latency_west" {
  zone_id = aws_route53_zone.healthfirst.zone_id
  name    = "api-latency.healthfirst.com"
  type    = "A"
  
  latency_routing_policy {
    region = "us-west-2"
  }
  
  alias {
    name                   = aws_lb.dr.dns_name
    zone_id                = aws_lb.dr.zone_id
    evaluate_target_health = true
  }
  
  set_identifier = "us-west-2"
  health_check_id = aws_route53_health_check.dr_endpoint.id
}
```

### 2. Aurora Global Database

```hcl
# terraform/aurora-global.tf

# Primary cluster
resource "aws_rds_global_cluster" "healthfirst" {
  global_cluster_identifier = "healthfirst-global"
  database_name             = "patient_data"
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.0"
  storage_encrypted         = true
  deletion_protection       = true
}

resource "aws_rds_cluster" "primary" {
  cluster_identifier        = "healthfirst-primary"
  global_cluster_identifier = aws_rds_global_cluster.healthfirst.id
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.0"
  database_name             = "patient_data"
  master_username           = "admin"
  master_password           = var.db_master_password
  backup_retention_period   = 35
  preferred_backup_window   = "03:00-04:00"
  
  vpc_security_group_ids    = [aws_security_group.aurora_primary.id]
  db_subnet_group_name      = aws_db_subnet_group.primary.name
  
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "healthfinal-final-snapshot"
  
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}

resource "aws_rds_cluster_instance" "primary_writer" {
  identifier           = "healthfirst-primary-writer"
  cluster_identifier   = aws_rds_cluster.primary.id
  instance_class       = "db.r6g.2xlarge"
  engine               = aws_rds_cluster.primary.engine
  
  performance_insights_enabled = true
  monitoring_interval  = 60
}

resource "aws_rds_cluster_instance" "primary_reader" {
  count                = 2
  identifier           = "healthfirst-primary-reader-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.primary.id
  instance_class       = "db.r6g.xlarge"
  engine               = aws_rds_cluster.primary.engine
  
  performance_insights_enabled = true
}

# Secondary cluster (DR region)
resource "aws_rds_cluster" "secondary" {
  provider                  = aws.west
  cluster_identifier        = "healthfirst-secondary"
  global_cluster_identifier = aws_rds_global_cluster.healthfirst.id
  engine                    = "aurora-mysql"
  engine_version            = "8.0.mysql_aurora.3.04.0"
  
  vpc_security_group_ids    = [aws_security_group.aurora_secondary.id]
  db_subnet_group_name      = aws_db_subnet_group.secondary.name
  
  depends_on = [aws_rds_cluster_instance.primary_writer]
}

resource "aws_rds_cluster_instance" "secondary_reader" {
  provider             = aws.west
  identifier           = "healthfirst-secondary-reader"
  cluster_identifier   = aws_rds_cluster.secondary.id
  instance_class       = "db.r6g.large"  # Smaller in standby
  engine               = aws_rds_cluster.secondary.engine
}

# Failover automation Lambda
resource "aws_lambda_function" "aurora_failover" {
  filename         = "lambda/failover.zip"
  function_name    = "aurora-failover-handler"
  role             = aws_iam_role.lambda_failover.arn
  handler          = "index.handler"
  runtime          = "python3.11"
  timeout          = 60
  
  environment {
    variables = {
      GLOBAL_CLUSTER_ID = aws_rds_global_cluster.healthfirst.id
      SECONDARY_CLUSTER_ARN = aws_rds_cluster.secondary.arn
      SNS_TOPIC_ARN = aws_sns_topic.dr_alerts.arn
    }
  }
}

# CloudWatch alarm to trigger failover
resource "aws_cloudwatch_metric_alarm" "primary_unhealthy" {
  alarm_name          = "aurora-primary-unhealthy"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Trigger Aurora failover when primary is unhealthy"
  
  dimensions = {
    LoadBalancer = aws_lb.primary.arn_suffix
  }
  
  alarm_actions = [aws_lambda_function.aurora_failover.arn]
}
```

### 3. DynamoDB Global Tables

```hcl
# terraform/dynamodb-global.tf

# User sessions - must be available in both regions
resource "aws_dynamodb_global_table" "user_sessions" {
  name = "UserSessions"
  
  billing_mode = "PAY_PER_REQUEST"
  
  hash_key  = "userId"
  range_key = "sessionId"
  
  attribute {
    name = "userId"
    type = "S"
  }
  
  attribute {
    name = "sessionId"
    type = "S"
  }
  
  attribute {
    name = "ttl"
    type = "N"
  }
  
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
  
  replica {
    region_name = "us-east-1"
    
    point_in_time_recovery = true
  }
  
  replica {
    region_name = "us-west-2"
    
    point_in_time_recovery = true
  }
}

# Application state
resource "aws_dynamodb_global_table" "app_state" {
  name = "ApplicationState"
  
  billing_mode = "PAY_PER_REQUEST"
  
  hash_key = "stateKey"
  
  attribute {
    name = "stateKey"
    type = "S"
  }
  
  replica {
    region_name = "us-east-1"
  }
  
  replica {
    region_name = "us-west-2"
  }
}
```

### 4. S3 Cross-Region Replication

```hcl
# terraform/s3-crr.tf

# Primary bucket with CRR to DR region
resource "aws_s3_bucket" "patient_documents" {
  bucket = "healthfirst-patient-docs-primary"
  
  versioning {
    enabled = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_primary.arn
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "patient_docs" {
  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.patient_documents.id
  
  rule {
    id     = "replicate-to-dr"
    status = "Enabled"
    priority = 1
    
    filter {
      prefix = ""  # Replicate all objects
    }
    
    delete_marker_replication {
      status = "Enabled"
    }
    
    destination {
      bucket        = aws_s3_bucket.patient_documents_dr.arn
      storage_class = "STANDARD"
      
      replication_time {
        status  = "Enabled"
        minutes = 15
      }
      
      metrics {
        status  = "Enabled"
        minutes = 15
      }
      
      encryption_configuration {
        replica_kms_key_id = aws_kms_key.s3_dr.arn
      }
    }
    
    source_selection_criteria {
      replica_modifications {
        status = "Enabled"
      }
      sse_kms_encrypted_objects {
        status = "Enabled"
      }
    }
  }
}

# DR bucket
resource "aws_s3_bucket" "patient_documents_dr" {
  provider = aws.west
  bucket   = "healthfirst-patient-docs-dr"
  
  versioning {
    enabled = true
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_dr.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
```

### 5. ECS Fargate Standby Pattern

```hcl
# terraform/ecs-standby.tf

# Primary region - full capacity
resource "aws_ecs_service" "app_primary" {
  name            = "healthfirst-app"
  cluster         = aws_ecs_cluster.primary.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 12
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = aws_subnet.primary_private[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.primary.arn
    container_name   = "app"
    container_port   = 8080
  }
  
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  
  deployment_controller {
    type = "ECS"
  }
}

# DR region - minimal standby (scale to full on failover)
resource "aws_ecs_service" "app_dr" {
  provider        = aws.west
  name              = "healthfirst-app"
  cluster           = aws_ecs_cluster.dr.id
  task_definition   = aws_ecs_task_definition.app.arn
  desired_count     = 2  # Minimum to keep warm
  launch_type       = "FARGATE"
  
  network_configuration {
    subnets          = aws_subnet.dr_private[*].id
    security_groups  = [aws_security_group.ecs_dr.id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.dr.arn
    container_name   = "app"
    container_port   = 8080
  }
  
  # Auto-scaling ready
  lifecycle {
    ignore_changes = [desired_count]  # Managed by failover automation
  }
}

# Auto-scaling for DR region (triggered during failover)
resource "aws_appautoscaling_target" "app_dr" {
  provider           = aws.west
  max_capacity       = 20
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.dr.name}/${aws_ecs_service.app_dr.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
```

---

## Failover Automation

### Lambda Function for Automated Failover

```python
# lambda/dr_failover.py
import json
import boto3
import os

def lambda_handler(event, context):
    """
    Automated DR failover orchestration
    Triggered by CloudWatch alarm when primary region is unhealthy
    """
    
    rds = boto3.client('rds')
    ecs = boto3.client('ecs', region_name='us-west-2')
    sns = boto3.client('sns')
    route53 = boto3.client('route53')
    
    results = {
        'initiated_at': context.aws_request_id,
        'steps': []
    }
    
    try:
        # Step 1: Failover Aurora Global Database
        results['steps'].append({'step': 'aurora_failover', 'status': 'started'})
        
        failover_response = rds.failover_global_cluster(
            GlobalClusterIdentifier=os.environ['GLOBAL_CLUSTER_ID'],
            TargetDbClusterIdentifier=os.environ['SECONDARY_CLUSTER_ARN']
        )
        
        results['steps'][-1]['status'] = 'completed'
        results['steps'][-1]['details'] = failover_response
        
        # Step 2: Scale up ECS in DR region
        results['steps'].append({'step': 'ecs_scale_up', 'status': 'started'})
        
        ecs.update_service(
            cluster='healthfirst-dr-cluster',
            service='healthfirst-app',
            desiredCount=12  # Full capacity
        )
        
        results['steps'][-1]['status'] = 'completed'
        
        # Step 3: Update Route 53 (manual approval for safety, or auto for critical)
        # For critical healthcare, we auto-failover
        results['steps'].append({'step': 'route53_failover', 'status': 'started'})
        
        # Health check already failed, Route 53 should auto-route
        # But we can force it by marking primary health check as unhealthy
        
        results['steps'][-1]['status'] = 'completed'
        
        # Step 4: Notify stakeholders
        results['steps'].append({'step': 'notifications', 'status': 'started'})
        
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Subject='DR FAILOVER INITIATED - HealthFirst Platform',
            Message=json.dumps({
                'alert': 'DISASTER RECOVERY FAILOVER',
                'timestamp': context.aws_request_id,
                'reason': event.get('reason', 'Primary region unhealthy'),
                'actions_taken': [
                    'Aurora Global Database failed over to us-west-2',
                    'ECS scaled up to full capacity in DR region',
                    'Route 53 failover in progress'
                ],
                'estimated_rto': '5 minutes',
                'manual_actions_required': [
                    'Verify application health in DR region',
                    'Notify customers if extended downtime expected',
                    'Begin root cause analysis for primary region'
                ]
            }, indent=2)
        )
        
        results['steps'][-1]['status'] = 'completed'
        results['overall_status'] = 'SUCCESS'
        
    except Exception as e:
        results['steps'][-1]['status'] = 'failed'
        results['steps'][-1]['error'] = str(e)
        results['overall_status'] = 'PARTIAL_FAILURE'
        
        # Send critical alert
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Subject='CRITICAL: DR FAILOVER FAILED',
            Message=f'Failover automation failed: {str(e)}'
        )
        raise
    
    return {
        'statusCode': 200,
        'body': json.dumps(results)
    }
```

---

## Pruebas de DR (Chaos Engineering)

### GameDay Procedure

```yaml
# gameday/schedule.yml
Monthly_DR_Test:
  frequency: "First Saturday of month"
  duration: "4 hours"
  
  phases:
    Preparation:
      - Notify stakeholders (48 hours before)
      - Create pre-test backup
      - Verify runbook is current
      
    Execution:
      - Inject failure in primary region
      - Measure actual RTO/RPO
      - Document issues found
      
    Validation:
      - Verify all services operational in DR
      - Run smoke tests
      - Check data consistency
      
    Recovery:
      - Failback to primary
      - Verify replication re-established
      - Generate report

Test_Scenarios:
  - name: "Complete region failure"
    injection: "Terminate all AZs in us-east-1"
    expected_rto: "5 minutes"
    
  - name: "Database corruption"
    injection: "Drop critical table in Aurora"
    expected_rpo: "15 minutes"
    
  - name: "Network partition"
    injection: "Isolate primary region network"
    expected_detection: "30 seconds"
```

---

## Resultados

### DR Metrics

| Métrica | Objetivo | Actual |
|---------|----------|--------|
| RPO | 15 minutos | 5 minutos |
| RTO | 1 hora | 8 minutos |
| Failover DNS | 5 minutos | 2 minutos |
| Availability | 99.99% | 99.995% |

### Costos DR

| Componente | Costo Mensual |
|------------|---------------|
| Aurora Secondary (1 instance) | $850 |
| ECS DR (2 tasks standby) | $420 |
| S3 CRR (replication) | $320 |
| DynamoDB Global Tables | $0 (on-demand) |
| Route 53 Health Checks | $50 |
| **Total** | **$1,640** |

**Porcentaje del costo total:** 12%

---

*Caso de estudio basado en arquitecturas de DR reales en healthcare.*

*Última actualización: Abril 2025*
