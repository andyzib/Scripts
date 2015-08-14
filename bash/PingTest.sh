#!/bin/bash

target=$1

count=$( ping -c 1 $target | grep icmp* | wc -l )

if [ $count -eq 0 ]
then

    echo "Host is not Alive! Try again later.."

else

    echo "Yes! Host is Alive!"

fi
