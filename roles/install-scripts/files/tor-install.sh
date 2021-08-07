#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please, run as root."
    exit
fi

echo -e "${HL}This is an optional script that creates a Tor hidden service${NC}"
echo -e "${HL}If you are not sure what this means, please read our documentation${NC}"
read -p "Do you wish to continue? y/n:   " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

apt-get install tor 

echo -e "${HL}Configuring Tor Hidden Service...${NC}"
echo 'HiddenServiceDir /var/lib/tor/sshd/' >> /etc/tor/torrc
echo 'HiddenServicePort 22 127.0.0.1:22' >> /etc/tor/torrc
systemctl restart tor

touch /home/probe/onionurl
cat /var/lib/tor/sshd/hostname > /home/probe/onionurl
echo -n 'direccion .onion del probe: '
cat /var/lib/tor/sshd/hostname
