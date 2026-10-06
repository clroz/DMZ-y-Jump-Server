#!/usr/bin/env bash
set -e
# Ruta de script admitida por el perfil AppArmor instalado de dhclient.
if [ -e /etc/dhcp/dhclient-script ]; then
 cp -a /etc/dhcp/dhclient-script "/root/dmz-infra1-backups/dhclient-script-$(date +%s)"
fi
cat > /etc/dhcp/dhclient-script <<'SH'
#!/bin/sh
case "$interface:$new_ip_address" in
eth1:192.168.10.*|eth1:192.168.20.*)
 case "$reason" in
 BOUND|RENEW|REBIND|REBOOT)
  ip addr replace "$new_ip_address/25" dev "$interface"
  ip route replace default via "$new_routers" dev "$interface"
  ;;
 esac
 ;;
esac
exit 0
SH
chmod 755 /etc/dhcp/dhclient-script
# Detener unicamente los clientes auxiliares anteriores de estos dos PCs.
python3 - <<'PY'
from pathlib import Path
import os,signal
for path in Path('/proc').glob('[0-9]*/cmdline'):
 try: args=path.read_bytes().split(b'\0')
 except OSError: continue
 if args and args[0] in (b'dhclient',b'/sbin/dhclient') and any(x in args for x in (b'/run/dmz-docker30.pid',b'/run/dmz-docker31.pid',b'/run/dhclient-dmz-docker30.pid',b'/run/dhclient-dmz-docker31.pid')):
  os.kill(int(path.parent.name),signal.SIGTERM)
PY
for pc in docker30 docker31; do
 pid=$(docker inspect -f '{{.State.Pid}}' "$pc")
 timeout 40 nsenter -t "$pid" -n dhclient -4 -1 -v -sf /etc/dhcp/dhclient-script -pf "/run/dhclient-dmz-$pc.pid" -lf "/var/lib/dhcp/dhclient-dmz-$pc.leases" eth1
 nsenter -t "$pid" -n ip -br addr show eth1
 nsenter -t "$pid" -n ip route
done
pid=$(docker inspect -f '{{.State.Pid}}' docker31)
if nsenter -t "$pid" -n ip -4 addr show dev eth1 | grep -q '192.168.99.10/24'; then
 nsenter -t "$pid" -n ip addr del 192.168.99.10/24 dev eth1
fi
docker exec docker30 ping -c 3 -W 2 192.168.10.1
docker exec docker31 ping -c 3 -W 2 192.168.20.1
docker exec docker31 curl -sS --connect-timeout 4 --max-time 8 -o /dev/null -w 'GUI VLAN20 HTTP=%{http_code}\n' http://192.168.20.1/login
