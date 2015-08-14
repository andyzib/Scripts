#!/bin/bash

#       Mac OS X 10.9 Script
#       Disables Unicast ARP Cache Validation OS Feature
#
#       Version 1.0

if [[  $(sw_vers -productVersion | grep '10.9')  ]]
        then
                if [[ -f /etc/sysctl.conf ]]
                then
                        if grep 'unicast' /etc/sysctl.conf > /dev/null 2>&1
                        then
                                echo "<result>Disabled</result>"
                        else
                                echo "<result>Enabled</result>"
                        fi
                fi
fi