#!/bin/bash

CODE_DIR="$1"

LOGFILE="/home/ubuntu/sec_info.log"

if [ -z "$CODE_DIR" ]; then
    echo "No directory provided to scan."
    exit 1
fi

touch "$LOGFILE"
chmod 600 "$LOGFILE"

PATTERNS="AWS_SECRET_KEY|AWS_ACCESS_KEY_ID|DB_PASSWORD"

grep -rI -E -i "$PATTERNS" "$CODE_DIR" >> "$LOGFILE"