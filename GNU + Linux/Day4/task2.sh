#!/bin/bash

find /var/tmp -name "*.log" -type f -mtime +7 -delete
