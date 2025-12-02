#!/bin/bash

# Update system
sudo yum update -y

# Install Python3 + pip
sudo yum install -y python3 python3-pip

# Create app directory
mkdir -p /app

# Write Flask application code
cat << 'EOF' > /app/app.py
from flask import Flask
import os
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

@app.route('/')
def hello():
    try:
        required_env = ["DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME"]
        for var in required_env:
            if var not in os.environ:
                return f"ERROR: Missing environment variable: {var}", 500

        conn = mysql.connector.connect(
            host=os.environ['DB_HOST'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASSWORD'],
            database=os.environ['DB_NAME']
        )

        if not conn.is_connected():
            return "ERROR: Failed to connect to MySQL database.", 500

        cur = conn.cursor()

        try:
            cur.execute("SELECT VERSION()")
            db_version = cur.fetchone()
        except Error as query_err:
            return f"ERROR running SQL query: {query_err}", 500

        cur.close()
        conn.close()

        hostname = os.environ.get('HOSTNAME') or os.uname()[1]
        return f"Hello from {hostname}! Database version: {db_version[0]}"

    except Error as db_err:
        return f"MySQL ERROR: {db_err}", 500

    except Exception as e:
        return f"Unexpected ERROR: {e}", 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOF

# Install Python dependencies
pip3 install flask mysql-connector-python

# Persist environment variables
echo "DB_USER=${db_user}"       >> /etc/environment
echo "DB_PASSWORD=${db_pass}"   >> /etc/environment
echo "DB_NAME=${db_name}"       >> /etc/environment
echo "DB_HOST=${db_host}"       >> /etc/environment

# Reload environment vars
source /etc/environment

# Create systemd service for Flask
cat << EOF > /etc/systemd/system/flask.service
[Unit]
Description=Flask Application
After=network.target

[Service]
ExecStart=/usr/bin/python3 /app/app.py
WorkingDirectory=/app
Restart=always
EnvironmentFile=/etc/environment

[Install]
WantedBy=multi-user.target
EOF

# Start and enable Flask app
systemctl daemon-reload
systemctl enable flask
systemctl start flask
