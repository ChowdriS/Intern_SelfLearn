#!/bin/bash
# Install Node Exporter for Linux metrics

set -e

VERSION="1.6.1"
USER="node_exporter"

echo "[*] Installing Node Exporter $VERSION..."

# Create user
if ! id -u $USER >/dev/null 2>&1; then
    sudo useradd --no-create-home --shell /bin/false $USER
fi

# Download & install
cd /tmp
curl -sLO https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz
tar xvf node_exporter-$VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$VERSION.linux-amd64/node_exporter /usr/local/bin/
sudo chown $USER:$USER /usr/local/bin/node_exporter

# Systemd service
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network-online.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

echo "[+] Node Exporter installed and running on port 9100"
