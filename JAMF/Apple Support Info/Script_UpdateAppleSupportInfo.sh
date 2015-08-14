#!/bin/sh

#	this script was written to query apple's service database to determine warranty coverage
#	base on a system's serial number. This updated version stores the infomration locally so
#	as not to have to query apple's website repeatedly. 

#	author: 	Andrew Thomson
#	date:		5/30/2013

# GetEstimatedPurchaseDAte
# Added by Andrew Zbikowski
# Date: 11/7/2014
# Changed some output around and made this into a script to run from policy instead
# of an extension attribute. The intent was to make an extension attribute for 
# Estimated Purchase Date, Warranty Status, and Warranty End Date. 

GetEstimatedPurchaseDate ()
{
	# Check Estimated Purchase Date
	# First test, $EstimatedPurchaseDate is null. 
	if [ -n $EstimatedPurchaseDate ]; then
		# If WarrantyDate is not available, we can't calculate purchase date.
		if [ $WarrantyDate = "N/A" ]; then
				# Macintosh introduced January 24, 1984. This is me being lazy. 
				EstimatedPurchaseDate="1984-01-24"
				/usr/bin/defaults write /Library/Preferences/com.apple.warranty EstimatedPurchaseDate $EstimatedPurchaseDate
				/usr/bin/defaults write /Library/Preferences/com.apple.warranty WarrantyDate $EstimatedPurchaseDate
		else
				# Do math and write EstimatedPurchaseDate
				# Split $WarrantyDate into YYYY and -MM-DD components.
				PYEAR=`echo $WarrantyDate | cut -c 1-4` # Should be YYYY
				PMMDD=`echo $WarrantyDate | cut -c 5-10` # Should be -MM-DD
				# Subtract 3 from year because we purchase everything with AppleCare.
				let PYEAR=$PYEAR-3
				# Write out the date in YYYY-mm-DD format.
				EstimatedPurchaseDate=${PYEAR}${PMMDD}
				/usr/bin/defaults write /Library/Preferences/com.apple.warranty EstimatedPurchaseDate $EstimatedPurchaseDate
		fi
	fi
}

# Get rid of N/A, replace with January 24, 1984.
CleanUpNA ()
{
	if [ $WarrantyDate = "N/A" ]; then
		/usr/bin/defaults write /Library/Preferences/com.apple.warranty WarrantyDate "1984-01-24"
		WarrantyDate="1984-01-24"
	fi
	
	if [ $EstimatedPurchaseDate = "N/A" ]; then
		/usr/bin/defaults write /Library/Preferences/com.apple.warranty EstimatedPurchaseDate "1984-01-24"
		EstimatedPurchaseDate="1984-01-24"
	fi
	
	if [ $EstimatedPurchaseDate = "A long time ago..." ]; then
		/usr/bin/defaults write /Library/Preferences/com.apple.warranty EstimatedPurchaseDate "1984-01-24"
		EstimatedPurchaseDate="1984-01-24"
	fi
}

if [ -f /Library/Preferences/com.apple.warranty.plist ]; then
	#	get plist data
	WarrantyDate=`/usr/bin/defaults read /Library/Preferences/com.apple.warranty WarrantyDate`
	WarrantyStatus=`/usr/bin/defaults read /Library/Preferences/com.apple.warranty WarrantyStatus`
	EstimatedPurchaseDate=`/usr/bin/defaults read /Library/Preferences/com.apple.warranty EstimatedPurchaseDate`
	GetEstimatedPurchaseDate
	CleanUpNA
	#	convert dates to integers 
	ExpirationDate=`/bin/date -j -f  "%Y-%m-%d" "${WarrantyDate}" +%s`
	TodaysDate=`/bin/date +%s`
	
	#	if warranty is listed as active but date is expired, update plist entry
	if [ "${WarrantyStatus}" == "Active" ] && [ ${TodaysDate} -gt ${ExpirationDate} ]; then 
		WarrantyStatus="Inactive"
		/usr/bin/defaults write /Library/Preferences/com.apple.warranty WarrantyStatus ${WarrantyStatus}
		echo Status updated.
	else
		echo Status unchanged.
	fi
	echo "<result>Estimated Purchase Date: $EstimatedPurchaseDate : Warranty Status ${WarrantyStatus} : Warranty End Date ${WarrantyDate}</result>"
	exit 0
fi


#	set temp file
WarrantyTempFile="/tmp/warranty.$(date +%s).txt"


#	get serial number
SerialNumber=`ioreg -l | awk '/IOPlatformSerialNumber/ { split($0, line, "\""); printf("%s\n", line[4]); }'`
if [ -z "${SerialNumber}" ]; then
		echo "Serial Number not found."
		exit 1
fi


#	query url
WarrantyURL="https://selfsolve.apple.com/wcResults.do?sn=${SerialNumber}&Continue=Continue&num=0"
WarrantyInfo=$(curl -k -s $WarrantyURL | awk '{gsub(/\",\"/,"\n");print}' | awk '{gsub(/\":\"/,":");print}' | sed s/\"\}\)// > ${WarrantyTempFile})


#	check validity of serial number
InvalidSerial=$(grep 'invalidserialnumber\|productdoesnotexist' "${WarrantyTempFile}")
if [[ -n "${InvalidSerial}" ]]; then
	echo "Invalid Serial Number."
	exit 2
fi


#	determine warranty status	
WarrantyStatus=$(grep displayHWSupportInfo "${WarrantyTempFile}")
if [[ $WarrantyStatus =~ "Active" ]]; then
	WarrantyStatus="Active"
else
	WarrantyStatus="Inactive"
fi


#	check for exirpation date
if [[ `grep displayHWSupportInfo "${WarrantyTempFile}"` ]]; then
	WarrantyDate=`grep displayHWSupportInfo "${WarrantyTempFile}" | grep -i "Estimated Expiration Date:"| awk -F'<br/>' '{print $2}'|awk '{print $4,$5,$6}'`
fi


#	convert format of date
if [[ -n "$WarrantyDate" ]]; then
	WarrantyDate=$(/bin/date -jf "%B %d, %Y" "${WarrantyDate}" +"%Y-%m-%d") > /dev/null 2>&1 
else
	WarrantyDate="1984-01-24"
fi


#	write status and date to plist
if [[ -n "$WarrantyStatus" ]] && [[ -n "$WarrantyDate" ]]; then
	/usr/bin/defaults write /Library/Preferences/com.apple.warranty WarrantyStatus ${WarrantyStatus}
	/usr/bin/defaults write /Library/Preferences/com.apple.warranty WarrantyDate ${WarrantyDate}
fi

# Estimate purchase date
GetEstimatedPurchaseDate

echo Serial Number: "${SerialNumber}"
echo Estimated Purchase Date: $EstimatedPurchaseDate
echo Warranty Status: ${WarrantyStatus}
echo Warranty Expiration: ${WarrantyDate}

echo "<result>Estimated Purchase Date: $EstimatedPurchaseDate : Warranty Status ${WarrantyStatus} : Warranty End Date ${WarrantyDate}</result>"
