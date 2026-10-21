#!/bin/bash
## day11_12_backup.sh - back up a local folder to a remote server
## Usage: ./day11_12_backup.sh <user@host> <source_dir> <remote_dir>

HOST="$1"      ## example: HOST = syed@localhost
SRC="$2"       ## example: SRC  = ~/Linux-Daily
DEST="$3"      ## example: DEST = /tmp/bkp

## --- guard: need all three inputs ---
if [ -z "$HOST" ] || [ -z "$SRC" ] || [ -z "$DEST" ]; then
  echo "Usage: $0 <user@host> <source_dir> <remote_dir>"
  exit 2
fi

## --- guard: source folder must exist ---
if [ ! -d "$SRC" ]; then
  echo "ERROR: $SRC is not a folder"
  exit 2
fi

echo "=== Backup: $SRC -> $HOST:$DEST ==="

## --- Day 11: check SSH key login works ---
if ssh "$HOST" 'echo ok' &> /dev/null; then
  ## &> /dev/null = hide BOTH normal output and errors (bash shortcut)
  echo "[OK] SSH works"
else
  echo "[FAIL] cannot SSH to $HOST"
  exit 1
fi

## --- Day 12: copy the folder with rsync ---
if rsync -avz "$SRC/" "$HOST:$DEST/"; then
  ## rsync -avz = archive + verbose + compress
  ## "$SRC/"    = trailing slash = "the contents of this folder"
  echo "[OK] Backup done"
  exit 0
else
  echo "[FAIL] rsync failed"
  exit 1
fi
