#!/bin/bash
echo "<result>`/usr/bin/java -version 2>&1 | grep "java" | awk '{ print substr($3, 2, length($3)-2); }'`</result>"
exit 0