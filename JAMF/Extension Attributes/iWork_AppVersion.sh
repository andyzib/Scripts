#!/bin/bash
# JAMF Casper Suite Extension Attribute
# Get version of installed iWork and iWork '09 applications. 
# By default, iWork 09 gets moved and is still present on the system. 
# This was causing issues with iWork policies based on the standard inventory. 
# Created by Andrew Zbikowski
# Configuration
# Which App? Keynote, Pages, or Numbers. 
FINDAPP="Pages"
# End configuration

if [ -d "/Applications/$FINDAPP.app/" ]; then
        echo "<result>`/usr/bin/defaults read /Applications/$FINDAPP.app/Contents/Info CFBundleShortVersionString`</result>"
else
        echo "<result>Not Installed</result>"
fi
