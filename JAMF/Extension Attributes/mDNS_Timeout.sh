#!/bin/sh

PROGRAMARGUMENTS=$( defaults read /System/Library/SystemConfiguration/IPMonitor.bundle/Contents/Info mdns_timeout  )

echo "<result>$PROGRAMARGUMENTS</result>"

exit 0