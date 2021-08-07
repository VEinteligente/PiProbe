#!/bin/bash
HL='\033[0;33m'
NC='\033[0m' # No Color
echo -n 'id: '
echo -e "${HL}$(cat /home/probe/probeid)${NC}"
echo -n 'city: '
echo -e "${HL}$(cat /home/probe/probecity)${NC}"
echo -n 'isp: '
echo -e "${HL}$(cat /home/probe/probeisp)${NC}"
echo -n 'version: '
echo -e "${HL}$(cat /home/probe/probe/version)${NC}"
echo -n 'disk space: '
echo -e "${HL}$(df | grep '/dev/root' | awk '{print $5}')${NC}"
echo -n 'available ram: '
echo -e "${HL}$(free -m | grep 'Mem' | awk '{print $7}')${NC}"
