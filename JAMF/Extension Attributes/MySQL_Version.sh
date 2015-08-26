#!/bin/sh
# JAMF Casper Suite Extension Atribute
# Get installed version of MySQL. 
# Created by Andrew Zbikowski

MYSQLBIN=`/usr/bin/which mysql`
if [ "$MYSQLBIN" == "" ]; then
	MYSQLBIN="/usr/local/mysql/bin/mysql"
else
	MYSQLBIN=`/usr/bin/which mysql`
fi
echo $MYSQLBIN

if [ -f /usr/local/mysql/bin/mysql ]; then
	echo "<result>`/usr/local/mysql/bin/mysql --version`</result>"
else
	echo "<result>NOT INSTALLED</result>"
fi
exit 0
