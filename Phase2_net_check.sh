#!/bin/bash
## phase2_net_check.sh - network health check (Days 8-14 combined)
## Runs 7 checks: connectivity, ports, HTTP, SSH, DNS, firewall.
## Exit: 0 = all healthy, 1 = at least one failed

## ---------- config (edit for your environment) ----------
PORT=22                        ## port that should be listening (Day 9)
URL="https://www.google.com"   ## web service to health-check (Day 10)
DNS_NAME="google.com"          ## name that should resolve (Day 13)
SSH_HOST="$USER@localhost"     ## ssh target (Day 11)

PROBLEMS=0                     ## 0 = all good, +1 per failed check

echo "=== Phase 2 Network Health Check ==="

## --- 1. Connectivity: gateway (Day 8) ---
GATEWAY=$(ip route | grep default | awk '{print $3}')
## ip route | grep default | awk '{print $3}' = auto-find the gateway IP
if ping -c 2 "$GATEWAY" &> /dev/null; then
  ## ping -c 2 = send 2 packets;  &> /dev/null = hide all output
  echo "[OK]   Gateway reachable ($GATEWAY)"
else
  echo "[FAIL] Gateway unreachable ($GATEWAY)"
  PROBLEMS=$((PROBLEMS + 1))
fi

## --- 2. Connectivity: internet (Day 8) ---
if ping -c 2 8.8.8.8 &> /dev/null; then
  echo "[OK]   Internet reachable"
else
  echo "[FAIL] Internet unreachable"
  PROBLEMS=$((PROBLEMS + 1))
fi

## --- 3. Port listening (Day 9) ---
if ss -tln | grep -q ":$PORT "; then
  ## ss -tln = TCP listening numeric; grep for the port (trailing space!)
  echo "[OK]   Port $PORT is listening"
else
  echo "[FAIL] Port $PORT is not listening"
  PROBLEMS=$((PROBLEMS + 1))
fi

## --- 4. HTTP returns 200 (Day 10) ---
CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
## -s silent, -o /dev/null discard body, -w print only the status code
if [ "$CODE" = "200" ]; then
  echo "[OK]   HTTP $URL -> $CODE"
else
  echo "[FAIL] HTTP $URL -> $CODE"
  PROBLEMS=$((PROBLEMS + 1))
fi

## --- 5. SSH reachable by key (Day 11) ---
if ssh -o BatchMode=yes -o ConnectTimeout=5 "$SSH_HOST" 'echo ok' &> /dev/null; then
  ## BatchMode=yes = never prompt for password (fail instead)
  echo "[OK]   SSH to $SSH_HOST works"
else
  echo "[FAIL] SSH to $SSH_HOST failed"
  PROBLEMS=$((PROBLEMS + 1))
fi

## --- 6. DNS resolves (Day 13) ---
if [ -n "$(dig +short "$DNS_NAME")" ]; then
  ## dig +short = just the IP;  -n = not empty = it resolved
  echo "[OK]   DNS resolves $DNS_NAME"
else
  echo "[FAIL] DNS cannot resolve $DNS_NAME"
  PROBLEMS=$((PROBLEMS + 1))
fi

## --- 7. Firewall active (Day 14) ---
if sudo ufw status | grep -q "Status: active"; then
  echo "[OK]   Firewall is active"
else
  echo "[WARN] Firewall is inactive"
  ## WARN, not FAIL - off is normal on a dev box
fi

echo "=== Summary: $PROBLEMS problem(s) found ==="
exit $PROBLEMS
