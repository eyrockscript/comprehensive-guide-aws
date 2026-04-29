# Laboratorio 9: Gestión DNS con Route 53

## Objetivo
Configurar DNS, health checks y failover usando Route 53.

## Duración Estimada
60 minutos

## Arquitectura
```
Usuario → Route 53 → Health Checks → [Región Primaria | Región Secundaria]
```

## Instrucciones

### Paso 1: Registrar Dominio (Simulado)
```bash
# Verificar disponibilidad
aws route53domains check-domain-availability \
    --domain-name example.com

# En un entorno real, se registraría el dominio
aws route53domains register-domain \
    --domain-name example.com \
    --duration-in-years 1 \
    --admin-contact file://contact.json
```

### Paso 2: Crear Hosted Zone
```bash
aws route53 create-hosted-zone \
    --name lab.example.com \
    --caller-reference $(date +%s)

# Obtener NS records
aws route53 get-hosted-zone --id Z1234567890ABC
```

### Paso 3: Crear Registros DNS
```bash
# Registro A para sitio web
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

# Registro CNAME
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

# Registro MX para email
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

### Paso 4: Configurar Health Checks
```bash
# Crear health check para endpoint HTTP
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

# Crear health check calculado
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

### Paso 5: Configurar Failover Routing
```bash
# Registro primario (activo)
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

# Registro secundario (pasivo)
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

### Paso 6: Configurar Latency-Based Routing
```bash
# Endpoint en us-east-1
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

# Endpoint en eu-west-1
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

## Pruebas
1. Verificar resolución DNS:
```bash
dig @ns-xxx.awsdns-xx.com www.lab.example.com
nslookup www.lab.example.com
```
2. Simular falla y verificar failover
3. Probar latency-based routing desde diferentes ubicaciones

## Retos Adicionales
1. Configurar Weighted Routing para A/B testing
2. Implementar Geolocation Routing
3. Configurar GeoProximity Routing
4. Usar Route 53 como service discovery

## Limpieza
1. Eliminar registros DNS
2. Eliminar health checks
3. Eliminar hosted zone (después de actualizar NS en registrar)
