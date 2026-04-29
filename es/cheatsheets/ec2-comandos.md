# Cheatsheet: Comandos CLI de EC2

## Información Básica

```bash
# Listar instancias
aws ec2 describe-instances
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# Filtrar por estado
aws ec2 describe-instances \
    --filters Name=instance-state-name,Values=running

# Filtrar por tag
aws ec2 describe-instances \
    --filters Name=tag:Environment,Values=Production
```

## Crear y Gestionar Instancias

```bash
# Lanzar instancia
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --count 1 \
    --instance-type t3.micro \
    --key-name MyKeyPair \
    --security-group-ids sg-903004f8 \
    --subnet-id subnet-6e7f829e \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WebServer}]'

# Detener instancia
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Iniciar instancia detenida
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Terminar instancia
aws ec2 terminate-instances --instance-ids i-1234567890abcdef0

# Reiniciar instancia
aws ec2 reboot-instances --instance-ids i-1234567890abcdef0
```

## AMIs y Snapshots

```bash
# Crear AMI
aws ec2 create-image \
    --instance-id i-1234567890abcdef0 \
    --name "WebServer-v1.0" \
    --description "AMI de servidor web"

# Crear snapshot de EBS
aws ec2 create-snapshot \
    --volume-id vol-1234567890abcdef0 \
    --description "Snapshot de volumen de datos"

# Listar AMIs propias
aws ec2 describe-images --owners self

# Copiar AMI a otra región
aws ec2 copy-image \
    --source-image-id ami-12345678 \
    --source-region us-east-1 \
    --region us-west-2 \
    --name "WebServer-v1.0-Copy"
```

## Security Groups

```bash
# Crear security group
aws ec2 create-security-group \
    --group-name WebServer-SG \
    --description "SG para servidores web"

# Agregar regla de entrada (HTTP)
aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Agregar regla de entrada (SSH desde IP específica)
aws ec2 authorize-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.0/32

# Eliminar regla
aws ec2 revoke-security-group-ingress \
    --group-id sg-903004f8 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.0/32

# Ver reglas del security group
aws ec2 describe-security-groups --group-ids sg-903004f8
```

## Key Pairs

```bash
# Crear key pair
aws ec2 create-key-pair \
    --key-name MyKeyPair \
    --query 'KeyMaterial' \
    --output text > MyKeyPair.pem

chmod 400 MyKeyPair.pem

# Importar key pair existente
aws ec2 import-key-pair \
    --key-name MyImportedKey \
    --public-key-material fileb://~/.ssh/id_rsa.pub

# Listar key pairs
aws ec2 describe-key-pairs

# Eliminar key pair
aws ec2 delete-key-pair --key-name MyKeyPair
```

## Volumes EBS

```bash
# Crear volumen
aws ec2 create-volume \
    --volume-type gp3 \
    --size 100 \
    --availability-zone us-east-1a

# Adjuntar volumen a instancia
aws ec2 attach-volume \
    --volume-id vol-1234567890abcdef0 \
    --instance-id i-1234567890abcdef0 \
    --device /dev/sdf

# Desconectar volumen
aws ec2 detach-volume --volume-id vol-1234567890abcdef0

# Modificar volumen (expandir)
aws ec2 modify-volume \
    --volume-id vol-1234567890abcdef0 \
    --size 200

# Eliminar volumen
aws ec2 delete-volume --volume-id vol-1234567890abcdef0
```

## Elastic IPs

```bash
# Asignar Elastic IP
aws ec2 allocate-address --domain vpc

# Asociar a instancia
aws ec2 associate-address \
    --instance-id i-1234567890abcdef0 \
    --allocation-id eipalloc-12345678

# Liberar Elastic IP
aws ec2 release-address --allocation-id eipalloc-12345678
```

## Tags

```bash
# Agregar tags
aws ec2 create-tags \
    --resources i-1234567890abcdef0 \
    --tags Key=Environment,Value=Production Key=Owner,Value=DevOps

# Eliminar tags
aws ec2 delete-tags \
    --resources i-1234567890abcdef0 \
    --tags Key=Owner

# Buscar por tags
aws ec2 describe-instances \
    --filters Name=tag:Environment,Values=Production
```

## Auto Scaling

```bash
# Crear Launch Template
aws ec2 create-launch-template \
    --launch-template-name WebServerTemplate \
    --launch-template-data '{
        "ImageId": "ami-0c55b159cbfafe1f0",
        "InstanceType": "t3.micro",
        "KeyName": "MyKeyPair",
        "SecurityGroupIds": ["sg-903004f8"]
    }'

# Crear Auto Scaling Group
aws autoscaling create-auto-scaling-group \
    --auto-scaling-group-name WebApp-ASG \
    --launch-template LaunchTemplateName=WebServerTemplate,Version='$Latest' \
    --min-size 1 \
    --max-size 5 \
    --desired-capacity 2 \
    --vpc-zone-identifier "subnet-6e7f829e"
```

## User Data (Script de Inicio)

```bash
# Crear instancia con user data
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --instance-type t3.micro \
    --user-data file://startup-script.sh

# Ver user data de instancia
aws ec2 describe-instance-attribute \
    --instance-id i-1234567890abcdef0 \
    --attribute userData \
    --query UserData.Value \
    --output text | base64 -d
```

## Conexión SSH

```bash
# Obtener IP pública
aws ec2 describe-instances \
    --instance-ids i-1234567890abcdef0 \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text

# Conectar SSH
ssh -i MyKeyPair.pem ec2-user@<public-ip>

# Windows (PowerShell)
ssh -i "$env:USERPROFILE\.ssh\MyKeyPair.pem" ec2-user@<public-ip>
```

## Consejos Rápidos

| Tarea | Comando |
|-------|---------|
| Encender instancia | `aws ec2 start-instances --instance-ids <id>` |
| Apagar instancia | `aws ec2 stop-instances --instance-ids <id>` |
| Ver IPs | `aws ec2 describe-instances --query ...` |
| Cambiar tipo | `aws ec2 modify-instance-attribute ...` |
| Ver logs | `aws ec2 get-console-output --instance-id <id>` |
