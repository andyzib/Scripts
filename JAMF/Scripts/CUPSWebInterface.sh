#!/bin/sh
# Configure CUPS Web Interface availability on OS X. 
# URL is https://localhost:631
# $4 should be yes or no. 
# Created by Andrew Zbikowski <andrew@zibnet.us>
# Intended to by run by a JAMF Self Service policy. 
/usr/sbin/cupsctl WebInterface=$4

if [ $4 == "yes" ]; then
	echo "<result>CUPS Web Interface is Enabled.</result>"
elif [ $4 == "no" ]; then
	echo "<result>CUPS Web Interface is Disabled.</result>"
else
	echo "<result>Unknown parameter given: $4</result>"
fi
exit 0
