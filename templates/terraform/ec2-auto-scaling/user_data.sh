#!/bin/bash
set -e

# Update system
yum update -y

# Install and configure Apache
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Create custom index page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AWS Auto Scaling Demo</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            padding: 30px;
            border-radius: 10px;
            backdrop-filter: blur(10px);
        }
        h1 { margin-top: 0; }
        .info {
            background: rgba(255, 255, 255, 0.2);
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .label { font-weight: bold; color: #ffd700; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Auto Scaling Group Demo</h1>
        <p>This page is served by an EC2 instance in an Auto Scaling Group behind an Application Load Balancer.</p>

        <div class="info">
            <p><span class="label">Instance ID:</span> INSTANCE_ID_PLACEHOLDER</p>
            <p><span class="label">Availability Zone:</span> AVAILABILITY_ZONE_PLACEHOLDER</p>
            <p><span class="label">Private IP:</span> PRIVATE_IP_PLACEHOLDER</p>
            <p><span class="label">Environment:</span> ENVIRONMENT_PLACEHOLDER</p>
        </div>

        <p>Refresh the page to see requests potentially served by different instances!</p>
    </div>
</body>
</html>
EOF

# Replace placeholders with actual values
sed -i "s/INSTANCE_ID_PLACEHOLDER/$INSTANCE_ID/g" /var/www/html/index.html
sed -i "s/AVAILABILITY_ZONE_PLACEHOLDER/$AVAILABILITY_ZONE/g" /var/www/html/index.html
sed -i "s/PRIVATE_IP_PLACEHOLDER/$PRIVATE_IP/g" /var/www/html/index.html
sed -i "s/ENVIRONMENT_PLACEHOLDER/${environment}/g" /var/www/html/index.html

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Create CloudWatch agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CWEOF'
{
    "metrics": {
        "namespace": "EC2/AutoScaling",
        "metrics_collected": {
            "disk": {
                "measurement": ["used_percent"],
                "resources": ["*"]
            },
            "mem": {
                "measurement": ["mem_used_percent"]
            }
        }
    }
}
CWEOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
