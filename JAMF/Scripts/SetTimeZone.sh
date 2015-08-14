#!/bin/sh
####################################################################################################
#
# Copyright (c) 2010, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
####################################################################################################
#
# SUPPORT FOR THIS PROGRAM
#
#       This program is distributed "as is" by JAMF Software, LLC's Resource Kit team. For more
#       information or support for the Resource Kit, please utilize the following resources:
#
#               http://list.jamfsoftware.com/mailman/listinfo/resourcekit
#
#               http://www.jamfsoftware.com/support/resource-kit
#
#       Please reference our SLA for information regarding support of this application:
#
#               http://www.jamfsoftware.com/support/resource-kit-sla
#
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#    setTimeZone.sh -- Set the time zone
#
# SYNOPSIS
#	sudo setTimeZone.sh
#	sudo setTimeZone.sh <mountPoint> <computerName> <currentUsername> <timeZone>
#
# 	If the $timeZone parameter is specified (parameter 4), this is the time zone that will be set.
#
# 	If no parameter is specified for parameter 4, the hardcoded value in the script will be used.
#
# DESCRIPTION
#	This script sets the system time zone as reflected in the Date & Time preference pane with the
#	System Preferences application.  It has been designed to work on Mac OS X 10.3 and higher.
#
#	A list of supported time zone entries can be found by running the command:
#
#		For Mac OS X 10.5 or later:
#
#			/usr/sbin/systemsetup -listtimezones
#
#		For Mac OS X 10.4 or earlier:
#
#			/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/systemsetup -listtimezones
#
#	The system time zone will be set according to the value specified in the paramter $timeZone.
#	It can be used with a hardcoded value in the script, or read in as a parameter.  Since the
#	Casper Suite defines the first three parameters as (1) Mount Point, (2) Computer Name and
#	(3) username, we are using the forth parameter ($4) as the passable parameter.  If no parameter
#	is passed, then the hardcoded value will be used.
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Nick Amundsen on August 5th, 2008
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUE FOR "timeZone" IS SET HERE
#timeZone="America/Chicago"


# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "timeZone"
if [ "$4" != "" ] && [ "$timeZone" == "" ]; then
    timeZone=$4
fi

####################################################################################################
#
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

OS=`/usr/bin/defaults read /System/Library/CoreServices/SystemVersion ProductVersion | awk '{print substr($1,1,4)}'`

if [ "$timeZone" != "" ]; then
	if [[ "$OS" < "10.5" ]]; then
		echo "Setting time zone for OS $OS..."
		/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/systemsetup -settimezone "$timeZone"
		echo "Refreshing the clock in the Menu Bar..."
		/usr/bin/killall SystemUIServer
	else
		echo "Setting time zone for OS $OS..."
		/usr/sbin/systemsetup -settimezone "$timeZone"
		echo "Refreshing the clock in the Menu Bar..."
		/usr/bin/killall SystemUIServer
	fi
else
	echo "Error:  The parameter 'timeZone' is blank.  Please specify a valid time zone."
fi
