terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment_name
      ManagedBy   = "terraform"
    }
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name        = "${var.environment_name}-db-subnet-group"
  description = "Subnet group for RDS database"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name = "${var.environment_name}-db-subnet-group"
  }
}

# Security Group
resource "aws_security_group" "db" {
  name_prefix = "${var.environment_name}-db-"
  vpc_id      = var.vpc_id
  description = "Security group for RDS database"

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
    description = "Database access from allowed CIDR"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-db-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  name        = "${var.environment_name}-db-params"
  family      = "${var.db_engine}${var.db_engine_version}"
  description = "Custom parameters for database"

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }
}

# Enhanced Monitoring Role
resource "aws_iam_role" "enhanced_monitoring" {
  name = "${var.environment_name}-rds-enhanced-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Random password if not provided
resource "random_password" "db" {
  count  = var.db_password == "" ? 1 : 0
  length = 16
  special = true
}

locals {
  db_password = var.db_password != "" ? var.db_password : random_password.db[0].result
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.environment_name}-db"

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  db_name  = var.db_name
  username = var.db_username
  password = local.db_password

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = var.enable_encryption

  multi_az               = var.enable_multi_az
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  backup_retention_period = var.backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  final_snapshot_identifier  = var.skip_final_snapshot ? null : "${var.environment_name}-db-final-snapshot"

  performance_insights_enabled    = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? 7 : 0

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.enhanced_monitoring.arn

  tags = {
    Name = "${var.environment_name}-database"
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.environment_name}-db-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when DB CPU exceeds 80%"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "storage_low" {
  alarm_name          = "${var.environment_name}-db-storage-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 10000000000  # 10 GB in bytes
  alarm_description   = "Alarm when DB free storage is less than 10GB"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

resource "aws_cloudwatch_metric_alarm" "connections_high" {
  alarm_name          = "${var.environment_name}-db-connections-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 400
  alarm_description   = "Alarm when DB connections exceed 400"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}

# Store password in Secrets Manager (optional)
resource "aws_secretsmanager_secret" "db" {
  count = var.store_password_in_secrets_manager ? 1 : 0
  name  = "${var.environment_name}/database/password"
}

resource "aws_secretsmanager_secret_version" "db" {
  count     = var.store_password_in_secrets_manager ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = local.db_password
    host     = aws_db_instance.main.address
    port     = aws_db_instance.main.port
    dbname   = var.db_name
  })
}
