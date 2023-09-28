#!/bin/bash

#storyline: extract IPs from emergin threats and create firewall ruleset
if [[ -f "emerging-drop.suricata.rules" ]]
then
	echo "the rules file has already been downloaded"
	echo -n "Do you want to download again?[y/N]"
	read to_redownload
	if [[ "${to_redownload}" == "y" ]]
	then
		wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -o /tmp/emerging-drop.suricata.rules
	elif [[ "${to_redownload}" == "N" || "${to_redownload}" == "n" ]]
	then 
		echo "file will not redownload"
	else
		echo "Invalid value"
			exit 1
			fi
else
	wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -o /tmp/emerging-drop.suricata.rules
fi
#regex to extract the networks
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' emerging-drop.suricata.rules | sort -u | tee -a  badIPs.txt

while getopts 'icwmpe' OPTION ; do
	case "$OPTION" in
	I|i)
for eachIP in $(cat badIPs.txt)
do
	echo "iptables -A INPUT -s ${eachIP} -j DROP" | tee -a  badIPs.iptables	
done
sleep 1
clear
echo "created iptables firewall drop rules in badIPs.iptables"
;;
M|m)
echo '

scrub-anchor "com.apple/*"
nat-anchor "com.apple/*"
rdr-anchor "com.apple/*"
dummynet-anchor "com.apple/*"
anchor "com.apple/*"
load anchor "com.apple" from "/etc/pf.anchors/com.apple"

' | tee pf.conf
for eachIP in $(cat badIPs.txt)
do
	echo "block in from ${eachIP} to any" | tee -a  pf.conf
done
	sleep 1
	clear
	echo "created IP tables for firewall drop rules in pf.conf"
;;

C|c)
	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badIPs.txt | tee badips.nocidr
	for eachIP in $(cat badips.nocidr)
	do
	echo "deny ip host ${eachIP} any" | tee -a badips.cisco
	done
	rm badips.nocidr
	sleep 1
	clear
	echo "created ip tables for firewall drop rules in badips.cisco"
	
;;
W|w)

	egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badIPs.txt | tee badips.windowsform
	for eachIP in $(cat badips.windowsform)
	do 
		echo "netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachIP}\" dir=in action=block remoteip=${eachIP}" | tee -a badips.netsh
		done
		rm badips.windowsform
		sleep 1
		clear
		echo "created ip tables for  firewall drop rules in badips.netsh"
;;

P|p)
	wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -o /tmp/targetedthreats.csv
	awk '/domain/ {print}' targetedthreats.csv | awk -F \" '{print $4}' | sort -u > threats.txt
	echo 'class-map match-any BAD_URLS' | tee ciscothreats.txt
	for eachIP in $(cat threats.txt)
	do
	echo "match protocol http host \"${eachIP}\"" | tee -a ciscothreats.txt
	done
	rm threats.txt
	sleep 1
	clear
	echo "cisco url filters file succesfully parsed and created at ciscothreats.txt"
exit 0;
;;
E|e) exit 0;
;;
*)
echo "invalid option"
exit 1;
;;

esac
done

exit 0;
