#!/bin/bash
# Exit immediately on errors
apt update -y
apt install -y nginx

# Create custom content
echo "<h1>Welcome to Nginx Root (/)</h1>" > /var/www/html/index.html
mkdir -p /var/www/html/path2
echo "<h1>Welcome to Nginx path2 (/path2)</h1>" > /var/www/html/path2/index.html

# Create nginx config for /path2
cat <<'EOF' > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location /path2 {
        alias /var/www/html/path2;
        index index.html;
    }
}
EOF

# Restart nginx to apply changes
systemctl restart nginx
