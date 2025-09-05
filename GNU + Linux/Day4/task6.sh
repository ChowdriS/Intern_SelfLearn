#!/bin/bash

LOGFILE="/var/log/service_monitor.log"

if ! systemctl is-active --quiet sshd; then
    echo "$(date) sshd was down. Restarting..." >> $LOGFILE
    systemctl restart sshd
    echo "$(date) sshd restarted." >> $LOGFILE
fi

if ! systemctl is-active --quiet nginx; then
    echo "$(date) nginx was down. Restarting..." >> $LOGFILE
    systemctl restart nginx
    echo "$(date) nginx restarted." >> $LOGFILE
fi
