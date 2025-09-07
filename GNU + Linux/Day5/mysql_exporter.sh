#!/bin/bash
# Install MySQL Exporter for Prometheus

set -e

VERSION="0.14.0"
USER="mysqld_exporter"
PASS="StrongPassword123!" 

echo "[*] Installing MySQL Exporter $VERSION..."

# Create MySQL user
sudo mysql -e "CREATE USER IF NOT EXISTS '$USER'@'%' IDENTIFIED BY '$PASS';
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '$USER'@'%';
FLUSH PRIVILEGES;"

# Install exporter
cd /tmp
curl -sLO https://github.com/prometheus/mysqld_exporter/releases/download/v$VERSION/mysqld_exporter-$VERSION.linux-amd64.tar.gz
tar xvf mysqld_exporter-$VERSION.linux-amd64.tar.gz
sudo mv mysqld_exporter-$VERSION.linux-amd64/mysqld_exporter /usr/local/bin/
sudo useradd --no-create-home --shell /bin/false $USER || true

# Config
sudo bash -c "cat > /etc/default/mysqld_exporter <<EOF
DATA_SOURCE_NAME=\"$USER:$PASS@(127.0.0.1:3306)/\"
EOF"

# Systemd service
cat <<EOF | sudo tee /etc/systemd/system/mysqld_exporter.service
[Unit]
Description=MySQL Prometheus Exporter
After=network.target

[Service]
User=$USER
EnvironmentFile=/etc/default/mysqld_exporter
ExecStart=/usr/local/bin/mysqld_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now mysqld_exporter

echo "[+] MySQL Exporter running on port 9104"
