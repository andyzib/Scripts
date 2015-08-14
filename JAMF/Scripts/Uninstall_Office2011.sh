#!/bin/sh
# Source: http://www.officeformachelp.com/office/install/remove-office/
osascript -e 'tell application "Microsoft Database Daemon" to quit'
rm -R '/Applications/Microsoft Communicator.app/'
rm -R '/Applications/Microsoft Messenger.app/'
rm -R '/Applications/Microsoft Office 2011/'
rm -R '/Applications/Remote Desktop Connection.app/'
rm -R '/Library/Application Support/Microsoft/'
rm -R '/Library/Automator/*Excel*'
rm -R '/Library/Automator/*Office*'
rm -R '/Library/Automator/*Outlook*'
rm -R '/Library/Automator/*PowerPoint*'
rm -R '/Library/Automator/*Word*'
rm -R '/Library/Automator/Add New Sheet to Workbooks.action'
rm -R '/Library/Automator/Create List from Data in Workbook.action'
rm -R '/Library/Automator/Create Table from Data in Workbook.action'
rm -R '/Library/Automator/Get Parent Presentations of Slides.action'
rm -R '/Library/Automator/Get Parent Workbooks.action'
rm -R '/Library/Automator/Set Document Settings.action'
rm -R '/Library/Fonts/Microsoft/'
rm -R '/Library/Internet Plug-Ins/*SharePoint*'
rm -R '/Library/LaunchDaemons/*Microsoft*'
rm -R '/Library/Preferences/*Microsoft*'
rm -R '/Library/PrivilegedHelperTools/*Microsoft*'
rm -R '/Library/LaunchDaemons/com.microsoft.office.licensing.helper.plist'
rm -R '/Library/PrivilegedHelperTools/com.microsoft.office.licensing.helper'
rm -R '/Library/Preferences/com.microsoft.office.licensing.plist'
OFFICERECEIPTS=$(pkgutil --pkgs=com.microsoft.office*)
for ARECEIPT in $OFFICERECEIPTS
do
    pkgutil --forget $ARECEIPT
done