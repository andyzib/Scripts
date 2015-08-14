#!/bin/sh
### When run, this script will terminate all running instances of Caffeine
## and then remove the Caffeine application. 

/usr/bin/killall -9 Caffeine
/bin/rm -rf /Applications/Caffeine.app

exit 0