#!/bin/sh
# JAMF Casper Suite Extension Attribute
# Found some Macs that didn't have a Recovery HD. Doing a check to see if there
# are any others and will push a RecoveryHD package to them if the partition 
# is not present. 
# Created by Andrew Zbikowski <andrew@zibnet.us>

recoveryHDPresent=`/usr/sbin/diskutil list | grep "Recovery HD" | grep disk0`

if [ "$recoveryHDPresent" != "" ]; then
	echo "<result>Present</result>"
else
	echo "<result>Not Present</result>"
fi
