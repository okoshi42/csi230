#!/bin/bash

#Parse Apache log

#read in file

read -p "Please enter an apache log file." tFile

if [[ ! -f ${tFile} ]]
then echo "File does not exist"
exit 1
fi

sed -e "s/\[//g" -e "s/\"//g" ${tFile} | \
egrep -i "test|shell|echo|passwd|select|phpmyadmin|setup|admin|w00t" | egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| sort -u | \
awk 'BEGIN {format = "%-15s\n"}
{printf format,"iptables -A INPUT -s ${"$1"} -j DROP"}' | tee apacheIPs.iptables
