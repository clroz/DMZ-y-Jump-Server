#!/usr/bin/env bash
set -e
for mapping in 'docker28 192.168.30.2' 'docker27 192.168.30.3' 'docker29 192.168.30.4'; do
 set -- $mapping
 pc=$1
 address=$2
 pid=$(docker inspect -f '{{.State.Pid}}' "$pc")
 nsenter -t "$pid" -n ip addr replace "$address/28" dev eth1
 nsenter -t "$pid" -n ip link set eth1 up
 nsenter -t "$pid" -n ip route replace default via 192.168.30.1 dev eth1
 echo "DMZ: $pc $address"
 nsenter -t "$pid" -n ip -br addr show eth1
 nsenter -t "$pid" -n ping -c 3 -W 2 192.168.30.1
done
printf '\n--- GUI desde VLAN20 ---\n'
docker exec docker31 curl -sS --connect-timeout 4 --max-time 8 -o /dev/null -w 'HTTP=%{http_code}\n' http://192.168.20.1/login
printf '\n--- GUI desde VLAN10 (debe fallar) ---\n'
if docker exec docker30 curl -sS --connect-timeout 3 --max-time 5 -o /dev/null -w 'HTTP=%{http_code}\n' http://192.168.10.1/login; then
 echo 'ERROR: GUI accesible desde VLAN10'; exit 1
else
 echo 'Correcto: sin acceso HTTP administrativo desde VLAN10'
fi
