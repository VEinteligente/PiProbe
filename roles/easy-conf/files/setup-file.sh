#!/bin/bash

FILE=/boot/overlays/PiProbe.conf
if test -f "$FILE"; then

	# Extract and save probe parameters 
	ISP=`sed -n 's/^ISP=\(.*\)/\1/p' < ${FILE}`
	ID=`sed -n 's/^ID=\(.*\)/\1/p' < ${FILE}`
	city=`sed -n 's/^city=\(.*\)/\1/p' < ${FILE}`
	echo $ID > /home/probe/probeid 
	echo $ISP > /home/probe/probeisp
	echo $city > /home/probe/probecity 

	## CREDENTIALS SECTION
	# Extract new probe password from config file
	password=`sed -n 's/^password=\(.*\)/\1/p' < ${FILE}` 
	if [ ! -z "$password" ]; then
        echo "probe:$password" | chpasswd
	fi

	# # OONI SECTION
	# Create file for crontab
	touch mycron

	# Check if the user defined an internet list
	web_list=`sed -n 's/^web_list=\(.*\)/\1/p' < ${FILE}` 
	if [ ! -z "$web_list" ]; then
		wget -O /boot/overlays/list.txt ${web_list}
		echo "0 */16 * * * wget -O /boot/overlays/list.txt ${web_list}" >> mycron # Update the list every day at 16:00
	fi	

	# Ooniprobe
	ooniprobe_scheduling=`sed -n 's/^ooniprobe_scheduling=\(.*\)/\1/p' < ${FILE}`
	# If the user did not specify the time to run ooniprobe, use the default time (01:00)
	if [ -z "$ooniprobe_scheduling" ]; then
		echo "0 */1 * * * ooniprobe run -c /home/probe/ooniprobe_config.json" >> mycron
	else
		hours=$(echo $ooniprobe_scheduling | tr "," "\n")
		# Echo new cronjobs into cron file
		for hour in $hours
		do
			echo "0 */${hour} * * * ooniprobe run -c /home/probe/ooniprobe_config.json" >> mycron
		done	
	fi

	# Miniooni
	miniooni_scheduling=`sed -n 's/^miniooni_scheduling=\(.*\)/\1/p' < ${FILE}`
	# If the user did not specify the time to run miniooni, use the default hours (06:00 12:00 18:00)
	if [ -z "$miniooni_scheduling" ]; then
		echo "0 */6 * * * /home/probe/ooni/miniooni -f '/boot/overlays/list.txt' web_connectivity" >> mycron
		echo "0 */12 * * * /home/probe/ooni/miniooni -f '/boot/overlays/list.txt' web_connectivity" >> mycron
		echo "0 */18 * * * /home/probe/ooni/miniooni -f '/boot/overlays/list.txt' web_connectivity" >> mycron
	else
		hours=$(echo $miniooni_scheduling | tr "," "\n")
		# Echo new cronjobs into cron file
		for hour in $hours
		do
			echo "0 */${hour} * * * /home/probe/ooni/miniooni -f '/boot/overlays/list.txt' web_connectivity" >> mycron
		done	
	fi

	# Install new cron file
	crontab -u probe mycron
	rm mycron

	# Delete conf file
	rm -f ${FILE}

fi
