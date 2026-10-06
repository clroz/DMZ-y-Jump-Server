#!/usr/bin/env bash
# Solo lectura del host: procesos, interfaces y vecinos; no configura FortiGate.
printf '\n--- Interfaces del host ---\n'
ip -br addr
printf '\n--- Vecinos del host ---\n'
ip neigh show
printf '\n--- Procesos de este laboratorio ---\n'
ps -eo pid,args | grep -E 'qemu|1f8a90f7|docker' | grep -v grep
printf '\n--- Interfaces de bridges ---\n'
bridge link show
printf '\n--- Contenedores ---\n'
docker ps --format '{{.ID}} {{.Names}} {{.Ports}}'
printf '\n--- Red de PC7 ---\n'
docker exec docker30 ip -br addr
docker exec docker30 ip route
printf '\n--- ARP e IP emitidos por FortiGate (12 segundos) ---\n'
timeout 12 tcpdump -nn -i vunl24_0 -c 12 'ether src 50:a4:eb:00:18:00 and (arp or ip)'
printf '\n--- Herramientas disponibles ---\n'
command -v arping
