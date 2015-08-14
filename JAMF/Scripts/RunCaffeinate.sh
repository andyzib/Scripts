#!/bin/sh

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

MESSAGE="$loggedInUser triggered caffeinate for $4 seconds." 
/bin/echo "<result>$MESSAGE</result>"
/usr/bin/caffeinate -d -u -t $4 &

exit 0