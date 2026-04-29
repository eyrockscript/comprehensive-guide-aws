# Lab 9: DNS Management with Route 53

## Objective
Configure DNS, health checks, and failover using Route 53.

## Estimated Duration
60 minutes

## Architecture
```
User → Route 53 → Health Checks → [Primary Region | Secondary Region]
```

## Instructions

### Step 1: Register Domain (Simulated)
```bash
# Check availability
aws route53domains check-domain-availability \
    --domain-name example.com

# In a real environment, the domain would be registered
aws route53domains register-domain \
    --domain-name example.com \
    --duration-in-years 1 \
    --admin-contact file://contact.json
```

### Step 2: Create Hosted Zone
```bash
aws route53 create-hosted-zone \
    --name lab.example.com \
    --caller-reference $(date +%s)

# Get NS records
aws route53 get-hosted-zone --id Z1234567890ABC
```

### Step 3: Create DNS Records
```bash
# A record for website
aws route53 change-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "www.lab.example.com",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [{"Value": "1.2.3.4"}]
            }
        }]
    }'

# CNAME record
aws route53 change-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "blog.lab.example.com",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [{"Value": "www.lab.example.com"}]
            }
        }]
    }'

# MX record for email
aws route53 change-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "lab.example.com",
                "Type": "MX",
                "TTL": 300,
                "ResourceRecords": [
                    {"Value": "10 mail1.example.com"},
                    {"Value": "20 mail2.example.com"}
                ]
            }
        }]
    }'
```

### Step 4: Configure Health Checks
```bash
# Create health check for HTTP endpoint
aws route53 create-health-check \
    --caller-reference $(date +%s) \
    --health-check-config '{
        "IPAddress": "1.2.3.4",
        "Port": 80,
        "Type": "HTTP",
        "ResourcePath": "/health",
        "FullyQualifiedDomainName": "www.lab.example.com",
        "RequestInterval": 30,
        "FailureThreshold": 3
    }'

# Create calculated health check
aws route53 create-health-check \
    --caller-reference $(date +%s) \
    --health-check-config '{
        "Type": "CALCULATED",
        "ChildHealthChecks": [
            "health-check-id-1",
            "health-check-id-2"
        ],
        "HealthThreshold": 1
    }'
```

### Step 5: Configure Failover Routing
```bash
# Primary record (active)
aws route53 change-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "api.lab.example.com",
                "Type": "A",
                "SetIdentifier": "Primary",
                "Failover": "PRIMARY",
                "HealthCheckId": "health-check-id",
                "TTL": 60,
                "ResourceRecords": [{"Value": "1.2.3.4"}]
            }
        }]
    }'

# Secondary record (passive)
aws route53 change-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "api.lab.example.com",
                "Type": "A",
                "SetIdentifier": "Secondary",
                "Failover": "SECONDARY",
                "TTL": 60,
                "ResourceRecords": [{"Value": "5.6.7.8"}]
            }
        }]
    }'
```

### Step 6: Configure Latency-Based Routing
```bash
# Endpoint in us-east-1
aws route53 change-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "app.lab.example.com",
                "Type": "A",
                "SetIdentifier": "US-East-1",
                "Region": "us-east-1",
                "TTL": 60,
                "ResourceRecords": [{"Value": "1.2.3.4"}]
            }
        }]
    }'

# Endpoint in eu-west-1
aws route53 change-resource-record-sets \
    --hosted-zone-id Z1234567890ABC \
    --change-batch '{
        "Changes": [{
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "app.lab.example.com",
                "Type": "A",
                "SetIdentifier": "EU-West-1",
                "Region": "eu-west-1",
                "TTL": 60,
                "ResourceRecords": [{"Value": "9.10.11.12"}]
            }
        }]
    }'
```

## Testing
1. Verify DNS resolution:
```bash
dig @ns-xxx.awsdns-xx.com www.lab.example.com
nslookup www.lab.example.com
```
2. Simulate failure and verify failover
3. Test latency-based routing from different locations

## Additional Challenges
1. Configure Weighted Routing for A/B testing
2. Implement Geolocation Routing
3. Configure GeoProximity Routing
4. Use Route 53 as service discovery

## Cleanup
1. Delete DNS records
2. Delete health checks
3. Delete hosted zone (after updating NS at registrar)
