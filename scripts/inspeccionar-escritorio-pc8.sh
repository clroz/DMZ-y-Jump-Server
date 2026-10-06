#!/usr/bin/env bash
set -e
docker inspect --format '{{.Name}} {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docker31
docker exec docker31 sh -c 'netstat -lnt; ps -eo comm,args | grep -E "xrdp|vnc|nginx|apache|novnc" | grep -v grep; getent passwd | cut -d: -f1,3,6,7'
curl -sS -I --connect-timeout 3 --max-time 5 http://10.177.0.6/
