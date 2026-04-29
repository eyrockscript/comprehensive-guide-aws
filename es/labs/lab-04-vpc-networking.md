# Laboratorio 04: VPC y Networking

## 🎯 Objetivo del Laboratorio

Crear una VPC completa con subredes públicas y privadas, configurar Internet Gateway, NAT Gateway y establecer reglas de seguridad con Security Groups y Network ACLs.

**Tiempo estimado:** 90 minutos  
**Nivel:** Intermedio  
**Costo:** Dentro del Free Tier (NAT Gateway genera costos - considera usar NAT Instance para pruebas)

---

## 📋 Prerrequisitos

- Laboratorio 01 completado (cuenta AWS configurada)
- Comprensión básica de redes (CIDR, subredes, enrutamiento)

---

## 🚀 Paso 1: Crear la VPC

### 1.1 Acceder al Servicio VPC

1. Inicia sesión en la Consola de AWS
2. En la barra de búsqueda, escribe "VPC"
3. Selecciona el servicio VPC
4. Asegúrate de estar en la región **us-east-1** (N. Virginia)

### 1.2 Crear la VPC

1. En el panel izquierdo, clic en "Your VPCs"
2. Clic en "Create VPC"
3. Selecciona "VPC and more" (esto crea recursos automáticamente)
4. Configura:

**VPC settings:**
```
Name tag auto-generation: lab-vpc
IPv4 CIDR block: 10.0.0.0/16
IPv6 CIDR block: None
Tenancy: Default
```

**Availability Zones:**
```
Number of Availability Zones (AZs): 2
   - us-east-1a
   - us-east-1b
```

**Subnets:**
```
Number of public subnets: 2
   - 10.0.1.0/24 (AZ: us-east-1a)
   - 10.0.2.0/24 (AZ: us-east-1b)

Number of private subnets: 2
   - 10.0.3.0/24 (AZ: us-east-1a)
   - 10.0.4.0/24 (AZ: us-east-1b)
```

**NAT Gateways ($):**
```
Number of NAT gateways: 1 (o None para evitar costos)
```

**VPC endpoints:**
```
S3 endpoint: Gateway (opcional pero recomendado)
```

5. Revisa el preview del diagrama
6. Clic en "Create VPC"

### 1.3 Verificar Recursos Creados

Espera unos minutos y verifica que se hayan creado:

- ✅ 1 VPC (lab-vpc)
- ✅ 1 Internet Gateway
- ✅ 2 Subredes Públicas
- ✅ 2 Subredes Privadas
- ✅ 1 NAT Gateway (si seleccionaste 1)
- ✅ 2 Route Tables (pública y privada)
- ✅ 1 VPC Endpoint para S3 (si lo seleccionaste)

---

## 🌐 Paso 2: Configurar Internet Gateway

### 2.1 Verificar Internet Gateway

1. En el panel izquierdo, clic en "Internet gateways"
2. Selecciona el Internet Gateway creado
3. Verifica que esté "Attached" a tu VPC

### 2.2 Revisar Route Table Pública

1. Ve a "Route tables" en el panel izquierdo
2. Selecciona la tabla de rutas pública
3. Ve a la pestaña "Routes"
4. Deberías ver:
   ```
   Destination: 10.0.0.0/16    Target: local
   Destination: 0.0.0.0/0      Target: igw-xxxxx
   ```

---

## 🔒 Paso 3: Configurar Security Groups

### 3.1 Crear Security Group para Servidor Web (Público)

1. En el panel izquierdo, clic en "Security Groups"
2. Clic en "Create security group"
3. Configura:

**Basic details:**
```
Security group name: lab-web-server-sg
Description: Security group for web servers in public subnet
VPC: lab-vpc
```

**Inbound rules:**
```
Rule 1:
   Type: HTTP
   Source: Anywhere-IPv4 (0.0.0.0/0)
   Description: HTTP access

Rule 2:
   Type: HTTPS
   Source: Anywhere-IPv4 (0.0.0.0/0)
   Description: HTTPS access

Rule 3:
   Type: SSH
   Source: My IP
   Description: SSH from my IP only
```

4. Clic en "Create security group"

### 3.2 Crear Security Group para Base de Datos (Privada)

1. Clic en "Create security group"
2. Configura:

**Basic details:**
```
Security group name: lab-database-sg
Description: Security group for database in private subnet
VPC: lab-vpc
```

**Inbound rules:**
```
Rule 1:
   Type: MySQL/Aurora
   Source: Custom → lab-web-server-sg
   Description: MySQL from web servers only
```

3. Clic en "Create security group"

### 3.3 Crear Security Group para Bastion Host (Jump Server)

1. Clic en "Create security group"
2. Configura:

**Basic details:**
```
Security group name: lab-bastion-sg
Description: Security group for bastion/jump server
VPC: lab-vpc
```

**Inbound rules:**
```
Rule 1:
   Type: SSH
   Source: My IP
   Description: SSH from my IP only
```

3. Clic en "Create security group"

---

## 🛡️ Paso 4: Configurar Network ACLs

### 4.1 Revisar la Network ACL por Defecto

1. En el panel izquierdo, clic en "Network ACLs"
2. Selecciona la NACL asociada a tu VPC
3. Ve a la pestaña "Inbound rules"
4. Ve a la pestaña "Outbound rules"

### 4.2 Crear Network ACL Personalizada para Subred Pública

1. Clic en "Create Network ACL"
2. Configura:
```
Name: lab-public-nacl
VPC: lab-vpc
```
3. Clic en "Create"

### 4.3 Configurar Reglas Inbound

1. Selecciona tu NACL pública
2. Ve a "Inbound rules" → "Edit inbound rules"
3. Añade las siguientes reglas:

```
Rule # | Type        | Protocol | Source      | Allow/Deny
-------|-------------|----------|-------------|------------
100    | HTTP        | TCP      | 0.0.0.0/0   | Allow
110    | HTTPS       | TCP      | 0.0.0.0/0   | Allow
120    | SSH         | TCP      | My IP       | Allow
*      | All traffic | All      | 0.0.0.0/0   | Deny
```

4. Clic en "Save"

### 4.4 Configurar Reglas Outbound

1. Ve a "Outbound rules" → "Edit outbound rules"
2. Añade:

```
Rule # | Type        | Protocol | Destination | Allow/Deny
-------|-------------|----------|-------------|------------
100    | All traffic | All      | 0.0.0.0/0   | Allow
*      | All traffic | All      | 0.0.0.0/0   | Deny
```

3. Clic en "Save"

### 4.5 Asociar NACL a Subredes Públicas

1. Ve a la pestaña "Subnet associations"
2. Clic en "Edit subnet associations"
3. Selecciona las subredes públicas:
   - lab-vpc-subnet-public1-us-east-1a
   - lab-vpc-subnet-public2-us-east-1b
4. Clic en "Save changes"

---

## 💻 Paso 5: Lanzar Instancias de Prueba

### 5.1 Crear Key Pair

1. Ve al servicio EC2
2. En el panel izquierdo, clic en "Key Pairs"
3. Clic en "Create key pair"
4. Configura:
```
Name: lab-vpc-keypair
Key pair type: RSA
Private key file format: .pem
```
5. Descarga y guarda el archivo .pem en `~/.ssh/`
6. Cambia permisos: `chmod 400 ~/.ssh/lab-vpc-keypair.pem`

### 5.2 Lanzar Instancia en Subred Pública (Web Server)

1. Ve a EC2 → "Instances"
2. Clic en "Launch instances"
3. Configura:

**Name:** web-server-public

**Application and OS:** Amazon Linux 2023

**Instance type:** t2.micro

**Key pair:** lab-vpc-keypair

**Network settings:**
```
VPC: lab-vpc
Subnet: lab-vpc-subnet-public1-us-east-1a
Auto-assign public IP: Enable
Security group: lab-web-server-sg
```

**Advanced details:**
```
User data:
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Servidor Web en Subred Pública</h1>" > /var/www/html/index.html
echo "<p>AZ: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>" >> /var/www/html/index.html
```

4. Clic en "Launch instance"

### 5.3 Lanzar Instancia en Subred Privada (App Server)

1. Clic en "Launch instances"
2. Configura:

**Name:** app-server-private

**Application and OS:** Amazon Linux 2023

**Instance type:** t2.micro

**Key pair:** lab-vpc-keypair

**Network settings:**
```
VPC: lab-vpc
Subnet: lab-vpc-subnet-private1-us-east-1a
Auto-assign public IP: Disable
Security group: Crea uno nuevo → lab-app-private-sg
   Inbound: SSH desde lab-vpc-subnet-public1-us-east-1a CIDR
```

3. Clic en "Launch instance"

### 5.4 Lanzar Bastion Host (Jump Server)

1. Clic en "Launch instances"
2. Configura:

**Name:** bastion-host

**Application and OS:** Amazon Linux 2023

**Instance type:** t2.micro

**Key pair:** lab-vpc-keypair

**Network settings:**
```
VPC: lab-vpc
Subnet: lab-vpc-subnet-public1-us-east-1a
Auto-assign public IP: Enable
Security group: lab-bastion-sg
```

3. Clic en "Launch instance"

---

## 🔗 Paso 6: Probar Conectividad

### 6.1 Acceder al Web Server Público

1. Copia la IP pública de la instancia web-server-public
2. Desde tu máquina local:
```bash
# Navegar al sitio web
curl http://[IP-PUBLICA-WEB-SERVER]

# Conectar por SSH
ssh -i ~/.ssh/lab-vpc-keypair.pem ec2-user@[IP-PUBLICA-WEB-SERVER]
```

### 6.2 Probar Conectividad desde Web Server

Una vez conectado al web server:
```bash
# Verificar que tiene acceso a internet
ping google.com -c 4

# Verificar metadata de la instancia
curl http://169.254.169.254/latest/meta-data/placement/availability-zone
```

### 6.3 Acceder al Servidor Privado vía Bastion

Desde tu máquina local, configura el túnel SSH:

```bash
# Opción 1: ProxyJump (SSH moderno)
ssh -i ~/.ssh/lab-vpc-keypair.pem -J ec2-user@[IP-BASTION] ec2-user@[IP-PRIVADA-APP]

# Opción 2: Con config en ~/.ssh/config
# Crea/Edita ~/.ssh/config:
```

Añade a `~/.ssh/config`:
```
Host bastion
    HostName [IP-PUBLICA-BASTION]
    User ec2-user
    IdentityFile ~/.ssh/lab-vpc-keypair.pem

Host app-private
    HostName [IP-PRIVADA-APP]
    User ec2-user
    IdentityFile ~/.ssh/lab-vpc-keypair.pem
    ProxyJump bastion
```

Luego conecta:
```bash
ssh app-private
```

### 6.4 Verificar Conectividad del Servidor Privado

Una vez conectado al servidor privado:

```bash
# Verificar que NO tiene IP pública
curl ifconfig.me
# Debería fallar o no retornar nada (timeout)

# Verificar que SÍ tiene salida a internet (si hay NAT Gateway)
ping 8.8.8.8 -c 4

# Verificar que puede hacer DNS resolution
nslookup google.com
```

---

## 🧪 Paso 7: Pruebas de Seguridad

### 7.1 Probar Security Groups

Desde una máquina diferente (o después de cambiar tu IP):

```bash
# Intentar SSH desde IP diferente (debería fallar)
ssh -i ~/.ssh/lab-vpc-keypair.pem ec2-user@[IP-WEB-SERVER]
# Resultado: Connection timed out

# Acceso HTTP debería funcionar desde cualquier lugar
curl http://[IP-WEB-SERVER]
# Resultado: HTML del servidor
```

### 7.2 Probar Network ACL

Modifica temporalmente las reglas de NACL:

1. Ve a VPC → Network ACLs → lab-public-nacl
2. Edita Inbound rules
3. Añade una regla DENY antes de ALLOW:
```
Rule #99: Deny HTTP desde tu IP
```
4. Prueba el acc HTTP - debería fallar
5. Elimina la regla DENY
6. El acceso debería restaurarse

---

## 🎯 Bonus: VPC Flow Logs

### 8.1 Habilitar VPC Flow Logs

1. Ve a VPC → "Your VPCs"
2. Selecciona lab-vpc
3. Ve a la pestaña "Flow logs"
4. Clic en "Create flow log"
5. Configura:

```
Name: lab-vpc-flow-logs
Filter: All
Destination: Send to CloudWatch Logs
Log group: /aws/vpc/lab-vpc-flow-logs (crear nuevo)
IAM role: Create new IAM role → lab-vpc-flow-logs-role
Max aggregation interval: 1 minute
```

6. Clic en "Create flow log"

### 8.2 Analizar Flow Logs

1. Ve a CloudWatch → Logs → Log groups
2. Selecciona `/aws/vpc/lab-vpc-flow-logs`
3. Explora los logs de tráfico
4. Intenta identificar:
   - Conexiones ACCEPTED
   - Conexiones REJECTED

---

## 🎯 Bonus: Peering entre VPCs (Opcional)

### 9.1 Crear Segunda VPC

1. VPC → Create VPC
2. Configura:
```
Name: lab-vpc-2
CIDR: 10.1.0.0/16
```
3. Clic en "Create VPC"

### 9.2 Crear VPC Peering Connection

1. VPC → Peering Connections → Create peering connection
2. Configura:
```
Name: lab-vpc-to-lab-vpc-2
VPC (Requester): lab-vpc
VPC (Accepter): lab-vpc-2
```
3. Clic en "Create peering connection"
4. Selecciona la conexión → Actions → Accept request

### 9.3 Actualizar Route Tables

1. Ve a la route table de lab-vpc
2. Añade ruta:
```
Destination: 10.1.0.0/16
Target: pcx-xxxxx (peering connection)
```

3. Ve a la route table de lab-vpc-2
4. Añade ruta:
```
Destination: 10.0.0.0/16
Target: pcx-xxxxx (peering connection)
```

---

## ✅ Verificación

- [ ] VPC creada con CIDR 10.0.0.0/16
- [ ] 2 subredes públicas creadas (10.0.1.0/24, 10.0.2.0/24)
- [ ] 2 subredes privadas creadas (10.0.3.0/24, 10.0.4.0/24)
- [ ] Internet Gateway creado y asociado
- [ ] NAT Gateway configurado (opcional)
- [ ] Route tables configuradas correctamente
- [ ] Security Groups creados (web, database, bastion)
- [ ] Network ACL personalizada creada y asociada
- [ ] Instancia en subred pública accesible por HTTP y SSH
- [ ] Instancia en subred privada accesible solo vía bastion
- [ ] Conexión SSH exitosa al servidor privado a través del bastion
- [ ] VPC Flow Logs habilitados (bonus)

---

## 🧹 Limpieza

### Eliminar Recursos en Orden

**IMPORTANTE:** Elimina en este orden para evitar errores de dependencias.

1. **Terminar Instancias EC2:**
   - Selecciona todas las instancias
   - Actions → Instance State → Terminate

2. **Eliminar NAT Gateway (si existe):**
   - VPC → NAT Gateways
   - Selecciona → Actions → Delete NAT gateway

3. **Liberar Elastic IPs:**
   - EC2 → Elastic IPs
   - Selecciona la IP del NAT Gateway
   - Actions → Release Elastic IP

4. **Eliminar VPC:**
   - VPC → Your VPCs
   - Selecciona lab-vpc
   - Actions → Delete VPC
   - Esto elimina automáticamente: subredes, route tables, security groups, IGW

5. **Eliminar Key Pair (opcional):**
   - EC2 → Key Pairs
   - Selecciona lab-vpc-keypair → Delete

6. **Eliminar Flow Logs y recursos CloudWatch:**
   - CloudWatch → Log Groups
   - Selecciona y elimina el log group

7. **Eliminar IAM Roles (opcional):**
   - IAM → Roles
   - Elimina el rol de Flow Logs

---

## 📚 Recursos Adicionales

- [Guía de Usuario de VPC](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [Security Groups vs NACLs](https://docs.aws.amazon.com/vpc/latest/userguide/security-groups.html)
- [NAT Gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [VPC Peering](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html)
- [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)

---

## 🎯 Siguiente Laboratorio

→ [Lab 05: Contenedores con ECS](lab-05-contenedores-ecs.md)

---

*Última actualización: Abril 2025*
