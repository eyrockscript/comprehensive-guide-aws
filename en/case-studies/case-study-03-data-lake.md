# Case Study 3: RetailCorp - Enterprise Data Lake on AWS

## Executive Summary

**Company:** RetailCorp International  
**Industry:** Retail / E-commerce  
**Challenge:** Consolidate 50+ data sources, 2.5PB of data, with real-time analytics requirements  
**Results:** Unified data platform enabling real-time inventory, ML-powered recommendations, 40% faster decision-making

---

## The Challenge

### Business Context
RetailCorp, a multinational retailer with 1,200+ stores and $12B annual revenue, struggled with siloed data across multiple systems:

- **50+ Data Sources:** ERP, POS, e-commerce, supply chain, CRM, marketing
- **Data Volume:** 2.5PB historical data, 50TB daily ingestion
- **Processing:** Overnight batch jobs, 12-hour delay for reports
- **Analytics:** Excel-based, no self-service capabilities
- **Innovation:** Unable to implement AI/ML due to data accessibility issues

### Business Impact

| Challenge | Business Impact |
|-----------|-----------------|
| **Data Silos** | Inconsistent customer view across channels |
| **Batch Processing** | Stockouts due to delayed inventory updates |
| **No Real-Time Analytics** | Missed sales opportunities, excess inventory |
| **Manual Reporting** | 40% of analyst time spent on data preparation |
| **ML Readiness** | Cannot implement personalization at scale |

### Technical Requirements

| Requirement | Specification |
|-------------|---------------|
| **Data Volume** | 2.5PB initial, 50TB daily growth |
| **Latency** | Near real-time (5-minute SLA) |
| **Users** | 5,000+ internal users, self-service |
| **Sources** | 50+ systems, structured and unstructured |
| **Cost Target** | <$50K/month total platform cost |
| **Compliance** | GDPR, PCI DSS, SOX |

---

## Architecture

### Lake House Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Data Sources Layer                                  │
│                                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │    POS       │  │  E-commerce  │  │     ERP      │  │     CRM      │         │
│  │  (Oracle)    │  │   (MySQL)    │  │   (SAP)      │  │  (Salesforce)│         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                 │                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │   Supply     │  │   Marketing  │  │   IoT        │  │   External   │         │
│  │   Chain      │  │   (Adobe)    │  │   Sensors    │  │   APIs       │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
└─────────┼─────────────────┼─────────────────┼─────────────────┼──────────────────┘
          │                 │                 │                 │
          └─────────────────┼─────────────────┴─────────────────┘
                            │
┌───────────────────────────▼────────────────────────────────────────────────────────┐
│                         Ingestion Layer                                           │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────┐     │
│  │                    AWS Glue Data Catalog                               │     │
│  │              (Schema Discovery, Crawlers, Classifiers)                │     │
│  └────────────────────────────────────────────────────────────────────────┘     │
│                                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐              │
│  │   Kinesis        │  │   MSK            │  │   DMS            │              │
│  │   Data Streams   │  │   (Kafka)        │  │   (CDC)          │              │
│  │   (Real-time)    │  │   (Streaming)    │  │   (Databases)    │              │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘              │
│           │                     │                     │                         │
│  ┌────────▼─────────────────────▼─────────────────────▼─────────┐              │
│  │                    AWS Glue (ETL Jobs)                        │              │
│  │              (Bookmarking, Incremental, Spark)                │              │
│  └─────────────────────────┬───────────────────────────────────┘              │
└──────────────────────────┼─────────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼─────────────────────────────────────────────────────┐
│                         Storage Layer                                           │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                      Amazon S3 (Data Lake)                             │  │
│  │                                                                         │  │
│  │   ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                │  │
│  │   │   Bronze     │  │   Silver     │  │   Gold       │                │  │
│  │   │   (Raw)      │  │   (Cleaned)  │  │   (Curated)  │                │  │
│  │   │              │  │              │  │              │                │  │
│  │   │ • Raw JSON   │  │ • Parquet    │  │ • Aggregated │                │  │
│  │   │ • CSV dumps  │  │ • Delta      │  │ • Modeled    │                │  │
│  │   │ • Logs       │  │ • Deduplicated│ • Business   │                │  │
│  │   │ • CDC events │  │ • Validated  │    ready       │                │  │
│  │   └──────────────┘  └──────────────┘  └──────────────┘                │  │
│  │                                                                         │  │
│  │   S3 Buckets:                                                           │  │
│  │   • s3://retailcorp-data-lake-bronze/                                   │  │
│  │   • s3://retailcorp-data-lake-silver/                                   │  │
│  │   • s3://retailcorp-data-lake-gold/                                     │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                    Lake Formation (Governance)                          │  │
│  │              (Fine-grained Access Control, Column-level)                │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                        Processing Layer                                         │
│                                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐              │
│  │   EMR            │  │   Glue           │  │   SageMaker      │              │
│  │   (Spark)        │  │   (Serverless)   │  │   (ML)           │              │
│  │                  │  │                  │  │                  │              │
│  │ • Large-scale    │  │ • Daily ETL      │  │ • Training       │              │
│  │   transformations│  │ • Incremental    │  │ • Inference      │              │
│  │ • ML preprocessing│ │ • Data quality   │  │ • Feature store  │              │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘              │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                    Step Functions (Orchestration)                     │  │
│  │              (DAG-based pipelines, Error handling, Monitoring)        │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                    Consumption Layer                                            │
│                                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐              │
│  │   Athena         │  │   Redshift       │  │   QuickSight     │              │
│  │   (Ad-hoc)       │  │   (Data         │  │   (Dashboards)   │              │
│  │                  │  │    Warehouse)    │  │                  │              │
│  │ • SQL queries    │  │ • Analytics      │  │ • Self-service   │              │
│  │ • Partitioned    │  │ • Reporting      │  │ • Embedding      │              │
│  │ • Cost-effective │  │ • BI workloads   │  │ • ML insights    │              │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘              │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │              Data API (API Gateway + Lambda)                            │  │
│  │         (Application integration, Real-time access)                     │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                    Governance Layer                                             │
│                                                                                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐             │
│  │  Glue    │ │  Config  │ │CloudTrail│ │  KMS     │ │Macie     │             │
│  │  Catalog │ │  Rules   │ │          │ │          │ │          │             │
│  │          │ │          │ │          │ │          │ │          │             │
│  │ • Schema │ │ • S3     │ │ • Audit  │ │ • Encrypt│ │ • PII    │             │
│  │ • Lineage│ │   config │ │   logs   │ │   at rest│ │   detect │             │
│  │ • Search │ │ • Encrypt│ │ • API    │ │ • Key    │ │ • Data   │             │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘             │
│                                                                                  │
│  ┌────────────────────────────────────────────────────────────────────────┐  │
│  │                    CloudWatch (Monitoring)                            │  │
│  └────────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

#### 1. Bronze-Silver-Gold Architecture

```python
# Data quality progression
BRONZE_ZONE = {
    "description": "Raw data as-is from sources",
    "format": "JSON, CSV, Avro, Parquet",
    "retention": "7 years (compliance)",
    "access": "Data engineers only",
    "quality_checks": ["Schema validation", "Basic format checking"]
}

SILVER_ZONE = {
    "description": "Cleaned and validated data",
    "format": "Delta Lake (Parquet)",
    "retention": "3 years",
    "access": "Data analysts, Data scientists",
    "quality_checks": [
        "Deduplication",
        "Data type validation",
        "Null checks",
        "Referential integrity"
    ]
}

GOLD_ZONE = {
    "description": "Business-ready curated datasets",
    "format": "Delta Lake (Parquet)",
    "retention": "7 years",
    "access": "BI analysts, Business users",
    "quality_checks": [
        "Business rule validation",
        "Aggregation accuracy",
        "Dimensional modeling"
    ]
}
```

#### 2. Medallion Architecture with Delta Lake

```sql
-- Bronze: Raw ingestion
CREATE TABLE retailcorp.bronze.pos_transactions
USING DELTA
LOCATION 's3://retailcorp-data-lake-bronze/pos/transactions'
PARTITIONED BY (date);

-- Silver: Cleaned and deduplicated
CREATE TABLE retailcorp.silver.pos_transactions
USING DELTA
LOCATION 's3://retailcorp-data-lake-silver/pos/transactions'
PARTITIONED BY (date)
TBLPROPERTIES (
  'delta.enableChangeDataFeed' = 'true'
);

-- MERGE for incremental updates
MERGE INTO retailcorp.silver.pos_transactions AS target
USING (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY ingestion_timestamp DESC) as rn
  FROM retailcorp.bronze.pos_transactions
  WHERE date >= current_date() - 1
) AS source
ON target.transaction_id = source.transaction_id
WHEN MATCHED AND source.rn = 1 THEN UPDATE SET *
WHEN NOT MATCHED AND source.rn = 1 THEN INSERT *

-- Gold: Business aggregates
CREATE TABLE retailcorp.gold.daily_sales_summary
USING DELTA
LOCATION 's3://retailcorp-data-lake-gold/sales/daily_summary'
PARTITIONED BY (date)
AS SELECT
    date,
    store_id,
    product_category,
    SUM(amount) as total_sales,
    COUNT(*) as transaction_count,
    AVG(amount) as avg_transaction_value
FROM retailcorp.silver.pos_transactions
GROUP BY date, store_id, product_category;
```

#### 3. Real-Time Streaming Pipeline

```python
# Kinesis Data Analytics for real-time processing
import boto3
from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import StreamTableEnvironment, EnvironmentSettings

# Real-time inventory updates
env = StreamExecutionEnvironment.get_execution_environment()
t_env = StreamTableEnvironment.create(env)

# Kinesis source
t_env.execute_sql("""
    CREATE TABLE pos_stream (
        transaction_id STRING,
        store_id STRING,
        product_id STRING,
        quantity INT,
        timestamp TIMESTAMP_LTZ(3),
        WATERMARK FOR timestamp AS timestamp - INTERVAL '5' SECOND
    ) WITH (
        'connector' = 'kinesis',
        'stream' = 'pos-transactions-stream',
        'aws.region' = 'us-east-1',
        'scan.stream.initpos' = 'LATEST',
        'format' = 'json'
    )
""")

# Real-time inventory calculation
t_env.execute_sql("""
    CREATE TABLE inventory_alerts (
        store_id STRING,
        product_id STRING,
        current_stock INT,
        alert_type STRING,
        timestamp TIMESTAMP(3)
    ) WITH (
        'connector' = 'kinesis',
        'stream' = 'inventory-alerts-stream',
        'aws.region' = 'us-east-1',
        'format' = 'json'
    )
""")

# Low stock detection
t_env.execute_sql("""
    INSERT INTO inventory_alerts
    SELECT 
        store_id,
        product_id,
        SUM(quantity) as current_stock,
        CASE 
            WHEN SUM(quantity) < 10 THEN 'CRITICAL'
            WHEN SUM(quantity) < 50 THEN 'LOW'
            ELSE 'OK'
        END as alert_type,
        TUMBLE_END(timestamp, INTERVAL '1' MINUTE) as timestamp
    FROM pos_stream
    GROUP BY 
        store_id,
        product_id,
        TUMBLE(timestamp, INTERVAL '1' MINUTE)
    HAVING SUM(quantity) < 50
""")
```

---

## Implementation

### Data Ingestion Patterns

#### 1. Database CDC with DMS

```python
# DMS task configuration
import boto3

dms = boto3.client('dms')

# Create replication task for Oracle CDC
response = dms.create_replication_task(
    ReplicationTaskIdentifier='retailcorp-pos-cdc',
    SourceEndpointArn='arn:aws:dms:us-east-1:ACCOUNT:endpoint:oracle-source',
    TargetEndpointArn='arn:aws:dms:us-east-1:ACCOUNT:endpoint:s3-target',
    MigrationType='cdc',
    TableMappings='''{
        "rules": [{
            "rule-type": "selection",
            "rule-id": "1",
            "rule-name": "1",
            "object-locator": {
                "schema-name": "POS",
                "table-name": "TRANSACTIONS"
            },
            "rule-action": "include"
        },{
            "rule-type": "transform",
            "rule-id": "2",
            "rule-name": "2",
            "rule-action": "add-column",
            "object-locator": {
                "schema-name": "POS",
                "table-name": "TRANSACTIONS"
            },
            "value": "_ingestion_timestamp",
            "expression": "\$AR_M_INSERTED"
        }]
    }''',
    ReplicationTaskSettings=json.dumps({
        "Logging": {"EnableLogging": True},
        "TargetMetadata": {
            "ParallelLoadThreads": 8,
            "ParallelLoadBufferSize": 1000
        },
        "ChangeProcessingTuning": {
            "CommitRate": 10000,
            "MinTransactionSize": 1000
        }
    })
)
```

#### 2. Event Streaming with MSK (Kafka)

```yaml
# Kafka Connect configuration
# connect-distributed.properties

# Source: Debezium CDC connector
name=debezium-pos-source
connector.class=io.debezium.connector.oracle.OracleConnector
database.hostname=oracle.retailcorp.internal
database.port=1521
database.user=${file:/kafka/secrets/datasource-credentials.properties:username}
database.password=${file:/kafka/secrets/datasource-credentials.properties:password}
database.dbname=POSDB
database.server.name=retailcorp
table.include.list=POS.TRANSACTIONS,POS.INVENTORY,POS.CUSTOMERS

# Sink: S3 connector
name=s3-sink-connector
connector.class=io.confluent.connect.s3.S3SinkConnector
s3.bucket.name=retailcorp-data-lake-bronze
s3.region=us-east-1
format.class=io.confluent.connect.s3.format.parquet.ParquetFormat
partitioner.class=io.confluent.connect.storage.partitioner.TimeBasedPartitioner
partition.duration.ms=3600000
path.format='year'=YYYY/'month'=MM/'day'=dd/'hour'=HH
topics=retailcorp.POS.TRANSACTIONS,retailcorp.POS.INVENTORY
flush.size=1000
```

### Data Transformation

#### AWS Glue ETL Jobs

```python
# Glue ETL job for Silver zone transformation
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from delta import DeltaTable, configure_spark_with_delta_pip

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'S3_BUCKET'])

# Configure Spark with Delta Lake
builder = SparkSession.builder \
    .appName("RetailCorpSilverETL") \
    .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension") \
    .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")

spark = configure_spark_with_delta_pip(builder).getOrCreate()
glueContext = GlueContext(spark)
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read from Bronze
bronze_df = spark.read.format("delta") \
    .load(f"s3://{args['S3_BUCKET']}/bronze/pos/transactions")

# Transformations
from pyspark.sql.functions import *
from pyspark.sql.types import *

silver_df = bronze_df \
    .filter(col("amount") > 0) \
    .withColumn("amount", col("amount").cast(DecimalType(10, 2))) \
    .withColumn("transaction_date", to_date(col("timestamp"))) \
    .dropDuplicates(["transaction_id"]) \
    .withColumn("_processed_timestamp", current_timestamp()) \
    .withColumn("_year", year(col("transaction_date"))) \
    .withColumn("_month", month(col("transaction_date")))

# Write to Silver with merge
silver_table = DeltaTable.forPath(spark, f"s3://{args['S3_BUCKET']}/silver/pos/transactions")

silver_table.alias("target").merge(
    silver_df.alias("source"),
    "target.transaction_id = source.transaction_id"
).whenMatchedUpdateAll() \
 .whenNotMatchedInsertAll() \
 .execute()

job.commit()
```

#### Data Quality with Great Expectations

```python
# Data quality validation
import great_expectations as gx
from great_expectations.core.expectation_suite import ExpectationSuite

# Initialize context
context = gx.get_context()

# Define expectations
suite = ExpectationSuite(name="retail_transactions_suite")

# Column expectations
suite.add_expectation(
    gx.expectations.ExpectColumnValuesToNotBeNull(
        column="transaction_id"
    )
)

suite.add_expectation(
    gx.expectations.ExpectColumnValuesToBeBetween(
        column="amount",
        min_value=0.01,
        max_value=100000
    )
)

suite.add_expectation(
    gx.expectations.ExpectColumnValuesToBeInSet(
        column="payment_method",
        value_set=["CASH", "CREDIT", "DEBIT", "GIFT_CARD", "DIGITAL_WALLET"]
    )
)

suite.add_expectation(
    gx.expectations.ExpectColumnValuesToMatchRegex(
        column="email",
        regex=r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    )
)

# Referential integrity
suite.add_expectation(
    gx.expectations.ExpectColumnPairValuesToBeEqual(
        column_A="store_id",
        column_B="stores.store_id",
        join_kwargs={"condition": "store_id = stores.store_id"}
    )
)

# Run validation
results = context.run_checkpoint(
    checkpoint_name="silver_transactions_checkpoint",
    batch_request={
        "datasource_name": "s3_datasource",
        "data_asset_name": "silver.pos_transactions"
    }
)

# Alert on failures
if not results.success:
    send_alert("Data quality validation failed", results)
```

### Data Consumption

#### Athena for Ad-Hoc Queries

```sql
-- Create views for business users
CREATE VIEW retailcorp_views.v_daily_sales AS
SELECT 
    date,
    store_id,
    store_name,
    region,
    product_category,
    SUM(amount) as total_sales,
    COUNT(*) as transaction_count,
    SUM(quantity) as units_sold
FROM retailcorp.gold.daily_sales_summary
JOIN retailcorp.gold.stores USING (store_id)
WHERE date >= current_date - interval '30' day
GROUP BY 1, 2, 3, 4, 5;

-- Optimized query with partition pruning
SELECT 
    store_id,
    SUM(total_sales) as revenue
FROM retailcorp_views.v_daily_sales
WHERE date BETWEEN '2025-01-01' AND '2025-01-31'
  AND region = 'Northeast'
GROUP BY store_id
ORDER BY revenue DESC;
```

#### QuickSight Dashboards

```python
# QuickSight dataset creation
import boto3

quicksight = boto3.client('quicksight')

# Create dataset from Athena
response = quicksight.create_data_set(
    AwsAccountId='ACCOUNT_ID',
    DataSetId='retailcorp-sales-dataset',
    Name='Sales Performance Dataset',
    PhysicalTableMap={
        'sales-table': {
            'RelationalTable': {
                'DataSourceArn': 'arn:aws:quicksight:us-east-1:ACCOUNT:datasource/retailcorp-athena',
                'Schema': 'retailcorp_views',
                'Name': 'v_daily_sales',
                'InputColumns': [
                    {'Name': 'date', 'Type': 'DATETIME'},
                    {'Name': 'store_id', 'Type': 'STRING'},
                    {'Name': 'total_sales', 'Type': 'DECIMAL'}
                ]
            }
        }
    },
    LogicalTableMap={
        'sales-logical': {
            'Alias': 'sales',
            'Source': {'PhysicalTableId': 'sales-table'}
        }
    },
    ImportMode='SPICE',  # In-memory cache
    Permissions=[{
        'Principal': 'arn:aws:quicksight:us-east-1:ACCOUNT:group/default/RetailCorp-Analysts',
        'Actions': ['quicksight:DescribeDataSet', 'quicksight:DescribeDataSetPermissions']
    }]
)
```

---

## Governance and Security

### Lake Formation Permissions

```python
# Fine-grained access control
import boto3

lakeformation = boto3.client('lakeformation')

# Grant permissions to data stewards
lakeformation.grant_permissions(
    Principal={
        'DataLakePrincipalIdentifier': 'arn:aws:iam::ACCOUNT:role/DataSteward'
    },
    Resource={
        'Table': {
            'DatabaseName': 'retailcorp_silver',
            'Name': 'pos_transactions'
        }
    },
    Permissions=['SELECT', 'DESCRIBE'],
    PermissionsWithGrantOption=['SELECT']
)

# Column-level security for sensitive data
lakeformation.grant_permissions(
    Principal={
        'DataLakePrincipalIdentifier': 'arn:aws:iam::ACCOUNT:role/FinancialAnalyst'
    },
    Resource={
        'TableWithColumns': {
            'DatabaseName': 'retailcorp_gold',
            'Name': 'customer_transactions',
            'ColumnNames': ['customer_id', 'total_spend', 'visit_frequency']
            # Excludes: email, phone, address (PII)
        }
    },
    Permissions=['SELECT']
)
```

### Data Masking

```sql
-- Dynamic data masking for sensitive columns
CREATE MASKING POLICY email_mask AS (val string) RETURNS string ->
  CASE
    WHEN CURRENT_USER() IN ('admin@retailcorp.com') THEN val
    ELSE CONCAT('***', RIGHT(val, 4))
  END;

ALTER TABLE retailcorp_gold.customers 
MODIFY COLUMN email SET MASKING POLICY email_mask;
```

---

## Results

### Business Outcomes

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Data Access Latency** | 12 hours | 5 minutes | 99.3% faster |
| **Report Generation** | 4 hours | 30 seconds | 99.8% faster |
| **Analyst Productivity** | 40% on prep | 5% on prep | 8x more analysis |
| **Data-Driven Decisions** | 20% | 85% | 4x increase |
| **Stockouts** | 8%/month | 1%/month | 88% reduction |
| **Personalization Accuracy** | N/A | 34% CTR | New capability |

### Technical Metrics

| Metric | Target | Actual |
|--------|--------|--------|
| **Data Ingestion** | 50TB/day | 50TB/day sustained |
| **Query Performance** | < 30s | 12s average |
| **Platform Availability** | 99.9% | 99.95% |
| **Cost per TB** | $20/TB | $18/TB |
| **Data Quality Score** | 95% | 98.5% |

### Cost Breakdown

| Service | Monthly Cost | % of Total |
|---------|--------------|------------|
| S3 Storage | $15,000 | 35% |
| Glue ETL | $8,000 | 19% |
| Athena Queries | $6,000 | 14% |
| EMR | $5,000 | 12% |
| Kinesis | $4,000 | 9% |
| Redshift | $3,000 | 7% |
| Other | $2,000 | 4% |
| **Total** | **$43,000** | 100% |

---

## Lessons Learned

### Success Factors

1. **Start with Business Outcomes:** Focus on high-value use cases first
2. **Invest in Data Quality:** Poor data quality undermines trust
3. **Implement Incrementally:** Don't try to migrate everything at once
4. **Enable Self-Service:** Training and tooling for data consumers
5. **Monitor Data Lineage:** Critical for debugging and compliance

### Challenges

| Challenge | Impact | Solution |
|-----------|--------|----------|
| **Schema Evolution** | Breaking changes | Delta Lake + schema registry |
| **Data Skew** | Slow joins | Salting and partition tuning |
| **Small Files Problem** | Query slowdown | Compaction jobs hourly |
| **Data Ownership** | Quality issues | Data mesh with domain owners |

---

*Last Updated: April 2025*
*AWS Well-Architected Framework Version: 2025*
