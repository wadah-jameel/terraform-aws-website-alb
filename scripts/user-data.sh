#!/bin/bash

# User data script for EC2 instances
# This script runs when the instance starts

# Update system
yum update -y

# Install Apache web server
yum install -y httpd

# Install AWS CLI (if not already installed)
yum install -y awscli

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create web directory
mkdir -p /var/www/html

# Create a simple server info endpoint
cat > /var/www/html/server-info << 'EOF'
{
    "instanceId": "$(curl -s http://169.254.169.254/latest/meta-data/instance-id)",
    "region": "$(curl -s http://169.254.169.254/latest/meta-data/placement/region)",
    "availabilityZone": "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)",
    "instanceType": "$(curl -s http://169.254.169.254/latest/meta-data/instance-type)",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

# Make the server-info executable and process it
chmod +x /var/www/html/server-info

# Create a simple health check endpoint
echo "OK" > /var/www/html/health

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure Apache to serve JSON files properly
cat > /etc/httpd/conf.d/json.conf << 'EOF'
<Files "server-info">
    Header set Content-Type "application/json"
</Files>
EOF

# Create a script to update server info dynamically
cat > /usr/local/bin/update-server-info.sh << 'EOF'
#!/bin/bash
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

cat > /var/www/html/server-info << END
{
    "instanceId": "$INSTANCE_ID",
    "region": "$REGION",
    "availabilityZone": "$AZ",
    "instanceType": "$INSTANCE_TYPE",
    "timestamp": "$TIMESTAMP"
}
END
EOF

chmod +x /usr/local/bin/update-server-info.sh

# Run the update script initially
/usr/local/bin/update-server-info.sh

# Add cron job to update server info every minute
echo "* * * * * /usr/local/bin/update-server-info.sh" | crontab -

# Download and deploy website files from S3 (we'll create this bucket)
# For now, create a simple placeholder website
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Static Website - Loading...</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        .loading { color: #666; }
    </style>
</head>
<body>
    <h1>Website Loading...</h1>
    <p class="loading">Please wait while we set up your static website.</p>
    <p>Instance ID: <span id="instance-id">Loading...</span></p>
    <script>
        fetch('/server-info')
            .then(response => response.json())
            .then(data => {
                document.getElementById('instance-id').textContent = data.instanceId;
            })
            .catch(error => {
                console.log('Error:', error);
            });
    </script>
</body>
</html>
EOF

# Restart Apache to apply all configurations
systemctl restart httpd

# Log completion
echo "User data script completed at $(date)" >> /var/log/user-data.log
