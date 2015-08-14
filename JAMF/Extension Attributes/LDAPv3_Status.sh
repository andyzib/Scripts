#!/bin/sh

# These variables probably don't need to be changed
check4OD=`/usr/bin/dscl localhost -list /LDAPv3`

if [ -z $check4OD ]; then
    echo "<result>Not Bound</result>"
else
	echo "<result>${check4OD}</result>"
fi
exit 0