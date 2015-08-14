#!/bin/sh

if [ -e /usr/sbin/RemoteUpdateManager ]; then
  echo "<result>YES</result>"
else
  echo "<result>NO</result>"
fi

exit 0