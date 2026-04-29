# Lab 4: MySQL Database with RDS

## Objective
Deploy a MySQL instance on RDS with Multi-AZ high availability.

## Estimated Duration
60 minutes

## Architecture
```
Application → RDS Proxy → RDS MySQL (Multi-AZ)
```

## Instructions

### Step 1: Create Security Group for RDS
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

### Step 2: Create Subnet Group
```bash
aws rds create-db-subnet-group \
    --db-subnet-group-name mysql-subnet-group \
    --db-subnet-group-description "Subnet group for MySQL" \
    --subnet-ids '["subnet-xxxxx","subnet-yyyyy"]'
```

### Step 3: Create RDS Instance
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

### Step 4: Create RDS Proxy (Optional)
```bash
aws rds create-db-proxy \
    --db-proxy-name mysql-proxy \
    --engine-family MYSQL \
    --auth ProxySecretArn \
    --role-arn arn:aws:iam::xxx:role/RDSProxyRole \
    --vpc-subnet-ids '["subnet-xxxxx","subnet-yyyyy"]'
```

### Step 5: Configure Read Replica
```bash
aws rds create-db-instance-read-replica \
    --db-instance-identifier lab-mysql-replica \
    --source-db-instance-identifier lab-mysql
```

## Testing
1. Connect with MySQL Workbench
2. Create test database
3. Simulate failover (reboot with failover)
4. Verify metrics in CloudWatch

## Additional Challenges
1. Configure encryption at rest (KMS)
2. Implement RDS Proxy
3. Configure automated snapshots
4. Migrate data with DMS

## Monitoring
```bash
# View RDS metrics
aws cloudwatch get-metric-statistics \
    --namespace AWS/RDS \
    --metric-name DatabaseConnections \
    --dimensions Name=DBInstanceIdentifier,Value=lab-mysql \
    --start-time 2024-01-01T00:00:00Z \
    --end-time 2024-01-02T00:00:00Z \
    --period 3600 \
    --statistics Average
```

## Cleanup
1. Delete Read Replica
2. Delete RDS Proxy
3. Delete RDS instance
4. Delete Subnet Group
5. Delete Security Group
