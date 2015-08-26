#!/bin/bash
# Get version of installed iWork and iWork '09 applications. 

# Configuration
# Which App? Keynote, Pages, or Numbers. 
FINDAPP="Pages"
# End configuration

if [ -d "/Applications/$FINDAPP.app/" ]; then
        echo "<result>`/usr/bin/defaults read /Applications/iWork\ \'09/$FINDAPP.app/Contents/Info CFBundleShortVersionString`</result>"
else
        echo "<result>Not Installed</result>"
fi