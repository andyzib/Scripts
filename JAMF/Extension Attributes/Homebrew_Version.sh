#!/bin/bash
if [ -e /usr/local/bin/brew ]; then
        echo "<result>`/usr/local/bin/brew --version`</result>"
else
        echo "<result>Not installed.</result>"
fi
exit 0
