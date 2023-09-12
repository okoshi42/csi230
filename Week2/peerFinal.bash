#!/bin/bash

# StoryLine: Create peer vpn configuration file


#what is the user / peer's name
echo -n "What is the peer's name? "
read the_client

#Filename variable
pFile="${the_client}-wg0.conf"

#check for existing config file/if we want to override
if [[ -f "${pFile}" ]]
then
	#prompt if we need to overwrite the file
	echo "The file ${pFile} already exists."
	echo -n "Do you want to overwrite it? [y/N]"
	read to_overwrite

	if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" || "${to_overwrite}" == "n" ]]
	then
		echo "Exiting..."
		exit 0
	elif [[ "${to_overwrite}" == "y"} ]]
	then
		echo "Creating the wireguard configuration file..."
	#If they dont specify y/N then error
	else
		echo "Invalid value"
		exit 1
	fi
fi
# Generate private key
p="$(wg genkey)"

#Generate public key
clientPub="$(echo ${p} | wg pubkey)"

# Generate preshared key (used for additional security for the client when establishing vpn tunnel)
pre="$(wg genpsk)"

#10.254.132.0/24, 172.16.28.0/24 192.199.97.163:4282
#NH9qUERcppInDrMp8aT5Lx3gPdwf6s980Msa7y1x9nE= 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0

#Endpoint
end="$(head -1 wg0.conf | awk ' { print $3 } ')"

#Server public key
pub="$(head -1 wg0.conf | awk ' { print $4 } ')"

#DNS servers
dns="$(head -1 wg0.conf | awk ' { print $5 } ')"

#MTU
mtu="$(head -1 wg0.conf | awk ' { print $6 } ')"

# KeepAlive
keep="$(head -1 wg0.conf | awk ' { print $7 } ')"

#listening port
lport="$(shuf -n1 -i 40000-50000)"

#default routes for vpn
routes="$(head -1 wg0.conf | awk ' { print $8 } ')"

#create client configuration file
echo "[Interface]
Address = 10.254.132.100/24
DNS = ${dns}
ListenPort = ${lport}
MTU = ${mtu}
PrivateKey = ${p}
[Peer]
AllowedIPs = ${keep}
PresharedKey = ${pre}
PublicKey = ${pub}
Endpoint = ${end}
" > ${pFile}

#add our peer configuration to the server config
echo "
[Peer]
PublicKey = ${clientPub}
PresharedKey = ${pre}
AllowedIPs = 10.254.132.100/32
# ${the_client} end
" | tee -a wg0.conf

