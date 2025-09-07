#!/bin/bash
set -e

# Variables
NODE_EXPORTER_VERSION="1.7.0"
NGINX_EXPORTER_VERSION="0.11.0"
MONITORING_VM_IP="10.0.31.157"
NGINX_CONF="/etc/nginx/sites-available/default"
EXPORTER_DIR="/opt/nginx_exporter"
EXPORTER_USER="nginx_exporter"

# 1. Configure Nginx stub_status
echo "[INFO] Configuring Nginx stub_status..."

if ! grep -q "location /nginx_status" $NGINX_CONF; then
    sudo tee -a $NGINX_CONF > /dev/null <<EOF

    location /nginx_status {
        stub_status;
        allow ${MONITORING_VM_IP};
        deny all;
    }
EOF
    echo "[INFO] Nginx stub_status added."
else
    echo "[INFO] Nginx stub_status already configured."
fi

sudo nginx -t
sudo systemctl restart nginx
echo "[INFO] Nginx restarted successfully."

# 2. Create dedicated user for exporter
if ! id -u $EXPORTER_USER >/dev/null 2>&1; then
    sudo useradd --system --no-create-home --shell /bin/false $EXPORTER_USER
    echo "[INFO] User $EXPORTER_USER created."
else
    echo "[INFO] User $EXPORTER_USER already exists."
fi

# 3. Install Nginx Exporter
echo "[INFO] Installing Nginx Prometheus Exporter..."
sudo rm -rf $EXPORTER_DIR
sudo mkdir -p $EXPORTER_DIR
cd /opt
wget -q https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v${NGINX_EXPORTER_VERSION}/nginx-prometheus-exporter_${NGINX_EXPORTER_VERSION}_linux_amd64.tar.gz -O nginx_exporter.tar.gz
tar xzf nginx_exporter.tar.gz -C $EXPORTER_DIR --strip-components=1
sudo chmod +x $EXPORTER_DIR/nginx-prometheus-exporter
sudo chown -R $EXPORTER_USER:$EXPORTER_USER $EXPORTER_DIR
echo "[INFO] Nginx Exporter installed to $EXPORTER_DIR"

# 4. Create systemd service
echo "[INFO] Creating systemd service for Nginx Exporter..."
sudo tee /etc/systemd/system/nginx_exporter.service > /dev/null <<EOF
[Unit]
Description=Nginx Prometheus Exporter
After=network.target

[Service]
User=${EXPORTER_USER}
Group=${EXPORTER_USER}
WorkingDirectory=${EXPORTER_DIR}
ExecStart=${EXPORTER_DIR}/nginx-prometheus-exporter -nginx.scrape-uri http://localhost/nginx_status
Restart=always
Type=simple

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable nginx_exporter
sudo systemctl restart nginx_exporter
echo "[INFO] Nginx Exporter service started."

# 5. Firewall
sudo ufw allow from ${MONITORING_VM_IP} to any port 9113
echo "[INFO] Firewall updated to allow monitoring VM."

# 6. Finish
echo "[SUCCESS] Nginx + Prometheus Exporter setup complete!"
echo "Exporter metrics available at: http://${MONITORING_VM_IP}:9113/metrics"
