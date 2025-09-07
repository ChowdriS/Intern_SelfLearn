#!/bin/bash
# Script to install Prometheus + Grafana on Monitoring VM

set -e

# ========================
# 1. Variables
# ========================
PROM_VERSION="2.54.1"
GRAFANA_VERSION="11.1.0"
WEB_VM_IP="10.0.25.111"
DB_VM_IP="10.0.25.111"

# ========================
# 2. Install Prometheus
# ========================
echo "[INFO] Installing Prometheus..."
cd /opt
wget -q https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
mv prometheus-${PROM_VERSION}.linux-amd64 prometheus

# Create Prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus || true

# Move binaries
sudo cp /opt/prometheus/prometheus /usr/local/bin/
sudo cp /opt/prometheus/promtool /usr/local/bin/

# Create directories
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo cp -r /opt/prometheus/consoles /etc/prometheus
sudo cp -r /opt/prometheus/console_libraries /etc/prometheus

# ========================
# 3. Prometheus Config
# ========================
echo "[INFO] Configuring Prometheus..."
cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "linux_web"
    static_configs:
      - targets: ["${WEB_VM_IP}:9100"]

  - job_name: "nginx"
    static_configs:
      - targets: ["${WEB_VM_IP}:9113"]

  - job_name: "linux_db"
    static_configs:
      - targets: ["${DB_VM_IP}:9100"]

  - job_name: "mysql"
    static_configs:
      - targets: ["${DB_VM_IP}:9104"]   # only if mysql exporter is installed
EOF

# Create systemd service
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus/ \\
  --web.console.templates=/etc/prometheus/consoles \\
  --web.console.libraries=/etc/prometheus/console_libraries
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# ========================
# 4. Install Grafana
# ========================
echo "[INFO] Installing Grafana..."
sudo apt-get update -y
sudo apt-get install -y adduser libfontconfig1 musl

wget -q https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
tar -zxvf grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz
sudo mv grafana-${GRAFANA_VERSION} /usr/share/grafana

# Create systemd service
cat <<EOF | sudo tee /etc/systemd/system/grafana.service
[Unit]
Description=Grafana
After=network.target

[Service]
ExecStart=/usr/share/grafana/bin/grafana-server web \\
  --homepath=/usr/share/grafana
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable grafana
sudo systemctl start grafana

# ========================
# 5. Firewall
# ========================
echo "[INFO] Configuring firewall..."
sudo ufw allow 9090    # Prometheus
sudo ufw allow 3000    # Grafana

# ========================
# 6. Finish
# ========================
echo "[SUCCESS] Prometheus running on :9090"
echo "[SUCCESS] Grafana running on :3000"
echo ">> Open Grafana in browser http://<MONITORING_VM_IP>:3000"
echo "   Default login: admin / admin"
echo ">> Add Prometheus as data source: http://localhost:9090"
