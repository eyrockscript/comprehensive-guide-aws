# Capítulo 1: Fundamentos de AWS y Computación en la Nube

## Resumen Ejecutivo

La adopción de servicios de computación en la nube ha revolucionado la forma en que las organizaciones desarrollan, implementan y gestionan recursos de TI. Amazon Web Services (AWS) lidera este mercado ofreciendo un amplio catálogo de servicios que permiten a las empresas de todos los tamaños beneficiarse de infraestructuras escalables, flexibles y rentables. Este whitepaper introduce los conceptos fundamentales de AWS y la computación en la nube, proporcionando una base sólida para comprender su potencial transformador para las organizaciones.

## Introducción a la Computación en la Nube

La computación en la nube se refiere al suministro de recursos informáticos (servidores, almacenamiento, bases de datos, redes, software) a través de internet, con un modelo de pago por uso. Este modelo elimina la necesidad de grandes inversiones iniciales en hardware y reduce significativamente el tiempo necesario para aprovisionar y escalar recursos.

### Beneficios Clave de la Computación en la Nube

- **Agilidad:** Implementación rápida de recursos tecnológicos cuando se necesitan
- **Elasticidad:** Capacidad de escalar automáticamente según demanda
- **Reducción de costos:** Cambio de gastos de capital (CAPEX) a gastos operativos (OPEX)
- **Alcance global:** Despliegue mundial en minutos
- **Innovación acelerada:** Foco en desarrollo en lugar de gestión de infraestructura

## Modelos de Servicio en la Nube

AWS ofrece servicios que abarcan los tres principales modelos de servicio en la nube:

### 1. Infraestructura como Servicio (IaaS)
Proporciona recursos informáticos virtualizados a través de internet. Los clientes gestionan sistemas operativos, aplicaciones y datos, mientras que el proveedor se encarga del hardware físico.

**Ejemplos en AWS:** EC2 (máquinas virtuales), S3 (almacenamiento de objetos), EBS (almacenamiento en bloques)

### 2. Plataforma como Servicio (PaaS)
Ofrece hardware y software necesarios para desarrollar aplicaciones. Los clientes se concentran en el desarrollo y despliegue de aplicaciones sin preocuparse por la infraestructura subyacente.

**Ejemplos en AWS:** Elastic Beanstalk, AWS App Runner, Amazon Lightsail

### 3. Software como Servicio (SaaS)
Aplicaciones completas accesibles a través de internet, eliminando necesidades de instalación, mantenimiento y actualizaciones.

**Ejemplos en AWS:** Amazon WorkMail, Amazon Connect, Amazon Chime

## Infraestructura Global de AWS

La infraestructura de AWS está diseñada para ofrecer alta disponibilidad, tolerancia a fallos y escalabilidad global.

### Regiones de AWS

AWS opera en múltiples regiones geográficas en todo el mundo. Cada región es un área geográfica separada que contiene múltiples centros de datos aislados. Las regiones están completamente aisladas entre sí, lo que proporciona:

- Tolerancia a fallos y estabilidad
- Cumplimiento de requisitos de residencia de datos
- Latencia reducida para usuarios finales
- Redundancia global

### Zonas de Disponibilidad (AZ)

Cada región de AWS contiene múltiples zonas de disponibilidad (generalmente tres o más). Cada zona:

- Consiste en uno o más centros de datos físicamente separados
- Tiene infraestructura de energía, refrigeración y redes independientes
- Está conectada a otras zonas mediante enlaces de baja latencia y alto ancho de banda
- Permite arquitecturas de alta disponibilidad

### Puntos de Presencia (PoP)

Red global de ubicaciones Edge que complementan las regiones:

- Amazon CloudFront (CDN)
- Amazon Route 53 (DNS)
- AWS Global Accelerator
- AWS Direct Connect

## Principios Fundamentales en AWS

### Well-Architected Framework

AWS ha desarrollado el Well-Architected Framework como conjunto de mejores prácticas para diseñar y operar sistemas confiables, seguros, eficientes y rentables. El framework se basa en seis pilares:

1. **Excelencia operativa:** Ejecución y monitoreo eficientes
2. **Seguridad:** Protección de información y sistemas
3. **Fiabilidad:** Capacidad de recuperación ante fallos
4. **Eficiencia de rendimiento:** Uso eficiente de recursos
5. **Optimización de costos:** Evitar gastos innecesarios
6. **Sostenibilidad:** Minimizar impacto ambiental

### Shared Responsibility Model

La seguridad y el cumplimiento son responsabilidades compartidas entre AWS y el cliente:

- **AWS:** Responsable de la seguridad "de" la nube (infraestructura física, virtualización, etc.)
- **Cliente:** Responsable de la seguridad "en" la nube (configuración, datos, accesos, etc.)

## Primeros Pasos con AWS

### AWS Management Console

Portal web para acceder y gestionar servicios AWS. Proporciona una interfaz gráfica intuitiva para:

- Crear y configurar recursos
- Monitorear servicios
- Ver facturación y gestionar costos

### AWS CLI

Herramienta de línea de comandos unificada para interactuar con los servicios AWS desde scripts o terminal.

### AWS SDKs

Bibliotecas para diferentes lenguajes de programación (Python, Java, .NET, JavaScript, etc.) que facilitan la integración con servicios AWS.

## Estrategias de Adopción de la Nube

### Migración de Cargas de Trabajo

Existen diferentes estrategias para migrar aplicaciones existentes a AWS:

1. **Rehosting (lift-and-shift):** Migración directa sin cambios
2. **Replatforming:** Optimizaciones menores manteniendo la arquitectura principal
3. **Refactoring/Re-architecting:** Reimaginación de la aplicación aprovechando capacidades nativas de la nube
4. **Repurchasing:** Cambio a soluciones SaaS
5. **Retire:** Eliminación de aplicaciones no necesarias
6. **Retain:** Mantenimiento temporal en entorno local

### Cultura y Cambio Organizacional

La adopción efectiva de la nube requiere:

- Capacitación continua
- Nuevos roles y responsabilidades
- Adopción de metodologías ágiles
- Cultura DevOps

## Casos de Éxito en Migración a la Nube

### Netflix: De Data Centers a AWS

**Situación:** Netflix operaba su propia infraestructura en data centers, enfrentando limitaciones de escalabilidad y tiempos de aprovisionamiento prolongados.

**Solución:** Migración completa a AWS aprovechando servicios como EC2, S3 y CloudFront.

**Resultados:**
- Capacidad de atender más de 230 millones de suscriptores globalmente
- Despliegue de miles de instancias en minutos para picos de demanda
- Reducción de costos operativos en un 70%
- Mejora en disponibilidad del 99.99%

**Factores Clave:**
- Arquitectura de microservicios distribuidos
- Uso extensivo de Auto Scaling
- Implementación de multi-AZ y multi-región

### Airbnb: Escalabilidad para Eventos de Alto Impacto

**Situación:** Startup con crecimiento explosivo necesitaba infraestructura que pudiera escalar de 0 a millones de usuarios en horas.

**Solución:** Arquitectura serverless-first con Lambda, API Gateway y DynamoDB.

**Resultados:**
- Capacidad de manejar tráfico 10x sin intervención manual
- Reducción de tiempo de despliegue de semanas a minutos
- Optimización de costos en un 60% vs infraestructura tradicional

### Epic Games: Infraestructura para Gaming Global

**Situación:** Lanzamiento de Fortnite requería infraestructura capaz de soportar millones de jugadores concurrentes.

**Solución:** Uso de GameLift, DynamoDB Global Tables y CloudFront.

**Resultados:**
- Soporte para 125 millones de jugadores concurrentes
- Latencia reducida a menos de 20ms para matchmaking
- Escalado automático durante eventos especiales

## Templates Seguros para Inicio de Proyectos

### Template de VPC Base Segura

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'VPC Base Segura para Proyectos AWS'

Parameters:
  EnvironmentName:
    Type: String
    Default: Production
    AllowedValues: [Development, Staging, Production]
  VpcCidr:
    Type: String
    Default: 10.0.0.0/16
    AllowedPattern: ^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/([0-9]|[1-2][0-9]|3[0-2])$

Resources:
  VPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: !Ref VpcCidr
      EnableDnsHostnames: true
      EnableDnsSupport: true
      Tags:
        - Key: Name
          Value: !Ref EnvironmentName
        - Key: Environment
          Value: !Ref EnvironmentName

  InternetGateway:
    Type: AWS::EC2::InternetGateway
    Properties:
      Tags:
        - Key: Name
          Value: !Ref EnvironmentName

  InternetGatewayAttachment:
    Type: AWS::EC2::VPCGatewayAttachment
    Properties:
      InternetGatewayId: !Ref InternetGateway
      VpcId: !Ref VPC

  # Subredes públicas con NAT Gateway
  PublicSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: !Select [0, !Cidr [!Ref VpcCidr, 6, 8]]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName} Public Subnet (AZ1)

  PublicSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [1, !GetAZs '']
      CidrBlock: !Select [1, !Cidr [!Ref VpcCidr, 6, 8]]
      MapPublicIpOnLaunch: true
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName} Public Subnet (AZ2)

  # Subredes privadas para workloads
  PrivateSubnet1:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [0, !GetAZs '']
      CidrBlock: !Select [2, !Cidr [!Ref VpcCidr, 6, 8]]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName} Private Subnet (AZ1)

  PrivateSubnet2:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref VPC
      AvailabilityZone: !Select [1, !GetAZs '']
      CidrBlock: !Select [3, !Cidr [!Ref VpcCidr, 6, 8]]
      MapPublicIpOnLaunch: false
      Tags:
        - Key: Name
          Value: !Sub ${EnvironmentName} Private Subnet (AZ2)

  # Security Group base restrictivo
  DefaultSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupName: !Sub ${EnvironmentName}-base-sg
      GroupDescription: Security Group base con acceso restringido
      VpcId: !Ref VPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
          Description: HTTPS inbound
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
          Description: Allow all outbound

Outputs:
  VPCId:
    Description: ID de la VPC creada
    Value: !Ref VPC
    Export:
      Name: !Sub ${EnvironmentName}-VPCID

  PrivateSubnets:
    Description: Lista de subnets privadas
    Value: !Join [',', [!Ref PrivateSubnet1, !Ref PrivateSubnet2]]
```

### Template de IAM Roles Base

```json
{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Description": "Roles IAM base seguros",
  "Resources": {
    "EC2InstanceRole": {
      "Type": "AWS::IAM::Role",
      "Properties": {
        "AssumeRolePolicyDocument": {
          "Version": "2012-10-17",
          "Statement": [{
            "Effect": "Allow",
            "Principal": {"Service": "ec2.amazonaws.com"},
            "Action": "sts:AssumeRole"
          }]
        },
        "ManagedPolicyArns": [
          "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
          "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        ],
        "Policies": [{
          "PolicyName": "S3LimitedAccess",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [{
              "Effect": "Allow",
              "Action": [
                "s3:GetObject",
                "s3:PutObject"
              ],
              "Resource": "arn:aws:s3:::company-data-${AWS::AccountId}/*",
              "Condition": {
                "StringEquals": {
                  "s3:x-amz-acl": "bucket-owner-full-control"
                }
              }
            }]
          }
        }]
      }
    }
  }
}
```

## Árbol de Decisiones: ¿Migrar a la Nube?

```
¿Tiene su organización necesidades de escalabilidad impredecibles?
│
├─ SÍ → La nube ofrece elasticidad automática sin inversión en capacidad ociosa
│   │
│   ├─ ¿Requiere despliegue global rápido?
│   │   ├─ SÍ → AWS tiene 30+ regiones para despliegue en minutos
│   │   └─ NO → Beneficios de escalabilidad local aún aplican
│   │
│   └─ ¿Tiene picos estacionales de tráfico?
│       ├─ SÍ → Auto Scaling optimiza costos vs capacidad fija
│       └─ NO → Elasticidad útil para crecimiento orgánico
│
├─ NO → Evaluar otros beneficios
│   │
│   ├─ ¿Busca reducir costos operativos?
│   │   ├─ SÍ → Modelo pay-as-you-go elimina CAPEX
│   │   └─ NO → Ver otros factores
│   │
│   ├─ ¿Necesita alta disponibilidad?
│   │   ├─ SÍ → Multi-AZ y multi-región nativos
│   │   └─ NO → Ver opciones single-region
│   │
│   └─ ¿Quiere acelerar innovación?
│       ├─ SÍ + Necesita experimentación rápida
│       │   ├─ SÍ → Servicios managed reducen time-to-market
│       │   └─ NO → Beneficios de automatización e IaC
│       └─ NO → Evaluar si on-premises sigue siendo viable
│
└─ ¿Tiene requisitos de soberanía de datos estrictos?
    ├─ SÍ → Verificar disponibilidad de región local AWS
    │   ├─ SÍ → AWS puede cumplir con regulaciones locales
    │   └─ NO → Considerar modelos híbridos con Outposts
    └─ NO → Migración viable sin restricciones adicionales
```

### Matriz de Decisión por Estrategia de Migración

| Criterio | Rehost | Replatform | Refactor | Retire |
|----------|--------|------------|----------|--------|
| **Tiempo disponible** | < 3 meses | 3-6 meses | > 6 meses | Inmediato |
| **Presupuesto** | Limitado | Moderado | Alto | N/A |
| **Complejidad técnica** | Baja | Media | Alta | N/A |
| **Valor a largo plazo** | Bajo | Medio | Alto | N/A |
| **Requisitos de negocio** | Continuidad | Mejora | Transformación | Eliminación |

## Calculadora de Costos de Migración

### Factores de Costo a Considerar

**Costos de Migración (Una vez):**
- Análisis y planificación: $10,000 - $50,000
- Ejecución de migración: $5,000 - $100,000+
- Capacitación del equipo: $5,000 - $25,000
- Optimización post-migración: $10,000 - $30,000

**Ahorros Mensuales Estimados:**

| Recurso | On-Premises/mes | AWS/mes | Ahorro |
|---------|-----------------|---------|--------|
| 10 servidores (medio) | $3,500 | $1,200 | $2,300 (66%) |
| Almacenamiento 50TB | $2,000 | $1,150 | $850 (43%) |
| Backup y DR | $1,500 | $300 | $1,200 (80%) |
| Licenciamiento | $2,000 | $800 | $1,200 (60%) |
| **Total** | **$9,000** | **$3,450** | **$5,550 (62%)** |

### ROI Calculator Framework

```
ROI = (Beneficios - Costos de Migración) / Costos de Migración × 100

Ejemplo:
- Costo migración: $50,000
- Ahorro mensual: $5,550
- Payback period: $50,000 / $5,550 = 9 meses
- ROI anual: ($5,550 × 12 - $50,000) / $50,000 × 100 = 33%
```

### Herramientas Recomendadas
- **AWS Migration Evaluator:** Análisis gratuito de cargas existentes
- **AWS Pricing Calculator:** Estimación de costos AWS
- **TCO Calculator:** Comparación total costo de propiedad

## Conclusión

AWS proporciona una plataforma robusta y versátil que permite a las organizaciones transformar sus operaciones de TI. Comprender estos fundamentos es el primer paso para aprovechar todo el potencial que ofrece la computación en la nube. A medida que las organizaciones avanzan en su viaje hacia la nube, los beneficios de agilidad, escalabilidad y optimización de costos se convierten en ventajas competitivas significativas en el panorama empresarial actual.

## Referencias y Recursos Adicionales

- [AWS Global Infrastructure](https://aws.amazon.com/about-aws/global-infrastructure/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Cloud Adoption Framework](https://aws.amazon.com/professional-services/CAF/)
- [AWS Training and Certification](https://aws.amazon.com/training/)
