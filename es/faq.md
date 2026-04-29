# Preguntas Frecuentes (FAQ)

> **Respuestas a las preguntas más comunes sobre AWS, organizadas por categoría**

---

## General

### ¿Qué es AWS?
AWS (Amazon Web Services) es una plataforma de servicios de computación en la nube que ofrece más de 200 servicios completos de infraestructura, almacenamiento, bases de datos, redes, inteligencia artificial, IoT y más desde centros de datos distribuidos globalmente.

### ¿Cuántos servicios ofrece AWS?
AWS ofrece más de 200 servicios completos que cubren cómputo, almacenamiento, bases de datos, redes, análisis, machine learning, IoT, seguridad, y herramientas de desarrollo.

### ¿Qué es el modelo de responsabilidad compartida de AWS?
Es un modelo de seguridad donde AWS es responsable de la **seguridad DE la nube** (infraestructura, hardware, red) y el cliente es responsable de la **seguridad EN la nube** (datos, configuraciones, accesos, encriptación).

### ¿Qué es la capa gratuita de AWS?
La capa gratuita (Free Tier) incluye servicios con límites mensuales gratuitos durante los primeros 12 meses, además de servicios siempre gratuitos como Lambda (1M solicitudes/mes), CloudWatch (10 métricas personalizadas), y DynamoDB (25 GB almacenamiento).

### ¿Cómo calculo los costos de AWS antes de usar un servicio?
Usa la **AWS Pricing Calculator** para estimar costos basados en tu arquitectura. También puedes usar **AWS Cost Explorer** para analizar gastos actuales y **AWS Budgets** para establecer alertas de presupuesto.

---

## Compute (EC2, Lambda, ECS, EKS)

### ¿Cuál es la diferencia entre EC2 On-Demand, Reserved y Spot?
- **On-Demand**: Pago por hora sin compromisos, ideal para cargas variables
- **Reserved**: Descuento hasta 72% por compromiso de 1-3 años, ideal para cargas predecibles
- **Spot**: Descuento hasta 90% usando capacidad sobrante, ideal para cargas tolerantes a interrupciones
- **Savings Plans**: Descuento flexible por compromiso de uso de computación por 1-3 años

### ¿Cuándo debo usar Lambda vs EC2?
- **Lambda**: Ideal para eventos cortos (<15 min), serverless, pago por ejecución, auto-scaling instantáneo
- **EC2**: Ideal para aplicaciones de larga duración, control total del SO, casos de uso específicos de hardware

### ¿Qué es Auto Scaling?
Es un servicio que automáticamente ajusta la cantidad de recursos EC2 basándose en demanda, manteniendo la salud del sistema y optimizando costos.

### ¿Cuál es la diferencia entre ECS y EKS?
- **ECS**: Servicio de contenedores propietario de AWS, más simple, integración nativa, sin costo adicional
- **EKS**: Servicio gestionado de Kubernetes, compatible con herramientas de ecosistema Kubernetes, tiene costo por cluster ($0.10/hora)

### ¿Qué es Fargate?
Fargate es una tecnología serverless para contenedores que elimina la necesidad de gestionar servidores o clusters. Funciona con ECS y EKS.

### ¿Cómo elijo el tipo de instancia EC2 correcta?
Considera:
- **Propósito**: Propósito general (T, M), Computación optimizada (C), Memoria optimizada (R, X), GPU (P, G)
- **Carga de trabajo**: Burstable (T3/T4g) para baja utilización, Sustained (M6i) para alta utilización
- **Costo**: Graviton (ARM) ofrece 40% mejor precio/rendimiento que x86

---

## Storage (S3, EBS, EFS)

### ¿Cuándo usar S3 vs EBS vs EFS?
- **S3**: Almacenamiento de objetos para archivos, backups, websites estáticos, acceso mediante HTTP
- **EBS**: Almacenamiento en bloques para sistemas de archivos de instancias EC2, baja latencia
- **EFS**: Sistema de archivos NFS compartido entre múltiples instancias EC2, escalable

### ¿Cuál es la diferencia entre S3 Standard, IA y Glacier?
- **Standard**: Acceso frecuente, 99.99% disponibilidad
- **Standard-IA**: Acceso poco frecuente, 40% menor costo que Standard
- **Glacier Instant Retrieval**: Archivado con recuperación en ms
- **Glacier Flexible Retrieval**: Archivado, recuperación de minutos a horas
- **Glacier Deep Archive**: Archivado de largo plazo, recuperación de 12+ horas

### ¿Cómo protejo datos en S3?
- **Encriptación**: SSE-S3, SSE-KMS, SSE-C, o encriptación cliente
- **Versionado**: Mantener múltiples versiones de objetos
- **Bloqueo de acceso público**: Prevenir acceso accidental
- **MFA Delete**: Requerir MFA para eliminación
- **Políticas de bucket**: Control granular de acceso
- **S3 Object Lock**: Prevenir eliminación durante período de retención

### ¿Qué es S3 Intelligent-Tiering?
Clase de almacenamiento que automáticamente mueve objetos entre tiers de acceso frecuente e infrecuente basándose en patrones de acceso, optimizando costos sin impacto en performance.

### ¿Puedo aumentar el tamaño de un volumen EBS?
Sí, los volúmenes EBS pueden aumentarse dinámicamente sin detener la instancia. Sin embargo, debes extender el sistema de archivos dentro del SO para usar el espacio adicional.

---

## Databases (RDS, DynamoDB, ElastiCache)

### ¿Cuándo usar RDS vs DynamoDB?
- **RDS**: Bases de datos relacionales (MySQL, PostgreSQL), consultas complejas, joins, transacciones ACID
- **DynamoDB**: NoSQL clave-valor, escalabilidad masiva, latencia predecible (<10ms), serverless

### ¿Qué es Multi-AZ en RDS?
Configuración que replica automáticamente la base de datos en múltiples Availability Zones para alta disponibilidad. Si falla la instancia principal, RDS fail-over automáticamente a la réplica en otra AZ.

### ¿Cómo escalo DynamoDB?
- **Modo Provisioned**: Especificar RCU/WCU (Read/Write Capacity Units)
- **Modo On-Demand**: Pago por solicitud, auto-scaling ilimitado
- **DAX**: Cache en memoria para lecturas de microsegundos
- **Global Tables**: Replicación multi-región

### ¿Qué es ElastiCache?
Servicio de almacenamiento en caché compatible con Redis y Memcached. Mejora performance de aplicaciones al almacenar datos frecuentemente accedidos en memoria.

### ¿Cómo migro una base de datos on-premises a AWS?
Opciones incluyen:
- **AWS DMS**: Servicio gestionado de migración con replicación continua
- **AWS SCT**: Convierte esquemas de bases de datos
- **Export/Import**: Para bases de datos pequeñas
- **Snapshots**: Para RDS compatible

---

## Networking (VPC, Route 53, CloudFront)

### ¿Qué es una VPC?
Virtual Private Cloud (VPC) es una red virtual aislada lógicamente dentro de AWS donde puedes desplegar recursos con control completo sobre direccionamiento IP, subredes, tablas de rutas y gateways.

### ¿Cuál es la diferencia entre subnet pública y privada?
- **Pública**: Tiene ruta a Internet Gateway, puede recibir tráfico entrante de internet
- **Privada**: Sin ruta a Internet Gateway, solo puede acceder a internet mediante NAT Gateway

### ¿Necesito NAT Gateway para cada AZ?
Para alta disponibilencia, recomiendan NAT Gateways en cada AZ usada. Los NAT Gateways son zonales y no redundantes entre AZs.

### ¿Qué es CloudFront?
Red de distribución de contenido (CDN) que entrega datos a usuarios con baja latencia mediante una red global de edge locations que cachean contenido cerca de los usuarios.

### ¿Cómo funciona Route 53?
Servicio DNS gestionado que:
- Registra y gestiona dominios
- Resuelve nombres de dominio a direcciones IP
- Ofrece enrutamiento inteligente (geográfico, latencia, failover)
- Realiza health checks

### ¿Qué es Direct Connect?
Servicio que establece una conexión de red dedicada y privada desde tu centro de datos a AWS, ofreciendo mayor ancho de banda, menor latencia y conexión más consistente que internet.

---

## Security (IAM, KMS, WAF)

### ¿Qué es IAM y por qué es importante?
Identity and Access Management (IAM) es el servicio para controlar quién puede acceder a qué recursos en AWS. Es fundamental para la seguridad porque:
- Implementa principio de mínimo privilegio
- Permite autenticación multifactor (MFA)
- Soporta roles para acceso temporal
- Facilita auditoría con CloudTrail

### ¿Cuál es la diferencia entre usuarios IAM y roles IAM?
- **Usuarios IAM**: Para personas o aplicaciones que necesitan acceso persistente, tienen credenciales de largo plazo
- **Roles IAM**: Para acceso temporal, usados por servicios AWS, aplicaciones o usuarios federados, sin credenciales permanentes

### ¿Cómo roto secretos de forma segura?
- **AWS Secrets Manager**: Rotación automática con Lambda
- **Parameter Store**: Rotación manual con versiones
- **Rotación programada**: Establecer períodos de rotación regulares
- **Uso de roles**: Preferir roles sobre credenciales de largo plazo

### ¿Qué es KMS?
Key Management Service (KMS) es un servicio gestionado para crear y controlar claves de encriptación usadas para proteger datos en AWS.

### ¿Cómo protejo mi aplicación web en AWS?
- **WAF**: Filtrar tráfico malicioso
- **Shield**: Protección DDoS
- **CloudFront**: Protección de origen, edge locations
- **Security Groups**: Firewall a nivel de instancia
- **NACLs**: Firewall a nivel de subnet
- **ACM**: Certificados SSL/TLS gratuitos

### ¿Qué son las SCP en AWS Organizations?
Service Control Policies (SCP) son políticas que establecen los permisos máximos disponibles para las cuentas en una organización, actuando como guardrails de seguridad.

---

## DevOps (CloudFormation, CodePipeline, Systems Manager)

### ¿Qué es Infrastructure as Code (IaC)?
Práctica de gestionar infraestructura mediante código y archivos de configuración en lugar de procesos manuales, permitiendo versionado, replicación y automatización.

### ¿CloudFormation vs Terraform?
- **CloudFormation**: Servicio nativo de AWS, gratuito, integración profunda, templates YAML/JSON
- **Terraform**: Multi-cloud, sintaxis HCL, state management, provider ecosystem amplio

### ¿Cómo implemento CI/CD en AWS?
Servicios principales:
- **CodeCommit**: Repositorios Git privados
- **CodeBuild**: Compilación y testing
- **CodeDeploy**: Despliegue automatizado
- **CodePipeline**: Orquestación de pipeline
Alternativa: Usar GitHub Actions, GitLab CI, o Jenkins con ECS/EKS.

### ¿Qué es Systems Manager (SSM)?
Servicio unificado para gestionar recursos AWS y on-premises, incluyendo:
- **Session Manager**: Acceso a instancias sin SSH/RDP
- **Parameter Store**: Almacenamiento de configuraciones y secretos
- **Patch Manager**: Gestión de parches
- **Automation**: Runbooks de automatización
- **Inventory**: Inventario de recursos

### ¿Cómo gestiono configuraciones en múltiples entornos?
- **Parameter Store**: Jerarquía de parámetros por entorno
- **Environment variables**: Configuración por Lambda/ECS
- **Config files**: En S3 o repositorio
- **Feature flags**: AWS AppConfig para gestión de características

---

## Monitoring (CloudWatch, X-Ray)

### ¿Qué puedo monitorear con CloudWatch?
- **Métricas**: CPU, memoria, disco, red de recursos AWS
- **Logs**: Logs de aplicaciones, sistema, flujos personalizados
- **Eventos**: Cambios en recursos, eventos de servicios
- **Alarms**: Notificaciones basadas en umbrales de métricas
- **Dashboards**: Visualizaciones personalizadas

### ¿Qué es CloudWatch Logs Insights?
Herramienta para consultar y analizar logs mediante un lenguaje de consulta especializado, con agregaciones, filtros y visualizaciones.

### ¿Cómo implemento distributed tracing?
- **X-Ray**: Trazas de solicitudes distribuidas
- **Instrumentación**: SDKs para Java, Node.js, Python, Go, .NET
- **Service Maps**: Visualización de dependencias
- **Subsegments**: Detalle de operaciones internas
- **Annotations**: Metadata para búsqueda y filtrado

### ¿Cómo configuro alarmas efectivas?
- **Umbrales realistas**: Basados en baseline de métricas
- **Acciones múltiples**: SNS para notificaciones, Lambda para auto-remediación
- **Periodos adecuados**: Evitar alarmas por picos temporales
- **Métricas compuestas**: Combinar múltiples condiciones
- **Alarmas de anomalías**: Basadas en machine learning

---

## Machine Learning (SageMaker, AI Services)

### ¿Qué es Amazon SageMaker?
Servicio gestionado para el ciclo completo de machine learning: preparación de datos, entrenamiento, tuning, deployment y monitoring de modelos.

### ¿Qué servicios de IA lista para usar ofrece AWS?
- **Rekognition**: Análisis de imagen y video
- **Polly**: Texto a voz
- **Transcribe**: Voz a texto
- **Translate**: Traducción automática
- **Comprehend**: Procesamiento de lenguaje natural
- **Personalize**: Sistemas de recomendación
- **Lex**: Chatbots y asistentes virtuales
- **Kendra**: Búsqueda empresarial inteligente

### ¿Cómo entreno modelos de ML en AWS?
- **SageMaker Studio**: IDE para ML
- **SageMaker Training**: Entrenamiento distribuido
- **SageMaker Autopilot**: AutoML
- **SageMaker JumpStart**: Modelos pre-entrenados
- **EC2 con GPUs**: Instancias P3/P4 para entrenamiento

---

## Cost Optimization

### ¿Cómo reduzco costos en AWS?
Estrategias principales:
- **Reserved Instances/Savings Plans**: Para cargas predecibles
- **Spot Instances**: Para cargas tolerantes a interrupciones
- **Right-sizing**: Seleccionar instancias apropiadas
- **Storage optimization**: Mover datos a clases de almacenamiento correctas
- **Auto Scaling**: Escalar según demanda
- **Serverless**: Lambda para cargas intermitentes

### ¿Qué es Cost Explorer?
Herramienta para visualizar, analizar y gestionar costos de AWS con reports personalizados, filtering por tags, servicios y períodos.

### ¿Cómo asigno costos a equipos/proyectos?
- **Tags**: Etiquetar todos los recursos
- **Cost Allocation Tags**: Activar en Billing Console
- **AWS Organizations**: Consolidar facturación
- **Cost Categories**: Agrupar costos lógicamente
- **Budgets**: Establecer límites por equipo/proyecto

### ¿Qué es AWS Billing Conductor?
Servicio para crear precios personalizados y generar reportes de facturación para clientes internos o externos (resellers, ISVs).

---

## Architecture & Best Practices

### ¿Qué es el Well-Architected Framework?
Marco de AWS con 6 pilares para evaluar arquitecturas:
1. Excelencia Operacional
2. Seguridad
3. Fiabilidad
4. Eficiencia de Performance
5. Optimización de Costos
6. Sostenibilidad

### ¿Qué es el AWS Well-Architected Tool?
Herramienta gratuita para revisar arquitecturas contra las mejores prácticas, identificar riesgos y obtener recomendaciones.

### ¿Cómo diseño para alta disponibilidad?
- **Multi-AZ**: Distribuir en múltiples AZs
- **Multi-Region**: Para recuperación ante desastres
- **Auto Scaling**: Responder a cambios de demanda
- **Load Balancers**: Distribuir tráfico
- **Health checks**: Detectar y reemplazar componentes fallidos
- **Circuit breakers**: Prevenir cascadas de fallos

### ¿Qué es Chaos Engineering?
Práctica de inyectar fallos controlados en sistemas para validar resiliencia. AWS ofrece **AWS Fault Injection Simulator (FIS)** para este propósito.

### ¿Cómo implemento Disaster Recovery?
Estrategias en orden de menor a mayor costo/RTO:
- **Backup & Restore**: Backups en S3/Glacier, restauración manual
- **Pilot Light**: Core mínimo siempre corriendo
- **Warm Standby**: Réplica reducida siempre activa
- **Multi-Site Active/Active**: Full deployment en múltiples regiones

---

## Certifications

### ¿Qué certificaciones ofrece AWS?
Niveles:
- **Cloud Practitioner**: Nivel fundacional
- **Associate**: Solutions Architect, Developer, SysOps Administrator
- **Professional**: Solutions Architect, DevOps Engineer
- **Specialty**: Security, Machine Learning, Database, Networking, etc.

### ¿Por dónde empiezo con certificaciones AWS?
Ruta recomendada:
1. **Cloud Practitioner**: Fundamentos generales
2. **Solutions Architect Associate**: Diseño de arquitecturas
3. **Developer Associate**: Desarrollo de aplicaciones
4. **SysOps Administrator Associate**: Operaciones
5. **Professional-level**: Según tu rol

### ¿Qué recursos uso para prepararme?
- **AWS Skill Builder**: Cursos oficiales gratuitos y de pago
- **AWS Documentation**: Whitepapers y FAQs
- **AWS Workshops**: Laboratorios prácticos
- **Practice exams**: Exámenes de práctica oficiales

---

*Última actualización: Abril 2025*
