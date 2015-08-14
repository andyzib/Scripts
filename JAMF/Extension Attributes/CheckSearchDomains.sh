#!/bin/sh

PROGRAMARGUMENTS=$( defaults read /System/Library/LaunchDaemons/com.apple.mDNSResponder ProgramArguments )

if [ "$PROGRAMARGUMENTS" = '(
    "/usr/sbin/mDNSResponder",
    "-launchd",
    "-AlwaysAppendSearchDomains"
)' ] ; then
echo "<result>AlwaysAppendSearchDomains set.</result>"
else
echo "<result>AlwaysAppendSearchDomains not set.</result>"
fi

exit 0