#!/bin/sh

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

# Remove WebEx from home directory. 
/bin/rm -rf /Users/$loggedInUser/Library/Application\ Support/WebEx\ Folder
/bin/rm -rf /Users/chansen/Library/Internet\ Plug-Ins/WebEx64.plugin

RESULT="Removed WebEx Plug-in from $loggedInUser's home directory." 

/bin/echo "<result>$RESULT</result>"

exit 0