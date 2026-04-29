# Laboratorio 02: Despliegue de EC2 Web Server

## 🎯 Objetivo del Laboratorio

Desplegar un servidor web Apache en una instancia EC2, configurar Security Groups y acceder al servidor públicamente.

**Tiempo estimado:** 60 minutos  
**Nivel:** Principiante  
**Costo:** Dentro del Free Tier (750 horas/mes de t2.micro)

---

## 📋 Prerrequisitos

- Laboratorio 01 completado (cuenta AWS con usuario IAM)
- AWS CLI instalado (opcional, para el bonus)

---

## 🚀 Paso 1: Lanzar Instancia EC2

### 1.1 Acceder al Servicio EC2

1. Inicia sesión en la Consola de AWS
2. En la barra de búsqueda, escribe "EC2"
3. Selecciona el servicio EC2
4. Asegúrate de estar en la región **us-east-1** (N. Virginia)

### 1.2 Lanzar Instancia

1. Haz clic en el botón naranja "Launch instances"
2. Configura los siguientes parámetros:

**Name and Tags:**
```
Name: web-server-lab
```

**Application and OS Images (Amazon Machine Image):**
```
Quick Start → Amazon Linux 2023 AMI
Architecture: 64-bit (x86)
```

**Instance Type:**
```
t2.micro (Free tier eligible)
```

**Key Pair (Login):**
```
- Selecciona "Create new key pair"
- Key pair name: ec2-lab-keypair
- Key pair type: RSA
- Private key file format: .pem
- Descarga y guarda el archivo .pem en ~/.ssh/ (Linux/Mac) o Documentos (Windows)
```

### 1.3 Configurar Security Group

En "Network settings", haz clic en "Edit" y luego:

```
VPC: Default VPC
Subnet: Default subnet in us-east-1a
Auto-assign public IP: Enable
```

**Firewall (Security Groups):**
- Selecciona "Create security group"
- Security group name: web-server-sg
- Description: Security group for web server lab

**Añadir reglas de inbound:**

1. **SSH (Regla existente):**
   ```
   Type: SSH
   Source type: My IP
   Description: SSH access from my IP
   ```

2. **HTTP (Nueva regla):**
   ```
   Type: HTTP
   Source type: Anywhere
   Description: HTTP access
   ```

3. **HTTPS (Nueva regla, opcional):**
   ```
   Type: HTTPS
   Source type: Anywhere
   Description: HTTPS access
   ```

### 1.4 Configuración Avanzada

Expande "Advanced details" y en "User data", pega el siguiente script:

```bash
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hola desde AWS EC2!</h1>" > /var/www/html/index.html
```

Este script instalará Apache y creará una página de prueba.

### 1.5 Resumen y Lanzamiento

1. Revisa el resumen en "Summary"
2. Clic en "Launch instance"
3. Espera a que el estado sea "Success"
4. Clic en "View all instances"

---

## 🌐 Paso 2: Conectar a la Instancia

### 2.1 Obtener la IP Pública

1. En la lista de instancias, selecciona tu instancia `web-server-lab`
2. Copia la "Public IPv4 address" (ej: 54.123.45.67)

### 2.2 Conectar vía SSH (Mac/Linux)

```bash
# Cambiar permisos de la clave privada
chmod 400 ~/.ssh/ec2-lab-keypair.pem

# Conectar a la instancia
ssh -i ~/.ssh/ec2-lab-keypair.pem ec2-user@[TU-IP-PUBLICA]
```

### 2.3 Conectar vía SSH (Windows - PuTTY)

1. Convierte la clave .pem a .ppk usando PuTTYgen
2. Abre PuTTY
3. En "Host Name", ingresa: `ec2-user@[TU-IP-PUBLICA]`
4. Ve a Connection → SSH → Auth → Private key
5. Selecciona tu archivo .ppk
6. Clic en "Open"

### 2.4 Verificar Conexión

Una vez conectado, deberías ver el prompt:

```bash
[ec2-user@ip-172-31-xx-xx ~]$
```

Verifica que Apache está corriendo:

```bash
sudo systemctl status httpd
```

Debería mostrar "active (running)".

---

## 🧪 Paso 3: Probar el Servidor Web

### 3.1 Acceder vía Navegador

1. Abre tu navegador web
2. Ingresa la IP pública de tu instancia: `http://[TU-IP-PUBLICA]`
3. Deberías ver: **"Hola desde AWS EC2!"**

### 3.2 Verificar Logs

Desde la conexión SSH:

```bash
# Ver logs de acceso de Apache
sudo tail -f /var/log/httpd/access_log

# En otra terminal, visita tu sitio web
# Deberías ver las peticiones HTTP en los logs
```

### 3.3 Personalizar la Página

```bash
# Editar la página de inicio
sudo nano /var/www/html/index.html
```

Reemplaza el contenido con:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Mi Servidor AWS</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        h1 { font-size: 3em; }
        .info { margin-top: 30px; font-size: 1.2em; }
    </style>
</head>
<body>
    <h1>¡Servidor Web en AWS EC2! 🚀</h1>
    <div class="info">
        <p>Este servidor está corriendo en Amazon Linux 2023</p>
        <p>Servidor: Apache HTTPd</p>
        <p>Fecha: <?php echo date('Y-m-d H:i:s'); ?></p>
    </div>
</body>
</html>
```

Guarda y recarga el navegador.

---

## 🔒 Paso 4: Configurar Security Groups

### 4.1 Verificar Reglas Actuales

1. En la consola EC2, ve a "Security Groups" (panel izquierdo)
2. Selecciona `web-server-sg`
3. Ve a la pestaña "Inbound rules"

### 4.2 Probar Restricción de SSH

1. Intenta conectarte desde una IP diferente (si tienes VPN o datos móviles)
2. La conexión debería fallar (timeout)
3. Esto demuestra que el Security Group está funcionando

### 4.3 Añadir Regla para ICMP (Ping)

1. Ve a "Inbound rules" → "Edit inbound rules"
2. Añade regla:
   ```
   Type: All ICMP - IPv4
   Source: Anywhere-IPv4
   Description: Allow ping
   ```
3. Guarda los cambios

Prueba desde tu máquina local:
```bash
ping [TU-IP-PUBLICA]
```

---

## 📊 Paso 5: Monitoreo con CloudWatch

### 5.1 Ver Métricas

1. En la consola EC2, selecciona tu instancia
2. Ve a la pestaña "Monitoring"
3. Explora las métricas disponibles:
   - CPU Utilization
   - Network In/Out
   - Disk Reads/Writes

### 5.2 Crear Dashboard Personalizado (Opcional)

1. Abre CloudWatch desde la barra de búsqueda
2. Ve a "Dashboards" → "Create dashboard"
3. Nombre: `web-server-dashboard`
4. Añade widgets:
   - Line: CPU Utilization
   - Number: Network In
   - Number: Network Out

---

## 🎯 Bonus: Usar AWS CLI

### Instalar y Configurar AWS CLI

```bash
# Mac (con Homebrew)
brew install awscli

# Windows (con Chocolatey)
choco install awscli

# Configurar
aws configure
AWS Access Key ID: [TU-ACCESS-KEY]
AWS Secret Access Key: [TU-SECRET-KEY]
Default region name: us-east-1
Default output format: json
```

### Comandos Útiles

```bash
# Listar instancias
aws ec2 describe-instances

# Iniciar instancia
aws ec2 start-instances --instance-ids [INSTANCE-ID]

# Detener instancia
aws ec2 stop-instances --instance-ids [INSTANCE-ID]

# Ver Security Groups
aws ec2 describe-security-groups --group-ids [SG-ID]
```

---

## ✅ Verificación

- [ ] Instancia EC2 lanzada exitosamente
- [ ] Security Group configurado con SSH, HTTP y HTTPS
- [ ] Apache instalado y ejecutándose
- [ ] Acceso SSH exitoso desde máquina local
- [ ] Sitio web accesible desde navegador
- [ ] Página personalizada visible
- [ ] Ping funcionando (ICMP habilitado)
- [ ] Métricas de CloudWatch visibles

---

## 🧹 Limpieza

Para evitar cargos, detén y termina la instancia:

1. Ve a EC2 → Instances
2. Selecciona tu instancia
3. Actions → Instance State → Terminate instance
4. Confirma la terminación
5. Opcionalmente, elimina el Security Group y el Key Pair

---

## 📚 Recursos Adicionales

- [Guía de Usuario de EC2](https://docs.aws.amazon.com/ec2/latest/UserGuide/)
- [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [Apache en Amazon Linux](https://docs.aws.amazon.com/AmazonLinux/latest/ec2-ug/ec2-ug.pdf)

---

## 🎯 Siguiente Laboratorio

→ [Lab 03: Almacenamiento S3](lab-03-almacenamiento-s3.md)

---

*Última actualización: Abril 2025*
