#!/bin/bash

sudo yum update -y
sudo yum install -y mariadb105-server

sudo systemctl enable --now mariadb

mkdir -p /etc/my.cnf.d
cat > /etc/my.cnf.d/remote.cnf <<EOF
[mysqld]
bind-address = 0.0.0.0
EOF

systemctl restart mariadb

mysql -e "CREATE DATABASE IF NOT EXISTS \`${db_name}\`;"
mysql -e "CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_pass}';"
mysql -e "GRANT ALL PRIVILEGES ON \`${db_name}\`.* TO '${db_user}'@'%';"
mysql -e "FLUSH PRIVILEGES;"
