# Capítulo 10: Estrategias de Costos en AWS

## Escenario: TechStart SaaS - De $5,000 a $2,800/mes

**Empresa:** TechStart, SaaS B2B de gestión de proyectos
**Situación:** Factura AWS de $5,000/mes creciendo 15% mensual
**Equipo:** 1 DevOps, 3 desarrolladores, sin experiencia en FinOps
**Infraestructura actual:** EC2, RDS, S3, CloudFront, Elasticache
**Objetivo:** Reducir costos 40% sin impactar performance

### Diagnóstico Inicial con AWS CLI

```bash
# Instalar AWS Cost Explorer CLI tools
pip install aws-cost-explorer-cli

# Análisis de gastos últimos 3 meses por servicio
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-03-31 \
  --granularity MONTHLY \
  --metrics "BlendedCost" "UnblendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE \
  --output table

# Identificar recursos huérfanos (sin tags de Owner)
aws resourcegroupstagging-api get-resources \
  --tag-filters Key=Owner,Values= \
  --resource-type-filters "ec2:instance" "rds:db" "s3"

# Reporte de instancias subutilizadas (>5 días <5% CPU)
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --start-time 2024-03-01T00:00:00Z \
  --end-time 2024-03-31T23:59:59Z \
  --period 86400 \
  --statistics Average \
  --dimensions Name=InstanceId,Value=i-0123456789abcdef0
```

### Hallazgos del Análisis de $5K/mes

```
Desglose de Costos TechStart (Marzo 2024):
┌─────────────────────────┬──────────┬────────┬─────────────────────┐
│ Servicio                │ Costo    │ %      │ Optimización Inicial│
├─────────────────────────┼──────────┼────────┼─────────────────────┤
│ EC2 (20 instancias)     │ $1,800   │ 36%    │ Spot, Graviton, RI  │
│ RDS (3 Multi-AZ)        │ $1,200   │ 24%    │ Reserved, serverless│
│ S3 (5TB + requests)     │ $650     │ 13%    │ Tiering, IA, Glacier│
│ Data Transfer           │ $500     │ 10%    │ CloudFront, VPC Endp│
│ Elasticache (3 nodos)   │ $350     │ 7%     │ T3, cluster mode    │
│ CloudFront              │ $280     │ 6%     │ Cache optimization  │
│ EBS (volumes)           │ $150     │ 3%     │ gp3 migration       │
│ Otros (ALB, CloudWatch) │ $170     │ 3%     │ Log retention       │
├─────────────────────────┼──────────┼────────┼─────────────────────┤
│ TOTAL                   │ $5,000   │ 100%   │ -                   │
└─────────────────────────┴──────────┴────────┴─────────────────────┘
```

**Problemas identificados:**
1. 12 instancias dev/test corriendo 24/7 ($720/mes innecesarios)
2. RDS sin Reserved Instances ($480/mes de oportunidad)
3. S3 Standard para datos >90 días sin acceso ($195/mes)
4. Data transfer sin CloudFront ($300/mes optimizable)
5. EBS gp2 en lugar de gp3 ($45/mes)

## Fase 1: Optimización Rápida (Semana 1-2)

### 1.1 Auto-Apagado de Entornos No Productivos

**Ahorro estimado:** $720/mes (14.4%)

```python
# lambda_function.py - Auto-shutdown para entornos dev/test
import boto3
import os
from datetime import datetime, timezone

ec2 = boto3.client('ec2')
sns = boto3.client('sns')

def lambda_handler(event, context):
    """
    Detiene instancias EC2 y RDS tagged como dev/test
    Horario: Lunes-Viernes 19:00 - 08:00 + fines de semana
    """
    current_hour = datetime.now(timezone.utc).hour
    current_weekday = datetime.now(timezone.utc).weekday()
    
    # Verificar si es horario fuera de oficina
    is_weekend = current_weekday >= 5
    is_after_hours = current_hour >= 19 or current_hour < 8
    
    if not (is_weekend or is_after_hours):
        return {"status": "Working hours - no action taken"}
    
    # EC2: Detener instancias dev/test
    response = ec2.describe_instances(
        Filters=[
            {'Name': 'instance-state-name', 'Values': ['running']},
            {'Name': 'tag:Environment', 'Values': ['dev', 'test', 'staging']},
            {'Name': 'tag:AutoShutdown', 'Values': ['true', 'yes']}
        ]
    )
    
    stopped_instances = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            try:
                ec2.stop_instances(InstanceIds=[instance_id])
                stopped_instances.append(instance_id)
            except Exception as e:
                print(f"Error stopping {instance_id}: {e}")
    
    # RDS: Detener instancias dev/test (solo si tienen Snapshot)
    rds = boto3.client('rds')
    rds_response = rds.describe_db_instances()
    
    stopped_rds = []
    for db in rds_response['DBInstances']:
        db_id = db['DBInstanceIdentifier']
        # Verificar tags
        try:
            tags = rds.list_tags_for_resource(
                ResourceName=f"arn:aws:rds:{boto3.session.Session().region_name}:{boto3.client('sts').get_caller_identity()['Account']}:db:{db_id}"
            )
            env_tags = [t['Value'] for t in tags['TagList'] if t['Key'] == 'Environment']
            if env_tags and env_tags[0] in ['dev', 'test']:
                rds.stop_db_instance(DBInstanceIdentifier=db_id)
                stopped_rds.append(db_id)
        except Exception as e:
            print(f"Error with RDS {db_id}: {e}")
    
    # Notificar
    if stopped_instances or stopped_rds:
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Subject=f"AWS Auto-Shutdown: {len(stopped_instances)} EC2, {len(stopped_rds)} RDS stopped",
            Message=f"Stopped instances: {stopped_instances}\nStopped RDS: {stopped_rds}"
        )
    
    return {
        "stopped_ec2": stopped_instances,
        "stopped_rds": stopped_rds,
        "estimated_savings": f"${len(stopped_instances) * 0.10 * 13 * 30:.2f}/month"
    }
```

```yaml
# cloudformation-auto-shutdown.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Auto-shutdown scheduler para entornos dev/test'

Parameters:
  NotificationEmail:
    Type: String
    Description: Email para notificaciones de shutdown
    Default: devops@techstart.io

Resources:
  AutoShutdownFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: auto-shutdown-dev-test
      Runtime: python3.11
      Handler: index.lambda_handler
      Timeout: 300
      MemorySize: 128
      Role: !GetAtt LambdaRole.Arn
      Environment:
        Variables:
          SNS_TOPIC_ARN: !Ref ShutdownNotificationTopic
      Code:
        ZipFile: |
          # [Insertar código Python de arriba]
          import boto3
          import os
          # ... código completo

  LambdaRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: EC2RDSControl
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - ec2:DescribeInstances
                  - ec2:StopInstances
                  - ec2:DescribeTags
                  - rds:DescribeDBInstances
                  - rds:StopDBInstance
                  - rds:ListTagsForResource
                  - sns:Publish
                Resource: "*"
              - Effect: Allow
                Action:
                  - sts:GetCallerIdentity
                Resource: "*"

  # CloudWatch Events: Ejecutar Lunes-Viernes a las 19:00
  ShutdownScheduleWeekday:
    Type: AWS::Events::Rule
    Properties:
      Name: shutdown-weekday-evening
      Description: "Apagar entornos dev/test a las 7pm"
      ScheduleExpression: "cron(0 19 ? * MON-FRI *)"
      State: ENABLED
      Targets:
        - Arn: !GetAtt AutoShutdownFunction.Arn
          Id: ShutdownTarget

  # CloudWatch Events: Mantener apagado fines de semana
  ShutdownScheduleWeekend:
    Type: AWS::Events::Rule
    Properties:
      Name: shutdown-weekend
      Description: "Verificar estado fines de semana"
      ScheduleExpression: "cron(0 */6 ? * SAT,SUN *)"
      State: ENABLED
      Targets:
        - Arn: !GetAtt AutoShutdownFunction.Arn
          Id: WeekendShutdownTarget

  # EventBridge permissions
  PermissionWeekday:
    Type: AWS::Lambda::Permission
    Properties:
      FunctionName: !Ref AutoShutdownFunction
      Action: lambda:InvokeFunction
      Principal: events.amazonaws.com
      SourceArn: !GetAtt ShutdownScheduleWeekday.Arn

  ShutdownNotificationTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: auto-shutdown-notifications
      DisplayName: AWS Auto-Shutdown

  EmailSubscription:
    Type: AWS::SNS::Subscription
    Properties:
      TopicArn: !Ref ShutdownNotificationTopic
      Protocol: email
      Endpoint: !Ref NotificationEmail

Outputs:
  LambdaArn:
    Description: ARN de la función Lambda
    Value: !GetAtt AutoShutdownFunction.Arn
```

### 1.2 Migración EBS gp2 → gp3

**Ahorro estimado:** $45/mes + 20% mejor performance

```bash
#!/bin/bash
# migrate-ebs-gp3.sh - Migrar volúmenes EBS de gp2 a gp3

# Listar volúmenes gp2
VOLUMES=$(aws ec2 describe-volumes \
  --filters Name=volume-type,Values=gp2 \
  --query 'Volumes[*].VolumeId' \
  --output text)

echo "Volúmenes gp2 encontrados: $VOLUMES"

for VOLUME in $VOLUMES; do
  echo "Migrando $VOLUME a gp3..."
  
  # Modificar volumen a gp3 con IOPS mejorado (hasta 16,000)
  aws ec2 modify-volume \
    --volume-id $VOLUME \
    --volume-type gp3 \
    --iops 3000 \
    --throughput 125
  
  echo "Migrado: $VOLUME"
done

echo "Migración completada. Verificar en EC2 Console."
```

### 1.3 S3 Intelligent-Tiering + Lifecycle Policies

**Ahorro estimado:** $195/mes (30% de S3)

```json
// s3-lifecycle-policy.json
{
  "Rules": [
    {
      "ID": "IntelligentTieringForDataLake",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "data/"
      },
      "Transitions": [
        {
          "Days": 0,
          "StorageClass": "INTELLIGENT_TIERING"
        }
      ]
    },
    {
      "ID": "MoveOldBackupsToGlacier",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "backups/"
      },
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER_IR"
        },
        {
          "Days": 365,
          "StorageClass": "DEEP_ARCHIVE"
        }
      ],
      "Expiration": {
        "Days": 2555
      }
    },
    {
      "ID": "AbortIncompleteUploads",
      "Status": "Enabled",
      "Filter": {
        "Prefix": ""
      },
      "AbortIncompleteMultipartUpload": {
        "DaysAfterInitiation": 7
      }
    },
    {
      "ID": "DeleteOldLogs",
      "Status": "Enabled",
      "Filter": {
        "Prefix": "logs/"
      },
      "Expiration": {
        "Days": 90
      },
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 30
      }
    }
  ]
}
```

```bash
# Aplicar política de lifecycle
aws s3api put-bucket-lifecycle-configuration \
  --bucket techstart-data-lake \
  --lifecycle-configuration file://s3-lifecycle-policy.json

# Crear configuración de Intelligent-Tiering con archivado automático
cat > intelligent-tiering-config.json << 'EOF'
{
  "Tierings": [
    {
      "Days": 90,
      "AccessTier": "ARCHIVE_ACCESS"
    },
    {
      "Days": 180,
      "AccessTier": "DEEP_ARCHIVE_ACCESS"
    }
  ]
}
EOF

aws s3api put-bucket-intelligent-tiering-configuration \
  --bucket techstart-data-lake \
  --id "AutoArchiveConfig" \
  --intelligent-tiering-configuration file://intelligent-tiering-config.json
```

## Fase 2: Compute Optimization (Semana 3-4)

### 2.1 Migración a Graviton2/3 (ARM)

**Ahorro estimado:** $360/mes (20% de EC2)

```bash
#!/bin/bash
# graviton-migration-assessment.sh

echo "=== Evaluación de migración a Graviton ==="

# Identificar instancias x86 candidatas a migración
aws ec2 describe-instances \
  --filters Name=instance-type,Values=t3.*,t2.*,m5.*,m4.*,c5.*,c4.*,r5.*,r4.* \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,Type:InstanceType,Name:Tags[?Key==`Name`]|[0].Value}' \
  --output table

# Mapeo de tipos x86 → Graviton
declare -A MIGRATION_MAP=(
  ["t3.micro"]="t4g.micro"
  ["t3.small"]="t4g.small"
  ["t3.medium"]="t4g.medium"
  ["t3.large"]="t4g.large"
  ["m5.large"]="m6g.large"
  ["m5.xlarge"]="m6g.xlarge"
  ["m5.2xlarge"]="m6g.2xlarge"
  ["c5.large"]="c6g.large"
  ["c5.xlarge"]="c6g.xlarge"
  ["r5.large"]="r6g.large"
  ["r5.xlarge"]="r6g.xlarge"
)

echo -e "\n=== Comparativa de Precios (us-east-1) ==="
printf "%-15s %-15s %-12s %-12s %-10s\n" "Tipo Original" "Tipo Graviton" "Precio/h x86" "Precio/h ARM" "Ahorro"
printf "%-15s %-15s %-12s %-12s %-10s\n" "-------------" "-------------" "------------" "------------" "------"

# Precios aproximados On-Demand us-east-1
declare -A PRICES=(
  ["t3.micro"]="0.0104"
  ["t4g.micro"]="0.0084"
  ["m5.large"]="0.096"
  ["m6g.large"]="0.077"
  ["c5.large"]="0.085"
  ["c6g.large"]="0.068"
  ["r5.large"]="0.126"
  ["r6g.large"]="0.1008"
)

for OLD_TYPE in "${!MIGRATION_MAP[@]}"; do
  NEW_TYPE=${MIGRATION_MAP[$OLD_TYPE]}
  OLD_PRICE=${PRICES[$OLD_TYPE]:-"N/A"}
  NEW_PRICE=${PRICES[$NEW_TYPE]:-"N/A"}
  
  if [[ "$OLD_PRICE" != "N/A" && "$NEW_PRICE" != "N/A" ]]; then
    SAVINGS=$(echo "scale=2; ($OLD_PRICE - $NEW_PRICE) / $OLD_PRICE * 100" | bc)
    printf "%-15s %-15s $%-11s $%-11s %s%%\n" "$OLD_TYPE" "$NEW_TYPE" "$OLD_PRICE" "$NEW_PRICE" "$SAVINGS"
  fi
done
```

### 2.2 Implementación de Spot Instances para Cargas Tolerantes

**Ahorro estimado:** $540/mes (70% de 6 instancias de procesamiento)

```yaml
# spot-fleet-template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Spot Fleet para procesamiento batch con diversificación'

Parameters:
  VpcId:
    Type: AWS::EC2::VPC::Id
    Description: VPC para las instancias Spot
  SubnetIds:
    Type: List<AWS::EC2::Subnet::Id>
    Description: Subnets para Spot Fleet
  KeyPair:
    Type: AWS::EC2::KeyPair::KeyName
    Description: Key pair para acceso SSH

Resources:
  SpotFleetRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: spotfleet.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetTaggingRole

  SpotFleet:
    Type: AWS::EC2::SpotFleet
    Properties:
      SpotFleetRequestConfigData:
        IamFleetRole: !GetAtt SpotFleetRole.Arn
        AllocationStrategy: capacityOptimized  # Mejor disponibilidad
        TargetCapacity: 6
        SpotPrice: 0.10
        ValidFrom: '2024-01-01T00:00:00Z'
        ValidUntil: '2025-01-01T00:00:00Z'
        TerminateInstancesWithExpiration: true
        LaunchSpecifications:
          # Pool 1: c5.large (Spot ~70% ahorro)
          - ImageId: ami-0123456789abcdef0
            InstanceType: c5.large
            KeyName: !Ref KeyPair
            SpotPrice: '0.025'
            WeightedCapacity: 1
            IamInstanceProfile:
              Arn: !GetAtt SpotInstanceProfile.Arn
            UserData:
              Fn::Base64: |
                #!/bin/bash
                yum update -y
                yum install -y docker
                service docker start
                # Instalar CloudWatch agent para métricas
                yum install -y amazon-cloudwatch-agent
                echo "Spot instance $(hostname) ready" > /var/log/spot-ready.log
            TagSpecifications:
              - ResourceType: instance
                Tags:
                  - Key: Name
                    Value: spot-worker-c5
                  - Key: Environment
                    Value: batch
                  - Key: CostCenter
                    Value: data-processing
          # Pool 2: c5a.large (AMD, alternativa)
          - ImageId: ami-0123456789abcdef0
            InstanceType: c5a.large
            KeyName: !Ref KeyPair
            SpotPrice: '0.023'
            WeightedCapacity: 1
            IamInstanceProfile:
              Arn: !GetAtt SpotInstanceProfile.Arn
            TagSpecifications:
              - ResourceType: instance
                Tags:
                  - Key: Name
                    Value: spot-worker-c5a
                  - Key: Environment
                    Value: batch
          # Pool 3: c6g.large (Graviton, mayor ahorro)
          - ImageId: ami-arm64-0123456789abcdef0
            InstanceType: c6g.large
            KeyName: !Ref KeyPair
            SpotPrice: '0.020'
            WeightedCapacity: 1
            IamInstanceProfile:
              Arn: !GetAtt SpotInstanceProfile.Arn
            TagSpecifications:
              - ResourceType: instance
                Tags:
                  - Key: Name
                    Value: spot-worker-c6g
                  - Key: Environment
                    Value: batch

  SpotInstanceProfile:
    Type: AWS::IAM::InstanceProfile
    Properties:
      Roles:
        - !Ref SpotInstanceRole

  SpotInstanceRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: ec2.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy
        - arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
      Policies:
        - PolicyName: SpotWorkerPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - sqs:ReceiveMessage
                  - sqs:DeleteMessage
                  - sqs:GetQueueAttributes
                Resource: "arn:aws:sqs:*:*:batch-queue-*"
              - Effect: Allow
                Action:
                  - sns:Publish
                Resource: "arn:aws:sns:*:*:spot-interruptions"

  # SNS Topic para notificaciones de interrupción Spot
  SpotInterruptionTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: spot-interruption-notifications

  # CloudWatch Events para capturar interrupciones Spot
  SpotInterruptionRule:
    Type: AWS::Events::Rule
    Properties:
      Name: spot-interruption-handler
      Description: "Capturar interrupciones de Spot"
      EventPattern:
        source:
          - aws.ec2
        detail-type:
          - EC2 Spot Instance Interruption Warning
      Targets:
        - Arn: !Ref SpotInterruptionTopic
          Id: SpotInterruptionTarget

Outputs:
  SpotFleetId:
    Description: ID del Spot Fleet
    Value: !Ref SpotFleet
```

### 2.3 Reserved Instances y Savings Plans

**Ahorro estimado:** $720/meaño 1 (40%), $936/mes año 2-3 (52% con 3 años)

```bash
#!/bin/bash
# savings-plans-calculator.sh

echo "=== Análisis de Savings Plans vs Reserved Instances ==="

# Escenario: 10 instancias m5.large corriendo 24/7
INSTANCES=10
HOURS_PER_MONTH=730
ON_DEMAND_PRICE=0.096  # m5.large us-east-1

# Cálculo On-Demand
ON_DEMAND_MONTHLY=$(echo "$INSTANCES * $HOURS_PER_MONTH * $ON_DEMAND_PRICE" | bc)
echo "Costo On-Demand mensual: \$$ON_DEMAND_MONTHLY"

# Reserved Instances - Standard 3 años, pago total
RI_DISCOUNT=0.60
RI_PRICE=$(echo "$ON_DEMAND_PRICE * (1 - $RI_DISCOUNT)" | bc)
RI_MONTHLY=$(echo "$INSTANCES * $HOURS_PER_MONTH * $RI_PRICE" | bc)
echo "Costo RI Standard 3yr (pago total): \$$RI_MONTHLY"
echo "Ahorro mensual: \$(echo "$ON_DEMAND_MONTHLY - $RI_MONTHLY" | bc)"

# Compute Savings Plans - 3 años
CSP_DISCOUNT=0.54
CSP_PRICE=$(echo "$ON_DEMAND_PRICE * (1 - $CSP_DISCOUNT)" | bc)
CSP_MONTHLY=$(echo "$INSTANCES * $HOURS_PER_MONTH * $CSP_PRICE" | bc)
echo -e "\nCosto Compute Savings Plans 3yr: \$$CSP_MONTHLY"
echo "Ahorro mensual: \$(echo "$ON_DEMAND_MONTHLY - $CSP_MONTHLY" | bc)"

# Recomendación
echo -e "\n=== RECOMENDACIÓN ==="
echo "Para cargas estables 24/7: Reserved Instances Standard 3 años"
echo "Para flexibilidad (cambio de familia/región): Compute Savings Plans"
echo "Nivel de compromiso recomendado: $((INSTANCES * HOURS_PER_MONTH)) horas/mes"

# Comprar Savings Plans via CLI (ejemplo)
echo -e "\n=== Comandos para compra ==="
cat << 'EOF'
# 1. Ver recomendaciones de Savings Plans
aws ce get-savings-plans-purchase-recommendation \
  --savings-plans-type COMPUTE_SP \
  --term-in-years THREE_YEARS \
  --payment-option ALL_UP \
  --look-back-period-last-thirty-days

# 2. Comprar Compute Savings Plans
aws ce create-savings-plan \
  --savings-plan-offering-id <offering-id> \
  --commitment 50.0  # $50/hora comprometidos
EOF
```

## Fase 3: Database Optimization (Semana 5-6)

### 3.1 RDS Reserved Instances + Storage Optimization

**Ahorro estimado:** $480/mes Reserved + $120/mes storage = $600/mes total

```bash
#!/bin/bash
# rds-optimization.sh

echo "=== RDS Optimization Assessment ==="

# Listar instancias RDS
aws rds describe-db-instances \
  --query 'DBInstances[*].{ID:DBInstanceIdentifier,Class:DBInstanceClass,Engine:Engine,Storage:AllocatedStorage}' \
  --output table

# Verificar multi-AZ (duplica costo - solo para producción crítica)
echo -e "\n=== Instancias Multi-AZ (revisar si todas son necesarias) ==="
aws rds describe-db-instances \
  --filters Name=multi-az,Values=true \
  --query 'DBInstances[*].{ID:DBInstanceIdentifier,Class:DBInstanceClass,Environment:TagList[?Key==`Environment`]|[0].Value}' \
  --output table

# Comprar Reserved Instances RDS
echo -e "\n=== Comprar RDS Reserved Instances ==="
aws rds purchase-reserved-db-instances-offering \
  --reserved-db-instances-offering-id <offering-id> \
  --reserved-db-instance-id prod-mysql-reserved \
  --db-instance-count 3
```

```yaml
# rds-storage-optimization.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Optimización de almacenamiento RDS con auto-scaling'

Resources:
  ProdDB:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: techstart-prod-mysql
      DBInstanceClass: db.t3.medium  # Downgrade si es posible
      Engine: mysql
      EngineVersion: '8.0'
      AllocatedStorage: 100
      MaxAllocatedStorage: 500  # Auto-scaling habilitado
      StorageType: gp3  # Migrar de gp2
      StorageEncrypted: true
      MultiAZ: true
      BackupRetentionPeriod: 7  # Reducir si era mayor
      EnablePerformanceInsights: false  # Ahorrar si no se usa
      DeletionProtection: true
      Tags:
        - Key: Environment
          Value: production
        - Key: CostCenter
          Value: database
        - Key: Reserved
          Value: 'true'

  DevDB:
    Type: AWS::RDS::DBInstance
    Properties:
      DBInstanceIdentifier: techstart-dev-mysql
      DBInstanceClass: db.t3.micro
      Engine: mysql
      AllocatedStorage: 20
      StorageType: gp3
      MultiAZ: false  # Dev NO necesita Multi-AZ
      BackupRetentionPeriod: 1  # Mínimo para dev
      Tags:
        - Key: Environment
          Value: development
        - Key: AutoShutdown
          Value: 'true'
```

### 3.2 Aurora Serverless para Cargas Variables

**Ahorro estimado:** $180/mes (vs provisioned 24/7)

```yaml
# aurora-serverless-template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Aurora Serverless v2 para cargas variables'

Resources:
  AuroraServerlessCluster:
    Type: AWS::RDS::DBCluster
    Properties:
      DBClusterIdentifier: techstart-serverless-aurora
      Engine: aurora-mysql
      EngineMode: serverless
      EngineVersion: '8.0.mysql_aurora.3.04.0'
      MasterUsername: admin
      MasterUserPassword: '{{resolve:secretsmanager:techstart/db/password}}'
      DatabaseName: techstartdb
      BackupRetentionPeriod: 7
      DeletionProtection: true
      EnableHttpEndpoint: true  # Data API para Lambda
      ScalingConfiguration:
        MinCapacity: 0.5  # ACU mínimo
        MaxCapacity: 16   # ACU máximo
        AutoPause: true
        SecondsUntilAutoPause: 300  # Pausar después de 5 min inactivo
      Tags:
        - Key: Environment
          Value: production
        - Key: CostOptimization
          Value: serverless

  # RDS Proxy para conexiones eficientes
  RDSProxy:
    Type: AWS::RDS::DBProxy
    Properties:
      DBProxyName: techstart-rds-proxy
      EngineFamily: MYSQL
      RoleArn: !GetAtt RDSProxyRole.Arn
      Auth:
        - AuthScheme: SECRETS
          IAMAuth: DISABLED
          SecretArn: !Ref DBSecret
      VpcSecurityGroupIds:
        - !Ref ProxySecurityGroup
      VpcSubnetIds:
        - !Ref Subnet1
        - !Ref Subnet2

  RDSProxyRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: rds.amazonaws.com
            Action: sts:AssumeRole
```

## Fase 4: Network & Data Transfer (Semana 7-8)

### 4.1 CloudFront + VPC Endpoints

**Ahorro estimado:** $300/mes (60% de data transfer)

```yaml
# cloudfront-optimization.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'CloudFront distribution optimizada para costos'

Parameters:
  S3Bucket:
    Type: String
    Description: Bucket origen para assets
  ALBDomain:
    Type: String
    Description: ALB para origen dinámico

Resources:
  CloudFrontDistribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        Origins:
          # Origen S3 para assets estáticos
          - Id: S3Assets
            DomainName: !Sub '${S3Bucket}.s3.amazonaws.com'
            S3OriginConfig:
              OriginAccessIdentity: ''
            OriginAccessControlId: !Ref S3OriginAccessControl
          # Origen ALB para API/dinámico
          - Id: ALBOrigin
            DomainName: !Ref ALBDomain
            CustomOriginConfig:
              OriginProtocolPolicy: https-only
        DefaultCacheBehavior:
          TargetOriginId: ALBOrigin
          ViewerProtocolPolicy: redirect-to-https
          CachePolicyId: !Ref APICachePolicy
          OriginRequestPolicyId: !Ref APIOriginRequestPolicy
          Compress: true
        CacheBehaviors:
          # Assets con cache agresivo
          - PathPattern: /assets/*
            TargetOriginId: S3Assets
            ViewerProtocolPolicy: redirect-to-https
            CachePolicyId: 658327ea-f89d-4fab-a63d-7e88639e58f6  # Managed-CachingOptimized
            Compress: true
          - PathPattern: /images/*
            TargetOriginId: S3Assets
            ViewerProtocolPolicy: redirect-to-https
            CachePolicyId: 658327ea-f89d-4fab-a63d-7e88639e58f6
            Compress: true
          - PathPattern: /static/*
            TargetOriginId: S3Assets
            ViewerProtocolPolicy: redirect-to-https
            CachePolicyId: 658327ea-f89d-4fab-a63d-7e88639e58f6
            Compress: true
        Enabled: true
        PriceClass: PriceClass_100  # Norteamérica y Europa (ahorro vs Global)
        HttpVersion: http2and3
        IPV6Enabled: true
        Logging:
          Bucket: !Sub 'techstart-logs.s3.amazonaws.com'
          Prefix: cloudfront/
          IncludeCookies: false

  # Cache policy personalizada para API
  APICachePolicy:
    Type: AWS::CloudFront::CachePolicy
    Properties:
      CachePolicyConfig:
        Name: techstart-api-cache
        DefaultTTL: 60
        MaxTTL: 300
        MinTTL: 0
        ParametersInCacheKeyAndForwardedToOrigin:
          EnableAcceptEncodingGzip: true
          EnableAcceptEncodingBrotli: true
          HeadersConfig:
            HeaderBehavior: whitelist
            Headers:
              - Authorization
              - Origin
          CookiesConfig:
            CookieBehavior: none
          QueryStringsConfig:
            QueryStringBehavior: all

  APIOriginRequestPolicy:
    Type: AWS::CloudFront::OriginRequestPolicy
    Properties:
      OriginRequestPolicyConfig:
        Name: techstart-api-origin-policy
        HeadersConfig:
          HeaderBehavior: whitelist
          Headers:
            - Origin
            - Access-Control-Request-Headers
            - Access-Control-Request-Method
        CookiesConfig:
          CookieBehavior: all
        QueryStringsConfig:
          QueryStringBehavior: all

  S3OriginAccessControl:
    Type: AWS::CloudFront::OriginAccessControl
    Properties:
      OriginAccessControlConfig:
        Name: techstart-s3-oac
        OriginAccessControlOriginType: s3
        SigningBehavior: always
        SigningProtocol: sigv4
```

```yaml
# vpc-endpoints.yaml - Reducir costos de NAT Gateway
AWSTemplateFormatVersion: '2010-09-09'
Description: 'VPC Endpoints para servicios AWS sin salir por Internet'

Resources:
  # S3 Gateway Endpoint (GRATIS, no cobra data processing)
  S3Endpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      VpcId: !Ref VPC
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.s3'
      VpcEndpointType: Gateway
      RouteTableIds:
        - !Ref PrivateRouteTable1
        - !Ref PrivateRouteTable2

  # DynamoDB Gateway Endpoint (GRATIS)
  DynamoDBEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      VpcId: !Ref VPC
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.dynamodb'
      VpcEndpointType: Gateway
      RouteTableIds:
        - !Ref PrivateRouteTable1
        - !Ref PrivateRouteTable2

  # SSM Interface Endpoint (cobre por hora, pero ahorra NAT)
  SSMEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      VpcId: !Ref VPC
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.ssm'
      VpcEndpointType: Interface
      PrivateDnsEnabled: true
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2
      SecurityGroupIds:
        - !Ref EndpointSecurityGroup

  # CloudWatch Logs Endpoint
  CloudWatchEndpoint:
    Type: AWS::EC2::VPCEndpoint
    Properties:
      VpcId: !Ref VPC
      ServiceName: !Sub 'com.amazonaws.${AWS::Region}.logs'
      VpcEndpointType: Interface
      PrivateDnsEnabled: true
      SubnetIds:
        - !Ref PrivateSubnet1
        - !Ref PrivateSubnet2
      SecurityGroupIds:
        - !Ref EndpointSecurityGroup

  EndpointSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Security group para VPC Endpoints
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          SourceSecurityGroupId: !Ref PrivateInstanceSG
```

## Dashboard FinOps y Monitoreo

### CloudWatch Dashboard de Costos

```json
// cost-dashboard.json - Importar en CloudWatch
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "title": "Estimated Monthly Cost",
        "region": "us-east-1",
        "metrics": [
          ["AWS/Billing", "EstimatedCharges", "Currency", "USD", { "stat": "Maximum" }]
        ],
        "period": 86400,
        "yAxis": {
          "left": { "min": 0 }
        },
        "annotations": {
          "horizontal": [
            { "value": 5000, "label": "Original Budget", "color": "#ff0000" },
            { "value": 2800, "label": "Target", "color": "#00aa00" }
          ]
        }
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "EC2 Costs by Instance",
        "region": "us-east-1",
        "metrics": [
          ["AWS/Billing", "EstimatedCharges", "ServiceName", "AmazonEC2", "Currency", "USD"]
        ],
        "period": 3600
      }
    },
    {
      "type": "metric",
      "properties": {
        "title": "S3 Costs Breakdown",
        "region": "us-east-1",
        "metrics": [
          ["AWS/Billing", "EstimatedCharges", "ServiceName", "AmazonS3", "Currency", "USD"]
        ],
        "period": 86400
      }
    },
    {
      "type": "log",
      "properties": {
        "title": "Cost Optimization Actions",
        "region": "us-east-1",
        "query": "fields @timestamp, @message\n| filter @message like /CostOptimization/\n| sort @timestamp desc\n| limit 100"
      }
    }
  ]
}
```

### Lambda de Cost Alerts Inteligentes

```python
# cost_alerts.py - Alertas basadas en ML forecasting
import boto3
import json
from datetime import datetime, timedelta

ce = boto3.client('ce')
sns = boto3.client('sns')

BUDGET_THRESHOLD = 2800  # Nuevo presupuesto objetivo
ALERT_TOPIC = 'arn:aws:sns:us-east-1:123456789:cost-alerts'

def lambda_handler(event, context):
    # Obtener costos actuales del mes
    today = datetime.now()
    start_of_month = today.replace(day=1)
    
    response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': start_of_month.strftime('%Y-%m-%d'),
            'End': today.strftime('%Y-%m-%d')
        },
        Granularity='MONTHLY',
        Metrics=['BlendedCost', 'UnblendedCost'],
        GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
    )
    
    current_cost = 0
    service_breakdown = []
    
    for result in response['ResultsByTime']:
        for group in result['Groups']:
            amount = float(group['Metrics']['BlendedCost']['Amount'])
            service = group['Keys'][0]
            current_cost += amount
            service_breakdown.append(f"{service}: ${amount:.2f}")
    
    # Calcular proyección
    days_in_month = (today.replace(month=today.month % 12 + 1, day=1) - timedelta(days=1)).day
    daily_avg = current_cost / today.day
    projected_monthly = daily_avg * days_in_month
    
    # Alertas inteligentes
    alerts = []
    
    if projected_monthly > BUDGET_THRESHOLD * 1.1:
        alerts.append(f"🚨 CRITICAL: Proyectado ${projected_monthly:.2f} (>{BUDGET_THRESHOLD*1.1:.0f})")
    elif projected_monthly > BUDGET_THRESHOLD:
        alerts.append(f"⚠️ WARNING: Proyectado ${projected_monthly:.2f} (>{BUDGET_THRESHOLD})")
    
    # Detectar anomalías (>30% vs promedio)
    if current_cost > daily_avg * today.day * 1.3:
        alerts.append(f"📈 Anomalía detectada: Costo 30% mayor al promedio esperado")
    
    # Enviar notificación si hay alertas
    if alerts:
        message = f"""
AWS Cost Alert - {today.strftime('%Y-%m-%d')}

Current MTD: ${current_cost:.2f}
Projected Monthly: ${projected_monthly:.2f}
Budget Target: ${BUDGET_THRESHOLD:.2f}

Alerts:
{chr(10).join(alerts)}

Top Services:
{chr(10).join(service_breakdown[:5])}
        """
        
        sns.publish(
            TopicArn=ALERT_TOPIC,
            Subject=f"AWS Cost Alert: ${current_cost:.2f} MTD",
            Message=message
        )
    
    return {
        'current_cost': current_cost,
        'projected': projected_monthly,
        'alerts': alerts
    }
```

## Árbol de Decisiones: Estrategia de Costos

```
┌─────────────────────────────────────────────────────────────────┐
│                    ÁRBOL DE OPTIMIZACIÓN AWS                    │
└─────────────────────────────────────────────────────────────────┘

¿Instancia corre 24/7 y carga es predecible?
│
├─ SÍ ──→ ¿Familia de instancia puede cambiar?
│   │
│   ├─ SÍ → Compute Savings Plans (hasta 66% ahorro)
│   │         └─ ¿3 años de uso seguro?
│   │             ├─ SÍ → Pago total adelantado (máximo descuento)
│   │             └─ NO → Pago parcial
│   │
│   └─ NO → EC2 Instance Savings Plans (hasta 72% ahorro)
│             └─ ¿Necesidad de cambiar familia futuro?
│                 ├─ SÍ → Convertible Reserved Instances
│                 └─ NO → Standard Reserved Instances
│
├─ NO ──→ ¿Carga tolera interrupciones?
│   │
│   ├─ SÍ → Spot Instances (hasta 90% ahorro)
│   │         ├─ ¿Stateful? → Spot con checkpointing
│   │         └─ ¿Stateless? → Spot Fleet diversificado
│   │
│   └─ NO → On-Demand + Auto Scaling
│             └─ ¿Horario específico?
│                 ├─ SÍ → Scheduled Scaling
│                 └─ NO → Target Tracking
│

¿Almacenamiento S3 > 1TB?
│
├─ SÍ → S3 Intelligent-Tiering automático
│         └─ ¿Datos > 90 días sin acceso?
│             ├─ SÍ → Configurar Archive Access (90 días)
│             │         └─ ¿Regulatorio > 1 año?
│             │             ├─ SÍ → Deep Archive (180 días)
│             │             └─ NO → Standard Glacier (90 días)
│             └─ NO → Monitor access patterns
│
└─ NO → S3 Standard-IA manual (si > 30 días)

¿Base de datos uso es variable?
│
├─ SÍ → Aurora Serverless v2 (auto-pause)
│
└─ NO → RDS Reserved Instances
      └─ ¿Multi-AZ realmente necesario?
          ├─ SÍ → Reserved + Multi-AZ (producción)
          └─ NO → Reserved single-AZ (ahorro 50%)

¿Data transfer > $200/mes?
│
├─ SÍ → Implementar CloudFront
│         ├─ ¿Static assets? → Cache behaviors agresivos
│         └─ ¿API responses cacheables? → Edge caching
│
└─ NO → VPC Endpoints para servicios AWS
```

## Resultado Final: TechStart Optimizado

```
Comparativa Before/After (TechStart):
┌──────────────────────┬────────────┬────────────┬────────────┐
│ Componente           │ Antes      │ Después    │ Ahorro     │
├──────────────────────┼────────────┼────────────┼────────────┤
│ EC2 Compute          │ $1,800     │ $720       │ 60%        │
│  ├─ Spot Instances   │ $0         │ $180       │ (70% off)  │
│  ├─ Graviton         │ $0         │ $360       │ (20% off)  │
│  ├─ Auto-shutdown    │ $720       │ $0         │ (100% off) │
│  └─ Reserved         │ $1,080     │ $180       │ (52% off)  │
├──────────────────────┼────────────┼────────────┼────────────┤
│ RDS                  │ $1,200     │ $600       │ 50%        │
│  ├─ Reserved         │ $0         │ $480       │ (40% off)  │
│  └─ No Multi-AZ dev  │ $400       │ $0         │ (100% off) │
├──────────────────────┼────────────┼────────────┼────────────┤
│ S3                   │ $650       │ $325       │ 50%        │
│  ├─ Intelligent-Tier │ $0         │ $195       │ (30% off)  │
│  └─ Lifecycle Glacier│ $455       │ $130       │ (70% off)  │
├──────────────────────┼────────────┼────────────┼────────────┤
│ Data Transfer        │ $500       │ $200       │ 60%        │
│  └─ CloudFront cache │ $0         │ $300       │ optimizado │
├──────────────────────┼────────────┼────────────┼────────────┤
│ Elasticache          │ $350       │ $280       │ 20%        │
│ EBS                  │ $150       │ $105       │ 30%        │
│ CloudFront           │ $280       │ $280       │ 0%         │
│ Otros                │ $170       │ $170       │ 0%         │
├──────────────────────┼────────────┼────────────┼────────────┤
│ TOTAL                │ $5,000     │ $2,800     │ 44%        │
└──────────────────────┴────────────┴────────────┴────────────┘

Payback de inversión:
┌────────────────────────┬────────────┐
│ Inversión inicial      │ $2,400     │
│ (RI upfront, setup)    │            │
├────────────────────────┼────────────┤
│ Ahorro mensual         │ $2,200     │
├────────────────────────┼────────────┤
│ ROI mensual            │ 91.7%      │
│ Payback period         │ 1.1 meses  │
│ ROI anual              │ 1,100%     │
└────────────────────────┴────────────┘
```

## Templates Rápidos

### Terraform: Full Cost Optimization Stack

```hcl
# main.tf - Stack completo de optimización
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Variables
variable "environment" {
  default = "production"
}

variable "budget_amount" {
  default = 3000  # USD mensual
}

# Budgets con alertas
resource "aws_budgets_budget" "monthly" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.budget_amount
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  cost_filter {
    name = "TagKeyValue"
    values = [
      "user:Environment$${var.environment}",
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = ["finance@company.com"]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = ["cto@company.com", "finance@company.com"]
  }
}

# SCP: Prevenir instancias caras sin aprobación
resource "aws_organizations_policy" "cost_control" {
  name    = "cost-control-scp"
  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyExpensiveInstances"
        Effect = "Deny"
        Action = [
          "ec2:RunInstances",
        ]
        Resource = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          "ForAnyValue:StringLike" = {
            "ec2:InstanceType" = [
              "x1.*",
              "x1e.*",
              "u-*",
              "*.10xlarge",
              "*.16xlarge",
              "*.24xlarge",
            ]
          }
          StringNotEquals = {
            "aws:PrincipalTag/CostApproved" = "true"
          }
        }
      },
      {
        Sid    = "DenyUnapprovedRegions"
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "us-east-1",
              "us-west-2",
              "eu-west-1",
            ]
          }
        }
      },
      {
        Sid    = "RequireCostTags"
        Effect = "Deny"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateVolume",
          "rds:CreateDBInstance",
          "s3:CreateBucket",
        ]
        Resource = "*"
        Condition = {
          Null = {
            "aws:RequestTag/CostCenter" = "true"
          }
        }
      },
    ]
  })
}

# AWS Cost Anomaly Detection
resource "aws_ce_anomaly_monitor" "service_monitor" {
  name              = "service-level-monitor"
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "alert_subscription" {
  name      = "anomaly-alerts"
  threshold = 100  # $100
  frequency = "DAILY"
  monitor_arn_list = [
    aws_ce_anomaly_monitor.service_monitor.arn,
  ]
  subscriber {
    type    = "EMAIL"
    address = "finance@company.com"
  }
}

# Outputs
output "budget_id" {
  value = aws_budgets_budget.monthly.id
}

output "anomaly_monitor_arn" {
  value = aws_ce_anomaly_monitor.service_monitor.arn
}
```

### Script de Health Check de Costos

```bash
#!/bin/bash
# cost-health-check.sh - Diagnóstico rápido de optimización

echo "=========================================="
echo "  AWS COST OPTIMIZATION HEALTH CHECK"
echo "=========================================="

# 1. Recursos huérfanos (sin Owner tag)
echo -e "\n🔍 [1/7] Recursos sin tag 'Owner':"
aws resourcegroupstagging-api get-resources \
  --tag-filters Key=Owner,Values= \
  --resources-per-page 100 \
  --query 'ResourceTagMappingList[*].{Resource:ResourceARN}' \
  --output table | head -20

# 2. Instancias paradas con EBS attachado (cobrando storage)
echo -e "\n💾 [2/7] Instancias stopped con volumes (costo EBS):"
aws ec2 describe-instances \
  --filters Name=instance-state-name,Values=stopped \
  --query 'Reservations[*].Instances[*].{ID:InstanceId,Vol:BlockDeviceMappings[*].Ebs.VolumeId}' \
  --output table

# 3. Volumes unattached
echo -e "\n📦 [3/7] Volumes EBS unattached (candidatos a eliminar):"
aws ec2 describe-volumes \
  --filters Name=status,Values=available \
  --query 'Volumes[*].{ID:VolumeId,Size:Size,AZ:AvailabilityZone,Created:CreateTime}' \
  --output table

# 4. Snapshots antiguos (>90 días)
echo -e "\n📸 [4/7] Snapshots > 90 días (revisar necesidad):"
aws ec2 describe-snapshots \
  --owner-ids self \
  --query "Snapshots[?StartTime<='$(date -v-90d +%Y-%m-%d)'].{ID:SnapshotId,Date:StartTime,Size:VolumeSize}" \
  --output table | head -20

# 5. IPs elásticas no asignadas
echo -e "\n🌐 [5/7] Elastic IPs no asignadas (cobra $0.005/hr):"
aws ec2 describe-addresses \
  --filters Name=association-id,Values= \
  --query 'Addresses[*].{IP:PublicIp,Alloc:AllocationId}' \
  --output table

# 6. Load balancers sin targets
echo -e "\n⚖️  [6/7] ALBs con 0 targets (potencialmente huérfanos):"
for alb in $(aws elbv2 describe-load-balancers --query 'LoadBalancers[*].LoadBalancerArn' --output text); do
  targets=$(aws elbv2 describe-target-groups --load-balancer-arn $alb --query 'length(TargetGroups)' --output text)
  if [ "$targets" == "0" ]; then
    echo "ALB sin target groups: $alb"
  fi
done

# 7. RDS sin Multi-AZ en producción (revisar RPO/RTO)
echo -e "\n🗄️  [7/7] RDS con Multi-AZ (revisar si es necesario):"
aws rds describe-db-instances \
  --filters Name=multi-az,Values=true \
  --query 'DBInstances[*].{ID:DBInstanceIdentifier,Class:DBInstanceClass,Env:TagList[?Key==`Environment`]|[0].Value}' \
  --output table

echo -e "\n=========================================="
echo "  ACCIONES SUGERIDAS:"
echo "=========================================="
echo "1. Taggear recursos sin Owner"
echo "2. Eliminar volumes unattached"
echo "3. Revisar snapshots > 90 días"
echo "4. Liberar IPs elásticas no usadas"
echo "5. Eliminar ALBs sin targets"
echo "6. Evaluar RDS Multi-AZ en dev/test"
echo "=========================================="
```

## Referencias Rápidas

### Precios de Referencia (us-east-1, aproximados)

| Servicio | On-Demand | Reserved 1y | Reserved 3y | Spot |
|----------|-----------|-------------|-------------|------|
| t3.micro | $0.0104/h | $0.0062/h | $0.0036/h | $0.003/h |
| m5.large | $0.096/h | $0.060/h | $0.038/h | $0.029/h |
| m6g.large| $0.077/h | $0.048/h | $0.031/h | $0.023/h |
| c5.large | $0.085/h | $0.053/h | $0.034/h | $0.026/h |
| r5.large | $0.126/h | $0.079/h | $0.050/h | $0.038/h |

### S3 Storage Classes

| Clase | Precio/GB | Retrieval | Use Case |
|-------|-----------|-----------|----------|
| Standard | $0.023 | Instant | Acceso frecuente |
| Standard-IA | $0.0125 | $0.01/GB | Acceso infrecuente |
| One Zone-IA | $0.010 | $0.01/GB | Backup reproducible |
| Glacier IR | $0.004 | Instant | Archivo con acceso rápido |
| Glacier | $0.0036 | 1-5 min | Archivo flexible |
| Deep Archive | $0.00099 | 12-48h | Archivo largo plazo |

### Data Transfer Costs

| Origen → Destino | Costo |
|------------------|-------|
| Internet → EC2 | $0.00 (entrada gratis) |
| EC2 → Internet | $0.09/GB |
| EC2 → CloudFront | $0.00 |
| CloudFront → Internet | $0.085/GB (varía por región) |
| Cross-AZ | $0.01/GB |
| Cross-Region | $0.02/GB |
| VPC Endpoint | $0.01/hr + procesamiento |
