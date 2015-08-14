#!/bin/sh
# Script to configure OS X Accessibility Settings for applications that use this API.
# Example Applications: TextExpander, A Better Snap Tool, Apple Script Editor, ADpassMon.  
##### Usage: 
# ./OSXAccessibilityConfig.sh <MountPoint> <ComputerName> <Username> <CFBundleIdentifier> 
# $1 = Mount point of the target drive
# $2 = Computer name
# $3 = Username
# $4 = CFBundleIdentifier for application. (example: com.apple.iWork.Keynote)
# Find the CFBundleIdentifier by viewing the Info.plist in your perferred text editor. 
# The Info.plist can be found in /Applications/ApplicationName.app/Contents/Info.plist. 
# Search for CFBundleIdentifier.

CFBUNDLEIDENTIFIER=$4

# Get OS X Version
if [ -e /usr/bin/sw_vers ]; then
	OSVERSION=`/usr/bin/sw_vers -productVersion | /usr/bin/cut -c 4`
else
	#OSVERSION="Probably not OS X."
	exit 1
fi

if [ ${OSVERSION} -le "8" ]; then
	# 10.8 and earlier, nice and easy. 
	if [ ! -e /private/var/db/.AccessibilityAPIEnabled ]; then
		/usr/bin/touch /private/var/db/.AccessibilityAPIEnabled
		#/bin/chmod 644 /private/var/db/.AccessibilityAPIEnabled
	fi
else
	# 10.9 (and up?)
	TCCDB="/Library/Application Support/com.apple.TCC/TCC.db"
	SQL="DELETE FROM access WHERE client='${CFBUNDLEIDENTIFIER}';"
	/usr/bin/sqlite3 "$TCCDB" "$SQL"
	SQL="INSERT INTO access VALUES('kTCCServiceAccessibility','${CFBUNDLEIDENTIFIER}',0,1,0,NULL);"
	# 0,1,0 = client_type,allowed,prompt_count
	/usr/bin/sqlite3 "$TCCDB" "$SQL"
fi

SQL="SELECT * from ACCESS;"
/usr/bin/sqlite3 "$TCCDB" "$SQL"

exit 0