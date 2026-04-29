# Laboratorio 3: Sitio Web Estático en S3 con CloudFront

## Objetivo
Hospedar un sitio web estático en S3 con distribución global mediante CloudFront.

## Duración Estimada
45 minutos

## Instrucciones

### Paso 1: Crear Bucket S3
```bash
aws s3 mb s3://my-static-website-$(date +%s) \
    --region us-east-1
```

### Paso 2: Configurar Bucket para Website Hosting
```bash
aws s3api put-bucket-website \
    --bucket my-static-website-xxx \
    --website-configuration file://website-config.json
```

Contenido de `website-config.json`:
```json
{
  "IndexDocument": {"Suffix": "index.html"},
  "ErrorDocument": {"Key": "error.html"}
}
```

### Paso 3: Subir Contenido
```bash
aws s3 sync ./website-content s3://my-static-website-xxx \
    --acl public-read
```

### Paso 4: Política de Bucket
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::my-static-website-xxx/*"
  }]
}
```

### Paso 5: Crear Distribución CloudFront
```bash
aws cloudfront create-distribution \
    --origin-domain-name my-static-website-xxx.s3.amazonaws.com \
    --default-root-object index.html
```

### Paso 6: Configurar DNS con Route 53
```bash
aws route53 change-resource-record-sets \
    --hosted-zone-id Z123456789 \
    --change-batch file://dns-changes.json
```

## Pruebas
1. Verificar acceso directo al bucket
2. Verificar distribución CloudFront
3. Probar invalidación de caché

## Retos Adicionales
1. Configurar certificado SSL personalizado
2. Implementar OAI (Origin Access Identity)
3. Configurar compresión gzip
4. Agregar headers de seguridad

## Limpieza
1. Eliminar distribución CloudFront
2. Vaciar y eliminar bucket S3
3. Eliminar registros DNS
