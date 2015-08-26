#!/bin/sh
# This helps when dealing with an Active Directory domain 
# or internal DNS domain that ends in .local. Mac OS assumes
# .local is Bonjour and doesn't append anything .local to the 
# DNS search. Users were unable to connect to things like 
# server.devl, server.prep. (FQDN: server.devl.example.com)
# Changing this option causes all DNS search domains to be
# tried if the lookup fails. 
#
# This is an JAMF Casper Suite extension attribute that checks
# to see if the AlwaysAppendSearchDomains option is set.  
#
# Created by Andrew Zbikowski
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
