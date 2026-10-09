#!/bin/bash
# day5_onboard.sh - create a new team member account
# Usage: sudo ./day5_onboard.sh <username> <group> 0	job done, everything worked	✅ success
##	tried the job, but it failed	❌ tried and failed
##	couldn’t even start the job	⛔ used wrong

USERNAME="$1"
GROUP="$2"

# Guard 1: need both inputs
if [ -z "$USERNAME" ] || [ -z "$GROUP" ]; then
  echo "Usage: $0 <username> <group>"
  exit 2
fi

# Guard 2: must run as root 0 means root 1000 or above real user-account
if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: run with sudo"
  exit 2
fi

# Guard 3: user must not already exist -q means quite "^ will check the usernamein /etc/passwd file
if grep -q "^$USERNAME:" /etc/passwd; then
  echo "[FAIL] User $USERNAME already exists"
  exit 1
fi

# All guards passed: do the real work

# Make sure the group exists (must come before useradd) checked inside /etc/group files
if grep -q "^$GROUP:" /etc/group; then
  echo "[OK] Group $GROUP already exists"
else
  groupadd "$GROUP"
  echo "[OK] Created group $GROUP"
fi

# Create the user
if useradd -m -s /bin/bash -G "$GROUP" "$USERNAME"; then
  echo "[OK] Created user $USERNAME"
else
  echo "[FAIL] Could not create $USERNAME"
  exit 1
fi

# Verify
echo "Account details:"
id "$USERNAME"
grep "^$USERNAME:" /etc/passwd

exit 0
