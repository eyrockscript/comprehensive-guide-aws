# Lab 8: Monitoring with CloudWatch

## Objective
Configure centralized monitoring using CloudWatch Logs, Metrics, and Alarms.

## Estimated Duration
60 minutes

## Architecture
```
Resources → CloudWatch Logs → Metrics → Alarms → SNS → Actions
```

## Instructions

### Step 1: Create Log Groups
```bash
# Create log groups for different services
aws logs create-log-group --log-group-name /aws/lab/application
aws logs create-log-group --log-group-name /aws/lab/database
aws logs create-log-group --log-group-name /aws/lab/security

# Configure retention
aws logs put-retention-policy \
    --log-group-name /aws/lab/application \
    --retention-in-days 30
```

### Step 2: Create Custom Metrics
```bash
# Publish metrics from CLI
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

### Step 3: Create CloudWatch Alarms
```bash
# Alarm for high CPU
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

# Alarm for 5xx errors on ALB
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

### Step 4: Configure Dashboard
```bash
aws cloudwatch put-dashboard \
    --dashboard-name LabDashboard \
    --dashboard-body file://dashboard.json
```

Content of `dashboard.json`:
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

### Step 5: Configure Insights
```bash
# Logs Insights query
aws logs start-query \
    --log-group-name /aws/lab/application \
    --start-time $(date -d '1 hour ago' +%s) \
    --end-time $(date +%s) \
    --query-string 'fields @timestamp, @message | filter @message like /ERROR/ | stats count() by bin(5m)'
```

### Step 6: Configure SNS for Notifications
```bash
aws sns create-topic --name lab-alerts-topic

aws sns subscribe \
    --topic-arn arn:aws:sns:us-east-1:xxx:lab-alerts-topic \
    --protocol email \
    --notification-endpoint admin@example.com
```

## Testing
1. Simulate high load on instances
2. Generate application errors
3. Verify alarms and notifications
4. Review real-time dashboard

## Additional Challenges
1. Configure CloudWatch Synthetics Canaries
2. Implement X-Ray for tracing
3. Create anomaly detection
4. Configure Contributor Insights

## Cleanup
1. Delete alarms
2. Delete dashboards
3. Delete log groups (or empty them)
4. Delete SNS topics
