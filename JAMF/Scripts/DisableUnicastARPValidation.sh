#!/bin/bash

#	Mac OS X 10.9 Script
#	Disables Unicast ARP Cache Validation OS Feature
#	
#	Version 1.0

if [[  $(sw_vers -productVersion | grep '10.9')  ]]
	then
		if [[ -f /etc/sysctl.conf ]]
		then
			if grep 'unicast' /etc/sysctl.conf > /dev/null 2>&1
			then
				echo “Unicast ARP Validation was Previously Disabled”
			fi
		else
			sysctl -w net.link.ether.inet.arp_unicast_lim=0  > /dev/null 2>&1
			echo "net.link.ether.inet.arp_unicast_lim=0" | tee -a /etc/sysctl.conf  > /dev/null 2>&1
			chown root:wheel /etc/sysctl.conf
			chmod 644 /etc/sysctl.conf
			echo “Unicast ARP Validation Disabled”
		fi
fi