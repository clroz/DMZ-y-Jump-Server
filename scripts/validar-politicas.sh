#!/usr/bin/env bash
set -u
probe(){
 pc=$1; label=$2; url=$3; expected=$4
 code=$(docker exec "$pc" curl -sS --connect-timeout 3 --max-time 5 -o /dev/null -w '%{http_code}' "$url" 2>/dev/null || true)
 echo "$label $url HTTP=${code:-000} esperado=$expected"
}
probe docker30 VLAN10-CAJA http://192.168.30.2/ permitido
probe docker30 VLAN10-INVENTARIO http://192.168.30.3/ bloqueado
probe docker31 VLAN20-CAJA http://192.168.30.2/ permitido
probe docker31 VLAN20-INVENTARIO http://192.168.30.3/ permitido
probe docker31 GUI-VLAN20 http://192.168.20.1/login permitido
printf '\nSSH: VLAN10 debe fallar; VLAN20 debe responder.\n'
docker exec docker30 timeout 3 bash -c '</dev/tcp/192.168.30.2/22' >/dev/null 2>&1 && echo 'ERROR VLAN10 SSH caja permitido' || echo 'OK VLAN10 SSH caja bloqueado'
docker exec docker31 timeout 3 bash -c '</dev/tcp/192.168.30.2/22' >/dev/null 2>&1 && echo 'OK VLAN20 SSH caja permitido' || echo 'ERROR VLAN20 SSH caja bloqueado'
printf '\nPrueba de ruta de gestion Docker desde VLAN10:\n'
docker exec docker30 timeout 3 bash -c '</dev/tcp/10.177.0.3/80' >/dev/null 2>&1 && echo 'ERROR interfaz de gestion accesible' || echo 'OK interfaz de gestion bloqueada'
printf '\nPersistencia del tunel RDP local en Windows:\n'
