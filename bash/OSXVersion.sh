#!/bin/sh
# Get OS X Version

if [ -e /usr/bin/sw_vers ]; then
	OSVERSION=`/usr/bin/sw_vers -productVersion`
else
	OSVERSION="Probably not OS X."
fi

OSMAJOR=`/usr/bin/sw_vers -productVersion | /usr/bin/cut -c 1-4`
OSRELEASE=`/usr/bin/sw_vers -productVersion | /usr/bin/cut -c 4`
echo $OSVERSION
echo $OSMAJOR
echo $OSRELEASE