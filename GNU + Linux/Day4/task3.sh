#!/bin/bash

LOAD=$(uptime | awk '{print $(NF-2)}' | tr -d ,)
if (( $(echo "$LOAD > 2.0" | bc -l) )); then
  echo "$(date) Load Average is $LOAD" >> /var/log/load.log
fi
