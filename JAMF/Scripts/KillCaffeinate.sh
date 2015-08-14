#!/bin/sh

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

MESSAGE="$loggedInUser triggered killall of caffeinate."
/bin/echo "<result>$MESSAGE</result>"
/usr/bin/killall -9 caffeinate

exit 0