#!/bin/bash
## ^ shebang: tells Linux to run this file using the bash shell

## day15_log_check.sh - count errors in a log file, alert if over a threshold
## Usage:   ./day15_log_check.sh <logfile> [threshold]
## Example: ./day15_log_check.sh /var/log/syslog 10

LOGFILE="$1"          ## $1 = first word you type after the script name (the log file path)
THRESHOLD="${2:-10}"  ## $2 = second word (the limit). ${2:-10} = use $2, or 10 if you gave nothing

## --- guard 1: did you give a logfile? ---
if [ -z "$LOGFILE" ]; then   ## [ -z "$LOGFILE" ] = is LOGFILE empty? (-z = zero length)
  echo "Usage: $0 <logfile> [threshold]"  ## print how to use it. $0 = this script's name
  exit 2                     ## exit 2 = used wrong, nothing was checked
fi                           ## fi = end of this if block

## --- guard 2: does the logfile actually exist? ---
if [ ! -f "$LOGFILE" ]; then ## -f = is it a regular file?   ! = NOT   so: "if it's NOT a file"
  echo "ERROR: $LOGFILE is not a file"  ## print an error message
  exit 2                     ## stop: can't check a file that isn't there
fi                           ## end of this if block

## --- count the error lines ---
COUNT=$(grep -c -i -E "error|fail|critical" "$LOGFILE")
## $( )                   = run the command inside, save its output into COUNT
## grep                   = search for matching lines
## -c                     = count the matches (print a number, not the lines)
## -i                     = case-insensitive (Error, ERROR, error all match)
## -E                     = extended regex, so the | symbol means "OR"
## "error|fail|critical"  = match any line containing error OR fail OR critical
## "$LOGFILE"             = the file to search in

echo "Log: $LOGFILE"                            ## print which file we checked
echo "Errors found: $COUNT  (threshold: $THRESHOLD)"  ## print the count and the limit

## --- compare the count to the threshold ---
if [ "$COUNT" -gt "$THRESHOLD" ]; then  ## -gt = greater than. "is COUNT greater than THRESHOLD?"
  echo "[FAIL] too many errors ($COUNT > $THRESHOLD)"  ## yes: report failure
  exit 1                                ## exit 1 = problem found
else                                    ## otherwise...
  echo "[OK] errors under threshold"    ## no: report OK
  exit 0                                ## exit 0 = all good
fi                                      ## end of the if block
