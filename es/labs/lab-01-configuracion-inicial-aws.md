# Laboratorio 01: Configuración Inicial de AWS

## 🎯 Objetivo del Laboratorio

Configurar una cuenta de AWS con las mejores prácticas de seguridad, incluyendo IAM, MFA y configuración de alertas de facturación.

**Tiempo estimado:** 45 minutos  
**Nivel:** Principiante  
**Costo:** Gratuito (Free Tier)

---

## 📋 Prerrequisitos

- Una dirección de correo electrónico válida
- Una tarjeta de crédito/débito (para verificación, no se cobrará dentro del Free Tier)
- Número de teléfono móvil (para MFA)

---

## 🚀 Paso 1: Crear la Cuenta de AWS

### 1.1 Registro Inicial

1. Visita [aws.amazon.com/free](https://aws.amazon.com/free)
2. Haz clic en "Create a Free Account"
3. Ingresa tu dirección de correo electrónico
4. Crea un nombre de cuenta (puede ser personal o empresarial)
5. Completa la información de contacto

### 1.2 Verificación

1. Ingresa la información de tu tarjeta de crédito/débito
2. AWS realizará un cargo temporal de $1 USD para verificar (se reembolsa)
3. Selecciona el plan "Basic Support" (gratuito)
4. Confirma tu identidad vía SMS o llamada telefónica

### 1.3 Primer Acceso

1. Accede a la Consola de AWS: [console.aws.amazon.com](https://console.aws.amazon.com)
2. Ingresa tu correo y contraseña
3. ¡Bienvenido a la consola de AWS!

---

## 🔐 Paso 2: Configurar IAM (Identity and Access Management)

### 2.1 Crear un Usuario Administrativo

**IMPORTANTE:** Nunca uses la cuenta root para operaciones diarias.

1. En la barra de búsqueda, escribe "IAM" y selecciona el servicio
2. En el panel izquierdo, haz clic en "Users"
3. Haz clic en "Create user"
4. Configuración del usuario:
   ```
   User name: admin-[tu-nombre]
   Provider type: IAM user
   ```
5. Selecciona "Attach policies directly"
6. Busca y selecciona "AdministratorAccess"
7. Clic en "Next" → "Create user"

### 2.2 Configurar Acceso Programático

1. En la lista de usuarios, selecciona tu usuario administrativo
2. Ve a la pestaña "Security credentials"
3. Desplázate a "Access keys"
4. Haz clic en "Create access key"
5. Selecciona "Command Line Interface (CLI)"
6. Marca la casilla de confirmación
7. **IMPORTANTE:** Descarga el archivo CSV y guárdalo en un lugar seguro
8. No podrás ver la Secret Access Key nuevamente

---

## 🛡️ Paso 3: Habilitar MFA (Multi-Factor Authentication)

### 3.1 MFA en la Cuenta Root

1. Haz clic en tu nombre de usuario (esquina superior derecha)
2. Selecciona "Security Credentials"
3. Desplázate a "Multi-factor authentication (MFA)"
4. Haz clic en "Assign MFA device"
5. Selecciona "Virtual MFA device"
6. Escanea el código QR con Google Authenticator o Authy
7. Ingresa dos códigos consecutivos del autenticador
8. Clic en "Assign MFA"

### 3.2 MFA en el Usuario IAM

1. Ve al servicio IAM
2. Selecciona "Users" → tu usuario administrativo
3. Ve a la pestaña "Security credentials"
4. En "Assigned MFA device", haz clic en "Manage"
5. Selecciona "Virtual MFA device"
6. Escanea el código QR con tu aplicación de autenticación
7. Ingresa dos códigos consecutivos
8. Clic en "Assign MFA"

---

## 💰 Paso 4: Configurar Alertas de Facturación

### 4.1 Activar Billing Alerts

1. Haz clic en tu nombre (esquina superior derecha)
2. Selecciona "Billing Dashboard"
3. En el panel izquierdo, ve a "Billing preferences"
4. Habilita:
   - ✅ Receive PDF invoice by email
   - ✅ Receive free tier usage alerts
   - ✅ Receive billing alerts

### 4.2 Crear Presupuesto y Alarmas

1. Ve a "Budgets" en el panel izquierdo
2. Haz clic en "Create budget"
3. Selecciona "Zero spend budget" (ideal para Free Tier)
4. Configuración:
   ```
   Budget name: free-tier-alert
   Amount: $1 USD
   Alert threshold: 80%
   Email recipients: tu-email@ejemplo.com
   ```
5. Clic en "Create budget"

### 4.3 Crear Alarma en CloudWatch (Opcional)

1. Busca "CloudWatch" en la barra de servicios
2. Ve a "Alarms" → "Create alarm"
3. Clic en "Select metric"
4. Navega a: Billing → Total Estimated Charge
5. Selecciona la moneda (USD)
6. Configura las condiciones:
   ```
   Threshold type: Static
   Whenever EstimatedCharges is...: Greater/Equal
   Threshold: 5 (ajusta según tu presupuesto)
   ```
7. Crea un tópico SNS para notificaciones
8. Ingresa tu email para recibir alertas
9. Clic en "Create alarm"

---

## 📊 Paso 5: Explorar la Consola

### 5.1 Servicios Principales

Navega y familiarízate con estos servicios:

| Servicio | URL de la Consola |
|----------|-------------------|
| EC2 | console.aws.amazon.com/ec2 |
| S3 | console.aws.amazon.com/s3 |
| RDS | console.aws.amazon.com/rds |
| VPC | console.aws.amazon.com/vpc |
| IAM | console.aws.amazon.com/iam |
| CloudWatch | console.aws.amazon.com/cloudwatch |

### 5.2 Regiones y Disponibilidad

1. En la barra superior, observa el selector de región (ej: "N. Virginia")
2. Haz clic y explora las diferentes regiones disponibles
3. Recuerda: los recursos son específicos de cada región

---

## ✅ Verificación

Para confirmar que has completado el laboratorio correctamente, verifica:

- [ ] Cuenta de AWS creada y verificada
- [ ] Usuario IAM administrativo creado con política AdministratorAccess
- [ ] Access Key y Secret Key generados y guardados de forma segura
- [ ] MFA habilitado en la cuenta root
- [ ] MFA habilitado en el usuario IAM
- [ ] Alertas de facturación configuradas
- [ ] Presupuesto creado con alerta de umbral
- [ ] Familiarización con la navegación de la consola AWS

---

## 🧹 Limpieza (No aplica para este laboratorio)

Este laboratorio no crea recursos que generen costos. Sin embargo, asegúrate de:

- Guardar las credenciales de acceso de forma segura
- No compartir tus access keys
- Eliminar el presupuesto si ya no lo necesitas

---

## 📚 Recursos Adicionales

- [Documentación de IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/)
- [Mejores prácticas de IAM](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [Free Tier FAQ](https://aws.amazon.com/free/faqs/)

---

## 🎯 Siguiente Laboratorio

→ [Lab 02: Despliegue de EC2 Web Server](lab-02-despliegue-ec2-web-server.md)

---

*Última actualización: Abril 2025*
