#!/bin/bash

tar -czf /tmp/data-$(date +%F).tar.gz /srv/data

mv /tmp/data-$(date +%F).tar.gz /backups/

find /backups/ -name "data-*.tar.gz" -type f -mtime +14 -delete

echo "Backup completed"
