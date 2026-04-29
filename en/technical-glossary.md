# AWS Technical Glossary

> **200+ essential AWS terms organized alphabetically**

---

## A

**Access Control List (ACL)**
A permissions list that determines which users or systems have access to specific objects in S3 or VPC.

**Access Key**
A pair of credentials (Access Key ID and Secret Access Key) used to authenticate requests to the AWS API via SDK or CLI.

**ACM (AWS Certificate Manager)**
A service that lets you provision, manage, and deploy public and private SSL/TLS certificates.

**Amazon Athena**
An interactive query service that makes it easy to analyze data in S3 using standard SQL without servers.

**Amazon Aurora**
A MySQL and PostgreSQL-compatible relational database built for the cloud, delivering up to 5x better performance than standard MySQL.

**Amazon Augmented AI (Amazon A2I)**
A service that enables building human review workflows for machine learning predictions.

**Amazon AppStream 2.0**
An application streaming service that lets you run desktop applications on any device.

**Amazon AppSync**
A managed GraphQL service that makes it easy to develop APIs by synchronizing data between applications and data sources.

**Amazon Athena**
An interactive analysis service that lets you query data in S3 using standard SQL without servers.

**AMI (Amazon Machine Image)**
A virtual machine image that provides the information required to launch an EC2 instance, including the operating system and configurations.

**API Gateway**
A managed service for creating, publishing, maintaining, monitoring, and securing RESTful and WebSocket APIs.

**Application Load Balancer (ALB)**
A Layer 7 (application) load balancer that distributes HTTP/HTTPS traffic based on advanced rules.

**ARN (Amazon Resource Name)**
A unique identifier for AWS resources with format: `arn:partition:service:region:account-id:resource`.

**ASG (Auto Scaling Group)**
A group of EC2 instances that automatically scales according to demand while maintaining system health.

**AWS AppConfig**
A service for managing application configurations and feature flags securely.

**AWS Application Composer**
A visual tool for designing and building serverless applications by dragging and dropping components.

**AWS Audit Manager**
A service for continuously auditing compliance with regulations and standards.

**AWS Artifact**
A portal for accessing compliance reports and AWS security agreements.

**AWS Auto Scaling**
A service that lets you scale multiple resources automatically based on custom metrics.

---

## B

**Batch**
A service for running large-scale computing workloads without managing infrastructure.

**Bastion Host**
A specially configured server for securely accessing resources in private subnets.

**Block Storage**
Block-level storage used by EBS to provide persistent volumes to EC2 instances.

**Blue/Green Deployment**
A deployment strategy that maintains two identical environments, alternating between them to minimize downtime.

**BYOL (Bring Your Own License)**
A licensing model that lets you use existing software licenses on AWS instances.

---

## C

**Canary Deployment**
A gradual deployment technique that routes a small portion of traffic to the new version.

**CloudFormation**
An IaC (Infrastructure as Code) service that lets you model and provision AWS resources using YAML/JSON templates.

**CloudFront**
A content delivery network (CDN) that delivers data, videos, and APIs to users with low latency.

**CloudTrail**
A governance and auditing service that records all account activity in your AWS account.

**CloudWatch**
An observability service for monitoring metrics, logs, and setting alarms.

**CodeCommit**
A secure, highly scalable version control service to host private Git repositories.

**CodeBuild**
A continuous integration service that compiles source code, runs tests, and produces artifacts.

**CodeDeploy**
An automated deployment service for EC2 instances, Lambda, ECS, and on-premises servers.

**CodePipeline**
A continuous delivery service that automates release pipelines.

**CodeStar**
A unified service for development, quickly creating projects with integrated CI/CD pipelines.

**Cognito**
An identity and access management service for web and mobile applications.

**Cold Storage**
Low-cost storage for infrequently accessed data, typical in Glacier.

**Container**
A standardized unit of software that packages code and dependencies for consistent execution.

**CIDR (Classless Inter-Domain Routing)**
Notation for defining IP address ranges (e.g., 10.0.0.0/16).

**Configuration Drift**
The difference between the current state of resources and their defined IaC configuration.

**Connection Draining**
An ELB feature that allows completing in-flight requests before removing instances.

**Consolidated Billing**
An AWS Organizations feature that lets you combine payments for multiple accounts.

**Cost Explorer**
A tool to visualize, understand, and manage AWS costs.

**Cross-Region Replication**
Automatic replication of S3 buckets across different AWS regions.

---

## D

**DAX (DynamoDB Accelerator)**
An in-memory cache for DynamoDB that provides microsecond response times.

**Data Lake**
A storage repository that holds vast amounts of data in its native format.

**Data Pipeline**
A web service for processing and moving data between AWS services and on-premises.

**Data Transfer Out (DTO)**
The cost associated with transferring data out of AWS services to the internet or between regions.

**Dedicated Host**
A physical EC2 server dedicated for meeting licensing requirements or compliance needs.

**Dedicated Instance**
An EC2 instance that runs on dedicated hardware but may share hardware with other instances in the same account.

**Direct Connect**
A service for establishing a dedicated network connection from on-premises to AWS.

**DMS (Database Migration Service)**
A service for migrating databases to AWS securely with minimal downtime.

**DynamoDB**
A key-value and document NoSQL database that delivers single-digit millisecond performance at any scale.

**DynamoDB Streams**
An ordered flow of item changes in DynamoDB tables, useful for triggers.

**DynamoDB Global Tables**
Tables automatically replicated across multiple AWS regions.

**DX (Direct Connect)**
Abbreviation for AWS Direct Connect.

---

## E

**EBS (Elastic Block Store)**
A persistent block storage service for EC2 instances.

**EC2 (Elastic Compute Cloud)**
A web service that provides resizable compute capacity in the cloud.

**ECR (Elastic Container Registry)**
A secure Docker registry for storing, managing, and deploying container images.

**ECS (Elastic Container Service)**
A fully managed Docker container orchestration service.

**EFS (Elastic File System)**
A managed, scalable NFS file storage service.

**EKS (Elastic Kubernetes Service)**
A managed Kubernetes service to run containers without operating the control plane.

**ElastiCache**
A caching service compatible with Redis and Memcached.

**Elastic Beanstalk**
A service for deploying and scaling web applications without managing infrastructure.

**Elastic IP**
A static IPv4 address designed for dynamic cloud computing.

**Elastic Load Balancer (ELB)**
A load balancer that distributes traffic across multiple targets.

**EMR (Elastic MapReduce)**
A big data platform for processing large amounts of data using Hadoop, Spark, etc.

**ENI (Elastic Network Interface)**
A virtual network component that can be attached to EC2 instances.

**EventBridge**
A serverless event bus service for connecting applications using events.

**Fargate**
A serverless compute technology for containers that eliminates server management.

---

## F

**Fargate**
Serverless technology for running containers without managing servers or clusters.

**Fault Tolerance**
A system's ability to continue operating when components fail.

**FIFO Queue**
An SQS queue that guarantees strict ordering and exactly-once delivery.

**Flow Logs**
A feature for capturing information about network traffic in VPC.

---

## G

**Glacier**
A low-cost archive storage service for long-term backup and archiving.

**Glacier Deep Archive**
The lowest-cost storage option for rarely accessed data (12+ hour retrieval time).

**Glue**
A serverless ETL service for preparing and transforming data for analysis.

**Greengrass**
A service for running AWS capabilities on local edge devices.

---

## H

**High Availability (HA)**
System design that ensures availability through redundancy and fault tolerance.

**Hot Standby**
A disaster recovery configuration where the backup system is active and ready.

**Hybrid Cloud**
Infrastructure that combines public cloud with private cloud or on-premises.

---

## I

**IAM (Identity and Access Management)**
A service for managing users, groups, roles, and secure access policies.

**IGW (Internet Gateway)**
A VPC component that enables communication between VPC and the Internet.

**Instance Store**
Temporary block storage physically attached to the EC2 host.

**IoT Core**
A managed platform for securely connecting IoT devices to the cloud.

**IOPS (Input/Output Operations Per Second)**
A storage performance metric relevant for EBS io1/io2 volumes.

---

## J

**JSON (JavaScript Object Notation)**
A data format used in APIs, CloudFormation templates, and configurations.

---

## K

**Kinesis**
A platform for collecting, processing, and analyzing real-time data streams.

**KMS (Key Management Service)**
A managed service for creating and controlling encryption keys.

---

## L

**Lambda**
A serverless compute service that runs code in response to events without managing servers.

**Launch Configuration**
A template defining instance configurations for Auto Scaling (deprecated, use Launch Templates).

**Launch Template**
A newer, more flexible template for defining EC2 launch configurations.

**Latency**
The response time between request and response, critical for interactive applications.

**Lifecycle Hooks**
Pause points in Auto Scaling that allow running custom actions during transitions.

**Load Balancer**
A service that distributes incoming traffic across multiple targets for high availability.

**Log Groups**
Groupings of log streams in CloudWatch Logs.

---

## M

**Managed Service**
A service where AWS manages the underlying infrastructure, freeing the user from operations.

**Multi-AZ**
Deployment of resources across multiple Availability Zones for high availability.

**Multi-Tenancy**
Architecture where multiple users (tenants) share isolated resources.

**MX Record**
A DNS record that specifies mail servers for a domain.

---

## N

**NAT Gateway**
A managed service that lets instances in private subnets connect to the Internet.

**NAT Instance**
An EC2 instance configured as NAT (alternative to managed NAT Gateway).

**Network ACL (NACL)**
A subnet-level firewall that controls inbound and outbound traffic.

**Network Load Balancer (NLB)**
A Layer 4 (transport) load balancer for TCP/UDP/TLS with high performance.

**NFS (Network File System)**
A file sharing protocol used by EFS.

**NIST**
National Institute of Standards and Technology, US agency that defines security standards.

---

## O

**Object Storage**
A storage architecture where data is managed as objects (S3).

**On-Demand**
A pricing model where you pay for resources used without commitments.

**Organization**
A service for consolidating multiple AWS accounts with centralized billing and policies.

**Origin**
The source server for content in CloudFront (S3, ELB, HTTP server).

**Outposts**
A service that extends AWS infrastructure to on-premises data centers.

---

## P

**Parameter Store**
An AWS Systems Manager service for storing configuration data and secrets.

**Peering Connection**
A network connection between two VPCs to enable private communication.

**Pilot Light**
A DR strategy where minimum core always runs in secondary region.

**Placement Group**
A logical grouping of instances to optimize network performance or hardware.

**Policy**
A JSON document that defines permissions in IAM, S3, etc.

**Private Subnet**
A subnet without a route to the Internet Gateway, used for internal resources.

**Public Subnet**
A subnet with a route to the Internet Gateway for publicly accessible resources.

---

## Q

**Queue**
A FIFO (First In, First Out) data structure used by SQS for decoupling.

**QuickSight**
A business intelligence (BI) service for creating dashboards and analytics.

---

## R

**RDS (Relational Database Service)**
A managed relational database service (MySQL, PostgreSQL, Oracle, SQL Server, MariaDB).

**Read Replica**
A read-only copy of a database for scaling read queries.

**Region**
A geographic area containing multiple Availability Zones.

**Reserved Instances**
A pricing model with discounts for long-term usage commitments.

**Resource**
Any AWS entity that can be created and managed (EC2, S3, IAM, etc.).

**Route 53**
A scalable, managed DNS service with intelligent routing.

**Route Table**
A routing table that controls traffic direction in VPC.

---

## S

**S3 (Simple Storage Service)**
A scalable, durable object storage service.

**S3 Glacier**
A low-cost archive storage service with different retrieval times.

**S3 Intelligent-Tiering**
A storage class that automatically moves objects based on access patterns.

**SageMaker**
A managed service for building, training, and deploying machine learning models.

**Savings Plans**
A flexible pricing model with discounts for compute usage commitments.

**SCP (Service Control Policy)**
IAM policies that define permission boundaries for accounts in Organizations.

**Secret Manager**
A service for rotating, managing, and retrieving secrets (passwords, API keys).

**Security Group**
A virtual firewall at the instance level that controls inbound and outbound traffic.

**Serverless**
A computing model where AWS manages the infrastructure completely.

**Service Catalog**
A service for creating and managing catalogs of approved IT products.

**Session Manager**
A Systems Manager tool for accessing instances without SSH bastion.

**SNS (Simple Notification Service)**
A pub/sub messaging service for push notifications.

**Spot Instances**
EC2 instances using spare capacity with discounts up to 90%.

**SQS (Simple Queue Service)**
A managed message queue service for decoupling components.

**SSE (Server-Side Encryption)**
Data encryption managed by the server (S3, EBS, etc.).

**SSM (AWS Systems Manager)**
A unified service for managing AWS resources and operations.

**Step Functions**
A service for orchestrating visual workflows across multiple AWS services.

**Storage Gateway**
A hybrid service that connects on-premises storage to the cloud.

**Subnet**
A segment of an IP network within a VPC.

---

## T

**Tag**
A metadata label (key-value) for organizing and categorizing AWS resources.

**Target Group**
A group of targets (instances, IPs, Lambda) for load balancers.

**Terraform**
A third-party IaC tool for managing cloud infrastructure.

**Throttling**
Request limiting to protect services from overload.

**Throughput**
The rate of data transfer processed per unit of time.

**TLS (Transport Layer Security)**
A cryptographic protocol for secure communications (successor to SSL).

**Trail**
A CloudTrail configuration that records events and delivers them to S3.

**Transit Gateway**
A network service connecting VPCs and on-premises networks through a central gateway.

---

## U

**User Pool**
A user directory in Cognito for authentication and registration.

---

## V

**VPC (Virtual Private Cloud)**
A logically isolated virtual network within AWS to deploy resources.

**VPC Endpoint**
A private gateway for connecting VPC to AWS services without going to the Internet.

**VPN Connection**
An encrypted connection between VPC and on-premises network.

**Volume**
An EBS storage unit attached to EC2 instances.

---

## W

**Warm Standby**
A DR strategy where a reduced replica of the application always runs on standby.

**Web Application Firewall (WAF)**
A firewall that protects web applications from common exploits.

**WorkSpaces**
A managed virtual desktop service (VDI) in the cloud.

---

## X

**X-Ray**
A distributed tracing service for analyzing and debugging applications.

---

## Y

**YAML**
A data serialization format used in CloudFormation and configurations.

---

## Z

**Zero Trust**
A security model that assumes nobody is trusted by default.

**Zone**
In Route 53, a managed DNS domain with its records.

---

## Common Acronyms

| Acronym | Meaning |
|---------|---------|
| ACL | Access Control List |
| ALB | Application Load Balancer |
| AMI | Amazon Machine Image |
| API | Application Programming Interface |
| ARN | Amazon Resource Name |
| AZ | Availability Zone |
| BYOL | Bring Your Own License |
| CDN | Content Delivery Network |
| CI/CD | Continuous Integration/Continuous Deployment |
| CIDR | Classless Inter-Domain Routing |
| CLI | Command Line Interface |
| CMK | Customer Master Key |
| DAX | DynamoDB Accelerator |
| DMS | Database Migration Service |
| DNS | Domain Name System |
| DR | Disaster Recovery |
| DTO | Data Transfer Out |
| EBS | Elastic Block Store |
| EC2 | Elastic Compute Cloud |
| ECR | Elastic Container Registry |
| ECS | Elastic Container Service |
| EFS | Elastic File System |
| EKS | Elastic Kubernetes Service |
| ELB | Elastic Load Balancer |
| EMR | Elastic MapReduce |
| ENI | Elastic Network Interface |
| FIFO | First In, First Out |
| IAM | Identity and Access Management |
| IGW | Internet Gateway |
| IOPS | Input/Output Operations Per Second |
| IP | Internet Protocol |
| KMS | Key Management Service |
| MTU | Maximum Transmission Unit |
| NAT | Network Address Translation |
| NACL | Network Access Control List |
| NLB | Network Load Balancer |
| PII | Personally Identifiable Information |
| RDS | Relational Database Service |
| RPO | Recovery Point Objective |
| RTO | Recovery Time Objective |
| SCP | Service Control Policy |
| SDK | Software Development Kit |
| SLA | Service Level Agreement |
| SNS | Simple Notification Service |
| SQS | Simple Queue Service |
| SRI | Subresource Integrity |
| S3 | Simple Storage Service |
| SSE | Server-Side Encryption |
| SSM | AWS Systems Manager |
| SSL/TLS | Secure Sockets Layer/Transport Layer Security |
| SSO | Single Sign-On |
| TTL | Time To Live |
| VDI | Virtual Desktop Infrastructure |
| VPC | Virtual Private Cloud |
| VPN | Virtual Private Network |
| WAF | Web Application Firewall |
| XML | eXtensible Markup Language |
| YAML | YAML Ain't Markup Language |

---

*Last updated: April 2025*
