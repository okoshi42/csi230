#!/bin/bash
# check for existing config file / if we want to override
if [[ -f "wg0.conf" ]]
then
	#prompt if we need to overwrite the file
	echo "The file wg0.conf  already exists."
	echo -n "Do you want to overwrite it? [y|N]"
	read to_overwrite

	if [[ "${to_overwrite}" == "N" || "${to_overwrite}" == "" || "${to_overwrite}" == "n" ]]
	then
		echo "Exiting..."
		exit 0
	elif [[ "${to_overwrite}" == "y" ]]
	then
		echo "Creating the wireguard configuration file..."
	#if they dont specify y/N then error
	else
		echo "Invalid value"
		exit 1
	fi
fi

#Storyline: Script to create a wireguard server
#create a private key
p="$(wg genkey)"
echo "${p}" > /etc/wireguard/server_private.key

#create a public key
pub="$(echo ${p} | wg pubkey)"
echo "${pub}" > /etc/wireguard/server_public.key


#set the address
address="10.254.132.0/24"

#set server IP addresses
ServerAddress="10.254.132.1/24"

#set a listening port
lport="4282"

#info to be used in client configuration
peerInfo="# ${address} 192.168.241.131:4282 ${pub} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"
# 1: #, 2: for obtaining an IP address for each client
# 3: server's actual IP address
# 4: clients will need server public key
# 5: dns information
# 6: determines the largest packet size allowed
# 7: keeping connection alive for
# 8: what traffic to be routed through vpn

echo " ${peerInfo}
[Interface]
Address = ${ServerAddress}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
ListenPort = ${lport}
PrivateKey = ${p}" > wg0.conf

#echo "${peerInfo}
#[Interface]
#Address = ${ServerAddress}
#PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE
#PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens33 -j MASQUERADE
#ListenPort = ${lport}
#PrivateKey = ${p}
#" > wg0.conf
#'

#sudo mv wg0.conf /etc/wireguard/
