#!/bin/bash
# Validate the Keychain entry for the Mac's Computer Account Object
# in Active Directory is able to authenticate. If authentication is
# successful, all should be well with the Active Directory bind.
#
# Source: https://jamfnation.jamfsoftware.com/discussion.html?id=13069
#
# Extension Attribute: ADCompAccount
# Note: This script must be run as root on Mac OS X. 

# Name of your Active Directory Domain
MYDOMAIN='CONTOSO.COM'
# FQDN of a ping-able Domain Controller, 
# or same as MYDOMAIN if all DCs can be pinged. 
MYDC="CONTOSO.COM"

count=$( ping -c 1 $MYDC | grep icmp* | wc -l )

# Check to make sure the Domain Controller is reachable first. 
if [ $count -eq 0 ]
then
#    echo "Host is not Alive! Try again later.."
	echo "<result>Ping test Failed</result>"
else
#    echo "Yes! Host is Alive!"
	COMPNAME=`scutil --get ComputerName | tr '[:upper:]' '[:lower:]'`
	SERVICEACCOUNTPASS=`security 2>&1 >/dev/null find-generic-password -ga $COMPNAME\$ | cut -d'"' -f2`
	echo $SERVICEACCOUNTPASS | kinit --password-file=STDIN $COMPNAME\$@$MYDOMAIN
	if [[ $? != 0 ]]
	then
        echo "<result>Fail</result>"
	else
        echo "<result>Pass</result>"
	fi
fi
exit 0 
