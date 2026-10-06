#!/usr/bin/env bash
cat /etc/apparmor.d/sbin.dhclient
cat /sbin/dhclient-script
printf '\n--- Procesos DHCP ---\n'
ps -eo pid,args | grep '[d]hclient'
