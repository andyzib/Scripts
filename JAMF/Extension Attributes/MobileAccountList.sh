#!/bin/sh
NETACCLIST=`dscl . list /Users OriginalNodeName | awk '{print $1}' 2>/dev/null`

if [ "$NETACCLIST" == "" ]; then
        echo "<result>No Network Accounts</result>"
else
        echo "<result>$NETACCLIST</result>"
fi
exit 0