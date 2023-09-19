#!/bin/bash
#refer to week 3 3rd video to create user shell
#storyline: menu for admin, vpn, and security functions
function invalid_opt(){
	echo ""
	echo "Invalid option"
	echo ""

	sleep 2

}
function menu() {

	#clears the screen
	clear

	echo "[1] Admin Menu"
	echo "[2] Security Menu"
	echo "[3] Exit"
	read -p "Please enter a choice above: " choice

	case "$choice" in

		1)	admin_menu
		
		;;

		2)	security_menu
		;;
		
		3) exit 0
		;;

		*)
			invalid_opt
			#call the main menu
			menu
		;;

	esac
}

function admin_menu () {
	clear
	
	echo "[L]ist running Processes"
	echo "[N]etwork Sockets"
	echo "[V]PN Menu"
	echo "[4] Exit"
	read -p "Please enter a choice above: " choice

	case  "$choice" in

		L|l) ps -ef |less
		;;
		
		N|n) netstat -an --inet |less
		;;
		
		V|v) vpn_menu
		;;
		
		4) exit 0
		;;
		
		*)
			invalid_opt

			admin_menu
		;;
		
	esac

	admin_menu
}

function vpn_menu() {
	clear
	echo "[A]dd a peer"
	echo "[D]elete a peer"
	echo "[B]ack to admin menu"
	echo "[M]ain menu"
	echo "[E]xit"
	read -p "Please enter a choice above: " choice

	case "$choice" in

	A|a)
		 bash peer.bash
		 tail -7 wg0.conf |less
	;;
	D|d)
		#prompt for peer name
		read -p "Please enter the peer you would like to delete: " pName
		#call manage-user.bash
		bash manage-users.bash -d -u ${pName}
	;;
	B|b) admin_menu
	;;
	M|m) menu
	;;
	E|e) exit 0
	;;
	*)
		invalid_opt	
	;;

	esac

	vpn_menu
}

function security_menu(){
	clear
	echo "[L]ist open Network Sockets"
	echo "[C]heck if any user has UID of 0"
	echo "[D]isplay last 10 logged in users"
	echo "[S]ee currently logged in users"
	echo "[M]ain menu"
	echo "[E]xit"
	read -p "Please enter a choice above: " choice
	case "$choice" in

		L|l) netstat -tulpn |grep LISTEN |less
		;;
		C|c) grep x:0: /etc/passwd |less
		;;
		D|d) last -n 10 |less
		;;
		S|s) who |less
		;;
		M|m) menu
		;;
		E|e) exit 0
		;;
		*)
		invalid_opt
		;;	
	esac
	security_menu
}
#call main funciton
menu

