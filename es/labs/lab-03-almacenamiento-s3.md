# Laboratorio 03: Almacenamiento S3

## 🎯 Objetivo del Laboratorio

Crear y configurar buckets S3, implementar políticas de ciclo de vida, habilitar hosting estático de sitios web y gestionar permisos de acceso.

**Tiempo estimado:** 60 minutos  
**Nivel:** Principiante-Intermedio  
**Costo:** Dentro del Free Tier (5 GB de almacenamiento estándar)

---

## 📋 Prerrequisitos

- Laboratorio 01 completado (cuenta AWS configurada)
- AWS CLI instalado y configurado (para el bonus)

---

## 🚀 Paso 1: Crear un Bucket S3

### 1.1 Acceder al Servicio S3

1. Inicia sesión en la Consola de AWS
2. En la barra de búsqueda, escribe "S3"
3. Selecciona el servicio S3
4. Asegúrate de estar en la región **us-east-1** (N. Virginia)

### 1.2 Crear el Bucket

1. Haz clic en el botón naranja "Create bucket"
2. Configura los siguientes parámetros:

**General configuration:**
```
Bucket name: mi-laboratorio-s3-[tu-iniciales]-[fecha]
   Ejemplo: mi-laboratorio-s3-jp-20250429
   
⚠️ IMPORTANTE: Los nombres de bucket S3 deben ser únicos GLOBALMENTE
```

**Object Ownership:**
```
Selecciona: ACLs disabled (recommended)
```

**Block Public Access settings:**
```
Desmarca: Block all public access
⚠️ Aparecerá una advertencia de seguridad
Marca: I acknowledge that the current settings might result in this bucket and the objects within becoming public
```

3. Deja las demás configuraciones por defecto
4. Clic en "Create bucket"

---

## 📤 Paso 2: Subir Archivos al Bucket

### 2.1 Subir Archivos Individuales

1. Haz clic en el nombre de tu bucket
2. Clic en el botón "Upload"
3. Clic en "Add files"
4. Selecciona cualquier archivo de tu computadora (imagen, documento, etc.)
5. Clic en "Upload"

### 2.2 Crear Carpetas y Organizar Contenido

1. En tu bucket, clic en "Create folder"
2. Nombre: `documentos/`
3. Clic en "Create folder"

Repite para crear:
- `imagenes/`
- `backups/`

### 2.3 Subir Múltiples Archivos

1. Clic en "Upload" nuevamente
2. Clic en "Add files" o "Add folder"
3. Selecciona múltiples archivos
4. Observa que puedes ver el progreso de carga
5. Clic en "Upload"

---

## 🌐 Paso 3: Configurar Hosting Estático de Sitio Web

### 3.1 Crear Archivos HTML de Prueba

Crea un archivo `index.html` en tu computadora:

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Sitio en S3</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        h1 { text-align: center; }
        .info {
            background: rgba(255,255,255,0.1);
            padding: 20px;
            border-radius: 10px;
            margin-top: 30px;
        }
        .info p { margin: 10px 0; }
    </style>
</head>
<body>
    <h1>¡Bienvenido a mi sitio web estático en S3! 🚀</h1>
    <div class="info">
        <p><strong>Servicio:</strong> Amazon S3 Static Website Hosting</p>
        <p><strong>Región:</strong> us-east-1</p>
        <p><strong>Fecha de creación:</strong> <span id="fecha"></span></p>
    </div>
    <script>
        document.getElementById('fecha').textContent = new Date().toLocaleDateString();
    </script>
</body>
</html>
```

Crea un archivo `error.html`:

```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - Página no encontrada</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background: #f5f5f5;
        }
        h1 { color: #e74c3c; }
        a { color: #3498db; text-decoration: none; }
    </style>
</head>
<body>
    <h1>404 - Página no encontrada</h1>
    <p>Lo sentimos, la página que buscas no existe.</p>
    <p><a href="index.html">Volver al inicio</a></p>
</body>
</html>
```

### 3.2 Subir Archivos al Bucket

1. En tu bucket de S3, clic en "Upload"
2. Selecciona ambos archivos: `index.html` y `error.html`
3. Clic en "Upload"

### 3.3 Habilitar Static Website Hosting

1. Ve a la pestaña "Properties" de tu bucket
2. Desplázate hasta el final a "Static website hosting"
3. Clic en "Edit"
4. Configura:
   ```
   Static website hosting: Enable
   Hosting type: Host a static website
   Index document: index.html
   Error document: error.html
   ```
5. Clic en "Save changes"

### 3.4 Configurar Política de Bucket para Acceso Público

1. Ve a la pestaña "Permissions" de tu bucket
2. Desplázate a "Bucket policy"
3. Clic en "Edit"
4. Pega la siguiente política (reemplaza `YOUR-BUCKET-NAME` con tu nombre de bucket):

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
        }
    ]
}
```

5. Clic en "Save changes"

### 3.5 Acceder al Sitio Web

1. Ve a "Properties" → "Static website hosting"
2. Copia la URL del "Bucket website endpoint"
   - Ejemplo: `http://mi-laboratorio-s3-jp.s3-website-us-east-1.amazonaws.com`
3. Abre la URL en tu navegador
4. ¡Deberías ver tu sitio web!

### 3.6 Probar la Página de Error

1. Intenta acceder a una URL que no existe, ejemplo:
   `http://tu-bucket.s3-website-us-east-1.amazonaws.com/pagina-inexistente`
2. Deberías ver tu página de error 404

---

## 🔄 Paso 4: Configurar Políticas de Ciclo de Vida

### 4.1 Crear Carpeta para Logs

1. En tu bucket, clic en "Create folder"
2. Nombre: `logs/`
3. Clic en "Create folder"

### 4.2 Crear Regla de Ciclo de Vida

1. Ve a la pestaña "Management" de tu bucket
2. En "Lifecycle rules", clic en "Create lifecycle rule"
3. Configura:

**Rule configuration:**
```
Lifecycle rule name: archivar-y-eliminar-logs
Rule scope: Apply to all objects in the folder
Prefix: logs/
```

**Lifecycle rule actions:**
```
✅ Transition current versions of objects between storage classes
   - Transition to Glacier Deep Archive after 90 days

✅ Permanently delete noncurrent versions of objects
   - Permanently delete after 30 days

✅ Delete expired object delete markers or incomplete multipart uploads
   - Delete incomplete multipart uploads after 7 days
```

4. Clic en "Create rule"

### 4.3 Crear Segunda Regla para Versionado

1. Clic en "Create lifecycle rule" nuevamente
2. Configura:

**Rule configuration:**
```
Lifecycle rule name: transicion-versiones
Rule scope: Apply to all objects in the bucket
```

**Lifecycle rule actions:**
```
✅ Transition noncurrent versions of objects between storage classes
   - Transition to Standard-IA after 30 days
   - Transition to Glacier Flexible Retrieval after 90 days
```

3. Clic en "Create rule"

---

## 🔒 Paso 5: Versionado de Objetos

### 5.1 Habilitar Versionado

1. Ve a la pestaña "Properties" de tu bucket
2. Desplázate a "Bucket Versioning"
3. Clic en "Edit"
4. Selecciona "Enable"
5. Clic en "Save changes"

### 5.2 Probar el Versionado

1. Sube un archivo al bucket (por ejemplo, `documento.txt`)
2. Modifica el archivo en tu computadora y súbelo nuevamente con el mismo nombre
3. Ve a la lista de objetos en S3
4. Selecciona el archivo y clic en "Versions"
5. ¡Verás ambas versiones del archivo!

### 5.3 Restaurar una Versión Anterior

1. En "Versions", identifica la versión que quieres restaurar
2. Selecciona la versión anterior
3. Clic en "Download" para obtener esa versión
4. O sube nuevamente como el archivo principal

---

## 🔐 Paso 6: Configurar Cifrado

### 6.1 Cifrado por Defecto

1. Ve a la pestaña "Properties" de tu bucket
2. Desplázate a "Default encryption"
3. Clic en "Edit"
4. Configura:
   ```
   Server-side encryption: Enable
   Encryption key type: Amazon S3 managed keys (SSE-S3)
   ```
5. Clic en "Save changes"

### 6.2 Cifrado con KMS (Opcional)

Si tienes acceso a AWS KMS:

1. En "Default encryption", clic en "Edit"
2. Selecciona:
   ```
   Encryption key type: AWS Key Management Service key (SSE-KMS)
   AWS KMS key: Choose from your AWS KMS keys
              O
              Enter AWS KMS key ARN
   ```
3. Clic en "Save changes"

---

## 🧪 Paso 7: Pruebas Avanzadas

### 7.1 Configurar Cross-Origin Resource Sharing (CORS)

1. Ve a la pestaña "Permissions" de tu bucket
2. Desplázate a "Cross-origin resource sharing (CORS)"
3. Clic en "Edit"
4. Pega la siguiente configuración CORS:

```json
[
    {
        "AllowedHeaders": [
            "*"
        ],
        "AllowedMethods": [
            "GET",
            "HEAD"
        ],
        "AllowedOrigins": [
            "*"
        ],
        "ExposeHeaders": [
            "x-amz-server-side-encryption",
            "x-amz-request-id",
            "x-amz-id-2"
        ],
        "MaxAgeSeconds": 3000
    }
]
```

5. Clic en "Save changes"

### 7.2 Configurar Eventos de Notificación (Opcional)

1. Ve a la pestaña "Properties"
2. Desplázate a "Event notifications"
3. Clic en "Create event notification"
4. Configura:
   ```
   Event name: notificacion-nuevos-archivos
   Prefix: imagenes/
   Suffix: .jpg
   
   Event types: 
   ✅ All object create events
   
   Destination:
   ☑️ SNS topic
      Selecciona un topic existente o crea uno nuevo
   ```
5. Clic en "Save changes"

---

## 🎯 Bonus: Usar AWS CLI con S3

### Instalar AWS CLI

```bash
# Mac (con Homebrew)
brew install awscli

# Windows (con Chocolatey)
choco install awscli

# Verificar instalación
aws --version
```

### Configurar AWS CLI

```bash
aws configure
AWS Access Key ID: [TU-ACCESS-KEY]
AWS Secret Access Key: [TU-SECRET-KEY]
Default region name: us-east-1
Default output format: json
```

### Comandos Útiles de S3

```bash
# Listar buckets
aws s3 ls

# Listar contenido de un bucket
aws s3 ls s3://mi-laboratorio-s3-jp-20250429

# Subir un archivo
aws s3 cp archivo.txt s3://mi-laboratorio-s3-jp-20250429/

# Descargar un archivo
aws s3 cp s3://mi-laboratorio-s3-jp-20250429/archivo.txt ./

# Sincronizar carpeta local con S3
aws s3 sync ./mi-carpeta s3://mi-laboratorio-s3-jp-20250429/carpeta-remota

# Copiar entre buckets
aws s3 cp s3://bucket-origen/archivo.txt s3://bucket-destino/

# Eliminar un archivo
aws s3 rm s3://mi-laboratorio-s3-jp-20250429/archivo.txt

# Eliminar todo el contenido de un bucket
aws s3 rm s3://mi-laboratorio-s3-jp-20250429/ --recursive

# Obtener información de un objeto
aws s3api head-object --bucket mi-laboratorio-s3-jp-20250429 --key archivo.txt
```

### S3 con S3cmd (Herramienta Alternativa)

```bash
# Instalar s3cmd
pip install s3cmd

# Configurar
s3cmd --configure

# Subir archivo
s3cmd put archivo.txt s3://mi-laboratorio-s3-jp-20250429/

# Descargar
s3cmd get s3://mi-laboratorio-s3-jp-20250429/archivo.txt
```

---

## ✅ Verificación

- [ ] Bucket S3 creado exitosamente con nombre único
- [ ] Archivos subidos al bucket correctamente
- [ ] Carpetas creadas (documentos/, imagenes/, backups/)
- [ ] Static website hosting habilitado
- [ ] Política de bucket configurada para acceso público de lectura
- [ ] Sitio web accesible desde el endpoint de S3
- [ ] Página de error 404 configurada y probada
- [ ] Versionado de objetos habilitado
- [ ] Múltiples versiones de un archivo creadas y visibles
- [ ] Reglas de ciclo de vida creadas (archivado y eliminación)
- [ ] Cifrado por defecto configurado (SSE-S3)
- [ ] Configuración CORS añadida
- [ ] AWS CLI configurado y probado (bonus)

---

## 🧹 Limpieza

Para evitar cargos, elimina los recursos:

### Método 1: Consola Web

1. Ve a S3 → selecciona tu bucket
2. Vacía el bucket:
   - Selecciona todos los objetos
   - Clic en "Delete"
   - Escribe "permanently delete" para confirmar
3. Elimina el bucket:
   - Selecciona el bucket en la lista
   - Clic en "Delete"
   - Escribe el nombre del bucket para confirmar

### Método 2: AWS CLI

```bash
# Vaciar el bucket primero
aws s3 rm s3://mi-laboratorio-s3-jp-20250429/ --recursive

# Eliminar el bucket
aws s3api delete-bucket --bucket mi-laboratorio-s3-jp-20250429 --region us-east-1
```

### Limpieza Adicional (si creaste recursos extra)

- Elimina topics de SNS (si creaste notificaciones)
- Elimina reglas de lifecycle (se eliminan con el bucket)
- Desactiva las keys de KMS (si usaste SSE-KMS)

---

## 📚 Recursos Adicionales

- [Guía de Usuario de S3](https://docs.aws.amazon.com/s3/latest/userguide/Welcome.html)
- [Hosting de Sitios Web Estáticos](https://docs.aws.amazon.com/s3/latest/userguide/WebsiteHosting.html)
- [Políticas de Ciclo de Vida](https://docs.aws.amazon.com/s3/latest/userguide/lifecycle-configuration-examples.html)
- [Versionado de Objetos](https://docs.aws.amazon.com/s3/latest/userguide/Versioning.html)
- [Mejores Prácticas de Seguridad S3](https://docs.aws.amazon.com/s3/latest/userguide/security-best-practices.html)

---

## 🎯 Siguiente Laboratorio

→ [Lab 04: VPC y Networking](lab-04-vpc-networking.md)

---

*Última actualización: Abril 2025*
