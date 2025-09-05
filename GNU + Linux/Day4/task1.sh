#!/bin/bash

LOGFILE="/var/log/file_backup.log"

if [ -z "$1" ]; then
    echo "No File Provided"
    exit 1
fi

FILE=$1

if [ ! -f "$FILE" ]; then
    echo "Error: not a valid file"
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

BACKUP_FILE="${FILE}.bak-${TIMESTAMP}"

cp "$FILE" "$BACKUP_FILE"

echo "$(date +"%Y-%m-%d %H:%M:%S") : Backed up $FILE to $BACKUP_FILE" >> "$LOGFILE"

echo "Backup completed successfully."