#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run as root."
    exit
fi

HL='\033[0;33m'
NC='\033[0m' # No Color
dpkg-reconfigure tzdata

inputok=0
cityok=0
ispok=0
idok=0

while [[ inputok -lt 1 ]]; do

	while [[ cityok -lt 1 ]]; do
		echo ''
		echo -e -n "${HL}ADD CITY OR LOCALITY: ${NC}"
		read cityname
		if [[ $cityname =~ [a-zA-Z] ]]; then
			cityok=1
		else
			echo 'Invalid city or location. Please, use only letters'
		fi
	done

	while [[ ispok -lt 1 ]]; do
		echo ''
		echo -e -n "${HL}ADD ISP: ${NC}"
		read isp
		ispok=1
	done

	while [[ idok -lt 1 ]]; do
		echo ''
		echo -e -n "${HL}PROBE ID: ${NC}"
		read idprobe
		if [[ $idprobe =~ ^-?[0-9]+$ ]]; then
			idok=1
		else
			echo 'Invalid ID, try only using numbers.'
		fi
	done
	
	echo -n 'You choose '$cityname' - '$isp' - '$idprobe'. Are you sure? [y/n]: '
	read confirmation
	if [[ $confirmation = "y" ]]; then
		inputok=1
		echo 'Ok.'
	else
		echo 'Lets start again'
		cityok=0
		ispok=0
		idok=0
	fi
done

echo -e "${HL}Changing default password for probe user...${NC}"
echo "Enter new password: "
read probepasswd
echo "probe:$probepasswd" | chpasswd

echo -e "${HL}Changing default password for pi...${NC}"
echo "Enter new password: "
read pipasswd
echo "pi:$pipasswd" | chpasswd

echo -e "${HL}Adding probe ID...${NC}"
touch /home/probe/probeid
echo $idprobe > /home/probe/probeid

echo -e "${HL}Adding probe city or location...${NC}"
touch /home/probe/probecity
echo $cityname > /home/probe/probecity

echo -e "${HL}Adding probe ISP...${NC}"
touch /home/probe/probeisp
echo $isp > /home/probe/probeisp

echo -e "${HL}Updating system packages...${NC}"
apt update -y
apt upgrade -y

echo -e "${HL}Writing Ooni version...${NC}"
touch /home/probe/ooniversion
echo $(ooniprobe --version | grep version) > /home/probe/ooniversion

echo -e "${HL}Writing PiProbe version...${NC}"
cp /home/probe/probe/version /home/probe/probeversion

# Ooni section
# Setup defaults
crontab -u probe -l > mycron

# Check if the user defined an internet list
echo "Enter the web address where the list is located for ooni (leave blank if you want to use the manual list): "
read web_list
if [ ! -z "$web_list" ]; then
	wget -O /boot/overlays/list.txt ${web_list}
	echo "0 */16 * * * wget -O /boot/overlays/list.txt ${web_list}" >> mycron # Update the list every day at 16:00
fi

# Ooniprobe
echo "0 */1 * * * ooniprobe run -c /home/probe/ooniprobe_config.json" >> mycron
# Miniooni
echo "0 */6 * * * ooniprobe run websites --input-file /boot/overlays/list.txt" >> mycron
echo "0 */12 * * * ooniprobe run websites --input-file /boot/overlays/list.txt" >> mycron
echo "0 */18 * * * ooniprobe run websites --input-file /boot/overlays/list.txt" >> mycron
crontab -u probe mycron
rm mycron


echo "0 0 1 * * sudo apt-get update && sudo apt-get -y upgrade" >> mycron
crontab -u root mycron
rm mycron


echo -e "${HL}Erasing history...${NC}"
history -cw

echo -e "${HL}Expanding filesystem${NC}"
raspi-config --expand-rootfs

echo -e "${HL}Rebooting...${NC}"
shutdown -r now
