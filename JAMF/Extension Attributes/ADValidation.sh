#!/bin/bash
# Quick check to verify Active Directory bind is working.
# JAMF Casper Suite Extension Attribute: AD_Validation_Status
# Created by Andrew Zbikowski <andrew@zibnet.us>
### Configuration
NTDOMAIN="CONTOSO"
LDAPDOMAIN="DC=CONTOSO,DC=COM"
### End Configuration. 

RESULT=`/usr/bin/dscl '/Active Directory/${NTDOMAIN}/All Domains' read /Groups/Domain\ Admins distinguishedName`
RESULT=`/bin/echo $RESULT | /usr/bin/sed -e 's/\r//'`

if [ "$RESULT" == "dsAttTypeNative:distinguishedName: CN=Domain Admins,CN=Users,${LDAPDOMAIN}"  ]; then
	RESULT="Valid"
else
	RESULT="Error"
fi

echo "<result>$RESULT</result>"
exit 0
