#!/bin/bash

# Define the service we want to monitor
 SERVICE=$1

echo "=== [DevOps Health Check] Checking status of service: $SERVICE ==="

# Search for the service PID using pgrep
PID=$(pgrep -x "$SERVICE")

# Check if pgrep succeeded (Exit Code 0)
if [ $? -eq 0 ]; then
    echo "[PASS] $SERVICE is healthy and running."
    echo "Active Process ID(s): $PID"
else
    echo "[FAIL] $SERVICE is NOT running!"
    echo "Action required: Please investigate service logs."
    exit 1
fi
