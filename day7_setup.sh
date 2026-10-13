#!/bin/bash
# ^ run this file with bash

# =====================================================
# day7_setup.sh - install required tools only if missing, then verify
# Usage: sudo ./day7_setup.sh
# Exit codes: 0 = all tools ready, 1 = a tool failed, 2 = not run as root
# =====================================================

PROBLEMS=0
# report number: 0 = all good so far (Day 3 pattern)


# ---------- GUARD: MUST BE ROOT ----------
if [ "$(id -u)" -ne 0 ]; then
# id -u  = my user ID number (root = 0)
# -ne 0  = not equal to 0 → not root
  echo "ERROR: run with sudo"
  exit 2
# exit 2 = used wrong, nothing was attempted
fi


# ---------- REFRESH PACKAGE LIST ----------
echo "Updating package list..."
apt-get update -qq
# apt-get = package manager (script-friendly version of apt)
# update  = download the latest list of available packages
# -qq     = very quiet: only print errors


# ---------- TOOL 1: tree ----------
if command -v tree > /dev/null; then
# command -v tree = is the tree command available? (Day 4)
# > /dev/null     = hide the path it prints, only keep the exit code
  echo "[OK] tree already installed"
else
  echo "[..] Installing tree"
  apt-get install -y -qq tree > /dev/null
  # install = install a package
  # -y      = answer "yes" automatically (scripts can't type)
  # -qq     = quiet
  # tree    = package name

  # verify it actually worked
  if command -v tree > /dev/null; then
    echo "[OK] tree installed"
  else
    echo "[FAIL] tree could not be installed"
    PROBLEMS=1
  fi
fi


# ---------- TOOL 2: jq ----------
if command -v jq > /dev/null; then
  echo "[OK] jq already installed"
else
  echo "[..] Installing jq"
  apt-get install -y -qq jq > /dev/null
  if command -v jq > /dev/null; then
    echo "[OK] jq installed"
  else
    echo "[FAIL] jq could not be installed"
    PROBLEMS=1
  fi
fi


# ---------- TOOL 3: htop ----------
if command -v htop > /dev/null; then
  echo "[OK] htop already installed"
else
  echo "[..] Installing htop"
  apt-get install -y -qq htop > /dev/null
  if command -v htop > /dev/null; then
    echo "[OK] htop installed"
  else
    echo "[FAIL] htop could not be installed"
    PROBLEMS=1
  fi
fi


# ---------- REPORT ----------
exit $PROBLEMS
# 0 = every tool ready, 1 = at least one failed
