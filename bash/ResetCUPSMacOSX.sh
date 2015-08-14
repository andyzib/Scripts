#!/bin/sh

# Reset Printing System

/bin/launchctl unload /System/Library/LaunchDaemons/org.cups.cupsd.plist
/bin/sleep 10
/bin/rm /Library/Printers/InstalledPrinters.plist
/bin/rm /private/etc/cups/cupsd.conf
/bin/cp /private/etc/cups/cupsd.conf.default /private/etc/cups/cupsd.conf
/bin/sleep 5
/bin/launchctl load /System/Library/LaunchDaemons/org.cups.cupsd.plist
echo "<result>Common UNIX Printing System has been reset.</result>"
exit 0