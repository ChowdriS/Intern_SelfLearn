#!/bin/bash
set -e

apt-get update -y
apt-get install -y git

# Clone app repo and run setup
git clone "${git_repo}" /home/ubuntu/app

# Navigate to app directory
cd /home/ubuntu/app

# Show DB credentials for debug
echo "DB Endpoint: ${db_endpoint}"
echo "DB Username: ${db_username}"
echo "DB Password: ${db_password}"

# Export DB credentials
export DB_ENDPOINT="${db_endpoint}"
export DB_USERNAME="${db_username}"
export DB_PASSWORD="${db_password}"

chmod +x setup.sh

# Run setup.sh with environment vars available even with sudo
sudo -E ./setup.sh
