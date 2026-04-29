# Capítulo 10: Estrategias de Costos en AWS

## Resumen Ejecutivo

La optimización de costos en la nube es un pilar fundamental para maximizar el valor de la inversión en AWS. Este whitepaper presenta estrategias integrales, mejores prácticas y herramientas para gestionar y optimizar eficientemente los costos en la plataforma AWS. Dirigido a directores financieros, gerentes de TI, arquitectos de soluciones y profesionales de operaciones en la nube, este documento proporciona un marco para implementar una cultura de conciencia de costos, técnicas de análisis detallado y métodos para equilibrar costos con rendimiento y disponibilidad. Las organizaciones que implementan estas estrategias pueden lograr reducciones significativas en gastos mientras mantienen o mejoran la calidad de sus servicios, convirtiendo la optimización de costos en una ventaja competitiva sostenible.

## Fundamentos del Modelo de Costos de AWS

### Modelo de Pago por Uso

El modelo de pago por uso de AWS representa un cambio fundamental en comparación con la infraestructura tradicional on-premises:

- **Sin gastos iniciales:** Eliminación de inversiones de capital significativas
- **Sin compromisos a largo plazo:** Flexibilidad para cambiar o eliminar recursos
- **Granularidad:** Facturación por segundo para muchos servicios
- **Escalabilidad bidireccional:** Capacidad de aumentar o reducir según demanda
- **Transparencia:** Visibilidad detallada del consumo

### Componentes de Costos AWS

Los costos en AWS se derivan de múltiples factores:

- **Cómputo:** Instancias EC2, Lambda, contenedores
- **Almacenamiento:** S3, EBS, EFS, Glacier
- **Transferencia de datos:** Tráfico entre regiones, hacia Internet
- **Bases de datos:** RDS, DynamoDB, Redshift
- **Servicios adicionales:** CloudFront, API Gateway, etc.
- **Características de apoyo:** Balanceadores de carga, IP elásticas

### Variabilidad Regional

Los precios varían según la región AWS, influenciados por:

- **Costos locales de energía y refrigeración**
- **Infraestructura de red**
- **Regulaciones y impuestos**
- **Competencia de mercado**
- **Costos inmobiliarios**

## Herramientas de Gestión y Visualización de Costos

AWS proporciona un conjunto completo de herramientas para administrar y analizar gastos.

### AWS Cost Explorer

Herramienta de visualización y análisis que permite:

- **Análisis de tendencias:** Visualización de patrones históricos de gasto
- **Filtrado granular:** Desglose por servicio, cuenta, región, etiqueta, etc.
- **Previsiones:** Proyecciones de gastos futuros
- **Informes personalizados:** Guardar y compartir vistas personalizadas
- **API:** Acceso programático a datos de costos
- **Recomendaciones:** Sugerencias para RI y Savings Plans

### AWS Budgets

Servicio para establecer presupuestos y alertas:

- **Presupuestos personalizados:** Por costo, uso, RI o Savings Plans
- **Alertas configurables:** Notificaciones al alcanzar umbrales
- **Acciones presupuestarias:** Respuestas automatizadas a superaciones
- **Seguimiento histórico:** Comparación con gastos anteriores
- **Nivel de detalle:** Granularidad por cuenta, servicio, región, etc.

### AWS Cost and Usage Report (CUR)

El conjunto más completo de datos de costos:

- **Máximo detalle:** Desglose completo a nivel de hora o día
- **Formatos flexibles:** CSV, Parquet
- **Integración con Athena:** Consultas SQL sobre datos de costos
- **Identificadores de recursos:** Vinculación con recursos específicos
- **Personalizable:** Configuración según necesidades

### AWS Cost Anomaly Detection

Detecta automáticamente gastos inusuales:

- **Machine learning:** Identificación de patrones anómalos
- **Alertas proactivas:** Notificaciones de desviaciones
- **Contexto detallado:** Información sobre causas potenciales
- **Monitores personalizables:** Por servicio, cuenta, tag, etc.
- **Historial de anomalías:** Seguimiento de incidentes pasados

### AWS Purchase Order Management

Gestión de órdenes de compra para facturación:

- **Asociación de facturas:** Vinculación con órdenes de compra
- **Seguimiento de gastos:** Control de saldos disponibles
- **Alertas:** Notificaciones sobre expiración o saldo bajo
- **Múltiples POs:** Configuración por servicios o períodos

## Estrategias de Descuento y Compromiso

AWS ofrece varios modelos para reducir costos a cambio de compromisos.

### Savings Plans

Modelo de ahorro flexible basado en compromiso de gasto:

- **Compute Savings Plans:** Aplicable a EC2, Fargate y Lambda
- **EC2 Instance Savings Plans:** Específicos para EC2 en región
- **SageMaker Savings Plans:** Para cargas de trabajo de ML
- **Términos:** Compromisos de 1 o 3 años
- **Opciones de pago:** Sin pago adelantado, parcial o total
- **Flexibilidad:** Cambio de familia, tamaño, región u OS

### Reserved Instances (RI)

Modelo de reserva para servicios específicos:

- **Standard RI:** Descuentos mayores, menor flexibilidad
- **Convertible RI:** Flexibilidad para cambiar familias de instancias
- **Términos:** Compromisos de 1 o 3 años
- **Opciones de pago:** Sin pago adelantado, parcial o total
- **Cobertura:** Específica por región o zona
- **Marketplace:** Posibilidad de vender RIs no utilizadas

### Spot Instances

Capacidad EC2 no utilizada a precios con descuento:

- **Descuentos significativos:** Hasta 90% sobre demanda
- **Disponibilidad variable:** AWS puede recuperar instancias
- **Estrategias de interrupción:** Hibernación, parada, terminación
- **Spot Fleet:** Gestión de flotas de instancias spot
- **Casos de uso:** Cargas tolerantes a fallos, procesamiento por lotes

### Descuentos por Volumen y Enterprise

Para organizaciones con gasto significativo:

- **Enterprise Discount Program (EDP):** Descuentos por compromiso
- **Private Pricing Terms:** Acuerdos personalizados
- **Créditos para migración:** Soporte financiero para transición
- **Enterprise Support:** Soporte técnico especializado
- **Arquitectos de soluciones:** Asesoramiento dedicado

## Estrategias de Optimización por Servicio

### Amazon EC2

- **Right-sizing:** Selección del tamaño óptimo de instancia
- **Familias de instancias adecuadas:** Selección por carga de trabajo
- **Aprovechamiento de Spot:** Para cargas de trabajo flexibles
- **Hibernación:** Preservación de estado sin costo de procesamiento
- **AMIs optimizadas:** Instancias pre-configuradas
- **Planes de Auto-scaling:** Adaptación a demanda real
- **Uso de ARM (Graviton):** Mayor eficiencia precio/rendimiento

### Amazon S3

- **Clases de almacenamiento adecuadas:**
  - S3 Standard: Acceso frecuente
  - S3 Intelligent-Tiering: Acceso variable
  - S3 Standard-IA: Acceso infrecuente
  - S3 One Zone-IA: Menor redundancia, menor costo
  - S3 Glacier: Archivado de largo plazo
  - S3 Glacier Deep Archive: Archivado más económico
- **Políticas de ciclo de vida:** Transición automática entre clases
- **Compresión:** Reducción del volumen de datos
- **S3 Analytics:** Identificación de patrones de acceso
- **Request pricing:** Optimización del tipo y número de operaciones

### Amazon RDS y Bases de Datos

- **Multi-AZ selectivo:** Solo para entornos críticos
- **Réplicas de lectura:** Balanceo de cargas de lectura
- **Storage autoscaling:** Crecimiento automático según necesidad
- **Reserved instances:** Para cargas predecibles
- **Hibernación de entornos:** Para ambientes de desarrollo
- **Serverless:** Aurora Serverless para cargas variables
- **Respaldo optimizado:** Política de retención adecuada

### Arquitectura Serverless

- **Lambda:**
  - Optimización de memoria/rendimiento
  - Reutilización de contextos de ejecución
  - Compresión de payload
  - Tiempo de ejecución eficiente
- **API Gateway:**
  - Cache de API
  - Consolidación de endpoints
  - Throttling adecuado
- **DynamoDB:**
  - On-demand vs provisioned
  - DAX para caching
  - Provisión de capacidad auto-escalable

## Prácticas de FinOps en AWS

FinOps (Cloud Financial Operations) es la práctica que combina finanzas, tecnología y negocio.

### Principios Fundamentales

- **Visibilidad y transparencia:** Datos accesibles a todas las partes interesadas
- **Optimización:** Mejora continua de costos-rendimiento
- **Operación:** Procesos integrados en ciclos de desarrollo
- **Rendición de cuentas:** Responsabilidad distribuida por costos
- **Alineación con negocio:** Costos vinculados a valor empresarial

### Implementación de FinOps

- **Establecimiento de Centro de Excelencia FinOps**
- **Definición de políticas y procedimientos**
- **Automatización de reporting y alertas**
- **Implementación de showback/chargeback**
- **Optimización continua**
- **Educación y cultura**

### Ciclo de Vida FinOps

1. **Informar:** Proporcionar visibilidad de costos
2. **Optimizar:** Identificar e implementar mejoras
3. **Operar:** Integrar en procesos diarios
4. **Repetir:** Ciclo de mejora continua

## Estrategias Organizacionales

### Etiquetado (Tagging)

Sistema fundamental para atribución y análisis de costos:

- **Etiquetas de asignación de costos:** Activadas en Billing
- **Estrategia coherente:** Nomenclatura y esquemas definidos
- **Obligatoriedad:** Políticas para asegurar cumplimiento
- **Automatización:** Asignación automática cuando sea posible
- **Categorías comunes:**
  - Centro de costos
  - Aplicación/servicio
  - Entorno (prod, dev, test)
  - Propietario
  - Proyecto

### AWS Organizations y Cuentas Múltiples

Estructura organizacional para control y visibilidad:

- **Consolidación de facturación:** Visión unificada de gastos
- **Descuentos por volumen:** Agregación de uso entre cuentas
- **Segregación por unidad de negocio:** Aislamiento y atribución
- **Aislamiento por entorno:** Separación prod/dev/test
- **Gobierno centralizado:** Políticas unificadas
- **SCP (Service Control Policies):** Límites de servicios disponibles

### Presupuestos y Gobernanza

- **Presupuestos detallados:** Por cuenta, departamento, proyecto
- **Alertas escalonadas:** Múltiples niveles de notificación
- **Acciones automáticas:** Respuestas a excesos presupuestarios
- **Revisiones periódicas:** Evaluación regular de gastos vs presupuesto
- **Forecasting:** Proyección y ajuste continuo

## Análisis y Optimización Avanzada

### Análisis de Costos Unitarios

Vinculación de costos con unidades de negocio:

- **Costo por cliente**
- **Costo por transacción**
- **Costo por usuario activo**
- **Costo por producto vendido**
- **Costo por servicio desplegado**

### Análisis de Eficiencia

Métricas para evaluar eficiencia del gasto:

- **Utilización de recursos vs capacidad**
- **Costo vs performance**
- **TCO comparado con on-premises**
- **ROI de inversiones en optimización**
- **Costos evitados**

### AWS Trusted Advisor

Recomendaciones automatizadas para optimización:

- **Optimización de costos:** Identificación de recursos infrautilizados
- **Rendimiento:** Sugerencias para mejorar performance
- **Seguridad:** Identificación de vulnerabilidades
- **Tolerancia a fallos:** Mejoras en resiliencia
- **Límites de servicio:** Alertas sobre límites cercanos

## Casos Prácticos y Patrones

### Ambientes de Desarrollo/Prueba

- **Programación de recursos:** Apagado automático fuera de horario
- **IAM restrictivo:** Limitación de recursos costosos
- **Tamaños reducidos:** Dimensionamiento apropiado para pruebas
- **Cuotas por equipo/proyecto:** Límites de gasto asignados
- **Limpieza automática:** Eliminación de recursos no utilizados

### Cargas de Trabajo Estacionales

- **Auto Scaling predictivo:** Basado en patrones históricos
- **Uso de capacidad reservada:** Para base predecible
- **Spot para picos:** Complemento económico para máximos
- **Servicios serverless:** Adaptación automática a demanda
- **Planificación proactiva:** Preparación para eventos conocidos

### Optimización de Data Lakes

- **Compresión y formatos columares:** Parquet, ORC
- **Particionamiento eficiente:** Optimización de consultas
- **Políticas de ciclo de vida S3:** Transición automática
- **Análisis de patrones de acceso:** Ajuste basado en uso real
- **Query optimization:** Reducción de datos escaneados

### Optimización de Transferencia de Datos

- **Ubicación estratégica:** Minimizar tráfico entre regiones
- **Compresión:** Reducción de volumen transferido
- **CloudFront:** Optimización de distribución
- **VPC Endpoints:** Evitar salida a internet
- **Direct Connect:** Para volúmenes grandes recurrentes
- **Reserva de ancho de banda:** Para transferencias predecibles

## Mejores Prácticas y Recomendaciones

### Cultura de Conciencia de Costos

- **Transparencia:** Dashboards accesibles a equipos
- **Responsabilidad compartida:** Costos como métricas de equipo
- **Gamificación:** Reconocimiento a optimizaciones exitosas
- **Capacitación continua:** Formación en prácticas eficientes
- **Costos en DoD:** Inclusión en definición de "done"

### Automatización de Optimización

- **Políticas de limpieza:** Eliminación de recursos huérfanos
- **Rightsizing automático:** Ajuste basado en métricas
- **Lifecycle hooks:** Transiciones automáticas entre clases
- **Resource scheduling:** Programación de recursos
- **Herramientas de terceros:** Soluciones especializadas

### Revisión Continua

- **Reuniones regulares de revisión de costos**
- **Benchmarking:** Comparación con referencias de industria
- **Challenges de optimización:** Eventos focalizados
- **Monitoreo de métricas clave**
- **Auditorías de recursos**

## Casos de Éxito en Optimización de Costos

### Airbnb: Reducción del 60% con Arquitectura Serverless

**Situación:** Airbnb enfrentaba costos crecientes en infraestructura tradicional para su motor de búsqueda y sistema de recomendaciones, con picos estacionales que dejaban capacidad ociosa.

**Solución:** Migración a arquitectura serverless con Lambda, API Gateway y DynamoDB on-demand.

**Resultados:**
- Reducción del 60% en costos de computación
- Escalado automático durante eventos de alto tráfico
- Eliminación de pagos por capacidad no utilizada
- Time-to-market reducido en 70%

**Factores Clave:**
- Uso extensivo de Spot Instances para procesamiento por lotes
- Implementación de S3 Intelligent-Tiering para datos históricos
- Aurora Serverless para bases de datos con carga variable

### Lyft: Ahorro de $50M/año con Optimización de Data Pipeline

**Situación:** Lyft procesaba petabytes de datos diarios para análisis de rutas y predicción de demanda, con costos de transferencia y almacenamiento creciendo exponencialmente.

**Solución:** Reorganización completa del data lake con compresión, particionamiento estratégico y políticas de ciclo de vida automatizadas.

**Resultados:**
- Ahorro de $50 millones anuales
- Reducción del 40% en costos de transferencia de datos
- Mejora del 35% en tiempos de consulta analítica

**Estrategias Implementadas:**
- Conversión a formatos columares (Parquet) con compresión
- Implementación de S3 Glacier para datos históricos
- Uso de Reserved Instances para procesamiento ETL predecible
- Kinesis Data Firehose para ingestión optimizada

### Capital One: 30% de Ahorro con FinOps y Tagging Estratégico

**Situación:** Capital One operaba cientos de cuentas AWS con visibilidad limitada de costos por aplicación, equipo y entorno.

**Solución:** Implementación de Centro de Excelencia FinOps con políticas de tagging obligatorias y chargeback automatizado.

**Resultados:**
- 30% de reducción en costos totales de nube
- Visibilidad del 100% de gastos atribuidos
- Reducción del 50% en recursos huérfanos
- Proyecciones de costos con 95% de precisión

**Implementación Clave:**
- Service Control Policies (SCPs) para gobernanza
- AWS Budgets con alertas escalonadas
- Automatización de apagado de entornos no productivos
- Rightsizing continuo basado en métricas CloudWatch

### Epic Games: Escalado Eficiente de Fortnite

**Situación:** Lanzamientos de Fortnite generaban picos de millones de jugadores concurrentes, con infraestructura tradicional resultando en costos masivos o degradación del servicio.

**Solución:** Arquitectura híbrida que combina instancias reservadas para carga base con Spot Instances para picos.

**Resultados:**
- Soporte de 125 millones de jugadores concurrentes
- Optimización del 45% en costos vs infraestructura 100% on-demand
- Matchmaking con latencia <20ms globalmente

**Optimizaciones Específicas:**
- GameLift con flotas Spot para matchmaking
- DynamoDB Global Tables con caché DAX
- CloudFront para distribución de assets con cache hit ratio del 94%

## Templates Seguros para Políticas de Costos

### Template de Service Control Policy (SCP) para Control de Costos

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyHighCostInstances",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances",
        "ec2:ModifyInstanceAttribute"
      ],
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "ForAnyValue:StringEquals": {
          "ec2:InstanceType": [
            "x1.*",
            "x1e.*",
            "u-*"
          ]
        },
        "StringNotEquals": {
          "aws:RequestedRegion": ["us-east-1", "eu-west-1"]
        }
      }
    },
    {
      "Sid": "RequireCostCenterTag",
      "Effect": "Deny",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateVolume",
        "rds:CreateDBInstance",
        "s3:CreateBucket"
      ],
      "Resource": "*",
      "Condition": {
        "Null": {
          "aws:RequestTag/CostCenter": "true"
        },
        "ForAllValues:StringEquals": {
          "aws:TagKeys": ["CostCenter", "Environment", "Owner"]
        }
      }
    },
    {
      "Sid": "DenyLargeStorage",
      "Effect": "Deny",
      "Action": [
        "ec2:CreateVolume",
        "rds:CreateDBInstance"
      ],
      "Resource": "*",
      "Condition": {
        "NumericGreaterThan": {
          "ec2:VolumeSize": "1000",
          "rds:AllocatedStorage": "1000"
        },
        "StringNotEquals": {
          "aws:PrincipalTag/Role": "DatabaseAdmin"
        }
      }
    },
    {
      "Sid": "DenyUnapprovedRegions",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringNotEquals": {
          "aws:RequestedRegion": [
            "us-east-1",
            "us-west-2",
            "eu-west-1"
          ]
        }
      }
    }
  ]
}
```

### Template de Políticas de Budgets y Alertas

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Políticas de Budgets y Alertas de Costos'

Parameters:
  MonthlyBudget:
    Type: Number
    Default: 10000
    Description: Presupuesto mensual en USD
  AlertEmail:
    Type: String
    Description: Email para notificaciones de alertas

Resources:
  MonthlyBudget:
    Type: AWS::Budgets::Budget
    Properties:
      Budget:
        BudgetName: MonthlyCloudBudget
        BudgetLimit:
          Amount: !Ref MonthlyBudget
          Unit: USD
        TimeUnit: MONTHLY
        BudgetType: COST
        CostFilters:
          TagKeyValue:
            - user:CostCenter
        CostTypes:
          IncludeTax: true
          IncludeSubscription: true
          UseBlended: false
          IncludeUpfront: true
          IncludeRecurring: true
          IncludeOtherSubscription: true
          IncludeSupport: true
          IncludeDiscount: true
          IncludeCredit: false
          UseAmortized: false
      NotificationsWithSubscribers:
        - Notification:
            NotificationType: ACTUAL
            ComparisonOperator: GREATER_THAN
            Threshold: 80
            ThresholdType: PERCENTAGE
          Subscribers:
            - SubscriptionType: SNS
              Address: !Ref BudgetAlertTopic
            - SubscriptionType: EMAIL
              Address: !Ref AlertEmail
        - Notification:
            NotificationType: FORECASTED
            ComparisonOperator: GREATER_THAN
            Threshold: 100
            ThresholdType: PERCENTAGE
          Subscribers:
            - SubscriptionType: EMAIL
              Address: !Ref AlertEmail
        - Notification:
            NotificationType: ACTUAL
            ComparisonOperator: GREATER_THAN
            Threshold: 50
            ThresholdType: PERCENTAGE
          Subscribers:
            - SubscriptionType: EMAIL
              Address: !Ref AlertEmail

  BudgetAlertTopic:
    Type: AWS::SNS::Topic
    Properties:
      TopicName: BudgetAlerts
      KmsMasterKeyId: alias/aws/sns

  AutoRemediationFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: CostOptimizationRemediation
      Runtime: python3.11
      Handler: index.handler
      Timeout: 60
      Role: !GetAtt LambdaExecutionRole.Arn
      Code:
        ZipFile: |
          import boto3
          import json
          
          def handler(event, context):
              ec2 = boto3.client('ec2')
              
              # Identificar instancias subutilizadas (>7 días <10% CPU)
              response = ec2.describe_instances(
                  Filters=[
                      {'Name': 'instance-state-name', 'Values': ['running']},
                      {'Name': 'tag:Environment', 'Values': ['dev', 'test']}
                  ]
              )
              
              for reservation in response['Reservations']:
                  for instance in reservation['Instances']:
                      instance_id = instance['InstanceId']
                      
                      # Detener instancias de desarrollo fuera de horario
                      cloudwatch = boto3.client('cloudwatch')
                      metrics = cloudwatch.get_metric_statistics(
                          Namespace='AWS/EC2',
                          MetricName='CPUUtilization',
                          Dimensions=[{'Name': 'InstanceId', 'Value': instance_id}],
                          StartTime=(context.get_remaining_time_in_millis() / 1000) - 604800,
                          EndTime=context.get_remaining_time_in_millis() / 1000,
                          Period=86400,
                          Statistics=['Average']
                      )
                      
                      avg_cpu = sum(dp['Average'] for dp in metrics['Datapoints']) / len(metrics['Datapoints']) if metrics['Datapoints'] else 0
                      
                      if avg_cpu < 10:
                          # Notificar en lugar de detener automáticamente
                          sns = boto3.client('sns')
                          sns.publish(
                              TopicArn=os.environ['ALERT_TOPIC'],
                              Subject=f'Instancia subutilizada: {instance_id}',
                              Message=f'CPU promedio: {avg_cpu:.2f}%. Considerar rightsizing o detención.'
                          )
              
              return {'statusCode': 200, 'body': json.dumps('Análisis completado')}
      Environment:
        Variables:
          ALERT_TOPIC: !Ref BudgetAlertTopic

  LambdaExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      RoleName: CostOptimizationLambdaRole
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
        - PolicyName: CostOptimizationPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - ec2:DescribeInstances
                  - ec2:DescribeInstanceAttribute
                  - ec2:StopInstances
                  - cloudwatch:GetMetricStatistics
                  - sns:Publish
                Resource: "*"
                Condition:
                  StringEquals:
                    aws:RequestedRegion:
                      - us-east-1
                      - us-west-2

  ScheduledRemediation:
    Type: AWS::Events::Rule
    Properties:
      Name: DailyCostOptimization
      ScheduleExpression: cron(0 2 * * ? *)
      State: ENABLED
      Targets:
        - Arn: !GetAtt AutoRemediationFunction.Arn
          Id: CostOptimizationTarget

  PermissionForEvents:
    Type: AWS::Lambda::Permission
    Properties:
      FunctionName: !Ref AutoRemediationFunction
      Action: lambda:InvokeFunction
      Principal: events.amazonaws.com
      SourceArn: !GetAtt ScheduledRemediation.Arn
```

### Terraform: Política de Tagging Obligatorio

```hcl
variable "mandatory_tags" {
  type    = list(string)
  default = ["Environment", "CostCenter", "Owner", "Project"]
}

# AWS Config Rule para tags obligatorios
resource "aws_config_config_rule" "required_tags" {
  name = "required-tags"

  source {
    owner             = "AWS"
    source_identifier = "REQUIRED_TAGS"
  }

  input_parameters = jsonencode({
    tag1Key = "Environment"
    tag2Key = "CostCenter"
    tag3Key = "Owner"
  })

  depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "cost-optimization-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    record_global_resource_types = true
  }
}

# Lambda para auto-tagging de recursos
resource "aws_lambda_function" "auto_tagger" {
  filename         = "auto_tagger.zip"
  function_name    = "auto-tagger"
  role            = aws_iam_role.lambda_role.arn
  handler         = "index.handler"
  runtime         = "python3.11"
  timeout         = 60

  environment {
    variables = {
      DEFAULT_COST_CENTER = "shared-services"
      DEFAULT_OWNER     = "cloud-ops"
    }
  }
}

resource "aws_cloudwatch_event_rule" "resource_created" {
  name        = "resource-created"
  description = "Captura creación de recursos para auto-tagging"

  event_pattern = jsonencode({
    source = ["aws.ec2", "aws.rds", "aws.s3"]
    detail-type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["ec2.amazonaws.com", "rds.amazonaws.com", "s3.amazonaws.com"]
      eventName = [
        "RunInstances",
        "CreateVolume",
        "CreateDBInstance",
        "CreateBucket"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.resource_created.name
  target_id = "AutoTagger"
  arn       = aws_lambda_function.auto_tagger.arn
}
```

## Árbol de Decisiones: Estrategia de Costos

### Árbol de Selección de Modelo de Precios

```
¿La carga de trabajo es continua y predecible?
│
├─ SÍ → ¿Requiere flexibilidad para cambiar familias de instancias?
│   │
│   ├─ SÍ → Compute Savings Plans (hasta 66% de ahorro)
│   │   │
│   │   └─ ¿Uso consistente por 3 años?
│   │       ├─ SÍ → Pago total adelantado (mayor descuento)
│   │       └─ NO → Pago parcial o sin adelanto
│   │
│   └─ NO → EC2 Instance Savings Plans (hasta 72% de ahorro)
│       │
│       └─ ¿Región y familia fijas?
│           ├─ SÍ → Standard Reserved Instances (mayor descuento)
│           └─ NO → Convertible Reserved Instances (flexibilidad)
│
├─ NO → ¿Carga variable o por eventos?
│   │
│   ├─ SÍ → ¿Tiempo de ejecución < 15 minutos?
│   │   ├─ SÍ → AWS Lambda (pago por milisegundo)
│   │   └─ NO → Fargate Spot o EC2 Spot
│   │
│   └─ NO → On-Demand con Auto Scaling
│
└─ ¿Carga de trabajo tolerante a interrupciones?
    ├─ SÍ → Spot Instances (hasta 90% de descuento)
    │   │
    │   ├─ ¿Aplicación stateless?
    │   │   ├─ SÍ → Spot Fleet con diversificación
    │   │   └─ NO → Spot con checkpointing/hibernación
    │   │
    │   └─ ¿Procesamiento por lotes?
    │       ├─ SÍ → AWS Batch con Spot
    │       └─ NO → Spot con grupo Auto Scaling
    │
    └─ NO → On-Demand con monitoreo continuo
```

### Árbol de Optimización de Almacenamiento

```
¿Qué tipo de acceso tienen los datos?
│
├─ Acceso frecuente (< 30 días)
│   ├─ SÍ → ¿Requiere baja latencia < 10ms?
│   │   ├─ SÍ → EBS SSD (gp3) o Instance Store
│   │   └─ NO → S3 Standard
│   │
│   └─ ¿Acceso desde múltiples zonas?
│       ├─ SÍ → S3 Standard
│       └─ NO → S3 One Zone-IA (ahorro 20%)
│
├─ Acceso variable/impredecible
│   └─ SÍ → S3 Intelligent-Tiering (monitoreo automático)
│       └─ ¿Objetos > 128KB?
│           ├─ SÍ → Costo de monitoreo justificado
│           └─ NO → S3 Standard-IA manual
│
├─ Acceso infrecuente (30-90 días)
│   └─ SÍ → S3 Standard-IA (ahorro 40% vs Standard)
│
├─ Archivado (90 días - 1 año)
│   ├─ ¿Recuperación flexible (1-5 minutos)?
│   │   ├─ SÍ → S3 Glacier Instant Retrieval
│   │   └─ NO → S3 Glacier Flexible Retrieval (3-5 horas)
│
└─ Archivado largo plazo (> 1 año)
    └─ SÍ → S3 Glacier Deep Archive (ahorro 95%)
        └─ ¿Requerimiento de recuperación < 12 horas?
            ├─ SÍ → Bulk retrieval (menor costo)
            └─ NO → Standard retrieval
```

### Árbol de Decisiones: Migración a Graviton

```
¿Las aplicaciones usan lenguajes interpretados o compilados?
│
├─ Interpretados (Python, Node.js, Java)
│   └─ SÍ → ¿Uso de dependencias nativas?
│       ├─ SÍ → Verificar soporte ARM64
│       │   ├─ Compatible → Migrar a Graviton2/3 (40% ahorro)
│       │   └─ No compatible → Mantener x86
│       │
│       └─ NO → Migración directa a Graviton
│
├─ Compilados (C++, Go, Rust)
│   └─ SÍ → ¿Recompilación disponible?
│       ├─ SÍ → Recompilar para ARM64 + migración
│       └─ NO → Binarios x86 en Graviton (emulación)
│
└─ Containers
    └─ SÍ → ¿Imágenes multi-arch?
        ├─ SÍ → ECS/EKS con mixed capacity (Graviton + x86)
        └─ NO → Rebuild de imágenes para ARM64
```

## Calculadora de Optimización de Costos

### Calculadora de TCO: Migración a Graviton

```
Escenario: 50 instancias EC2 m5.large vs 50 instancias m6g.large

On-Demand Pricing (us-east-1):
- m5.large (x86): $0.096/hora
- m6g.large (Graviton2): $0.077/hora

Cálculo mensual (730 horas):
┌─────────────────┬────────────┬────────────┬────────────┐
│ Métrica         │ x86        │ Graviton2  │ Ahorro     │
├─────────────────┼────────────┼────────────┼────────────┤
│ Costo/instancia │ $70.08     │ $56.21     │ $13.87     │
│ Total 50 inst.  │ $3,504     │ $2,810.50  │ $693.50    │
│ Anual           │ $42,048    │ $33,726    │ $8,322     │
│ % Ahorro        │ -          │ 20%        │ -          │
└─────────────────┴────────────┴────────────┴────────────┘

Con Savings Plans 3 años (pago total adelantado):
- m5.large: $0.0408/hora (57% descuento)
- m6g.large: $0.0327/hora (58% descuento)

Ahorro adicional anual: ~$35,000
```

### Calculadora de Spot vs On-Demand

```
Escenario: Procesamiento de datos por lotes, 100 instancias c5.2xlarge

Precios us-east-1:
- On-Demand: $0.34/hora
- Spot (promedio): $0.102/hora (70% descuento)

Análisis de disponibilidad Spot:
┌─────────────────┬────────────┬────────────┬────────────┐
│ Métrica         │ On-Demand  │ Spot       │ Diferencia │
├─────────────────┼────────────┼────────────┼────────────┤
│ Costo/hora      │ $34.00     │ $10.20     │ $23.80     │
│ Horas/día       │ 24         │ 20*        │ 4          │
│ Costo diario    │ $816       │ $204       │ $612       │
│ Costo mensual   │ $24,480    │ $6,120     │ $18,360    │
│ Anual           │ $293,760   │ $73,440    │ $220,320   │
│ % Ahorro        │ -          │ 75%        │ -          │
└─────────────────┴────────────┴────────────┴────────────┘

*Spot puede ser interrumpido ~20% del tiempo en promedio
Estrategia híbrida: 60 Spot + 40 On-Demand = $156,240/año (47% ahorro)
```

### Comparativa: Estrategias de Ahorro por Carga de Trabajo

```
Carga: 10 servidores web, uso 24/7, tráfico predecible

┌────────────────────┬──────────────┬─────────────┬──────────┐
│ Estrategia         │ Costo Mes    │ Costo Año   │ Ahorro   │
├────────────────────┼──────────────┼─────────────┼──────────┤
│ On-Demand          │ $2,102       │ $25,224     │ Base     │
│ Reserved (1 año)   │ $1,332       │ $15,984     │ 37%      │
│ Reserved (3 años)  │ $882         │ $10,584     │ 58%      │
│ Savings Plans (3)  │ $892         │ $10,704     │ 58%      │
│ Spot (100%)       │ $631         │ $7,572      │ 70%**    │
│ Híbrido (60/40)   │ $1,156       │ $13,872     │ 45%      │
└────────────────────┴──────────────┴─────────────┴──────────┘
**Requiere tolerancia a interrupciones

Carga: Desarrollo/Test, 8 horas/día hábiles

┌────────────────────┬──────────────┬─────────────┬──────────┐
│ Estrategia         │ Costo Mes    │ Costo Año   │ Ahorro   │
├────────────────────┼──────────────┼─────────────┼──────────┤
│ On-Demand 24/7    │ $701         │ $8,412      │ Base     │
│ Scheduled (8x5)    │ $234         │ $2,808      │ 67%      │
│ Spot Scheduled     │ $70          │ $840        │ 90%      │
└────────────────────┴──────────────┴─────────────┴──────────┘
```

### Framework de Cálculo de ROI de Optimización

```
Ejemplo: Implementación de FinOps + automatización

Inversión:
┌──────────────────────────┬─────────────┐
│ Componente               │ Costo       │
├──────────────────────────┼─────────────┤
│ Herramientas (licencias) │ $12,000/año │
│ Consultoría inicial      │ $25,000     │
│ Capacitación equipo      │ $8,000      │
│ Desarrollo automatización│ $15,000     │
│ Tiempo interno (200h)   │ $20,000     │
├──────────────────────────┼─────────────┤
│ TOTAL INVERSIÓN AÑO 1    │ $80,000     │
└──────────────────────────┴─────────────┘

Retorno (proyección conservadora):
┌──────────────────────────┬─────────────┐
│ Optimización             │ Ahorro/año  │
├──────────────────────────┼─────────────┤
│ Rightsizing instancias   │ $45,000     │
│ Reservas/Savings Plans   │ $120,000    │
│ Eliminación recursos huerfanos│ $25,000│
│ Auto-apagado dev/test    │ $30,000     │
│ Storage tiering          │ $18,000     │
├──────────────────────────┼─────────────┤
│ AHORRO TOTAL AÑO 1       │ $238,000    │
└──────────────────────────┴─────────────┘

Cálculos ROI:
- Beneficio neto Año 1: $238,000 - $80,000 = $158,000
- ROI Año 1: ($158,000 / $80,000) × 100 = 198%
- Payback period: ~4 meses
- Años 2+: $238,000 beneficio anual (sin costos iniciales)
```

### Matriz de Decisión: Cuándo Aplicar Cada Estrategia

```
┌────────────────────┬──────────────┬──────────────┬──────────────┐
│ Carga de Trabajo   │ Estrategia   │ Compromiso   │ Ahorro Est.  │
├────────────────────┼──────────────┼──────────────┼──────────────┤
│ Producción 24/7    │ Reserved 3y  │ Alto         │ 58-72%       │
│ Producción variable│ Compute SP   │ Medio        │ 40-66%       │
│ Batch processing   │ Spot         │ Bajo         │ 70-90%       │
│ CI/CD builds       │ Spot         │ Bajo         │ 60-80%       │
│ Desarrollo         │ Scheduled    │ Bajo         │ 60-70%       │
│ Microservicios     │ Graviton     │ Medio        │ 20-40%       │
│ Event-driven       │ Lambda       │ Ninguno      │ Pago uso     │
│ Bases de datos     │ Reserved     │ Alto         │ 40-60%       │
│ Data analytics     │ Spot/Graviton│ Medio        │ 50-75%       │
└────────────────────┴──────────────┴──────────────┴──────────────┘
```

## Tendencias y Futuro

### Evolución de Herramientas de Optimización

- **ML para predicción de costos**
- **Recomendación automática basada en patrones**
- **Integración profunda con CI/CD**
- **Simulación de escenarios de costos**
- **APIs avanzadas para integración**

### Nuevos Modelos de Precios

- **Pricing por valor de negocio**
- **Compromisos flexibles dinámicos**
- **Modelos híbridos pago por uso/reserva**
- **Descuentos cross-service**
- **Incentivos para prácticas sostenibles**

## Conclusión

La optimización de costos en AWS no es simplemente un ejercicio de reducción de gastos, sino una disciplina estratégica que equilibra inversión con valor empresarial. Las organizaciones más exitosas en la nube implementan un enfoque holístico que combina herramientas tecnológicas, procesos organizacionales y una cultura de responsabilidad compartida.

La naturaleza dinámica de AWS, con servicios y modelos de precios en constante evolución, requiere un enfoque igualmente dinámico de optimización. Las prácticas de FinOps proporcionan el marco para este enfoque continuo, vinculando decisiones técnicas con impacto financiero y objetivos de negocio.

Al implementar las estrategias, herramientas y prácticas descritas en este whitepaper, las organizaciones pueden transformar la gestión de costos en la nube de un desafío reactivo a una ventaja competitiva, permitiendo mayor innovación, agilidad y eficiencia operacional.

## Referencias y Recursos Adicionales

- [AWS Cost Management Documentation](https://docs.aws.amazon.com/cost-management/)
- [AWS Well-Architected Framework: Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/)
- [AWS Cloud Financial Management Guide](https://aws.amazon.com/aws-cost-management/aws-cost-optimization/)
- [AWS Pricing Calculator](https://calculator.aws/)
- [FinOps Foundation](https://www.finops.org/)
- [AWS Cloud Economics Center](https://aws.amazon.com/economics/)
- [AWS Cost Optimization Hub](https://aws.amazon.com/aws-cost-management/cost-optimization-hub/)
