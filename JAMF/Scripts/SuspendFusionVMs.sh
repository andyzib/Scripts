#!/bin/sh
# Uses VMware Fusion's command line tools to suspend and running VMs. 
# Helpful to run before updating VMWare fusion. 
# Created by Andrew Zbikowski <andrew@zibnet.us>

# Glob based on new line. 
IFS='
'

# Find vmrun
if [ -e "/Applications/VMware Fusion.app/Contents/Library/vmrun" ]; then
    # Fusion 5, 6
	VMRUN="/Applications/VMware Fusion.app/Contents/Library/vmrun"
elif [ -e "/Library/Application Support/VMware Fusion/vmrun" ]; then
	# Fusion 3, possibly 2. 
	VMRUN="/Library/Application Support/VMware Fusion/vmrun"
else
	# Fusion 1... :-(
	exit 1
fi

VMLIST=`"$VMRUN" list`

# If someone has managed to get more than 9 VMs running there are other problems... 
# This just needs to be a non-zero for the script to take action, so this is fine. 
NUMVMS=${VMLIST:19:1}
if [ $NUMVMS = 0 ]; then
	#echo "No VMs running, nothing to do."
	exit 0
fi

for i in ${VMLIST[*]}; do
	if [ ! `echo $i | cut -c 1-5` = "Total" ] ; then
		#echo $i
		"$VMRUN" suspend "$i"
	fi
done

# If there are still VMs running, use the hard option. 
VMLIST=`"$VMRUN" list`
NUMVMS=${VMLIST:19:2}

if [ $NUMVMS = 0 ]; then
	#echo "No VMs running, nothing to do."
	exit 0
fi

for i in ${VMLIST[*]}; do
	if [ ! `echo $i | cut -c 1-5` = "Total" ] ; then
		#echo $i
		"$VMRUN" suspend "$i" hard
	fi
done
exit 0
