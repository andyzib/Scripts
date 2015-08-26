#!/bin/bash
# JAMF Casper Suite Extension Attribute
# Get version of homebrew installed, used to check if we need to
# push updates to an OS X system with homebrew installed.
# Created by Andrew Zbikowski <andrew@zibnet.us>
if [ -e /usr/local/bin/brew ]; then
        echo "<result>`/usr/local/bin/brew --version`</result>"
else
        echo "<result>Not installed.</result>"
fi
exit 0
