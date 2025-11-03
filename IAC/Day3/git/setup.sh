#!/bin/bash

# Update package lists and install dependencies
sudo apt update
sudo apt install -y python3-flask python3-pymysql

# Run the Flask backend API (serves HTML and DB time) in background with output logged
nohup python3 /home/ubuntu/app/app.py > /home/ubuntu/app/flask.log 2>&1 &

# No need to run a separate static server since Flask serves the HTML

echo "Flask app started in background"
