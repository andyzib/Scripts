#!/bin/sh
# Logs off the user currently logged in. Accepts a delay. 

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "delay"
if [ "$4" != "" ]; then
    delay=$4
else
    delay=300
fi

/bin/sleep $delay
/usr/bin/osascript -e 'tell application "System Events" to log out'

exit 0