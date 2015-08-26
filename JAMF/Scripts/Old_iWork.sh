#!/bin/sh

# Move old versions of iWork to /Applications/iWork '09
# $1 = Mount point of the target drive
# $2 = Computer name
# $3 = Username
# $4 = Name of iWork app that is being installed/moved.
# Created by Andrew Zbikowski <andrew@zibnet.us>

APPNAME=$4
APPPATH=/Applications/$APPNAME
DESTDIR=/Applications/iWork\ \'09/

echo $APPNAME
echo $APPPATH
echo $DESTDIR

if [ "$APPNAME" = "" ]; then
    echo "Blank parameter"
	exit 1
fi

if [ -d "$APPPATH" ]; then
	if [ ! -d "$DESTDIR" ]; then
		/bin/mkdir "$DESTDIR"
	fi
	/bin/mv "$APPPATH" "$DESTDIR"
fi
exit 0
