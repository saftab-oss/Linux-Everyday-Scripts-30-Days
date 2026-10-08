#!/bin/bash

# Assign positional argument $1 (service name) to variable SERVICE
SERVICE=$1

# Sanity Check: Ensure an argument was passed
if [ -z "$SERVICE" ]; then
    echo "[ERROR] Usage: $0 <service_name>"
    echo "Example: $0 nginx"
    exit 1
fi

echo "=== [DevOps Auto-Healer] Checking status of: $SERVICE ==="

# Check service status quietly (output redirected to /dev/null)
systemctl is-active "$SERVICE" &> /dev/null

# $? holds the exit code of systemctl is-active (0 = active)
if [ $? -eq 0 ]; then
    echo "[PASS] Service '$SERVICE' is healthy and active."
else
    echo "[WARN] Service '$SERVICE' is NOT active!"
    echo "[ACTION] Attempting automatic recovery..."
    
    # Attempt to restart the service using root privileges
    sudo systemctl restart "$SERVICE"
    
    # Re-check status after restart attempt
    systemctl is-active "$SERVICE" &> /dev/null
    
    # Verify if the restart fixed the issue
    if [ $? -eq 0 ]; then
        echo "[RECOVERED] Service '$SERVICE' was successfully restarted!"
    else
        echo "[CRITICAL] Failed to restart '$SERVICE'. Manual intervention required."
        exit 1
    fi
fi
