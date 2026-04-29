# Laboratorio 8: Monitoreo con CloudWatch

## Objetivo
Configurar monitoreo centralizado usando CloudWatch Logs, Métricas y Alarmas.

## Duración Estimada
60 minutos

## Arquitectura
```
Recursos → CloudWatch Logs → Métricas → Alarmas → SNS → Acciones
```

## Instrucciones

### Paso 1: Crear Log Groups
```bash
# Crear grupos de logs para diferentes servicios
aws logs create-log-group --log-group-name /aws/lab/application
aws logs create-log-group --log-group-name /aws/lab/database
aws logs create-log-group --log-group-name /aws/lab/security

# Configurar retención
aws logs put-retention-policy \
    --log-group-name /aws/lab/application \
    --retention-in-days 30
```

### Paso 2: Crear Métricas Personalizadas
```bash
# Publicar métricas desde CLI
aws cloudwatch put-metric-data \
    --namespace Lab/Application \
    --metric-data '[
        {
            "MetricName": "ActiveUsers",
            "Value": 150,
            "Unit": "Count",
            "Timestamp": "2024-01-01T12:00:00Z"
        }
    ]'
```

### Paso 3: Crear Alarmas CloudWatch
```bash
# Alarma para CPU alta
aws cloudwatch put-metric-alarm \
    --alarm-name HighCPUAlarm \
    --alarm-description "CPU > 80% for 5 minutes" \
    --metric-name CPUUtilization \
    --namespace AWS/EC2 \
    --statistic Average \
    --dimensions Name=InstanceId,Value=i-xxxxx \
    --period 300 \
    --evaluation-periods 1 \
    --threshold 80 \
    --comparison-operator GreaterThanThreshold \
    --alarm-actions arn:aws:sns:us-east-1:xxx:alerts-topic

# Alarma para errores 5xx en ALB
aws cloudwatch put-metric-alarm \
    --alarm-name ALB-5xx-Errors \
    --metric-name HTTPCode_Target_5XX_Count \
    --namespace AWS/ApplicationELB \
    --statistic Sum \
    --dimensions Name=LoadBalancer,Value=app/lab-alb/xxx \
    --period 60 \
    --evaluation-periods 2 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold
```

### Paso 4: Configurar Dashboard
```bash
aws cloudwatch put-dashboard \
    --dashboard-name LabDashboard \
    --dashboard-body file://dashboard.json
```

Contenido de `dashboard.json`:
```json
{
  "widgets": [
    {
      "type": "metric",
      "x": 0, "y": 0, "width": 12, "height": 6,
      "properties": {
        "metrics": [["AWS/EC2", "CPUUtilization", "InstanceId", "i-xxxxx"]],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "CPU Utilization"
      }
    },
    {
      "type": "log",
      "x": 12, "y": 0, "width": 12, "height": 6,
      "properties": {
        "query": "SOURCE '/aws/lab/application' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20",
        "region": "us-east-1",
        "title": "Recent Errors"
      }
    }
  ]
}
```

### Paso 5: Configurar Insights
```bash
# Consulta de Logs Insights
aws logs start-query \
    --log-group-name /aws/lab/application \
    --start-time $(date -d '1 hour ago' +%s) \
    --end-time $(date +%s) \
    --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | stats count() by bin(5m)'
```

### Paso 6: Configurar SNS para Notificaciones
```bash
aws sns create-topic --name lab-alerts-topic

aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:xxx:lab-alerts-topic \
    --protocol email \
    --notification-endpoint admin@example.com
```

## Pruebas
1. Simular carga alta en instancias
2. Generar errores en aplicación
3. Verificar alarmas y notificaciones
4. Revisar dashboard en tiempo real

## Retos Adicionales
1. Configurar CloudWatch Synthetics Canaries
2. Implementar X-Ray para tracing
3. Crear anomalías detection
4. Configurar Contributor Insights

## Limpieza
1. Eliminar alarmas
2. Eliminar dashboards
3. Eliminar log groups (o vaciarlos)
4. Eliminar topics SNS
