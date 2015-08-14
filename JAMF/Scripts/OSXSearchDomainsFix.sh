#!/bin/sh
defaults write /System/Library/LaunchDaemons/com.apple.mDNSResponder ProgramArguments -array "/usr/sbin/mDNSResponder" "-launchd" "-AlwaysAppendSearchDomains"
launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
launchctl load -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
exit 0