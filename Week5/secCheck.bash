#!/bin/bash

#storyline:  script to perform local security checks

function checks(){
	if [[ $2  != $3  ]]
	then
		echo -e "\e[1;31mThe $1 is not compliant. the current policy should be: $2, the current value is $3.\e[0m "
		echo "REMEDIATE"
		echo -e "Edit: $4"
		echo -e "Set: $5"
		echo -e "Run: $6"
	else
		echo -e "\e[1;32m$1 is compliant. Current Value $3.\e[0m"
	
	fi

}
# checks the password max days policy
pmax=$(egrep -i '^PASS_MAX_DAYS' /etc/login.defs | awk ' {print $2} ')
#checks for password max
checks "Password Max Days" "365" "${pmax}" "/etc/login.defs" "PASS_MAX_DAYS    365" ""
# checks the pass min days between changes
pmin=$(egrep -i '^PASS_MIN_DAYS' /etc/login.defs | awk ' {print $2} ')
checks "Password Min Days" "14" "${pmin}" "/etc/login.defs" "PASS_MIN_DAYS    14" ""
#checks pass warn age
pwarn=$(egrep -i '^PASS_WARN_AGE' /etc/login.defs | awk ' {print $2} ')
checks "Password Warn Age" "7" "${pwarn}" "/etc/login.defs" "PASS_WARN_AGE    7" ""
#checks the ssh usepam configuration
chkSSHPAM=$(egrep -i "^UsePAM" /etc/ssh/sshd_config | awk ' {print $2}')
checks "SSH UsePAM" "yes" "${chkSSHPAM}" "/etc/ssh/sshd_config" "UsePAM yes" ""
#checks user compliance
echo ""
for eachDir in $(ls -l /home | egrep '^d' | awk ' {print $9}')
do
	chDir=$(ls -ld /home/${eachDir} | awk ' {print $1} ')
	checks "Home directory ${eachDir}" "drwx------" "${chDir}" "" "" "chown root:root /home/${eachDir}\n     chmod og-rwx /home/${eachDir}"
done

ipfwd=$(grep "net\.ipv4\.ip_forward" /etc/sysctl.conf)
checks "IP Forwarding" "#net.ipv4.ip_forward=0" "${ipfwd}" "/etc/sysctl.conf/" "#net.ipv4.ip_forward=0" 'sysctl -w net.ipv4.ip forward=0\n     sysctl -w net.ipv4.route.flush=1'

icmp=$(grep "net\.ipv4\.conf\.all\.accept_redirects" /etc/sysctl.conf | awk '{print $3}')
checks "ICMP Redirects" "0" "${icmp}" "/etc/sysctl.conf" "#net.ipv4.conf.all.accept_redirects = 0" "sysctl -w net.ipv4.conf.all.accept_redirects=0\n     sysctl -w net.ipv4.conf.default.accpet redirects=0\n     sysctl -w net.ipv4.route.flush=1" 

crontab=$(stat /etc/crontab | grep "Access: (" | cut -c 14-)
checks "Crontab Permissions" "/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)" "${crontab}" "/etc/crontab" "" "chown root:root /etc/crontab\n     chmod og-rwx /etc/crontab"

cronhr=$(stat /etc/cron.hourly | grep "Access: (" | cut -c 14-)
checks "Cron.hourly Permissions" "/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${cronhr}" "/etc/cron.hourly" "" "chown root:root /etc/cron.hourly\n     chmod og-rwx /etc/cron.hourly"
cronday=$(stat /etc/cron.daily | grep "Access: (" | cut -c 14-)
checks "Cron.daily Permissions" "/drwx------)  Uid: (    0/    root)   Gid: (    0/    root)" "${cronday}" "/etc/cron.daily" "" "chown root:root /etc/cron.daily\n     chmod og-rwx /etc/cron.daily"

cronwk=$(stat /etc/cron.weekly | grep "Access: (" | cut -c 14-)
checks "Cron.weekly Permissions" "/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)" "${cronwk}" "/etc/cron.weekly" "" "chown root:root /etc/cron.weekly\n     chmod og-rwx /etc/cron.weekly"
cronmonth=$(stat /etc/cron.monthly | grep "Access: (" | cut -c 14-)
checks "Cron.monthly Permissions" "/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)" "${cronmonth}" "/etc/cron.monthly" "" "chown root:root /etc/cron.monthly\n     chmod og-rwx /etc/cron.monthly"
pswd=$(stat /etc/passwd | grep "Access: (" | cut -c 14-)
checks "passwd Permissions" "/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${pswd}" "/etc/passwd" "" "chown root:root /etc/passwd\n     chmod 644 /etc/passwd"
shadow=$(stat /etc/shadow | grep "Access: (" | cut -c 14-)
checks "shadow Permissions" "/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${shadow}" "/etc/shadow" "" "chown root:shadow /etc/shadow\n     chmod o-rwx,g-wx /etc/shadow"
grp=$(stat /etc/group | grep "Access: (" | cut -c 14-)
checks "group Permissions" "/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${grp}" "/etc/group" "" "chown root:root /etc/group\n     chmod 644 /etc/group"
gshadow=$(stat /etc/gshadow | grep "Access: (" | cut -c 14-)
checks "gshadow Permissions" "/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${gshadow}" "/etc/gshadow" "" "chown root:shadow /etc/gshadow\n     chmod o-rwx,g-rw /etc/gshadow"
pswd2=$(stat /etc/passwd- | grep "Access: (" | cut -c 14-)
checks "passwd- Permissions" "/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${pswd2}" "/etc/passwd-" "" "chown root:root /etc/passwd-\n     chmod u-x,go-wx /etc/passwd-"
shadow2=$(stat /etc/shadow- | grep "Access: (" | cut -c 14-)
checks "shadow- Permissions" "/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${shadow2}" "/etc/shadow-" "" "chown root:shadow /etc/shadow-\n     chmod o-rwx,g-rw /etc/shadow-"
grp2=$(stat /etc/group- | grep "Access: (" | cut -c 14-)
checks "group- Permissions" "/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)" "${grp2}" "/etc/group-" "" "chown root:root /etc/group-\n     chmod u-x,go-wx /etc/group-"
gshadow2=$(stat /etc/gshadow- | grep "Access: (" | cut -c 14-)
checks "gshadow- Permissions" "/-rw-r-----)  Uid: (    0/    root)   Gid: (   42/  shadow)" "${gshadow2}" "/etc/gshadow-" "" "chown root:shadow /etc/gshadow-\n     chmod o-rwx,g-rw /etc/gshadow-"
legpwd=$(grep '^\+:' /etc/passwd)
checks "passwd legacy \"+\" entries" "" "${legpwd}" "/etc/passwd" "remove any legacy \'+\' entries" ""
legshad=$(grep '^\+:' /etc/shadow)
checks "shadow legacy \"+\" entries" "" "${legshad}" "/etc/shadow" "remove any legacy \'+\' entries" ""
leggrp=$(grep '^\+:' /etc/group)
checks "group legacy \"+\" entries" "" "${leggrp}" "/etc/group" "remove any legacy \'+\' entries" ""
uidacc=$(awk -F: '($3 == 0) {print $1}' /etc/passwd)
checks "UID 0 Accounts" "root" "${uidacc}" "" "Remove any users other than root with UID 0 or assign them new UID if appropriate" ""
