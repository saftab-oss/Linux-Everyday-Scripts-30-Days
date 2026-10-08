#!/bin/bash
# env_check.sh - check a server is ready before the app starts
# Usage: ./env_check.sh
# make env visible to every program export APP_ENV=dev and export DB_HOST=localhost

PROBLEMS=0

echo "Checking environment..."

# Check 1: required environment variables are set
if [ -z "$APP_ENV" ]; then
  echo "[FAIL] APP_ENV is not set"
  PROBLEMS=1
else
  echo "[OK] APP_ENV = $APP_ENV"
fi

if [ -z "$DB_HOST" ]; then
  echo "[FAIL] DB_HOST is not set"
  PROBLEMS=1
else
  echo "[OK] DB_HOST = $DB_HOST"
fi

# Check 2: required tools are installed (found in PATH) command -v means verify
if command -v git > /dev/null; then
  echo "[OK] git is installed"
else
  echo "[FAIL] git is not installed"
  PROBLEMS=1
fi

if command -v curl > /dev/null; then
  echo "[OK] curl is installed"
else
  echo "[FAIL] curl is not installed"
  PROBLEMS=1
fi

exit $PROBLEMS
