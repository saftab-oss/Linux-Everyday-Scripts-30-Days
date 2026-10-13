#!/bin/bash
# ^ shebang: tells Linux to run this file with bash

# =====================================================
# day6_disk_check.sh - alert when disk usage is over a limit
# Usage:   ./day6_disk_check.sh [limit]
# Example: ./day6_disk_check.sh 90
# Exit codes: 0 = disk OK, 1 = disk over limit
# =====================================================


# ---------- 1. SET THE LIMIT ----------
LIMIT="${1:-80}"
# LIMIT      = variable (box) holding the alert threshold in %
# $1         = first word typed after the script name
# :-80       = if $1 is empty, use 80 instead (backup value)
# ${ }       = braces wrap the whole "use $1 or 80" expression
# " "        = quotes keep the value safe as one piece


# ---------- 2. GET CURRENT DISK USAGE ----------
USAGE=$(df --output=pcent / | tail -1 | tr -dc '0-9')
# USAGE            = variable that will hold the % as a plain number
# $( )             = run the commands inside, save the result
# df               = "disk free": shows disk space info
# --output=pcent   = show only the percent-used column (pcent = percent)
# /                = check only the main (root) disk
#                    output so far:  "Use%"
#                                    "  2%"
# |                = pipe: send the output to the next command
# tail -1          = keep only the last 1 line (drops the "Use%" header)
#                    output so far:  "  2%"
# tr               = translate: change or delete characters
# -d               = delete
# -c               = complement = EXCEPT
# '0-9'            = the digits 0 1 2 3 4 5 6 7 8 9
#                    -dc '0-9' = delete everything EXCEPT digits
#                    final output:   "2"


# ---------- 3. SHOW THE RESULT ----------
echo "Disk usage on / : ${USAGE}% (limit ${LIMIT}%)"
# echo        = print text to the screen
# ${USAGE}    = replaced with the number, e.g. 2
# ${LIMIT}    = replaced with the limit, e.g. 80
# { }         = braces mark exactly where the variable name ends
# %           = plain text, added back so humans can read it
#               prints: Disk usage on / : 2% (limit 80%)


# ---------- 4. GUARD: UNDER THE LIMIT = ALL GOOD ----------
if [ "$USAGE" -lt "$LIMIT" ]; then
# if ... then = run the next lines only if the test is true
# [ ]         = test brackets (spaces inside are required)
# -lt         = "less than" (for numbers)
#               reads: is USAGE less than LIMIT?
  echo "[OK] Disk usage is under ${LIMIT}%"
  exit 0
# exit 0      = stop the script here, report SUCCESS
fi
# fi          = end of the if block ("if" backwards)


# ---------- 5. OVER THE LIMIT: SHOW WHAT'S USING SPACE ----------
# (we only reach this point if the guard above did NOT exit)
echo "[FAIL] Disk is over ${LIMIT}%"


echo "Biggest folders in $HOME:"
# $HOME       = built-in environment variable = your home folder (Day 4)

du -sh "$HOME"/* 2>/dev/null | sort -rh | head -5
# du          = "disk usage": how much space folders/files use
# -s          = summary: one total per item (not every subfolder)
# -h          = human-readable sizes (K, M, G)
# "$HOME"/*   = every item inside your home folder
#               (* = wildcard, "everything"; hidden .folders are skipped)
# 2>          = redirect errors (stream 2 = errors)
# /dev/null   = black hole: throws them away (hides "Permission denied")
# |           = pipe into the next command
# sort        = put lines in order
# -r          = reverse: biggest first
# -h          = understand human sizes (knows 1G > 500M)
# |           = pipe into the next command
# head -5     = keep only the first 5 lines (top 5 biggest)


echo "Files over 100MB in $HOME:"

find "$HOME" -type f -size +100M 2>/dev/null
# find        = search for files
# "$HOME"     = where to start searching (your home folder)
# -type f     = only regular files (f = file, not folders)
# -size       = match by size
# +100M       = bigger than 100 megabytes (+ = more than, M = MB)
# 2>/dev/null = hide permission errors


# ---------- 6. REPORT FAILURE ----------
exit 1
# exit 1      = stop and report FAILURE (disk over limit)
#               cron / monitoring tools read this code to send an alert
