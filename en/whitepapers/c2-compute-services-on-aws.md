# Chapter 2: Compute Services on AWS

## Executive Summary

Compute services constitute the fundamental core of the Amazon Web Services (AWS) platform, providing the computational resources needed to run applications of any scale and complexity. This whitepaper explores in detail the main compute services offered by AWS, from traditional virtual machines to serverless and container models, analyzing their features, optimal use cases, and implementation considerations. Understanding these services is essential for designing efficient and cost-effective architectures in the cloud.

## Amazon EC2: Elastic Compute Cloud

Amazon EC2 is AWS's most well-known compute service, offering resizable compute capacity in the cloud. EC2 provides virtual machines (instances) that can be configured with different operating systems and computational resources.

### Instance Types

EC2 offers a wide variety of instance types optimized for different use cases:

- **General purpose instances (T3, M5, M6):** Balance between compute, memory, and networking resources
- **Compute optimized instances (C5, C6):** High CPU-to-memory ratio
- **Memory optimized instances (R5, R6, X1):** Large memory capacity
- **Storage optimized instances (I3, D2):** High I/O and storage performance
- **Accelerated instances (P3, G4, Inf1):** Hardware accelerators (GPU, FPGA) for specific workloads
- **HPC instances (Hpc6a):** For high-performance computing

### Purchase Models

AWS offers different options for acquiring EC2 instances, allowing cost optimization according to needs:

- **On-demand instances:** Pay per hour/second with no commitments
- **Reserved instances:** Significant discounts for 1-3 year commitments
- **Savings Plans:** Commitment to hourly usage in exchange for reduced rates
- **Spot instances:** Unused EC2 capacity with discounts of up to 90%
- **Dedicated hosts:** Dedicated physical servers

### Amazon EC2 Auto Scaling

Allows automatic adjustment of EC2 capacity according to defined conditions:

- **Dynamic scaling:** Responds to changes in demand
- **Predictive scaling:** Schedules capacity changes
- **Auto Scaling Groups:** Manages sets of instances as a logical unit
- **Integrations:** CloudWatch, EventBridge, Application Load Balancer

### Storage Options

EC2 offers multiple storage options:

- **Amazon EBS (Elastic Block Store):** Persistent volumes independent of the instance
- **Instance storage:** Ephemeral storage physically attached to the host
- **Amazon EFS/FSx:** Shared file storage
- **S3/S3 Glacier:** Object storage for unstructured data

## AWS Lambda: Serverless Computing

AWS Lambda allows running code without provisioning or managing servers, paying only for the compute time consumed.

### Key Features

- **Event-driven execution:** Activates in response to events
- **Automatic scaling:** Automatically manages capacity
- **Pricing model:** Pay only for milliseconds of execution
- **Stateless architecture:** Each execution is independent
- **Time limits:** Up to 15 minutes per execution

### Supported Languages

Lambda supports multiple programming languages:
- Node.js, Python, Java, Go, .NET Core, Ruby
- Custom containers

### Integrations and Deployment Models

- **Native integrations:** API Gateway, S3, DynamoDB, SNS, SQS, etc.
- **AWS SAM:** Framework for developing serverless applications
- **AWS CDK:** Infrastructure definition using familiar languages

### Architecture Patterns

- **Asynchronous event processing**
- **Web/mobile application backends**
- **Real-time processing**
- **ETL and data processing**

## Containers on AWS

Containers provide a standard method for packaging application code, configurations, and dependencies.

### Amazon Elastic Container Service (ECS)

Fully managed container orchestration service:

- **Launch types:** EC2 and Fargate (serverless)
- **Task definitions:** Container specifications
- **ECS Services:** Maintaining task instances over time
- **Integrations:** ALB, CloudWatch, IAM, ECR

### Amazon Elastic Kubernetes Service (EKS)

Managed Kubernetes service:

- **Managed Kubernetes:** Fully managed control plane
- **Compliance:** 100% compatible with open source K8s
- **Flexible deployment:** EC2, Fargate, on-premises (with EKS Anywhere)
- **Integrations:** IAM, VPC, CloudWatch, ECR

### AWS Fargate

Serverless compute model for containers:

- **No infrastructure management:** Focus on applications
- **Precise scaling:** Resource allocation at task level
- **Enhanced security:** Workload isolation
- **Compatible:** Works with ECS and EKS

### Amazon Elastic Container Registry (ECR)

Fully managed container registry:

- **Secure storage:** For container images
- **IAM integration:** Granular access control
- **Security scanning:** Vulnerability detection
- **Cross-region replication:** For global availability

## AWS App Runner

Fully managed service for deploying web applications and APIs:

- **Simplicity:** One-click deployment from code or image
- **Fully managed:** Build, deployment, and operations
- **Auto-scaling:** Automatic adjustment according to traffic
- **Integrations:** VPC, CloudWatch, ECR, GitHub

## Service Comparison and Selection

### Selection Criteria

- **Level of management required:** From fully managed to full control
- **Flexibility vs. simplicity**
- **Pricing models and cost optimization**
- **Performance and scalability requirements**
- **Required integrations with other services**

### Scenarios and Recommendations

| Scenario | Recommended Service | Reason |
|----------|---------------------|--------|
| Traditional workloads | EC2 | Complete control over the environment |
| Microservices | ECS/EKS with Fargate | Orchestration without server management |
| Event processing | Lambda | Serverless model, pay-per-use |
| Standard web applications | App Runner | Deployment and management simplicity |
| Sharp traffic spikes | Lambda or Fargate | Automatic scaling without pre-provisioning |
| Predictable workloads | EC2 with reserved instances | Cost optimization |

## Hybrid Architectures

Many organizations implement architectures that combine different compute services:

- **Common patterns:**
  - EC2 for databases + Lambda for APIs
  - Containers for microservices + Lambda for integration
  - Core on EC2 + batch processing on Spot

- **Design considerations:**
  - Communication between services
  - Centralized management
  - Unified monitoring
  - Coherent security

## Best Practices

### Performance Optimization

- Appropriate selection of instance/service type
- Continuous monitoring and tuning
- Code and image optimization
- Appropriate geographic distribution

### Security

- Principle of least privilege with IAM
- Encryption in transit and at rest
- Network segmentation with VPC
- Regular vulnerability analysis

### Cost Optimization

- Right-sizing
- Reserved instances or Savings Plans for predictable workloads
- Use of Spot for fault-tolerant workloads
- Cost monitoring and alerts

### High Availability

- Multi-AZ design
- Auto-scaling
- Failure recovery strategies
- Resilience testing

## Future Trends

- Expansion of serverless models
- Greater performance with custom processors (Graviton)
- Deeper integration with ML/AI
- Edge computing

## Conclusion

AWS compute services provide a broad spectrum of options for running any type of application in the cloud. The choice between EC2, Lambda, containers, or fully managed services should be based on the specific requirements of each application, considering factors such as required control, operational model, performance requirements, and cost considerations.

The general trend in AWS is towards services that reduce operational burden, allow focus on application development, and automatically optimize resources. Regardless of the chosen service, following cloud architecture best practices will ensure that applications are secure, cost-effective, and highly available.

## References and Additional Resources

- [Official Amazon EC2 Documentation](https://aws.amazon.com/ec2/)
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/)
- [Amazon ECS User Guide](https://docs.aws.amazon.com/ecs/)
- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/)
- [AWS Compute Blog](https://aws.amazon.com/blogs/compute/)
