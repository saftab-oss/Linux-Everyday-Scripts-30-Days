#!/bin/bash
## #!/bin/bash = run this script with the bash shell

## day9_10_service_check.sh - check a service is UP (port) and HEALTHY (HTTP)
## Usage: ./day9_10_service_check.sh <port> <url>
## Example: ./day9_10_service_check.sh 22 https://www.google.com

PORT="$1"          ## $1 = first word you type after the script name (the port)
URL="$2"           ## $2 = second word you type (the URL)
PROBLEMS=0         ## counter: 0 = all good so far, becomes 1 if a check fails

## --- guard: stop if either input is missing ---
if [ -z "$PORT" ] || [ -z "$URL" ]; then
  ## [ -z "$PORT" ] = is PORT empty?   -z means "zero length"
  ## ||             = OR
  ## so this is true if EITHER input was not given
  echo "Usage: $0 <port> <url>"   ## $0 = this script's own name
  exit 2                          ## exit 2 = wrong usage, nothing was checked
fi

echo "=== Service check ==="

## --- Day 9: is the port listening? ---
if ss -tln | grep -q ":$PORT "; then
  ## ss        = socket statistics (show network connections)
  ## -t        = TCP sockets only
  ## -l        = listening sockets only
  ## -n        = numeric (show 22, not "ssh")
  ## |         = send that output into the next command
  ## grep -q   = search quietly (no output, just a true/false exit code)
  ## ":$PORT " = the port with a trailing SPACE so :22 won't match :2200
  echo "[OK]   Port $PORT is listening"
else
  echo "[FAIL] Port $PORT is NOT listening"
  PROBLEMS=1      ## mark that something failed
fi

## --- Day 10: does the web service return HTTP 200? ---
CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
## curl             = make an HTTP request to the URL
## -s               = silent (no progress bar)
## -o /dev/null     = throw away the page body (we don't want the HTML)
## -w "%{http_code}" = write out ONLY the HTTP status code (e.g. 200)
## $( )             = run the command and save its output into CODE
if [ "$CODE" = "200" ]; then
  ## compare the code to "200" (= is string equality here)
  echo "[OK]   $URL returned $CODE"
else
  echo "[FAIL] $URL returned $CODE"
  PROBLEMS=1
fi

echo "====================="
exit $PROBLEMS     ## 0 = both checks passed, 1 = at least one failed
