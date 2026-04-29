# 📚 AWS Comprehensive Guides

<p align="center">
  <img src="https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white" alt="AWS">
  <img src="https://img.shields.io/badge/Cloud-%23FF9900.svg?style=for-the-badge&logo=icloud&logoColor=white" alt="Cloud">
  <img src="https://img.shields.io/badge/Infrastructure-%23FF9900.svg?style=for-the-badge&logo=terraform&logoColor=white" alt="Infrastructure">
</p>

<p align="center">
  <a href="https://github.com/eyrockscript/comprehensive-guide-aws/stargazers"><img src="https://img.shields.io/github/stars/eyrockscript/comprehensive-guide-aws?style=social" alt="GitHub stars"></a>
  <a href="https://github.com/eyrockscript/comprehensive-guide-aws/network/members"><img src="https://img.shields.io/github/forks/eyrockscript/comprehensive-guide-aws?style=social" alt="GitHub forks"></a>
  <a href="https://github.com/eyrockscript/comprehensive-guide-aws/graphs/contributors"><img src="https://img.shields.io/github/contributors/eyrockscript/comprehensive-guide-aws?style=social" alt="Contributors"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Markdown-000000?style=for-the-badge&logo=markdown&logoColor=white" alt="Markdown">
  <img src="https://img.shields.io/badge/Open%20Source-%3C3-brightgreen?style=for-the-badge" alt="Open Source">
  <img src="https://img.shields.io/badge/Documentation-Complete-blue?style=for-the-badge" alt="Documentation">
</p>

---

## 🎯 Sobre Este Proyecto

**AWS Comprehensive Guides** es una colección completa de whitepapers técnicos que ofrecen conocimientos profundos sobre Amazon Web Services (AWS). Diseñado para profesionales, arquitectos cloud y tomadores de decisiones que buscan dominar AWS desde los fundamentos hasta arquitecturas avanzadas.

### ✨ Características Principales

- 📖 **10 Whitepapers Completos** cubriendo todos los aspectos de AWS
- 🔧 **Laboratorios Hands-On** con ejercicios prácticos paso a paso
- 📋 **Cheatsheets de Referencia Rápida** para consulta diaria
- 🏗️ **Templates de Infraestructura** (CloudFormation y Terraform)
- 📊 **Diagramas de Arquitectura** en formato Mermaid
- 🎓 **Guía de Certificaciones** mapeada al contenido
- 🌍 **Disponible en Español e Inglés**

---

## 📑 Tabla de Contenidos

- [🚀 Inicio Rápido](#-inicio-rápido)
- [📁 Estructura del Repositorio](#-estructura-del-repositorio)
- [☁️ Servicios AWS Cubiertos](#-servicios-aws-cubiertos)
- [🎓 Certificaciones AWS](#-certificaciones-aws)
- [🤝 Contribuciones](#-contribuciones)
- [📄 Licencia](#-licencia)
- [📧 Contacto](#-contacto)

---

## 🚀 Inicio Rápido

### Opción 1: Lectura Online

Explora el contenido directamente en GitHub:

<table>
<tr>
<td align="center" width="50%">

### 🇪🇸 [Versión en Español](es/)

**Completa y lista para usar**

[![Español](https://img.shields.io/badge/Ver%20Contenido-FF9900?style=for-the-badge)](es/README.md)

- ✅ 10 whitepapers
- ✅ 10 laboratorios prácticos
- ✅ 8 cheatsheets
- ✅ Glosario completo
- ✅ Guía de certificaciones

</td>
<td align="center" width="50%">

### 🇬🇧 [English Version](en/)

**Fully translated and ready**

[![English](https://img.shields.io/badge/View%20Content-232F3E?style=for-the-badge)](en/README.md)

- ✅ 10 whitepapers
- ✅ 10 hands-on labs
- ✅ 8 cheatsheets
- ✅ Complete glossary
- ✅ Certification guide

</td>
</tr>
</table>

### Opción 2: Clonar Localmente

```bash
# Clonar el repositorio
git clone https://github.com/eyrockscript/comprehensive-guide-aws.git

# Navegar al directorio
cd comprehensive-guide-aws

# Abrir en tu editor favorito
code .
```

---

## 📁 Estructura del Repositorio

```
comprehensive-guide-aws/
├── 📁 es/                          # Contenido en Español
│   ├── README.md                   # Índice principal
│   ├── objetivo-de-la-guia.md
│   ├── como-usar-este-recurso.md
│   ├── agradecimientos.md
│   ├── 📁 whitepapers/             # 10 whitepapers completos
│   ├── 📁 labs/                    # 10 laboratorios prácticos
│   ├── 📁 cheatsheets/             # 8 guías de referencia
│   ├── 📁 casos-de-estudio/        # 5 casos reales
│   ├── glosario.md
│   ├── faq.md
│   ├── certificaciones.md
│   └── recursos.md
│
├── 📁 en/                          # Content in English
│   ├── README.md                   # Main index
│   ├── objective-of-the-guide.md
│   ├── how-to-use-this-resource.md
│   ├── acknowledgments.md
│   ├── 📁 whitepapers/             # 10 complete whitepapers
│   ├── 📁 labs/                    # 10 hands-on labs
│   ├── 📁 cheatsheets/             # 8 reference guides
│   ├── 📁 case-studies/            # 5 real cases
│   ├── glossary.md
│   ├── faq.md
│   ├── certifications.md
│   └── resources.md
│
├── 📁 diagrams/                      # Diagramas Mermaid
│   ├── well-architected-framework.mmd
│   ├── shared-responsibility-model.mmd
│   ├── vpc-architecture.mmd
│   ├── 3-tier-web-application.mmd
│   ├── serverless-architecture.mmd
│   └── ...
│
├── 📁 templates/                   # Templates IaC
│   ├── 📁 cloudformation/           # 5 templates CF
│   └── 📁 terraform/               # 5 módulos Terraform
│
├── 📁 scripts/                     # Scripts de utilidad
│
├── 📁 .github/                     # GitHub Actions
│   └── 📁 workflows/
│
├── README.md                       # Este archivo
└── LICENSE                         # Licencia MIT
```

---

## ☁️ Servicios AWS Cubiertos

<table>
<tr>
<th>Categoría</th>
<th>Servicios</th>
<th>Whitepaper</th>
</tr>
<tr>
<td><strong>💻 Cómputo</strong></td>
<td>EC2, Lambda, ECS, EKS, Fargate, Batch</td>
<td><a href="es/whitepapers/c2-servicios-de-computo-en-aws.md">C2</a> / <a href="en/whitepapers/c2-compute-services-on-aws.md">C2</a></td>
</tr>
<tr>
<td><strong>💾 Almacenamiento</strong></td>
<td>S3, EBS, EFS, FSx, Storage Gateway</td>
<td><a href="es/whitepapers/c3-almacenamiento-y-bases-de-datos-en-aws.md">C3</a> / <a href="en/whitepapers/c3-storage-and-databases-on-aws.md">C3</a></td>
</tr>
<tr>
<td><strong>🗄️ Bases de Datos</strong></td>
<td>RDS, DynamoDB, Redshift, ElastiCache, Neptune</td>
<td><a href="es/whitepapers/c3-almacenamiento-y-bases-de-datos-en-aws.md">C3</a> / <a href="en/whitepapers/c3-storage-and-databases-on-aws.md">C3</a></td>
</tr>
<tr>
<td><strong>🌐 Redes</strong></td>
<td>VPC, CloudFront, Route 53, Transit Gateway, Direct Connect</td>
<td><a href="es/whitepapers/c4-redes-y-entrega-de-contenido-en-aws.md">C4</a> / <a href="en/whitepapers/c4-networking-and-content-delivery-on-aws.md">C4</a></td>
</tr>
<tr>
<td><strong>🔒 Seguridad</strong></td>
<td>IAM, KMS, CloudTrail, GuardDuty, WAF, Shield</td>
<td><a href="es/whitepapers/c5-seguridad-y-cumplimiento-en-aws.md">C5</a> / <a href="en/whitepapers/c5-security-and-compliance-on-aws.md">C5</a></td>
</tr>
<tr>
<td><strong>🔗 Integración</strong></td>
<td>SQS, SNS, EventBridge, Step Functions, AppFlow</td>
<td><a href="es/whitepapers/c6-servicios-de-integracion-y-orquestacion-en-aws.md">C6</a> / <a href="en/whitepapers/c6-integration-and-orchestration-services-on-aws.md">C6</a></td>
</tr>
<tr>
<td><strong>📊 Monitoreo</strong></td>
<td>CloudWatch, CloudTrail, X-Ray, Config, Systems Manager</td>
<td><a href="es/whitepapers/c7-monitoreo-y-gestion-en-aws.md">C7</a> / <a href="en/whitepapers/c7-monitoring-and-management-on-aws.md">C7</a></td>
</tr>
<tr>
<td><strong>🤖 IA/ML</strong></td>
<td>SageMaker, Bedrock, Rekognition, Comprehend, Lex</td>
<td><a href="es/whitepapers/c8-servicios-de-ia-ml-en-aws.md">C8</a> / <a href="en/whitepapers/c8-ai-ml-services-on-aws.md">C8</a></td>
</tr>
<tr>
<td><strong>🏛️ Arquitecturas</strong></td>
<td>Well-Architected Framework, Patrones, Casos de Uso</td>
<td><a href="es/whitepapers/c9-arquitecturas-de-referencia-y-casos-de-uso-en-aws.md">C9</a> / <a href="en/whitepapers/c9-reference-architectures-and-use-cases-on-aws.md">C9</a></td>
</tr>
<tr>
<td><strong>💰 Costos</strong></td>
<td>Pricing Models, Savings Plans, Reserved Instances, Cost Explorer</td>
<td><a href="es/whitepapers/c10-estrategias-de-costos-en-aws.md">C10</a> / <a href="en/whitepapers/c10-cost-optimization-strategies-on-aws.md">C10</a></td>
</tr>
</table>

---

## 🎓 Certificaciones AWS

Este contenido está diseñado para ayudarte a prepararte para las certificaciones AWS:

<table>
<tr>
<th>Nivel</th>
<th>Certificación</th>
<th>Whitepapers Relevantes</th>
</tr>
<tr>
<td rowspan="1"><strong>Cloud Practitioner</strong></td>
<td>AWS Certified Cloud Practitioner</td>
<td>C1, C2, C3, C4, C5, C10</td>
</tr>
<tr>
<td rowspan="3"><strong>Associate</strong></td>
<td>AWS Certified Solutions Architect - Associate</td>
<td>C1, C2, C3, C4, C5, C9, C10</td>
</tr>
<tr>
<td>AWS Certified Developer - Associate</td>
<td>C2, C3, C5, C6, C7</td>
</tr>
<tr>
<td>AWS Certified SysOps Administrator - Associate</td>
<td>C2, C4, C5, C7, C10</td>
</tr>
<tr>
<td rowspan="2"><strong>Professional</strong></td>
<td>AWS Certified Solutions Architect - Professional</td>
<td>Todos los whitepapers</td>
</tr>
<tr>
<td>AWS Certified DevOps Engineer - Professional</td>
<td>C2, C6, C7, C9</td>
</tr>
<tr>
<td rowspan="5"><strong>Specialty</strong></td>
<td>AWS Certified Security - Specialty</td>
<td>C5 (en profundidad)</td>
</tr>
<tr>
<td>AWS Certified Machine Learning - Specialty</td>
<td>C8 (en profundidad)</td>
</tr>
<tr>
<td>AWS Certified Database - Specialty</td>
<td>C3 (en profundidad)</td>
</tr>
<tr>
<td>AWS Certified Advanced Networking - Specialty</td>
<td>C4 (en profundidad)</td>
</tr>
</table>

📚 **Ver la guía completa**: [Español](es/certificaciones.md) | [English](en/certifications.md)

---

## 📊 Estadísticas del Proyecto

<p align="center">
  <img src="https://img.shields.io/badge/Whitepapers-10-blue?style=flat-square" alt="10 Whitepapers">
  <img src="https://img.shields.io/badge/Laboratorios-20-green?style=flat-square" alt="20 Labs">
  <img src="https://img.shields.io/badge/Cheatsheets-8-orange?style=flat-square" alt="8 Cheatsheets">
  <img src="https://img.shields.io/badge/Diagramas-10-purple?style=flat-square" alt="10 Diagrams">
  <img src="https://img.shields.io/badge/Templates-10-red?style=flat-square" alt="10 Templates">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/T%C3%A9rminos%20en%20Glosario-200+-yellow?style=flat-square" alt="200+ Terms">
  <img src="https://img.shields.io/badge/Casos%20de%20Estudio-5-pink?style=flat-square" alt="5 Case Studies">
  <img src="https://img.shields.io/badge/Idiomas-2-lightgrey?style=flat-square" alt="2 Languages">
</p>

---

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Puedes:

- 🐛 Reportar errores o problemas
- 💡 Sugerir mejoras o nuevos temas
- 📝 Corregir typos o mejorar redacción
- 🌍 Ayudar con traducciones
- 🔧 Compartir templates o casos de estudio

### Cómo Contribuir

1. Fork el repositorio
2. Crea una rama para tu contribución (`git checkout -b feature/nueva-mejora`)
3. Realiza tus cambios
4. Envía un Pull Request

📋 **Ver guía de contribución**: [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 👥 Contribuidores Destacados

<a href="https://github.com/eyrockscript/comprehensive-guide-aws/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=eyrockscript/comprehensive-guide-aws" alt="Contribuidores">
</a>

---

## 📄 Licencia

Este proyecto está licenciado bajo la **Licencia MIT**.

```
MIT License

Copyright (c) 2025 AWS Comprehensive Guides Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND...
```

📄 **[Ver licencia completa](LICENSE)**

---

## 📧 Contacto

¿Preguntas o sugerencias?

- 🐛 **Issues**: [Abrir un issue](https://github.com/eyrockscript/comprehensive-guide-aws/issues)
- 💬 **Discusiones**: [GitHub Discussions](https://github.com/eyrockscript/comprehensive-guide-aws/discussions)
- 📧 **Email**: Contactar a través de GitHub

---

<p align="center">
  <strong>⭐ Si este proyecto te es útil, ¡dale una estrella! ⭐</strong>
</p>

<p align="center">
  <sub>Hecho con ❤️ para la comunidad cloud</sub>
</p>

<p align="center">
  <sub>Última actualización: Abril 2025</sub>
</p>
