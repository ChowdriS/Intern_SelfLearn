#!/bin/bash
sudo apt update -y
sudo apt install -y nginx
echo "Hello, World from $(hostname -f)" | sudo tee /var/www/html/index.html
sudo systemctl start nginx
sudo systemctl enable nginx
