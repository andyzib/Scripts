#!/bin/sh

oldDomain="od01.example.com" # Enter the FQDN of your old OD
oldODip="10.1.3.210" # Enter the IP of your old OD

# These variables probably don't need to be changed
check4OD=`/usr/bin/dscl localhost -list /LDAPv3`

# Check if bound to old Open Directory domain

if [ "${check4OD}" == "${oldDomain}" ]; then
    #echo "This machine is joined to ${oldDomain}"
	#echo "Removing from ${oldDomain}"
	/usr/sbin/dsconfigldap -r "${oldDomain}"
	/usr/bin/dscl /Search -delete / CSPSearchPath /LDAPv3/"${oldDomain}"
	/usr/bin/dscl /Search/Contacts -delete / CSPSearchPath /LDAPv3/"${oldDomain}"
	#if [ "${odSearchPath}" = "" ]; then
	#	echo "$oldDomain not found in search path."
	#fi
# Check if bound to old Open Directory domain's IP address
else if [ "${check4OD}" == "${oldODip}" ]; then
	#echo "This machine is joined to ${oldODip}"
	#echo "Removing from ${oldODip}"
	/usr/sbin/dsconfigldap -r "${oldODip}"
	/usr/bin/dscl /Search -delete / CSPSearchPath /LDAPv3/"${oldODip}"
	/usr/bin/dscl /Search/Contacts -delete / CSPSearchPath /LDAPv3/"${oldODip}"
	#if [ "${odSearchPath}" = "" ]; then
	#	echo "$oldODip not found in search path."
	#fi
fi
fi
#killall DirectoryService
#echo "Finished. Exiting..."
exit 0