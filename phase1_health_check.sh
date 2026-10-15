#!/bin/bash
# =============================================================================
# phase1_health_check.sh - Server health check (Days 1-7 combined)
#
# Runs 7 checks in sequence, prints [OK]/[WARN]/[FAIL] for each,
# and exits 0 if everything passed or 1 if any check failed.
#
# Usage:   ./phase1_health_check.sh [disk_limit]
# Example: ./phase1_health_check.sh 90
#
# Exit codes:
#   0 = all checks passed
#   1 = at least one check failed
# =============================================================================


# ---------- CONFIG (edit these for your server) ----------
DISK_LIMIT="${1:-80}"          # disk % that triggers a warning; $1 or default 80
REQUIRED_PROCESS="cron"        # a process that must be running (Day 1)
REQUIRED_SERVICE="cron"        # a service that must be active (Day 2)
CHECK_DIR="$HOME"              # folder to scan for bad permissions (Day 3)
REQUIRED_USER="root"           # a user account that must exist (Day 5)
REQUIRED_GROUP="sudo"          # a group that must exist (Day 5)

PROBLEMS=0                     # running count of failed checks (Day 3 pattern)
# $1 = first argument;  ${1:-80} = use it, or 80 if empty (Day 6)


echo "========================================"
echo " SERVER HEALTH CHECK - $(hostname) - $(date '+%F %T')"
echo "========================================"
# $(...) runs a command and drops its output here (Day 1)
# hostname = this machine's name;  date '+%F %T' = 2026-10-15 07:44:00


# ========== CHECK 1: PROCESS (Day 1) ==========
echo ""
echo "[1] Process: $REQUIRED_PROCESS"
if pgrep -x "$REQUIRED_PROCESS" > /dev/null; then
  # pgrep       = find a process by name
  # -x          = exact name match (not partial)
  # > /dev/null = hide the PID it prints, keep only the exit code
  echo "    [OK] $REQUIRED_PROCESS is running"
else
  echo "    [FAIL] $REQUIRED_PROCESS is NOT running"
  PROBLEMS=$((PROBLEMS + 1))   # bump the problem counter by 1
fi


# ========== CHECK 2: SERVICE (Day 2) ==========
echo ""
echo "[2] Service: $REQUIRED_SERVICE"
if ! command -v systemctl > /dev/null || [ ! -d /run/systemd/system ]; then
  # command -v systemctl   = is systemctl available? (Day 7)
  # !                      = NOT, so true when it is MISSING
  # ||                     = OR
  # [ ! -d /run/systemd/system ] = systemd is NOT the init system
  #   (true in containers / WSL without systemd) -> skip instead of erroring
  echo "    [WARN] systemd not available, skipping service check"
elif systemctl is-active --quiet "$REQUIRED_SERVICE" 2>/dev/null; then
  # is-active        = is the service running?
  # --quiet          = print nothing, just set the exit code (Day 2)
  # 2>/dev/null      = hide any stderr noise
  echo "    [OK] $REQUIRED_SERVICE is active"
else
  echo "    [FAIL] $REQUIRED_SERVICE is not active"
  PROBLEMS=$((PROBLEMS + 1))
fi


# ========== CHECK 3: FILE PERMISSIONS (Day 3) ==========
echo ""
echo "[3] Permissions in: $CHECK_DIR"
WW=$(find "$CHECK_DIR" -type f -perm -o+w 2>/dev/null)
# find        = search for files
# -type f     = regular files only
# -perm -o+w  = others have write permission (world-writable = risky)
# 2>/dev/null = hide "Permission denied" errors
# $( )        = save the results into WW
if [ -z "$WW" ]; then
  # -z = is it empty? (no bad files found)
  echo "    [OK] No world-writable files"
else
  echo "    [FAIL] World-writable files found:"
  echo "$WW" | head -5          # show at most the first 5
  PROBLEMS=$((PROBLEMS + 1))
fi


# ========== CHECK 4: ENVIRONMENT VARIABLES (Day 4) ==========
echo ""
echo "[4] Environment variables"
if [ -z "$HOME" ]; then
  # -z = empty? If HOME is unset, something is very wrong
  echo "    [FAIL] HOME is not set"
  PROBLEMS=$((PROBLEMS + 1))
else
  echo "    [OK] HOME = $HOME"
fi
if [ -z "$PATH" ]; then
  echo "    [FAIL] PATH is not set"
  PROBLEMS=$((PROBLEMS + 1))
else
  echo "    [OK] PATH is set"
fi


# ========== CHECK 5: USER & GROUP (Day 5) ==========
echo ""
echo "[5] Required user and group"
if grep -q "^$REQUIRED_USER:" /etc/passwd; then
  # grep -q        = search quietly (no output, just exit code)
  # "^name:"       = a line that STARTS WITH name followed by a colon
  # /etc/passwd    = the file that lists all users
  echo "    [OK] User '$REQUIRED_USER' exists"
else
  echo "    [FAIL] User '$REQUIRED_USER' missing"
  PROBLEMS=$((PROBLEMS + 1))
fi
if grep -q "^$REQUIRED_GROUP:" /etc/group; then
  echo "    [OK] Group '$REQUIRED_GROUP' exists"
else
  echo "    [FAIL] Group '$REQUIRED_GROUP' missing"
  PROBLEMS=$((PROBLEMS + 1))
fi


# ========== CHECK 6: DISK USAGE (Day 6) ==========
echo ""
echo "[6] Disk usage on /"
USAGE=$(df --output=pcent / | tail -1 | tr -dc '0-9')
# df --output=pcent / = show only the % used column for the / disk
# tail -1             = keep the last line (drop the "Use%" header)
# tr -dc '0-9'        = delete everything that is NOT a digit -> plain number
if [ "$USAGE" -lt "$DISK_LIMIT" ]; then
  # -lt = less than (number comparison)
  echo "    [OK] ${USAGE}% used (limit ${DISK_LIMIT}%)"
else
  echo "    [FAIL] ${USAGE}% used - over ${DISK_LIMIT}% limit"
  echo "    Biggest folders:"
  du -sh "$CHECK_DIR"/* 2>/dev/null | sort -rh | head -3
  # du -sh  = size summary, human-readable, per item
  # sort -rh = sort by human size, reverse (biggest first)
  # head -3  = top 3 only
  PROBLEMS=$((PROBLEMS + 1))
fi


# ========== CHECK 7: REQUIRED PACKAGES (Day 7) ==========
echo ""
echo "[7] Required tools installed"
if command -v git > /dev/null; then
  # command -v git = is the 'git' command available?
  echo "    [OK] git installed"
else
  echo "    [FAIL] git not installed"
  PROBLEMS=$((PROBLEMS + 1))
fi
if command -v curl > /dev/null; then
  echo "    [OK] curl installed"
else
  echo "    [FAIL] curl not installed"
  PROBLEMS=$((PROBLEMS + 1))
fi


# ========== SUMMARY ==========
echo ""
echo "========================================"
if [ "$PROBLEMS" -eq 0 ]; then
  # -eq = equal (number comparison)
  echo " RESULT: ALL CHECKS PASSED"
else
  echo " RESULT: $PROBLEMS CHECK(S) FAILED"
fi
echo "========================================"

exit $PROBLEMS
# exit with the problem count: 0 = healthy, 1+ = something failed
# (cron or a monitoring tool reads this code to decide whether to alert)
