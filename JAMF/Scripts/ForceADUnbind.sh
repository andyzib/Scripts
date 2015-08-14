#!/bin/sh
/usr/bin/logger "Forcibly unbinding from Active Directory due to validation error. Triggered by JAMF agent." 
/usr/sbin/dsconfigad dsconfigad -force -remove -u johndoe -p nopasswordhere
exit 0