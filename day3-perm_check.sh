#!/bin/bash
# perm_check.sh - check a folder for unsafe permissions
# Usage: ./perm_check.sh <folder>

DIR="$1"
PROBLEMS=0

## z means if folder or directory is empty
if [ -z "$DIR" ]; then
  echo "Usage: $0 <folder>"
  exit 2
fi

##! -d means if the entered input is not a directory
if [ ! -d "$DIR" ]; then
  echo "ERROR: $DIR is not a folder"
  exit 2
fi

echo "Checking $DIR ..."

# Check 1: files anyone can edit
WW=$(find "$DIR" -type f -perm -o+w)
if [ -n "$WW" ]; then
  echo "[FAIL] World-writable files:"
  echo "$WW"
  PROBLEMS=1
else
  echo "[OK] No world-writable files"
fi

# Check 2: private keys that are not 600
KEYS=$(find "$DIR" -type f -name "*.pem" ! -perm 600)
if [ -n "$KEYS" ]; then
  echo "[FAIL] Keys not set to 600:"
  echo "$KEYS"
  PROBLEMS=1
else
  echo "[OK] All keys are 600"
fi

exit $PROBLEMS
