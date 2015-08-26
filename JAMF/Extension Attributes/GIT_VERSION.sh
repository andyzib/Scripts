#!/bin/bash
# JAMF Casper Suite extension attribute. 
# Get the command line version of GIT installed.
# Created by Andrew Zbikowski 
GIT=`/usr/bin/which git`

# GIT from http://git-scm.com/download/mac
if [ -a /usr/local/git/bin/git ];
then
	VERSION=`/usr/local/git/bin/git --version`
# GIT from Xcode
elif [ -a /usr/bin/git ];
then
	VERSION=`/usr/bin/git --version`
# No GIT in $PATH? 
elif [ -z $GIT ];
then
	VERSION="Not Installed"
# Whatever /usr/bin/which git returns... 
else 
	VERSION=`$GIT --version`
fi

/bin/echo "<result>$VERSION</result>"
exit 0 
