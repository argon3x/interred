#!/bin/bash

# /* Colors */
red="\e[01;31m"; green="\e[01;32m"; yellow="\e[01;33m";
blue="\e[01;34m"; purple="\e[01;35m"; cyan="\e[01;36m";
end="\e[00m";

# /* Process Boxes */
NBOX="${blue}[${cyan}*${blue}]${end}"
TBOX="${blue}[${green}+${blue}]${end}"
FBOX="${blue}[${red}-${blue}]${end}"

# /* Error Function */
ERROR(){
	local error=$1
	local name=${0##*/}
	echo -e "${red}Error ${green}${name%.*}${end}:\n ${red}${error}\n${end}"
	tput cnorm
	exit 1
}

# /* Cancel Function */
CTRL_C(){	
	echo -e "\n${blue}>>> ${green}Process Canceled${blue} <<<${end}\n"
	tput cnorm
	exit 0
}

# /* Calling Signals */
trap ERROR SIGTERM
trap CTRL_C INT

# /* Listing Interfaces */
INTERFACE(){
	local interfaces=($(ifconfig | grep 'BROADCAST' | awk '{print $1}' FS=':'))
	local count=1

	for interface in ${interfaces[@]}; do
		echo -e "${blue}[ ${end}${count} ${blue}] ${yellow}=> ${green}${interface}${end}"
		let count+=1
	done
}

# /* Rename Interface Function */
RENAME_INTERFACE(){
	local interfaces=($(ifconfig | grep 'BROADCAST' | awk '{print $1}' FS=':'))
	local let count=${1}-1
	local newname=$2
	local interface=${interfaces[${count}]}

	echo -e "\n${NBOX} ${yellow}Checking data${end}........\c"; sleep 1
	if [[ ${interface} != ${newname} ]]; then
		echo -e "${green} done ${end}"; sleep 1
	else
		echo -e "${red} failed ${end}"
		ERROR "The name new of interface, is equal to the interface current.\n Try again with other name."
	fi

	echo -e "${NBOX} ${yellow}Shutting down interface ${green}${interface}${end}.......\c"; sleep 1
	`sudo ifconfig ${interface} down 2>/dev/null`
	if [[ $? -eq 0 ]]; then
		echo -e "${green} done ${end}"; sleep 1
	else
		echo -e "${red} failed ${end}"
		ERROR "Occurred an Error to shutdown ${interface} interface"
	fi

	echo -e "${NBOX} ${yellow}Renameing ${green}${interface} ${yellow}interface to ${green}${newname}${end}.......\c"; sleep 1
	`sudo ip link "set" ${interface} name ${newname} 2>/dev/null`
	if [[ $? -eq 0 ]]; then
		echo -e "${green} done ${end}"
	else
		echo -e "${red} failed ${end}"
		ERROR "Occurred an Error to renamed the interface ${interface}"
	fi

	echo -e "${NBOX} ${yellow}Turning on the new ${green}${newname} ${yellow}interface${end}........\c"; sleep 1
	`sudo ifconfig ${newname} up 2>/dev/null`
	if [[ $? -eq 0 ]]; then
		echo -e "${green} done ${end}"; sleep 1
	else
		echo -e "${red} failed ${end}"
		ERROR "An Error Occurred when turning on the new interface ${newname}"
	fi
}

# /* Main Function */
if [[ $(id -u) -eq 0 ]]; then
	clear
	echo -e "${TBOX} ${yellow}Scannig Network Interfaces.......${end}\n"; sleep 1
	echo -e "${blue}----------------------------------${end}"
	echo -e "${yellow}   Select a Network Interface  ${end}"
	echo -e "${blue}----------------------------------${end}"
	INTERFACE
	echo -en "\n${yellow}Interface${end}: "; read inter
	echo -en "${yellow}New name${end}: "; read newname
	RENAME_INTERFACE ${inter} ${newname}
	echo -e "\n${green}Interface changed to ${newname} successfully${end}\n"
else
	ERROR "use: sudo $0"
fi
