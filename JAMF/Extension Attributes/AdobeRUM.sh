#!/bin/sh
# Why is the rum always gone?!?
# Yo ho, yo ho, a pirate's life for me.
# Actually just checking for Adobe Remote Update Manager. 
# Created by Andrew Zbikowski <andrew@zibnet.us>
if [ -e /usr/sbin/RemoteUpdateManager ]; then
  echo "<result>YES</result>"
else
  echo "<result>NO</result>"
fi

exit 0
