# Cheatsheet: Comandos CLI de RDS

## Crear Instancias de Base de Datos

### MySQL/MariaDB

```bash
aws rds create-db-instance \
    --db-instance-identifier mi-mysql \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username admin \
    --master-user-password 'PasswordSeguro123!' \
    --allocated-storage 20 \
    --vpc-security-group-ids sg-xxxxx \
    --db-subnet-group-name mi-subnet-group \
    --multi-az \
    --publicly-accessible false \
    --backup-retention-period 7
```

### PostgreSQL

```bash
aws rds create-db-instance \
    --db-instance-identifier mi-postgres \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.3 \
    --master-username postgres \
    --master-user-password 'PasswordSeguro123!' \
    --allocated-storage 20 \
    --storage-type gp3
```

### SQL Server

```bash
aws rds create-db-instance \
    --db-instance-identifier mi-sqlserver \
    --db-instance-class db.t3.small \
    --engine sqlserver-ex \
    --master-username admin \
    --master-user-password 'PasswordSeguro123!' \
    --allocated-storage 20
```

### Oracle

```bash
aws rds create-db-instance \
    --db-instance-identifier mi-oracle \
    --db-instance-class db.t3.micro \
    --engine oracle-se2 \
    --master-username admin \
    --master-user-password 'PasswordSeguro123!' \
    --license-model license-included
```

## Amazon Aurora

### Crear Cluster Aurora

```bash
aws rds create-db-cluster \
    --db-cluster-identifier mi-aurora-cluster \
    --engine aurora-mysql \
    --master-username admin \
    --master-user-password 'PasswordSeguro123!' \
    --db-subnet-group-name mi-subnet-group \
    --vpc-security-group-ids sg-xxxxx

aws rds create-db-instance \
    --db-instance-identifier mi-aurora-instance-1 \
    --db-cluster-identifier mi-aurora-cluster \
    --engine aurora-mysql \
    --db-instance-class db.t3.medium
```

## Gestión de Instancias

```bash
# Listar instancias
aws rds describe-db-instances

# Describir instancia específica
aws rds describe-db-instances \
    --db-instance-identifier mi-mysql

# Modificar instancia
aws rds modify-db-instance \
    --db-instance-identifier mi-mysql \
    --db-instance-class db.t3.small \
    --apply-immediately

# Reiniciar instancia
aws rds reboot-db-instance \
    --db-instance-identifier mi-mysql \
    --force-failover

# Eliminar instancia
aws rds delete-db-instance \
    --db-instance-identifier mi-mysql \
    --skip-final-snapshot
```

## Snapshots

```bash
# Crear snapshot
aws rds create-db-snapshot \
    --db-instance-identifier mi-mysql \
    --db-snapshot-identifier mi-mysql-snapshot-$(date +%Y%m%d)

# Listar snapshots
aws rds describe-db-snapshots \
    --db-instance-identifier mi-mysql

# Restaurar desde snapshot
aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier mi-mysql-restaurada \
    --db-snapshot-identifier mi-mysql-snapshot-20240101

# Copiar snapshot a otra región
aws rds copy-db-snapshot \
    --source-db-snapshot-identifier arn:aws:rds:us-east-1:123456789012:snapshot:mi-snapshot \
    --target-db-snapshot-identifier mi-snapshot-copia \
    --source-region us-east-1 \
    --region eu-west-1

# Compartir snapshot
aws rds modify-db-snapshot-attribute \
    --db-snapshot-identifier mi-snapshot \
    --attribute-name restore \
    --values-to-add 987654321098
```

## Read Replicas

```bash
# Crear read replica
aws rds create-db-instance-read-replica \
    --db-instance-identifier mi-mysql-replica \
    --source-db-instance-identifier mi-mysql \
    --db-instance-class db.t3.micro

# Promover a instancia standalone
aws rds promote-read-replica \
    --db-instance-identifier mi-mysql-replica

# Crear read replica en otra región
aws rds create-db-instance-read-replica \
    --db-instance-identifier mi-mysql-replica-eu \
    --source-db-instance-identifier arn:aws:rds:us-east-1:123456789012:db:mi-mysql \
    --region eu-west-1
```

## Backup Automatizado

```bash
# Modificar período de retención
aws rds modify-db-instance \
    --db-instance-identifier mi-mysql \
    --backup-retention-period 35 \
    --preferred-backup-window 03:00-04:00 \
    --preferred-maintenance-window Mon:04:00-Mon:05:00

# Deshabilitar backups automáticos
aws rds modify-db-instance \
    --db-instance-identifier mi-mysql \
    --backup-retention-period 0 \
    --apply-immediately
```

## Subnet Groups

```bash
# Crear subnet group
aws rds create-db-subnet-group \
    --db-subnet-group-name mi-subnet-group \
    --db-subnet-group-description "Subnets para RDS" \
    --subnet-ids '["subnet-aaaa","subnet-bbbb","subnet-cccc"]'

# Listar subnet groups
aws rds describe-db-subnet-groups

# Modificar subnet group
aws rds modify-db-subnet-group \
    --db-subnet-group-name mi-subnet-group \
    --subnet-ids '["subnet-aaaa","subnet-bbbb","subnet-cccc","subnet-dddd"]'
```

## Parameter Groups

```bash
# Crear parameter group
aws rds create-db-parameter-group \
    --db-parameter-group-name mi-mysql-params \
    --db-parameter-group-family mysql8.0 \
    --description "Parámetros personalizados MySQL"

# Modificar parámetros
aws rds modify-db-parameter-group \
    --db-parameter-group-name mi-mysql-params \
    --parameters \
        "ParameterName=max_connections,ParameterValue=500,ApplyMethod=pending-reboot" \
        "ParameterName=innodb_buffer_pool_size,ParameterValue=268435456,ApplyMethod=pending-reboot"

# Aplicar a instancia
aws rds modify-db-instance \
    --db-instance-identifier mi-mysql \
    --db-parameter-group-name mi-mysql-params \
    --apply-immediately
```

## Eventos y Logs

```bash
# Ver eventos de RDS
aws rds describe-events \
    --duration 1440 \
    --source-type db-instance \
    --source-identifier mi-mysql

# Descargar logs
aws rds download-db-log-file-portion \
    --db-instance-identifier mi-mysql \
    --log-file-name "error/mysql-error.log" \
    --output text > mysql-error.log

# Listar archivos de log
aws rds describe-db-log-files \
    --db-instance-identifier mi-mysql
```

## RDS Proxy

```bash
# Crear RDS Proxy
aws rds create-db-proxy \
    --db-proxy-name mi-proxy \
    --engine-family MYSQL \
    --auth '{
      "AuthScheme": "SECRETS",
      "SecretArn": "arn:aws:secretsmanager:us-east-1:123456789012:secret:rds-credentials",
      "IAMAuth": "DISABLED"
    }' \
    --role-arn arn:aws:iam::123456789012:role/RDSProxyRole \
    --vpc-subnet-ids '[]' \
    --vpc-security-group-ids '[]'

# Asociar a instancia
aws rds register-db-proxy-targets \
    --db-proxy-name mi-proxy \
    --db-instance-identifiers mi-mysql
```

## Performance Insights

```bash
# Habilitar Performance Insights
aws rds modify-db-instance \
    --db-instance-identifier mi-mysql \
    --enable-performance-insights \
    --performance-insights-retention-period 7

# Obtener métricas
aws pi get-resource-metrics \
    --service-type RDS \
    --identifier db-XXXXXXXXXX \
    --metric-queries '[{"Metric": "db.load.avg"}]' \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z
```

## Consejos Rápidos

| Tarea | Comando |
|-------|---------|
| Ver instancias | `aws rds describe-db-instances` |
| Ver clusters | `aws rds describe-db-clusters` |
| Ver snapshots | `aws rds describe-db-snapshots` |
| Crear snapshot | `aws rds create-db-snapshot ...` |
| Restaurar | `aws rds restore-db-instance-from-db-snapshot ...` |
| Crear réplica | `aws rds create-db-instance-read-replica ...` |

## Conexión a Bases de Datos

```bash
# Obtener endpoint
aws rds describe-db-instances \
    --db-instance-identifier mi-mysql \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text

# MySQL
mysql -h <endpoint> -u admin -p

# PostgreSQL
psql -h <endpoint> -U postgres -d postgres

# SQL Server
sqlcmd -S <endpoint> -U admin -P '<password>'
```
