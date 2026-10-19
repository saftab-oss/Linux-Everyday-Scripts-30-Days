#!/bin/bash
# day8_net_check.sh - check network connectivity layer by layer
# Uses: ip a, ip route, ping, traceroute

PROBLEMS=0

# ---------- INFO: show my network setup (ip a + ip route) ----------
echo "=== My network ==="
ip -br a                 # -br = brief: one clean line per interface (my IP)
echo ""
ip route | grep default  # show my default gateway line
echo ""

# ---------- find the gateway automatically (from ip route) ----------
GATEWAY=$(ip route | grep default | awk '{print $3}')
# ip route | grep default  -> "default via 192.168.240.1 dev eth0 ..."
# awk '{print $3}'         -> prints the 3rd word -> the gateway IP

echo "=== Connectivity check ==="

# ---------- 1. Gateway (local network) ----------
if ping -c 2 "$GATEWAY" > /dev/null; then
  echo "[OK]   Gateway reachable ($GATEWAY)"
else
  echo "[FAIL] Gateway unreachable ($GATEWAY)"
  PROBLEMS=1
fi

# ---------- 2. Internet by IP (routing) ----------
if ping -c 2 8.8.8.8 > /dev/null; then
  echo "[OK]   Internet reachable (8.8.8.8)"
else
  echo "[FAIL] Internet unreachable (8.8.8.8)"
  PROBLEMS=1
  echo "       Tracing the path to see where it breaks:"
  traceroute 8.8.8.8      # only runs when the internet is down
fi

# ---------- 3. Internet by name (DNS) ----------
if ping -c 2 google.com > /dev/null; then
  echo "[OK]   DNS working (google.com)"
else
  echo "[FAIL] DNS not working (google.com)"
  PROBLEMS=1
fi

echo "=================="
exit $PROBLEMS
