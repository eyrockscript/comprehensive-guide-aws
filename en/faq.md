# Frequently Asked Questions (FAQ)

> **Answers to the most common AWS questions, organized by category**

---

## General

### What is AWS?
AWS (Amazon Web Services) is a cloud computing platform that offers over 200 full-featured services for infrastructure, storage, databases, networking, artificial intelligence, IoT, and more from globally distributed data centers.

### How many services does AWS offer?
AWS offers over 200 full-featured services covering compute, storage, databases, networking, analytics, machine learning, IoT, security, and developer tools.

### What is the AWS Shared Responsibility Model?
A security model where AWS is responsible for **security OF the cloud** (infrastructure, hardware, network) and the customer is responsible for **security IN the cloud** (data, configurations, access, encryption).

### What is the AWS Free Tier?
The Free Tier includes services with monthly free limits for the first 12 months, plus always-free services like Lambda (1M requests/month), CloudWatch (10 custom metrics), and DynamoDB (25 GB storage).

### How do I calculate AWS costs before using a service?
Use the **AWS Pricing Calculator** to estimate costs based on your architecture. You can also use **AWS Cost Explorer** to analyze current spending and **AWS Budgets** to set budget alerts.

---

## Compute (EC2, Lambda, ECS, EKS)

### What is the difference between EC2 On-Demand, Reserved, and Spot?
- **On-Demand**: Pay per hour with no commitments, ideal for variable workloads
- **Reserved**: Up to 72% discount for 1-3 year commitments, ideal for predictable workloads
- **Spot**: Up to 90% discount using spare capacity, ideal for interruption-tolerant workloads
- **Savings Plans**: Flexible discount for compute usage commitments over 1-3 years

### When should I use Lambda vs EC2?
- **Lambda**: Ideal for short events (<15 min), serverless, pay-per-execution, instant auto-scaling
- **EC2**: Ideal for long-running applications, full OS control, specific hardware use cases

### What is Auto Scaling?
A service that automatically adjusts the amount of EC2 resources based on demand, maintaining system health and optimizing costs.

### What is the difference between ECS and EKS?
- **ECS**: AWS's proprietary container service, simpler, native integration, no additional cost
- **EKS**: Managed Kubernetes service, compatible with ecosystem tools, has cluster cost ($0.10/hour)

### What is Fargate?
Fargate is serverless technology for containers that eliminates the need to manage servers or clusters. Works with ECS and EKS.

### How do I choose the right EC2 instance type?
Consider:
- **Purpose**: General purpose (T, M), Compute optimized (C), Memory optimized (R, X), GPU (P, G)
- **Workload**: Burstable (T3/T4g) for low utilization, Sustained (M6i) for high utilization
- **Cost**: Graviton (ARM) offers 40% better price/performance than x86

---

## Storage (S3, EBS, EFS)

### When should I use S3 vs EBS vs EFS?
- **S3**: Object storage for files, backups, static websites, access via HTTP
- **EBS**: Block storage for EC2 instance file systems, low latency
- **EFS**: NFS file system shared across multiple EC2 instances, scalable

### What is the difference between S3 Standard, IA, and Glacier?
- **Standard**: Frequent access, 99.99% availability
- **Standard-IA**: Infrequent access, 40% lower cost than Standard
- **Glacier Instant Retrieval**: Archive with millisecond retrieval
- **Glacier Flexible Retrieval**: Archive, minutes to hours retrieval
- **Glacier Deep Archive**: Long-term archive, 12+ hour retrieval

### How do I protect data in S3?
- **Encryption**: SSE-S3, SSE-KMS, SSE-C, or client-side encryption
- **Versioning**: Keep multiple versions of objects
- **Block public access**: Prevent accidental public access
- **MFA Delete**: Require MFA for deletion
- **Bucket policies**: Granular access control
- **S3 Object Lock**: Prevent deletion during retention period

### What is S3 Intelligent-Tiering?
A storage class that automatically moves objects between frequent and infrequent access tiers based on access patterns, optimizing costs without performance impact.

### Can I increase the size of an EBS volume?
Yes, EBS volumes can be dynamically increased without stopping the instance. However, you must extend the file system within the OS to use the additional space.

---

## Databases (RDS, DynamoDB, ElastiCache)

### When should I use RDS vs DynamoDB?
- **RDS**: Relational databases (MySQL, PostgreSQL), complex queries, joins, ACID transactions
- **DynamoDB**: NoSQL key-value, massive scalability, predictable latency (<10ms), serverless

### What is Multi-AZ in RDS?
Configuration that automatically replicates the database across multiple Availability Zones for high availability. If the primary instance fails, RDS automatically fails over to the replica in another AZ.

### How do I scale DynamoDB?
- **Provisioned Mode**: Specify RCU/WCU (Read/Write Capacity Units)
- **On-Demand Mode**: Pay per request, unlimited auto-scaling
- **DAX**: In-memory cache for microsecond reads
- **Global Tables**: Multi-region replication

### What is ElastiCache?
A managed in-memory caching service compatible with Redis and Memcached. Improves application performance by storing frequently accessed data in memory.

### How do I migrate an on-premises database to AWS?
Options include:
- **AWS DMS**: Managed migration service with continuous replication
- **AWS SCT**: Converts database schemas
- **Export/Import**: For small databases
- **Snapshots**: For compatible RDS

---

## Networking (VPC, Route 53, CloudFront)

### What is a VPC?
Virtual Private Cloud (VPC) is a logically isolated virtual network within AWS where you can deploy resources with complete control over IP addressing, subnets, route tables, and gateways.

### What is the difference between public and private subnets?
- **Public**: Has a route to Internet Gateway, can receive inbound internet traffic
- **Private**: No route to Internet Gateway, can only access internet via NAT Gateway

### Do I need a NAT Gateway for each AZ?
For high availability, NAT Gateways are recommended in each AZ used. NAT Gateways are zonal and not redundant across AZs.

### What is CloudFront?
A content delivery network (CDN) that delivers data to users with low latency through a global network of edge locations that cache content near users.

### How does Route 53 work?
A managed DNS service that:
- Registers and manages domains
- Resolves domain names to IP addresses
- Offers intelligent routing (geographic, latency, failover)
- Performs health checks

### What is Direct Connect?
A service that establishes a dedicated, private network connection from your data center to AWS, offering higher bandwidth, lower latency, and more consistent connection than internet.

---

## Security (IAM, KMS, WAF)

### What is IAM and why is it important?
Identity and Access Management (IAM) is the service for controlling who can access what resources in AWS. It is fundamental for security because:
- Implements principle of least privilege
- Enables multi-factor authentication (MFA)
- Supports roles for temporary access
- Facilitates auditing with CloudTrail

### What is the difference between IAM users and IAM roles?
- **IAM Users**: For people or applications that need persistent access, have long-term credentials
- **IAM Roles**: For temporary access, used by AWS services, applications, or federated users, no permanent credentials

### How do I rotate secrets securely?
- **AWS Secrets Manager**: Automatic rotation with Lambda
- **Parameter Store**: Manual rotation with versions
- **Scheduled rotation**: Set regular rotation periods
- **Use roles**: Prefer roles over long-term credentials

### What is KMS?
Key Management Service (KMS) is a managed service for creating and controlling encryption keys used to protect data in AWS.

### How do I protect my web application on AWS?
- **WAF**: Filter malicious traffic
- **Shield**: DDoS protection
- **CloudFront**: Origin protection, edge locations
- **Security Groups**: Instance-level firewall
- **NACLs**: Subnet-level firewall
- **ACM**: Free SSL/TLS certificates

### What are SCPs in AWS Organizations?
Service Control Policies (SCP) are policies that establish the maximum permissions available for accounts in an organization, acting as security guardrails.

---

## DevOps (CloudFormation, CodePipeline, Systems Manager)

### What is Infrastructure as Code (IaC)?
The practice of managing infrastructure through code and configuration files instead of manual processes, enabling versioning, replication, and automation.

### CloudFormation vs Terraform?
- **CloudFormation**: Native AWS service, free, deep integration, YAML/JSON templates
- **Terraform**: Multi-cloud, HCL syntax, state management, broad provider ecosystem

### How do I implement CI/CD on AWS?
Main services:
- **CodeCommit**: Private Git repositories
- **CodeBuild**: Build and testing
- **CodeDeploy**: Automated deployment
- **CodePipeline**: Pipeline orchestration
Alternative: Use GitHub Actions, GitLab CI, or Jenkins with ECS/EKS.

### What is Systems Manager (SSM)?
A unified service for managing AWS and on-premises resources, including:
- **Session Manager**: Access instances without SSH/RDP
- **Parameter Store**: Store configurations and secrets
- **Patch Manager**: Patch management
- **Automation**: Automation runbooks
- **Inventory**: Resource inventory

### How do I manage configurations across multiple environments?
- **Parameter Store**: Parameter hierarchy by environment
- **Environment variables**: Per Lambda/ECS configuration
- **Config files**: In S3 or repository
- **Feature flags**: AWS AppConfig for feature management

---

## Monitoring (CloudWatch, X-Ray)

### What can I monitor with CloudWatch?
- **Metrics**: CPU, memory, disk, network from AWS resources
- **Logs**: Application, system, custom log streams
- **Events**: Resource changes, service events
- **Alarms**: Notifications based on metric thresholds
- **Dashboards**: Custom visualizations

### What is CloudWatch Logs Insights?
A tool to query and analyze logs using a specialized query language, with aggregations, filters, and visualizations.

### How do I implement distributed tracing?
- **X-Ray**: Distributed request tracing
- **Instrumentation**: SDKs for Java, Node.js, Python, Go, .NET
- **Service Maps**: Dependency visualization
- **Subsegments**: Internal operation detail
- **Annotations**: Metadata for search and filtering

### How do I configure effective alarms?
- **Realistic thresholds**: Based on metric baselines
- **Multiple actions**: SNS for notifications, Lambda for auto-remediation
- **Appropriate periods**: Avoid alarms from temporary spikes
- **Composite metrics**: Combine multiple conditions
- **Anomaly detection alarms**: Based on machine learning

---

## Machine Learning (SageMaker, AI Services)

### What is Amazon SageMaker?
A managed service for the complete machine learning lifecycle: data preparation, training, tuning, deployment, and model monitoring.

### What AI services does AWS offer?
- **Rekognition**: Image and video analysis
- **Polly**: Text to speech
- **Transcribe**: Speech to text
- **Translate**: Automatic translation
- **Comprehend**: Natural language processing
- **Personalize**: Recommendation systems
- **Lex**: Chatbots and virtual assistants
- **Kendra**: Intelligent enterprise search

### How do I train ML models on AWS?
- **SageMaker Studio**: IDE for ML
- **SageMaker Training**: Distributed training
- **SageMaker Autopilot**: AutoML
- **SageMaker JumpStart**: Pre-trained models
- **EC2 with GPUs**: P3/P4 instances for training

---

## Cost Optimization

### How do I reduce costs on AWS?
Main strategies:
- **Reserved Instances/Savings Plans**: For predictable workloads
- **Spot Instances**: For interruption-tolerant workloads
- **Right-sizing**: Select appropriate instances
- **Storage optimization**: Move data to correct storage classes
- **Auto Scaling**: Scale according to demand
- **Serverless**: Lambda for intermittent workloads

### What is Cost Explorer?
A tool to visualize, analyze, and manage AWS costs with custom reports, filtering by tags, services, and time periods.

### How do I allocate costs to teams/projects?
- **Tags**: Tag all resources
- **Cost Allocation Tags**: Activate in Billing Console
- **AWS Organizations**: Consolidate billing
- **Cost Categories**: Logically group costs
- **Budgets**: Set limits per team/project

### What is AWS Billing Conductor?
A service to create custom pricing and generate billing reports for internal or external customers (resellers, ISVs).

---

## Architecture & Best Practices

### What is the Well-Architected Framework?
AWS framework with 6 pillars for evaluating architectures:
1. Operational Excellence
2. Security
3. Reliability
4. Performance Efficiency
5. Cost Optimization
6. Sustainability

### What is the AWS Well-Architected Tool?
A free tool to review architectures against best practices, identify risks, and get recommendations.

### How do I design for high availability?
- **Multi-AZ**: Distribute across multiple AZs
- **Multi-Region**: For disaster recovery
- **Auto Scaling**: Respond to demand changes
- **Load Balancers**: Distribute traffic
- **Health checks**: Detect and replace failed components
- **Circuit breakers**: Prevent failure cascades

### What is Chaos Engineering?
The practice of injecting controlled failures into systems to validate resilience. AWS offers **AWS Fault Injection Simulator (FIS)** for this purpose.

### How do I implement Disaster Recovery?
Strategies in order of increasing cost/RTO:
- **Backup & Restore**: Backups in S3/Glacier, manual restoration
- **Pilot Light**: Minimum core always running
- **Warm Standby**: Reduced replica always active
- **Multi-Site Active/Active**: Full deployment in multiple regions

---

## Certifications

### What certifications does AWS offer?
Levels:
- **Cloud Practitioner**: Foundational level
- **Associate**: Solutions Architect, Developer, SysOps Administrator
- **Professional**: Solutions Architect, DevOps Engineer
- **Specialty**: Security, Machine Learning, Database, Networking, etc.

### Where do I start with AWS certifications?
Recommended path:
1. **Cloud Practitioner**: General fundamentals
2. **Solutions Architect Associate**: Architecture design
3. **Developer Associate**: Application development
4. **SysOps Administrator Associate**: Operations
5. **Professional-level**: According to your role

### What resources do I use to prepare?
- **AWS Skill Builder**: Official free and paid courses
- **AWS Documentation**: Whitepapers and FAQs
- **AWS Workshops**: Hands-on labs
- **Practice exams**: Official practice exams

---

*Last updated: April 2025*
