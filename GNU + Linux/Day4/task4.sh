#!/bin/bash

GROUP="dev"
PASSFILE="/root/passwords.txt"

if ! getent group $GROUP > /dev/null; then
    groupadd $GROUP
fi

chmod 600 $PASSFILE

for i in {1..20}; do
    USER="dev$i"
    if ! id $USER &>/dev/null; then
        useradd -m -g $GROUP $USER
    fi
    PASS=$(openssl rand -base64 12)
    echo "$USER:$PASS" | chpasswd
    echo "$USER : $PASS" >> $PASSFILE
done

echo "developer accounts created."
