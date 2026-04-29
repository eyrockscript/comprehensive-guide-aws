# Laboratorio 4: Base de Datos MySQL con RDS

## Objetivo
Desplegar una instancia de MySQL en RDS con alta disponibilidad Multi-AZ.

## Duración Estimada
60 minutos

## Arquitectura
```
Aplicación → RDS Proxy → RDS MySQL (Multi-AZ)
```

## Instrucciones

### Paso 1: Crear Security Group para RDS
```bash
aws ec2 create-security-group \
    --group-name RDS-MySQL-SG \
    --description "Security group for RDS MySQL" \
    --vpc-id vpc-xxxxx

aws ec2 authorize-security-group-ingress \
    --group-id sg-xxxxx \
    --protocol tcp \
    --port 3306 \
    --source-group sg-application-xxxxx
```

### Paso 2: Crear Subnet Group
```bash
aws rds create-db-subnet-group \
    --db-subnet-group-name mysql-subnet-group \
    --db-subnet-group-description "Subnet group for MySQL" \
    --subnet-ids '["subnet-xxxxx","subnet-yyyyy"]'
```

### Paso 3: Crear Instancia RDS
```bash
aws rds create-db-instance \
    --db-instance-identifier lab-mysql \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0 \
    --allocated-storage 20 \
    --storage-type gp3 \
    --master-username admin \
    --master-user-password 'SecurePassword123!' \
    --vpc-security-group-ids sg-xxxxx \
    --db-subnet-group-name mysql-subnet-group \
    --multi-az \
    --publicly-accessible false \
    --backup-retention-period 7 \
    --preferred-backup-window 03:00-04:00 \
    --enable-performance-insights \
    --performance-insights-retention-period 7
```

### Paso 4: Crear RDS Proxy (Opcional)
```bash
aws rds create-db-proxy \
    --db-proxy-name mysql-proxy \
    --engine-family MYSQL \
    --auth ProxySecretArn \
    --role-arn arn:aws:iam::xxx:role/RDSProxyRole \
    --vpc-subnet-ids '["subnet-xxxxx","subnet-yyyyy"]'
```

### Paso 5: Configurar Read Replica
```bash
aws rds create-db-instance-read-replica \
    --db-instance-identifier lab-mysql-replica \
    --source-db-instance-identifier lab-mysql
```

## Pruebas
1. Conectar con MySQL Workbench
2. Crear base de datos de prueba
3. Simular failover (reboot con failover)
4. Verificar métricas en CloudWatch

## Retos Adicionales
1. Configurar Encripción en reposo (KMS)
2. Implementar RDS Proxy
3. Configurar snapshot automatizados
4. Migrar datos con DMS

## Monitoreo
```bash
# Ver métricas de RDS
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name DatabaseConnections \
    --dimensions Name=DBInstanceIdentifier,Value=lab-mysql \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Average
```

## Limpieza
1. Eliminar Read Replica
2. Eliminar RDS Proxy
3. Eliminar instancia RDS
4. Eliminar Subnet Group
5. Eliminar Security Group
