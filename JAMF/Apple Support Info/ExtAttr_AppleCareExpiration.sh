#!/bin/sh
# Read AppleCare Expiration from 
# /Library/Preferences/com.apple.warranty 
# into an extension attribute. 

if [ -f /Library/Preferences/com.apple.warranty.plist ]; then
	echo "<result>`/usr/bin/defaults read /Library/Preferences/com.apple.warranty WarrantyDate`</result>"
else
	echo "<result>N/A</result>"
fi