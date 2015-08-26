#!/bin/bash
# Run this as a logoff script as Finder needs to be restarted after changing. 
defaults write ~/Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores true
