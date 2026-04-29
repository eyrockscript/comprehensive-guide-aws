# Cheatsheet: Comandos CLI de VPC y Networking

## Crear VPC

```bash
# Crear VPC básica
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=MiVPC}]'

# Crear VPC con DNS habilitado
aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --enable-dns-support \
    --enable-dns-hostnames \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=MiVPC-Prod}]'

# Describir VPC
aws ec2 describe-vpcs --vpc-ids vpc-12345678

# Describir VPCs propios
aws ec2 describe-vpcs --filters Name=owner-id,Values=123456789012
```

## Subnets

```bash
# Crear subnet pública
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.1.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Public-1a}]'

# Crear subnet privada
aws ec2 create-subnet \
    --vpc-id vpc-12345678 \
    --cidr-block 10.0.2.0/24 \
    --availability-zone us-east-1a \
    --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Private-1a}]'

# Habilitar auto-asignación de IPs públicas en subnet
aws ec2 modify-subnet-attribute \
    --subnet-id subnet-12345678 \
    --map-public-ip-on-launch

# Describir subnets
aws ec2 describe-subnets --filters Name=vpc-id,Values=vpc-12345678

# Eliminar subnet
aws ec2 delete-subnet --subnet-id subnet-12345678
```

## Internet Gateway

```bash
# Crear Internet Gateway
aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=MiIGW}]'

# Adjuntar a VPC
aws ec2 attach-internet-gateway \
    --internet-gateway-id igw-12345678 \
    --vpc-id vpc-12345678

# Describir IGWs
aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=vpc-12345678

# Desadjuntar de VPC
aws ec2 detach-internet-gateway \
    --internet-gateway-id igw-12345678 \
    --vpc-id vpc-12345678

# Eliminar IGW
aws ec2 delete-internet-gateway --internet-gateway-id igw-12345678
```

## NAT Gateway

```bash
# Crear Elastic IP para NAT
aws ec2 allocate-address --domain vpc

# Crear NAT Gateway
aws ec2 create-nat-gateway \
    --subnet-id subnet-12345678 \
    --allocation-id eipalloc-12345678 \
    --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=NAT-1a}]'

# Esperar a que esté disponible
aws ec2 describe-nat-gateways --nat-gateway-ids nat-12345678

# Eliminar NAT Gateway
aws ec2 delete-nat-gateway --nat-gateway-id nat-12345678

# Liberar Elastic IP
aws ec2 release-address --allocation-id eipalloc-12345678
```

## Route Tables

```bash
# Crear route table
aws ec2 create-route-table \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=Public-RT}]'

# Agregar ruta a Internet Gateway (ruta pública)
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id igw-12345678

# Agregar ruta a NAT Gateway (ruta privada)
aws ec2 create-route \
    --route-table-id rtb-87654321 \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id nat-12345678

# Asociar route table a subnet
aws ec2 associate-route-table \
    --route-table-id rtb-12345678 \
    --subnet-id subnet-12345678

# Crear ruta a peering connection
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 172.16.0.0/16 \
    --vpc-peering-connection-id pcx-12345678

# Crear ruta a Transit Gateway
aws ec2 create-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 192.168.0.0/16 \
    --transit-gateway-id tgw-12345678

# Describir route tables
aws ec2 describe-route-tables --filters Name=vpc-id,Values=vpc-12345678

# Eliminar ruta
aws ec2 delete-route \
    --route-table-id rtb-12345678 \
    --destination-cidr-block 0.0.0.0/0

# Eliminar route table
aws ec2 delete-route-table --route-table-id rtb-12345678
```

## Security Groups

```bash
# Crear security group
aws ec2 create-security-group \
    --group-name WebServer-SG \
    --description "Security group para servidores web" \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=WebServer-SG}]'

# Agregar regla de entrada - HTTP
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Agregar regla de entrada - HTTPS
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# Agregar regla de entrada - SSH desde IP específica
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.10/32

# Agregar regla de entrada desde otro security group
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 3306 \
    --source-group sg-87654321

# Agregar regla de salida
aws ec2 authorize-security-group-egress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# Describir security groups
aws ec2 describe-security-groups --filters Name=vpc-id,Values=vpc-12345678

# Eliminar regla de entrada
aws ec2 revoke-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --cidr 203.0.113.10/32

# Eliminar security group
aws ec2 delete-security-group --group-id sg-12345678
```

## Network ACLs

```bash
# Crear Network ACL
aws ec2 create-network-acl \
    --vpc-id vpc-12345678 \
    --tag-specifications 'ResourceType=network-acl,Tags=[{Key=Name,Value=NACL-Public}]'

# Agregar regla de entrada
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow \
    --ingress

# Agregar regla de entrada - HTTPS
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 110 \
    --protocol tcp \
    --port-range From=443,To=443 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow \
    --ingress

# Agregar regla de salida
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol -1 \
    --cidr-block 0.0.0.0/0 \
    --rule-action allow \
    --egress

# Asociar NACL a subnet
aws ec2 replace-network-acl-association \
    --association-id aclassoc-12345678 \
    --network-acl-id acl-12345678

# Describir NACLs
aws ec2 describe-network-acls --filters Name=vpc-id,Values=vpc-12345678

# Eliminar regla
aws ec2 delete-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --ingress
```

## VPC Peering

```bash
# Crear peering connection
aws ec2 create-vpc-peering-connection \
    --vpc-id vpc-12345678 \
    --peer-vpc-id vpc-87654321 \
    --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=Peer-Prod-Dev}]'

# Aceptar peering (cuenta diferente)
aws ec2 accept-vpc-peering-connection --vpc-peering-connection-id pcx-12345678

# Describir peering connections
aws ec2 describe-vpc-peering-connections --filters Name=requester-vpc-info.vpc-id,Values=vpc-12345678

# Rechazar peering
aws ec2 reject-vpc-peering-connection --vpc-peering-connection-id pcx-12345678

# Eliminar peering
aws ec2 delete-vpc-peering-connection --vpc-peering-connection-id pcx-12345678
```

## VPC Endpoints

```bash
# Crear Gateway Endpoint para S3
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.s3 \
    --vpc-endpoint-type Gateway \
    --route-table-ids rtb-12345678 rtb-87654321

# Crear Interface Endpoint para SSM
aws ec2 create-vpc-endpoint \
    --vpc-id vpc-12345678 \
    --service-name com.amazonaws.us-east-1.ssm \
    --vpc-endpoint-type Interface \
    --subnet-ids subnet-12345678 subnet-87654321 \
    --security-group-ids sg-12345678

# Describir endpoints
aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values=vpc-12345678

# Eliminar endpoint
aws ec2 delete-vpc-endpoints --vpc-endpoint-ids vpce-12345678
```

## VPC Flow Logs

```bash
# Crear flow log a CloudWatch
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-12345678 \
    --traffic-type ALL \
    --log-destination-type cloud-watch-logs \
    --log-group-name /aws/vpc/flowlogs \
    --deliver-logs-permission-arn arn:aws:iam::123456789012:role/FlowLogRole

# Crear flow log a S3
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-12345678 \
    --traffic-type REJECT \
    --log-destination-type s3 \
    --log-destination arn:aws:s3:::mi-bucket-logs/vpc-flowlogs/

# Describir flow logs
aws ec2 describe-flow-logs --filter Name=resource-id,Values=vpc-12345678

# Eliminar flow log
aws ec2 delete-flow-logs --flow-log-id fl-12345678
```

## Elastic IPs

```bash
# Asignar Elastic IP
aws ec2 allocate-address --domain vpc

# Asignar desde pool de direcciones
aws ec2 allocate-address --domain vpc --address 203.0.113.5

# Asociar a instancia
aws ec2 associate-address \
    --instance-id i-1234567890abcdef0 \
    --allocation-id eipalloc-12345678

# Asociar a interfaz de red
aws ec2 associate-address \
    --network-interface-id eni-12345678 \
    --allocation-id eipalloc-12345678

# Describir direcciones
aws ec2 describe-addresses

# Desasociar
aws ec2 disassociate-address --association-id eipassoc-12345678

# Liberar
aws ec2 release-address --allocation-id eipalloc-12345678
```

## Consejos Rápidos

| Tarea | Comando |
|-------|---------|
| Crear VPC | `aws ec2 create-vpc --cidr-block 10.0.0.0/16` |
| Crear subnet | `aws ec2 create-subnet --vpc-id <vpc> --cidr-block 10.0.1.0/24` |
| Crear IGW | `aws ec2 create-internet-gateway` |
| Adjuntar IGW | `aws ec2 attach-internet-gateway --internet-gateway-id <igw> --vpc-id <vpc>` |
| Crear NAT Gateway | `aws ec2 create-nat-gateway --subnet-id <subnet> --allocation-id <eip>` |
| Crear route | `aws ec2 create-route --route-table-id <rtb> --destination-cidr-block 0.0.0.0/0 --gateway-id <igw>` |
| Crear SG | `aws ec2 create-security-group --group-name <name> --vpc-id <vpc>` |
| Agregar regla SG | `aws ec2 authorize-security-group-ingress --group-id <sg> ...` |

## Arquitectura VPC Básica

```
VPC (10.0.0.0/16)
├── IGW (Internet Gateway)
├── Subnet Pública (10.0.1.0/24) - AZ 1a
│   └── NAT Gateway
├── Subnet Pública (10.0.2.0/24) - AZ 1b
├── Subnet Privada (10.0.3.0/24) - AZ 1a
└── Subnet Privada (10.0.4.0/24) - AZ 1b

Route Tables:
- Public RT: 0.0.0.0/0 → IGW
- Private RT: 0.0.0.0/0 → NAT Gateway
```
