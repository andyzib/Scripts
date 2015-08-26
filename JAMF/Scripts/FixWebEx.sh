#!/bin/sh
# Intended to be run as a Self Service policy in JAMF Casper Suite. 
# Occasionally WebEx components become corrupt or won't start. 
# This removes the cached WebEx software so a fresh copy will be downloaded.
# Created by Andrew Zbikowski <andrew@zibnet.us>

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`

# Remove WebEx from home directory. 
/bin/rm -rf /Users/$loggedInUser/Library/Application\ Support/WebEx\ Folder

RESULT="Removed WebEx Plug-in from $loggedInUser's home directory." 

/bin/echo "<result>$RESULT</result>"

exit 0
