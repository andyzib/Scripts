#!/bin/sh
# JAMF Casper Suite Extension Attribute
# Read the lastUserName into an extension attribute. 
# Created by Andrew Zbikowski <andrew@zibnet.us>
lastUser=`defaults read /Library/Preferences/com.apple.loginwindow lastUserName`

if [ "$lastUser" == "" ]; then
	echo "<result>No logins</result>"
else
	echo "<result>$lastUser</result>"
fi
