#!/bin/bash
# Quick check to verify Active Directory bind is working.
RESULT=`/usr/bin/dscl '/Active Directory/EXAMPLE/All Domains' read /Groups/Domain\ Admins distinguishedName`
RESULT=`/bin/echo $RESULT | /usr/bin/sed -e 's/\r//'`

if [ "$RESULT" == "dsAttTypeNative:distinguishedName: CN=Domain Admins,CN=Users,DC=example,DC=local"  ]; then
	RESULT="Valid"
else
	RESULT="Error"
fi
echo "<result>$RESULT</result>"
exit 0
