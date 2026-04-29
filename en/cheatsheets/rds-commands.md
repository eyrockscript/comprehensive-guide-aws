# Cheatsheet: RDS CLI Commands

## Create Database Instances

### MySQL/MariaDB

```bash
aws rds create-db-instance \
    --db-instance-identifier my-mysql \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --master-username admin \
    --master-user-password 'SecurePassword123!' \
    --allocated-storage 20 \
    --vpc-security-group-ids sg-xxxxx \
    --db-subnet-group-name my-subnet-group \
    --multi-az \
    --publicly-accessible false \
    --backup-retention-period 7
```

### PostgreSQL

```bash
aws rds create-db-instance \
    --db-instance-identifier my-postgres \
    --db-instance-class db.t3.micro \
    --engine postgres \
    --engine-version 15.3 \
    --master-username postgres \
    --master-user-password 'SecurePassword123!' \
    --allocated-storage 20 \
    --storage-type gp3
```

### SQL Server

```bash
aws rds create-db-instance \
    --db-instance-identifier my-sqlserver \
    --db-instance-class db.t3.small \
    --engine sqlserver-ex \
    --master-username admin \
    --master-user-password 'SecurePassword123!' \
    --allocated-storage 20
```

### Oracle

```bash
aws rds create-db-instance \
    --db-instance-identifier my-oracle \
    --db-instance-class db.t3.micro \
    --engine oracle-se2 \
    --master-username admin \
    --master-user-password 'SecurePassword123!' \
    --license-model license-included
```

## Amazon Aurora

### Create Aurora Cluster

```bash
aws rds create-db-cluster \
    --db-cluster-identifier my-aurora-cluster \
    --engine aurora-mysql \
    --master-username admin \
    --master-user-password 'SecurePassword123!' \
    --db-subnet-group-name my-subnet-group \
    --vpc-security-group-ids sg-xxxxx

aws rds create-db-instance \
    --db-instance-identifier my-aurora-instance-1 \
    --db-cluster-identifier my-aurora-cluster \
    --engine aurora-mysql \
    --db-instance-class db.t3.medium
```

## Instance Management

```bash
# List instances
aws rds describe-db-instances

# Describe specific instance
aws rds describe-db-instances \
    --db-instance-identifier my-mysql

# Modify instance
aws rds modify-db-instance \
    --db-instance-identifier my-mysql \
    --db-instance-class db.t3.small \
    --apply-immediately

# Reboot instance
aws rds reboot-db-instance \
    --db-instance-identifier my-mysql \
    --force-failover

# Delete instance
aws rds delete-db-instance \
    --db-instance-identifier my-mysql \
    --skip-final-snapshot
```

## Snapshots

```bash
# Create snapshot
aws rds create-db-snapshot \
    --db-instance-identifier my-mysql \
    --db-snapshot-identifier my-mysql-snapshot-$(date +%Y%m%d)

# List snapshots
aws rds describe-db-snapshots \
    --db-instance-identifier my-mysql

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier my-mysql-restored \
    --db-snapshot-identifier my-mysql-snapshot-20240101

# Copy snapshot to another region
aws rds copy-db-snapshot \
    --source-db-snapshot-identifier arn:aws:rds:us-east-1:123456789012:snapshot:my-snapshot \
    --target-db-snapshot-identifier my-snapshot-copy \
    --source-region us-east-1 \
    --region eu-west-1

# Share snapshot
aws rds modify-db-snapshot-attribute \
    --db-snapshot-identifier my-snapshot \
    --attribute-name restore \
    --values-to-add 987654321098
```

## Read Replicas

```bash
# Create read replica
aws rds create-db-instance-read-replica \
    --db-instance-identifier my-mysql-replica \
    --source-db-instance-identifier my-mysql \
    --db-instance-class db.t3.micro

# Promote to standalone instance
aws rds promote-read-replica \
    --db-instance-identifier my-mysql-replica

# Create read replica in another region
aws rds create-db-instance-read-replica \
    --db-instance-identifier my-mysql-replica-eu \
    --source-db-instance-identifier arn:aws:rds:us-east-1:123456789012:db:my-mysql \
    --region eu-west-1
```

## Automated Backups

```bash
# Modify retention period
aws rds modify-db-instance \
    --db-instance-identifier my-mysql \
    --backup-retention-period 35 \
    --preferred-backup-window 03:00-04:00 \
    --preferred-maintenance-window Mon:04:00-Mon:05:00

# Disable automated backups
aws rds modify-db-instance \
    --db-instance-identifier my-mysql \
    --backup-retention-period 0 \
    --apply-immediately
```

## Subnet Groups

```bash
# Create subnet group
aws rds create-db-subnet-group \
    --db-subnet-group-name my-subnet-group \
    --db-subnet-group-description "Subnets for RDS" \
    --subnet-ids '["subnet-aaaa","subnet-bbbb","subnet-cccc"]'

# List subnet groups
aws rds describe-db-subnet-groups

# Modify subnet group
aws rds modify-db-subnet-group \
    --db-subnet-group-name my-subnet-group \
    --subnet-ids '["subnet-aaaa","subnet-bbbb","subnet-cccc","subnet-cccc"]'
```

## Parameter Groups

```bash
# Create parameter group
aws rds create-db-parameter-group \
    --db-parameter-group-name my-mysql-params \
    --db-parameter-group-family mysql8.0 \
    --description "Custom MySQL parameters"

# Modify parameters
aws rds modify-db-parameter-group \
    --db-parameter-group-name my-mysql-params \
    --parameters \
        "ParameterName=max_connections,ParameterValue=500,ApplyMethod=pending-reboot" \
        "ParameterName=innodb_buffer_pool_size,ParameterValue=268435456,ApplyMethod=pending-reboot"

# Apply to instance
aws rds modify-db-instance \
    --db-instance-identifier my-mysql \
    --db-parameter-group-name my-mysql-params \
    --apply-immediately
```

## Events and Logs

```bash
# View RDS events
aws rds describe-events \
    --duration 1440 \
    --source-type db-instance \
    --source-identifier my-mysql

# Download logs
aws rds download-db-log-file-portion \
    --db-instance-identifier my-mysql \
    --log-file-name "error/mysql-error.log" \
    --output text > mysql-error.log

# List log files
aws rds describe-db-log-files \
    --db-instance-identifier my-mysql
```

## RDS Proxy

```bash
# Create RDS Proxy
aws rds create-db-proxy \
    --db-proxy-name my-proxy \
    --engine-family MYSQL \
    --auth '{
      "AuthScheme": "SECRETS",
      "SecretArn": "arn:aws:secretsmanager:us-east-1:123456789012:secret:rds-credentials",
      "IAMAuth": "DISABLED"
    }' \
    --role-arn arn:aws:iam::123456789012:role/RDSProxyRole \
    --vpc-subnet-ids '[]' \
    --vpc-security-group-ids '[]'

# Associate with instance
aws rds register-db-proxy-targets \
    --db-proxy-name my-proxy \
    --db-instance-identifiers my-mysql
```

## Performance Insights

```bash
# Enable Performance Insights
aws rds modify-db-instance \
    --db-instance-identifier my-mysql \
    --enable-performance-insights \
    --performance-insights-retention-period 7

# Get metrics
aws pi get-resource-metrics \
    --service-type RDS \
    --identifier db-XXXXXXXXXX \
    --metric-queries '[{"Metric": "db.load.avg"}]' \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z
```

## Quick Tips

| Task | Command |
|------|---------|
| View instances | `aws rds describe-db-instances` |
| View clusters | `aws rds describe-db-clusters` |
| View snapshots | `aws rds describe-db-snapshots` |
| Create snapshot | `aws rds create-db-snapshot ...` |
| Restore | `aws rds restore-db-instance-from-db-snapshot ...` |
| Create replica | `aws rds create-db-instance-read-replica ...` |

## Database Connection

```bash
# Get endpoint
aws rds describe-db-instances \
    --db-instance-identifier my-mysql \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text

# MySQL
mysql -h <endpoint> -u admin -p

# PostgreSQL
psql -h <endpoint> -U postgres -d postgres

# SQL Server
sqlcmd -S <endpoint> -U admin -P '<password>'
```
