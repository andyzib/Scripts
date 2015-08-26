#!/bin/sh
# JAMF Casper Suite Extension Attribute
# Gets the value of mdns_timeout. The default 5 ms timeout can cause
# unacceptable delays when dealing with an Active Directory domain
# or other internal DNS domain that ends with .local. 
# Created by Andrew Zbikowski <andrew@zibnet.us>

PROGRAMARGUMENTS=$( defaults read /System/Library/SystemConfiguration/IPMonitor.bundle/Contents/Info mdns_timeout  )

echo "<result>$PROGRAMARGUMENTS</result>"

exit 0
