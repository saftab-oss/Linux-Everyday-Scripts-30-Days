#!/bin/bash
## day13_14_netsec_check.sh - check DNS resolution + firewall status
## Day 13 (dig) + Day 14 (ufw)
## Usage: ./day13_14_netsec_check.sh <hostname>
## Example: ./day13_14_netsec_check.sh google.com

HOST="$1"      ## example: HOST = google.com
PROBLEMS=0     ## counter: 0 = all good, 1 if a check fails

## --- guard: need a hostname ---
if [ -z "$HOST" ]; then
  echo "Usage: $0 <hostname>"
  exit 2
fi

echo "=== Network check for: $HOST ==="

## --- Day 13: does the name resolve to an IP? ---
IP=$(dig +short "$HOST")
## dig +short "$HOST" = ask DNS for the IP, print only the answer
## $( )               = save the result into IP
if [ -n "$IP" ]; then
  ## -n = not empty, so we got an IP back
  echo "[OK]   DNS: $HOST -> $IP"
else
  echo "[FAIL] DNS: $HOST did not resolve"
  PROBLEMS=1
fi

## --- Day 14: is the firewall active? ---
if sudo ufw status | grep -q "Status: active"; then
  ## sudo ufw status          = show the firewall state
  ## grep -q "Status: active" = quietly check if it says "active"
  echo "[OK]   Firewall is active"
else
  echo "[WARN] Firewall is inactive"
  ## WARN, not FAIL - off is normal on a dev box, worth noting on a server
fi

echo "================================"
exit $PROBLEMS
