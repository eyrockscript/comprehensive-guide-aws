# Laboratorio 1: Creación de una VPC Básica

## Objetivo
Crear una VPC completa con subredes públicas y privadas, gateways de Internet y NAT.

## Duración Estimada
45-60 minutos

## Requisitos Previos
- Cuenta de AWS con acceso a la consola
- Conocimientos básicos de redes

## Instrucciones

### Paso 1: Crear la VPC
1. Ir a VPC Dashboard
2. Click en "Create VPC"
3. Configurar:
   - Nombre: `LabVPC`
   - CIDR: `10.0.0.0/16`
   - Habilitar DNS hostnames

### Paso 2: Crear Subredes
Crear 4 subredes:

| Nombre | AZ | CIDR | Tipo |
|--------|-----|------|------|
| Public-1a | us-east-1a | 10.0.1.0/24 | Pública |
| Public-1b | us-east-1b | 10.0.2.0/24 | Pública |
| Private-1a | us-east-1a | 10.0.3.0/24 | Privada |
| Private-1b | us-east-1b | 10.0.4.0/24 | Privada |

### Paso 3: Crear Internet Gateway
```bash
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=LabIGW}]'
aws ec2 attach-internet-gateway --internet-gateway-id igw-xxxxx --vpc-id vpc-xxxxx
```

### Paso 4: Configurar Tablas de Rutas
- Tabla pública: ruta a Internet Gateway
- Tabla privada: ruta a NAT Gateway

### Paso 5: Verificar Conectividad
Lanzar instancias de prueba en cada subred y verificar conectividad.

## Retos Adicionales
1. Configurar VPC Flow Logs
2. Crear Endpoint de S3
3. Configurar peering con otra VPC

## Limpieza
Eliminar recursos en orden inverso:
1. Terminar instancias
2. Eliminar NAT Gateway
3. Desasociar y eliminar Internet Gateway
4. Eliminar subredes
5. Eliminar VPC

## Referencias
- [Documentación VPC](https://docs.aws.amazon.com/vpc/)
