# Caso de Estudio: Data Lake para Análisis de Big Data

> **Empresa:** RetailCorp Internacional  
> **Industria:** Retail / E-commerce  
> **Duración:** 12 meses  
> **Equipo:** 8 ingenieros de datos, 4 científicos de datos, 3 arquitectos

---

## Situación Inicial

### Contexto del Negocio

RetailCorp opera 2,500 tiendas físicas en 45 países y una plataforma e-commerce que procesa 50 millones de transacciones anuales. Su infraestructura de datos legacy:

- **Data Warehouse Teradata** de 800TB con licencias costosas
- **Hadoop on-premises** con 200 nodos ( Hortonworks )
- **Tiempo de procesamiento:** 18-24 horas para reportes diarios
- **Data silos:** 15 sistemas diferentes sin integración
- **Costo:** $4.2M/año solo en infraestructura de datos

### Dolor del Negocio

| Problema | Impacto |
|----------|---------|
| Reportes con 24h delay | Decisiones basadas en datos obsoletos |
| No predicción de demanda | Stock-outs en 12% de SKUs populares |
| Customer 360 imposible | Personalización básica, sin ML |
| Data scientists esperando datos | 40% del tiempo en ETL, no en modelos |
| Compliance GDPR difícil | Datos dispersos, sin linaje |

### Objetivos

1. **Reduce reporting de 24h a 15 minutos** (real-time analytics)
2. **Unifica data silos** en data lake centralizado
3. **Enable ML/AI** para personalización y forecasting
4. **Disminuye costos 40%** vs infraestructura legacy
5. **Compliance:** GDPR, CCPA, SOC2 automatizado

---

## Arquitectura del Data Lake

### Diseño: Lake House Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    LAKE HOUSE ARCHITECTURE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Principios:                                                    │
│   1. Storage desacoplado de compute (S3 + query engines)        │
│   2. Formatos abiertos (Parquet, Delta Lake)                    │
│   3. Schema-on-read + governance centralizada (Lake Formation)   │
│   4. Capa Medallion: Bronze → Silver → Gold                     │
│   5. Multi-protocolo: SQL, Python, Spark, notebooks               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAKE PLATFORM                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   Sources Layer                                                  │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐         │
│   │E-commerce│ │   POS    │ │ Inventory│ │  CRM     │         │
│   │PostgreSQL│ │ Systems  │ │  SAP     │ │Salesforce│         │
│   └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘         │
│        │            │            │            │                 │
│        └─────────────┴────────────┴────────────┘                │
│                      │                                            │
│                      ▼                                            │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              INGESTION LAYER                            │   │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐             │   │
│   │  │  DMS     │  │ Kinesis  │  │  Glue    │             │   │
│   │  │(CDC)     │  │ Data     │  │ Crawlers │             │   │
│   │  │          │  │ Streams  │  │          │             │   │
│   │  └────┬─────┘  └────┬─────┘  └────┬─────┘             │   │
│   │       │             │             │                    │   │
│   │       └─────────────┴─────────────┘                    │   │
│   │                     │                                   │   │
│   └─────────────────────┼───────────────────────────────────┘   │
│                         │                                        │
│                         ▼                                        │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                   STORAGE LAYER (S3)                   │   │
│   │                                                         │   │
│   │   Bronze Zone (Raw)                                     │   │
│   │   ┌─────────────────────────────────────────────────┐  │   │
│   │   │ s3://retail-lake/bronze/                         │  │   │
│   │   │   ├── e-commerce/clickstream/parquet/           │  │   │
│   │   │   ├── pos/transactions/json/                    │  │   │
│   │   │   ├── inventory/sap/csv/                        │  │   │
│   │   │   └── crm/salesforce/api-responses/             │  │   │
│   │   └─────────────────────────────────────────────────┘  │   │
│   │                                                         │   │
│   │   Silver Zone (Cleaned)                                 │   │
│   │   ┌─────────────────────────────────────────────────┐  │   │
│   │   │ s3://retail-lake/silver/                         │  │   │
│   │   │   ├── transactions/                              │  │   │
│   │   │   ├── customers/                                 │  │   │
│   │   │   ├── products/                                  │  │   │
│   │   │   └── inventory/                                 │  │   │
│   │   └─────────────────────────────────────────────────┘  │   │
│   │                                                         │   │
│   │   Gold Zone (Aggregated)                                │   │
│   │   ┌─────────────────────────────────────────────────┐  │   │
│   │   │ s3://retail-lake/gold/                           │  │   │
│   │   │   ├── daily_sales/                               │  │   │
│   │   │   ├── customer_360/                              │  │   │
│   │   │   ├── inventory_forecast/                        │  │   │
│   │   │   └── marketing_attribution/                     │  │   │
│   │   └─────────────────────────────────────────────────┘  │   │
│   │                                                         │   │
│   │   Data Catalog (Glue)                                   │   │
│   │   ┌─────────────────────────────────────────────────┐  │   │
│   │   │ • Automated schema discovery                    │  │   │
│   │   │ • Table definitions for Athena/Redshift         │  │   │
│   │   │ • Partitioning: year/month/day                 │  │   │
│   │   │ • Data quality metrics                          │  │   │
│   │   └─────────────────────────────────────────────────┘  │   │
│   │                                                         │   │
│   │   Governance (Lake Formation)                          │   │
│   │   ┌─────────────────────────────────────────────────┐  │   │
│   │   │ • Row-level security (RLS)                      │  │   │
│   │   │ • Column-level filtering (PII)                │  │   │
│   │   │ • Access controls by persona                   │  │   │
│   │   │ • Audit logging                                 │  │   │
│   │   └─────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   Processing Layer                                               │
│   ┌──────────────┬──────────────┬──────────────┬──────────────┐ │
│   │   EMR        │    Glue      │   Lambda    │   SageMaker  │ │
│   │   Spark      │   ETL Jobs   │   (light    │   Training   │ │
│   │   Clusters   │   (Python    │   transforms)│   Pipelines  │ │
│   │   (transient)│    Shell)    │             │             │ │
│   └──────────────┴──────────────┴──────────────┴──────────────┘ │
│                                                                  │
│   Analytics Layer                                                │
│   ┌──────────────┬──────────────┬──────────────┬──────────────┐ │
│   │   Athena     │   Redshift   │   QuickSight│   Jupyter    │ │
│   │   (ad-hoc    │   Spectrum   │   Dashboards│   (SageMaker │ │
│   │    queries)  │   (federated)│             │   Studio)    │ │
│   └──────────────┴──────────────┴──────────────┴──────────────┘ │
│                                                                  │
│   ML Layer                                                       │
│   ┌──────────────┬──────────────┬──────────────┐               │
│   │   Personalize│   Forecast   │   Comprehend│               │
│   │   (product   │   (demand    │   (NLP for  │               │
│   │    recs)     │    planning) │    reviews)  │               │
│   └──────────────┴──────────────┴──────────────┘               │
│                                                                  │
│   Consumption                                                    │
│   ┌──────────────┬──────────────┬──────────────┐               │
│   │   BI Tools   │   APIs       │   Data      │               │
│   │   (Tableau)  │   (AppSync)  │   Scientists│               │
│   └──────────────┴──────────────┴──────────────┘               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementación

### 1. Data Ingestion Pipeline

```python
# glue_jobs/ingest_ecommerce.py
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame
import boto3

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'source_table', 'target_path'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read from RDS via JDBC
datasource = glueContext.create_dynamic_frame.from_options(
    connection_type="jdbc",
    connection_options={
        "url": "jdbc:postgresql://ecommerce-db.retailcorp.com:5432/transactions",
        "dbtable": args['source_table'],
        "user": "${username}",
        "password": "${password}"
    },
    transformation_ctx="datasource"
)

# Transformations
def add_metadata(rec):
    """Add ingestion metadata to each record"""
    from datetime import datetime
    rec['ingestion_timestamp'] = datetime.utcnow().isoformat()
    rec['ingestion_date'] = datetime.utcnow().strftime('%Y-%m-%d')
    rec['data_source'] = 'e-commerce'
    return rec

# Apply transformations
datasource_with_metadata = datasource.map(add_metadata)

# Convert to Spark DataFrame for complex transforms
df = datasource_with_metadata.toDF()

# Data quality checks
from pyspark.sql.functions import col

valid_df = df.filter(
    (col('transaction_id').isNotNull()) &
    (col('amount') > 0) &
    (col('timestamp').isNotNull())
)

# Write to Bronze zone (raw, partitioned)
valid_df.write \
    .mode('append') \
    .partitionBy('ingestion_date') \
    .parquet(f"s3://retail-lake/bronze/e-commerce/{args['source_table']}/")

# Update Glue catalog
glue = boto3.client('glue')
glue.create_table(
    DatabaseName='retail_bronze',
    TableInput={
        'Name': f"bronze_{args['source_table']}",
        'StorageDescriptor': {
            'Location': f"s3://retail-lake/bronze/e-commerce/{args['source_table']}/",
            'InputFormat': 'org.apache.hadoop.mapred.TextInputFormat',
            'OutputFormat': 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat',
            'SerdeInfo': {'SerializationLibrary': 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'}
        },
        'PartitionKeys': [{'Name': 'ingestion_date', 'Type': 'string'}]
    }
)

job.commit()
```

### 2. Data Quality with Great Expectations

```python
# data_quality/validate_transactions.py
import great_expectations as ge
from great_expectations.checkpoint import SimpleCheckpoint
import boto3

def validate_transaction_data(df):
    """
    Validate transaction data before moving to Silver zone
    """
    context = ge.get_context()
    
    # Create expectation suite
    suite = context.create_expectation_suite(
        expectation_suite_name="transactions_suite"
    )
    
    # Define expectations
    validator = context.get_validator(
        batch_request={"datasource_name": "transactions"},
        expectation_suite=suite
    )
    
    # Schema validation
    validator.expect_table_columns_to_match_ordered_list(
        column_list=[
            "transaction_id",
            "customer_id",
            "amount",
            "currency",
            "timestamp",
            "status",
            "payment_method"
        ]
    )
    
    # Data quality rules
    validator.expect_column_values_to_not_be_null("transaction_id")
    validator.expect_column_values_to_be_unique("transaction_id")
    validator.expect_column_values_to_be_between("amount", min_value=0.01)
    validator.expect_column_values_to_be_in_set(
        "status",
        ["completed", "pending", "failed", "refunded"]
    )
    validator.expect_column_values_to_be_in_set(
        "currency",
        ["USD", "EUR", "GBP", "MXN"]
    )
    
    # Statistical checks
    validator.expect_column_mean_to_be_between("amount", 50, 500)
    
    # Save expectation suite
    validator.save_expectation_suite(discard_failed_expectations=False)
    
    # Run validation
    checkpoint = SimpleCheckpoint(
        name="transactions_checkpoint",
        data_context=context,
        validator=validator
    )
    checkpoint_result = checkpoint.run()
    
    # Alert on failure
    if not checkpoint_result.success:
        sns = boto3.client('sns')
        sns.publish(
            TopicArn='arn:aws:sns:region:account:data-quality-alerts',
            Subject='Data Quality Validation Failed',
            Message=f'Validation failed for transactions: {checkpoint_result}'
        )
        raise ValueError("Data quality validation failed")
    
    return True
```

### 3. Incremental Processing with Delta Lake

```python
# silver_processing/update_customer_360.py
from delta import DeltaTable, configure_spark_with_delta_pip
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp

# Initialize Spark with Delta
spark = configure_spark_with_delta_pip(
    SparkSession.builder.appName("Customer360Update")
).getOrCreate()

# Read new data from Bronze
new_transactions = spark.read.parquet(
    "s3://retail-lake/bronze/e-commerce/transactions/"
).filter(col("ingestion_date") == "2024-04-29")

# Calculate customer metrics
from pyspark.sql import functions as F

customer_metrics = new_transactions.groupBy("customer_id").agg(
    F.count("*").alias("transaction_count_24h"),
    F.sum("amount").alias("revenue_24h"),
    F.max("timestamp").alias("last_purchase"),
    F.collect_set("category").alias("categories_purchased")
)

# Merge into Delta table (Silver)
delta_table = DeltaTable.forPath(spark, "s3://retail-lake/silver/customer_360/")

# Schema evolution handled automatically
delta_table.alias("target").merge(
    customer_metrics.alias("source"),
    "target.customer_id = source.customer_id"
).whenMatchedUpdateAll(
    set={
        "total_transactions": col("target.total_transactions") + col("source.transaction_count_24h"),
        "lifetime_value": col("target.lifetime_value") + col("source.revenue_24h"),
        "last_updated": current_timestamp(),
        "customer_segment": F.when(
            col("target.lifetime_value") > 1000, "VIP"
        ).when(
            col("target.lifetime_value") > 500, "High Value"
        ).otherwise("Standard")
    }
).whenNotMatchedInsertAll().execute()

# Optimize table
spark.sql("OPTIMIZE delta.`s3://retail-lake/silver/customer_360/`")
spark.sql("VACUUM delta.`s3://retail-lake/silver/customer_360/` RETAIN 168 HOURS")
```

### 4. Real-time Streaming with Kinesis

```python
# lambda/stream_processor.py
import json
import boto3
import base64
from datetime import datetime

def lambda_handler(event, context):
    """
    Process clickstream data from Kinesis in real-time
    """
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('real_time_metrics')
    firehose = boto3.client('firehose')
    
    processed_records = []
    
    for record in event['Records']:
        # Decode Kinesis data
        payload = base64.b64decode(record['kinesis']['data'])
        data = json.loads(payload)
        
        # Enrich data
        enriched = {
            'session_id': data['session_id'],
            'user_id': data['user_id'],
            'event_type': data['event_type'],
            'product_id': data.get('product_id'),
            'timestamp': data['timestamp'],
            'device': data['user_agent'],
            'country': get_country_from_ip(data['ip_address']),
            'referrer': data.get('referrer'),
            'enriched_at': datetime.utcnow().isoformat()
        }
        
        # Real-time aggregations in DynamoDB
        if data['event_type'] == 'purchase':
            # Update real-time revenue counter
            table.update_item(
                Key={'metric_type': 'revenue_today'},
                UpdateExpression='SET amount = if_not_exists(amount, :zero) + :val, #ts = :ts',
                ExpressionAttributeNames={'#ts': 'timestamp'},
                ExpressionAttributeValues={
                    ':val': data['amount'],
                    ':zero': 0,
                    ':ts': datetime.utcnow().isoformat()
                }
            )
        
        # Send to Firehose for S3 landing
        processed_records.append({
            'Data': json.dumps(enriched).encode('utf-8')
        })
    
    # Batch write to Firehose
    if processed_records:
        firehose.put_record_batch(
            DeliveryStreamName='clickstream-to-s3',
            Records=processed_records
        )
    
    return {'statusCode': 200, 'processed': len(processed_records)}

def get_country_from_ip(ip):
    # Integration with GeoIP service
    # Implementation omitted
    return "US"  # Placeholder
```

---

## ML Implementation

### Personalized Recommendations

```python
# sagemaker/personalize_recommendations.py
import boto3
import sagemaker
from sagemaker.personalize import Personalize

# Create dataset group
personalize = boto3.client('personalize')

response = personalize.create_dataset_group(
    name='retail-recommendations',
    domain='ECOMMERCE'
)

dataset_group_arn = response['datasetGroupArn']

# Create interaction dataset
interactions_schema = {
    "type": "record",
    "name": "Interactions",
    "namespace": "com.amazonaws.personalize.schema",
    "fields": [
        {"name": "USER_ID", "type": "string"},
        {"name": "ITEM_ID", "type": "string"},
        {"name": "EVENT_TYPE", "type": "string"},
        {"name": "TIMESTAMP", "type": "long"},
        {"name": "EVENT_VALUE", "type": "float"}
    ]
}

personalize.create_dataset(
    datasetGroupArn=dataset_group_arn,
    datasetType='Interactions',
    name='user-item-interactions',
    schemaArn='arn:aws:personalize:::schema/ECOMMERCE_Interactions',
    dataSource={
        'dataLocation': 's3://retail-lake/gold/interactions/'
    }
)

# Train solution
personalize.create_solution(
    name='product-recommendations',
    datasetGroupArn=dataset_group_arn,
    recipeArn='arn:aws:personalize:::recipe/aws-ecomm-personalized-ranking'
)

# Deploy campaign
personalize.create_campaign(
    name='retail-recommendations-live',
    solutionVersionArn=solution_version_arn,
    minProvisionedTPS=10
)

# Real-time inference
response = personalize_runtime.get_recommendations(
    campaignArn='arn:aws:personalize:region:account:campaign/retail-recommendations-live',
    userId='customer-12345',
    numResults=10
)

recommended_items = response['itemList']
```

---

## Resultados

### Métricas de Negocio

| KPI | Antes | Después | Mejora |
|-----|-------|---------|--------|
| Reporting latency | 24 horas | 15 minutos | -99% |
| Data scientist productivity | 40% ETL | 90% modelos | +125% |
| Stock-outs | 12% | 3% | -75% |
| Personalización | Básica | ML-driven | Nuevo |
| Costo de infraestructura | $4.2M/año | $1.8M/año | -57% |

### Métricas Técnicas

| Métrica | Valor |
|---------|-------|
| Data lake size | 2.5 PB |
| Daily ingestion | 15 TB |
| Query performance | Sub-segundo (Athena) |
| Data freshness | < 1 minuto (streaming) |
| Uptime | 99.99% |

---

*Caso de estudio basado en arquitecturas lake house reales.*

*Última actualización: Abril 2025*
