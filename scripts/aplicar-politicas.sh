#!/usr/bin/env bash
set -e
python3 -u - <<'PY'
import telnetlib,time,re,pathlib,base64,os
t=telnetlib.Telnet('127.0.0.1',30024,5); t.write(b'\x03\x03'); time.sleep(.4); t.write(b'end\r')
def read(timeout=12):
 out=''; end=time.time()+timeout
 while time.time()<end:
  time.sleep(.15); d=t.read_very_eager().decode(errors='replace'); out+=d
  if '--More--' in d: t.write(b' ')
  if re.search(r'(?:#|login:|Password:)\s*$',out): return out
 raise RuntimeError('FortiGate consola no respondio al prompt')
t.write(b'\r'); out=read()
if out.rstrip().endswith('login:'):
 t.write(b'admin\r'); out=read()
 if out.rstrip().endswith('Password:'):
  t.write(os.environ['FGT_PASSWORD'].encode()+b'\r'); out=read()
if not out.rstrip().endswith('#'): raise RuntimeError('FortiGate requiere autenticacion')
for cmd in ['show firewall address','show firewall service custom','show firewall service group','show firewall policy']:
 t.write(cmd.encode()+b'\r'); out=read(); pathlib.Path('/root/dmz-infra1-backups/'+cmd.replace(' ','-')+'.txt').write_text(out)
commands=base64.b64decode('@@FWPOL@@').decode().splitlines()
for cmd in commands:
 if not cmd.strip(): continue
 time.sleep(.25); t.write(cmd.encode()+b'\r'); out=read()
 if re.search(r'Command fail|parse error|Unknown action|command parse error',out,re.I):
  raise RuntimeError('FortiGate rechazo un comando: '+out[-1200:])
print('Objetos y politicas FortiGate aplicados')
for cmd in ['show firewall policy','show firewall address']:
 t.write(cmd.encode()+b'\r'); print(read(),flush=True)
t.close()
PY
printf '%s' '@@CAJA@@' | base64 -d | docker exec -i docker28 sh -c 'cat > /var/www/html/index.html'
docker exec docker28 chown www-data:www-data /var/www/html/index.html
docker exec docker28 chmod 644 /var/www/html/index.html
printf '%s' '@@INVENTARIO@@' | base64 -d | docker exec -i docker27 sh -c 'cat > /var/www/html/index.html'
docker exec docker27 chown www-data:www-data /var/www/html/index.html
docker exec docker27 chmod 644 /var/www/html/index.html
docker exec docker28 sha256sum /var/www/html/index.html
docker exec docker27 sha256sum /var/www/html/index.html
for port in 3389 22 80 443; do :; done
# Aislar las interfaces de gestion Docker 10.177.0.0/16 para cerrar rutas
# paralelas al FortiGate. PC8 conserva el tunel RDP recibido desde el host.
for spec in 'docker30 no' 'docker31 rdp' 'docker28 no' 'docker27 no' 'docker29 no'; do
 set -- $spec; pc=$1; permit_rdp=$2; pid=$(docker inspect -f '{{.State.Pid}}' "$pc")
 nsenter -t "$pid" -n iptables -C INPUT -i eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || nsenter -t "$pid" -n iptables -I INPUT 1 -i eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
 nsenter -t "$pid" -n iptables -C OUTPUT -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || nsenter -t "$pid" -n iptables -I OUTPUT 1 -o eth0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
 if [ "$permit_rdp" = rdp ]; then
  nsenter -t "$pid" -n iptables -C INPUT -i eth0 -p tcp --dport 3389 -m conntrack --ctstate NEW -j ACCEPT 2>/dev/null || nsenter -t "$pid" -n iptables -I INPUT 2 -i eth0 -p tcp --dport 3389 -m conntrack --ctstate NEW -j ACCEPT
 fi
 nsenter -t "$pid" -n iptables -C INPUT -i eth0 -j DROP 2>/dev/null || nsenter -t "$pid" -n iptables -A INPUT -i eth0 -j DROP
 nsenter -t "$pid" -n iptables -C OUTPUT -o eth0 -j DROP 2>/dev/null || nsenter -t "$pid" -n iptables -A OUTPUT -o eth0 -j DROP
 echo "GESTION AISLADA: $pc"
done
