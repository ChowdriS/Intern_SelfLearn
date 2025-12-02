#!/bin/bash

# Install nginx
sudo amazon-linux-extras install nginx1
# sudo yum install -y nginx

systemctl enable nginx

# Write nginx config — QUOTED HEREDOC
cat << 'EOF' > /etc/nginx/nginx.conf
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent"';
    access_log /var/log/nginx/access.log main;

    upstream flask_backend {
        server ${flask_ip}:80;
    }

    server {
        listen 80;

        location / {
            proxy_pass http://flask_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /nginx_status {
            stub_status;
            allow all;
        }
    }
}
EOF

# Restart nginx
systemctl restart nginx

echo "Installing AWS MGN Replication Agent..."

# Download installer for us-east-1
sudo wget -O /tmp/aws-replication-installer-init \
  https://aws-application-migration-service-us-east-1.s3.us-east-1.amazonaws.com/latest/linux/aws-replication-installer-init

sudo chmod +x /tmp/aws-replication-installer-init

# Run installer for region us-east-1
print '\n' | sudo /tmp/aws-replication-installer-init --region us-east-1 --user-provided-id we-tried
 <<EOF2
EOF2

echo "AWS MGN Replication Agent installation complete."