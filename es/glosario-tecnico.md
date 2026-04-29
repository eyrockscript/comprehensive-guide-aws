# Glosario Técnico AWS

> **200+ términos esenciales de AWS organizados alfabéticamente**

---

## A

**Access Control List (ACL)**
Lista de permisos que determina qué usuarios o sistemas tienen acceso a objetos específicos en S3 o VPC.

**Access Key**
Par de credenciales (Access Key ID y Secret Access Key) utilizadas para autenticar solicitudes a la API de AWS mediante SDK o CLI.

**ACM (AWS Certificate Manager)**
Servicio que permite provisionar, gestionar e implementar certificados SSL/TLS públicos y privados.

**Amazon Athena**
Servicio de consultas interactivas que permite analizar datos en S3 utilizando SQL estándar sin necesidad de servidores.

**Amazon Aurora**
Base de datos relacional compatible con MySQL y PostgreSQL, optimizada para ofrecer hasta 5 veces mejor rendimiento que MySQL estándar.

**Amazon Augmented AI (Amazon A2I)**
Servicio que permite construir flujos de trabajo de revisión humana para predicciones de machine learning.

**Amazon AppStream 2.0**
Servicio de streaming de aplicaciones que permite ejecutar aplicaciones de escritorio en cualquier dispositivo.

**Amazon AppSync**
Servicio gestionado de GraphQL que facilita el desarrollo de APIs sincronizando datos entre aplicaciones y fuentes de datos.

**Amazon Athena**
Servicio de análisis interactivo que permite consultar datos en S3 usando SQL estándar sin servidor.

**AMI (Amazon Machine Image)**
Imagen de máquina virtual que proporciona la información necesaria para lanzar una instancia EC2, incluyendo sistema operativo y configuraciones.

**API Gateway**
Servicio gestionado para crear, publicar, mantener, monitorear y proteger APIs RESTful y WebSocket.

**Application Load Balancer (ALB)**
Balanceador de carga de capa 7 (aplicación) que distribuye tráfico HTTP/HTTPS basado en reglas avanzadas.

**ARN (Amazon Resource Name)**
Identificador único para recursos de AWS con formato: `arn:partition:service:region:account-id:resource`.

**ASG (Auto Scaling Group)**
Grupo de instancias EC2 que se escalan automáticamente según demanda, manteniendo la salud del sistema.

**AWS AppConfig**
Servicio para gestionar configuraciones de aplicaciones y feature flags de forma segura.

**AWS Application Composer**
Herramienta visual para diseñar y construir aplicaciones serverless arrastrando y soltando componentes.

**AWS Audit Manager**
Servicio para evaluar continuamente el cumplimiento de regulaciones y estándares.

**AWS Artifact**
Portal para acceder a reportes de cumplimiento y acuerdos de seguridad de AWS.

**AWS Auto Scaling**
Servicio que permite escalar múltiples recursos automáticamente basado en métricas personalizadas.

---

## B

**Batch**
Servicio para ejecutar cargas de trabajo de computación a gran escala sin gestionar infraestructura.

**Bastion Host**
Servidor especial configurado para acceder a recursos en subnets privadas de forma segura.

**Block Storage**
Almacenamiento de bloques utilizado por EBS para proporcionar volúmenes persistentes a instancias EC2.

**Blue/Green Deployment**
Estrategia de despliegue que mantiene dos entornos idénticos, alternando entre ellos para minimizar downtime.

**BYOL (Bring Your Own License)**
Modelo de licenciamiento que permite usar licencias de software existentes en instancias AWS.

---

## C

**Canary Deployment**
Técnica de despliegue gradual que dirige una porción pequeña de tráfico a la nueva versión.

**CloudFormation**
Servicio de IaC (Infrastructure as Code) que permite modelar y provisionar recursos AWS usando templates YAML/JSON.

**CloudFront**
Red de distribución de contenido (CDN) que entrega datos, videos y APIs a usuarios con baja latencia.

**CloudTrail**
Servicio de gobernanza y auditoría que registra todas las actividades de la cuenta AWS.

**CloudWatch**
Servicio de observabilidad para monitorear métricas, logs y establecer alarmas.

**CodeCommit**
Servicio de control de versiones seguro y altamente escalable para alojar repositorios Git privados.

**CodeBuild**
Servicio de integración continua que compila código fuente, ejecuta tests y produce artefactos.

**CodeDeploy**
Servicio de despliegue automatizado para instancias EC2, Lambda, ECS y servidores on-premises.

**CodePipeline**
Servicio de entrega continua que automatiza pipelines de release.

**CodeStar**
Servicio unificado para desarrollo, creación rápida de proyectos con pipelines CI/CD integrados.

**Cognito**
Servicio de gestión de identidad y acceso para aplicaciones web y móviles.

**Cold Storage**
Almacenamiento de bajo costo para datos poco accedidos, típico en Glacier.

**Container**
Unidad estandarizada de software que empaqueta código y dependencias para ejecución consistente.

**CIDR (Classless Inter-Domain Routing)**
Notación para definir rangos de direcciones IP (ej: 10.0.0.0/16).

**Configuration Drift**
Diferencia entre el estado actual de recursos y su configuración definida en IaC.

**Connection Draining**
Característica de ELB que permite completar solicitudes en curso antes de eliminar instancias.

**Consolidated Billing**
Característica de AWS Organizations que permite combinar pagos de múltiples cuentas.

**Cost Explorer**
Herramienta para visualizar, entender y gestionar costos de AWS.

**Cross-Region Replication**
Replicación automática de buckets S3 entre diferentes regiones AWS.

---

## D

**DAX (DynamoDB Accelerator)**
Cache en memoria para DynamoDB que ofrece respuestas en microsegundos.

**Data Lake**
Repositorio de almacenamiento que contiene grandes volúmenes de datos en su formato nativo.

**Data Pipeline**
Servicio web para procesar y mover datos entre servicios AWS y on-premises.

**Data Transfer Out (DTO)**
Costo asociado a transferir datos fuera de los servicios AWS hacia internet o entre regiones.

**Dedicated Host**
Servidor físico EC2 dedicado para cumplir con requisitos de licenciamiento o compliance.

**Dedicated Instance**
Instancia EC2 que corre en hardware dedicado pero puede compartir hardware con otras instancias de la misma cuenta.

**Direct Connect**
Servicio para establecer conexión de red dedicada desde on-premises a AWS.

**DMS (Database Migration Service)**
Servicio para migrar bases de datos a AWS de forma segura y con mínimo downtime.

**DynamoDB**
Base de datos NoSQL clave-valor y documentos que ofrece rendimiento de milisegundos a cualquier escala.

**DynamoDB Streams**
Flujo ordenado de cambios de ítems en tablas DynamoDB, útil para triggers.

**DynamoDB Global Tables**
Tablas replicadas automáticamente entre múltiples regiones AWS.

**DX (Direct Connect)**
Abreviatura de AWS Direct Connect.

---

## E

**EBS (Elastic Block Store)**
Servicio de almacenamiento en bloques persistente para instancias EC2.

**EC2 (Elastic Compute Cloud)**
Servicio web que proporciona capacidad de computación redimensionable en la nube.

**ECR (Elastic Container Registry)**
Registro Docker seguro para almacenar, gestionar y desplegar imágenes de contenedores.

**ECS (Elastic Container Service)**
Servicio de orquestación de contenedores Docker completamente gestionado.

**EFS (Elastic File System)**
Servicio de almacenamiento de archivos NFS gestionado y escalable.

**EKS (Elastic Kubernetes Service)**
Servicio gestionado de Kubernetes para ejecutar contenedores sin operar el plano de control.

**ElastiCache**
Servicio de almacenamiento en caché compatible con Redis y Memcached.

**Elastic Beanstalk**
Servicio para desplegar y escalar aplicaciones web sin gestionar infraestructura.

**Elastic IP**
Dirección IPv4 estática diseñada para computación en la nube dinámica.

**Elastic Load Balancer (ELB)**
Balanceador de carga que distribuye tráfico entre múltiples destinos.

**EMR (Elastic MapReduce)**
Plataforma de big data para procesar grandes volúmenes de datos usando Hadoop, Spark, etc.

**ENI (Elastic Network Interface)**
Componente de red virtual que puede adjuntarse a instancias EC2.

**EventBridge**
Servicio de bus de eventos serverless para conectar aplicaciones mediante eventos.

**Fargate**
Tecnología serverless de computación para contenedores que elimina gestión de servidores.

---

## F

**Fargate**
Tecnología serverless para ejecutar contenedores sin gestionar servidores o clusters.

**Fault Tolerance**
Capacidad de un sistema para continuar operando cuando componentes fallan.

**FIFO Queue**
Cola SQS que garantiza orden estricto y entrega exactamente una vez.

**Flow Logs**
Característica para capturar información sobre tráfico de red en VPC.

---

## G

**Glacier**
Servicio de almacenamiento de archivos de bajo costo para archivado y backups a largo plazo.

**Glacier Deep Archive**
Opción de almacenamiento con el costo más bajo para datos raramente accedidos (12+ horas de recuperación).

**Glue**
Servicio de ETL serverless para preparar y transformar datos para análisis.

**Greengrass**
Servicio para ejecutar capacidades de AWS en dispositivos edge locales.

---

## H

**High Availability (HA)**
Diseño de sistema que garantiza disponibilidad mediante redundancia y tolerancia a fallos.

**Hot Standby**
Configuración de recuperación ante desastres donde el sistema de respaldo está activo y listo.

**Hybrid Cloud**
Infraestructura que combina cloud pública con cloud privada o on-premises.

---

## I

**IAM (Identity and Access Management)**
Servicio para gestionar usuarios, grupos, roles y políticas de acceso seguro.

**IGW (Internet Gateway)**
Componente VPC que permite comunicación entre VPC e Internet.

**Instance Store**
Almacenamiento de bloques temporal físicamente adjunto al host de EC2.

**IoT Core**
Plataforma gestionada para conectar dispositivos IoT de forma segura a la nube.

**IOPS (Input/Output Operations Per Second)**
Medida de rendimiento de almacenamiento, relevante para volúmenes EBS io1/io2.

---

## J

**JSON (JavaScript Object Notation)**
Formato de datos utilizado en APIs, plantillas CloudFormation y configuraciones.

---

## K

**Kinesis**
Plataforma para recolectar, procesar y analizar streams de datos en tiempo real.

**KMS (Key Management Service)**
Servicio gestionado para crear y controlar claves de encriptación.

---

## L

**Lambda**
Servicio de computación serverless que ejecuta código en respuesta a eventos sin gestionar servidores.

**Launch Configuration**
Plantilla que define configuración de instancias para Auto Scaling (obsoleto, usar Launch Templates).

**Launch Template**
Plantilla más reciente y flexible para definir configuraciones de lanzamiento de EC2.

**Latency**
Tiempo de respuesta entre solicitud y respuesta, crítico para aplicaciones interactivas.

**Lifecycle Hooks**
Puntos de pausa en Auto Scaling que permiten ejecutar acciones personalizadas durante transiciones.

**Load Balancer**
Servicio que distribuye tráfico entrante entre múltiples destinos para alta disponibilidad.

**Log Groups**
Agrupaciones de streams de logs en CloudWatch Logs.

---

## M

**Managed Service**
Servicio donde AWS gestiona la infraestructura subyacente, liberando al usuario de operaciones.

**Multi-AZ**
Despliegue de recursos en múltiples Availability Zones para alta disponibilidad.

**Multi-Tenancy**
Arquitectura donde múltiples usuarios (tenants) comparten recursos aislados.

**MX Record**
Registro DNS que especifica servidores de correo para un dominio.

---

## N

**NAT Gateway**
Servicio gestionado que permite instancias en subnets privadas conectarse a Internet.

**NAT Instance**
Instancia EC2 configurada como NAT (alternativa al NAT Gateway gestionado).

**Network ACL (NACL)**
Firewall a nivel de subnet que controla tráfico entrante y saliente.

**Network Load Balancer (NLB)**
Balanceador de carga de capa 4 (transporte) para TCP/UDP/TLS con alta performance.

**NFS (Network File System)**
Protocolo de compartición de archivos utilizado por EFS.

**NIST**
Instituto Nacional de Estándares y Tecnología de EE.UU., define estándares de seguridad.

---

## O

**Object Storage**
Arquitectura de almacenamiento donde datos se gestionan como objetos (S3).

**On-Demand**
Modelo de precios donde se paga por recurso utilizado sin compromisos.

**Organization**
Servicio para consolidar múltiples cuentas AWS con facturación centralizada y políticas.

**Origin**
Servidor fuente de contenido en CloudFront (S3, ELB, servidor HTTP).

**Outposts**
Servicio que extiente infraestructura AWS a centros de datos on-premises.

---

## P

**Parameter Store**
Servicio de AWS Systems Manager para almacenar datos de configuración y secretos.

**Peering Connection**
Conexión de red entre dos VPCs para permitir comunicación privada.

**Pilot Light**
Estrategia de DR donde core mínimo siempre corre en región secundaria.

**Placement Group**
Agrupación lógica de instancias para optimizar rendimiento de red o hardware.

**Policy**
Documento JSON que define permisos en IAM, S3, etc.

**Private Subnet**
Subnet sin ruta a Internet Gateway, usada para recursos internos.

**Public Subnet**
Subnet con ruta a Internet Gateway para recursos accesibles públicamente.

---

## Q

**Queue**
Estructura de datos FIFO (First In, First Out) utilizada por SQS para desacoplamiento.

**QuickSight**
Servicio de inteligencia empresarial (BI) para crear dashboards y análisis.

---

## R

**RDS (Relational Database Service)**
Servicio gestionado de bases de datos relacionales (MySQL, PostgreSQL, Oracle, SQL Server, MariaDB).

**Read Replica**
Copia de solo lectura de base de datos RDS para escalar consultas.

**Region**
Área geográfica que contiene múltiples Availability Zones.

**Reserved Instances**
Modelo de precios con descuento por compromiso de uso a largo plazo.

**Resource**
Cualquier entidad AWS que puede ser creada y gestionada (EC2, S3, IAM, etc.).

**Route 53**
Servicio DNS escalable y gestionado con enrutamiento inteligente.

**Route Table**
Tabla de rutas que controla direccionamiento de tráfico en VPC.

---

## S

**S3 (Simple Storage Service)**
Servicio de almacenamiento de objetos escalable y duradero.

**S3 Glacier**
Servicio de archivado de bajo costo con diferentes tiempos de recuperación.

**S3 Intelligent-Tiering**
Clase de almacenamiento que mueve objetos automáticamente según patrones de acceso.

**SageMaker**
Servicio gestionado para construir, entrenar y desplegar modelos de machine learning.

**Savings Plans**
Modelo de precios flexible con descuento por compromiso de uso de computación.

**SCP (Service Control Policy)**
Políticas de IAM que definen límites de permisos para cuentas en Organizations.

**Secret Manager**
Servicio para rotar, gestionar y recuperar secretos (contraseñas, API keys).

**Security Group**
Firewall virtual a nivel de instancia que controla tráfico entrante y saliente.

**Serverless**
Modelo de computación donde AWS gestiona la infraestructura completamente.

**Service Catalog**
Servicio para crear y gestionar catálogos de productos IT aprobados.

**Session Manager**
Herramienta de Systems Manager para acceder a instancias sin SSH bastion.

**SNS (Simple Notification Service)**
Servicio de mensajería pub/sub para notificaciones push.

**Spot Instances**
Instancias EC2 de capacidad sobrante con descuentos hasta 90%.

**SQS (Simple Queue Service)**
Servicio de colas de mensajes gestionado para desacoplamiento de componentes.

**SSE (Server-Side Encryption)**
Encriptación de datos gestionada por el servidor (S3, EBS, etc.).

**SSM (Systems Manager)**
Servicio unificado para gestionar recursos AWS y operaciones.

**Step Functions**
Servicio para orquestar workflows visuales de múltiples servicios AWS.

**Storage Gateway**
Servicio híbrido que conecta almacenamiento on-premises con la nube.

**Subnet**
Segmento de red IP dentro de una VPC.

---

## T

**Tag**
Etiqueta de metadatos (clave-valor) para organizar y categorizar recursos AWS.

**Target Group**
Grupo de destinos (instancias, IPs, Lambda) para balanceadores de carga.

**Terraform**
Herramienta IaC de terceros para gestionar infraestructura cloud.

**Throttling**
Limitación de solicitudes para proteger servicios de sobrecarga.

**Throughput**
Tasa de transferencia de datos procesados por unidad de tiempo.

**TLS (Transport Layer Security)**
Protocolo criptográfico para comunicaciones seguras (sucesor de SSL).

**Trail**
Configuración de CloudTrail que registra eventos y los entrega a S3.

**Transit Gateway**
Servicio de red que conecta VPCs y redes on-premises mediante una gateway central.

---

## U

**User Pool**
Directorio de usuarios en Cognito para autenticación y registro.

---

## V

**VPC (Virtual Private Cloud)**
Red virtual aislada lógicamente dentro de AWS para desplegar recursos.

**VPC Endpoint**
Gateway privada para conectar VPC a servicios AWS sin salir a Internet.

**VPN Connection**
Conexión encriptada entre VPC y red on-premises.

**Volume**
Unidad de almacenamiento EBS que se adjunta a instancias EC2.

---

## W

**Warm Standby**
Estrategia de DR donde réplica reducida de la aplicación siempre corre en standby.

**Web Application Firewall (WAF)**
Firewall que protege aplicaciones web contra exploits comunes.

**WorkSpaces**
Servicio de escritorio virtual gestionado (VDI) en la nube.

---

## X

**X-Ray**
Servicio de trazas distribuidas para analizar y debuggear aplicaciones.

---

## Y

**YAML**
Formato de serialización de datos utilizado en CloudFormation y configuraciones.

---

## Z

**Zero Trust**
Modelo de seguridad que asume que nadie es confiable por defecto.

**Zone**
En Route 53, dominio DNS gestionado con sus registros.

---

## Acrónimos Comunes

| Acrónimo | Significado |
|----------|-------------|
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

*Última actualización: Abril 2025*
