#!/bin/bash
# Install Apache Exporter for Prometheus

set -e

VERSION="0.13.0"
USER="apache_exporter"
MON_IP="10.0.31.157"

echo "[*] Installing Apache Exporter $VERSION..."

# Enable mod_status
sudo a2enmod status
cat <<EOF | sudo tee /etc/apache2/conf-available/prom_status.conf
ExtendedStatus On
<Location /server-status>
    SetHandler server-status
    Require ip $MON_IP 127.0.0.1
</Location>
EOF
sudo a2enconf prom_status
sudo systemctl reload apache2

# Install exporter
cd /tmp
curl -sLO https://github.com/Lusitaniae/apache_exporter/releases/download/v$VERSION/apache_exporter-$VERSION.linux-amd64.tar.gz
tar xvf apache_exporter-$VERSION.linux-amd64.tar.gz
sudo mv apache_exporter-$VERSION.linux-amd64/apache_exporter /usr/local/bin/
sudo useradd -r -s /usr/sbin/nologin $USER || true

# Systemd service
cat <<EOF | sudo tee /etc/systemd/system/apache_exporter.service
[Unit]
Description=Prometheus Apache Exporter
After=network.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/apache_exporter -scrape-uri http://127.0.0.1/server-status?auto

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now apache_exporter

echo "[+] Apache Exporter running on port 9117"
