#!/usr/bin/env bash
set -e
python3 -u - <<'PY'
import telnetlib,time,re
t=telnetlib.Telnet('127.0.0.1',30024,5); t.write(b'\x03\x03'); time.sleep(.4); t.write(b'end\r')
def read(timeout=5):
 out=''; end=time.time()+timeout
 while time.time()<end:
  time.sleep(.15); d=t.read_very_eager().decode(errors='replace'); out+=d
  if '--More--' in d: t.write(b' ')
  if re.search(r'(?:#|login:|Password:)\s*$',out): break
 return out
out=read()
if out.rstrip().endswith('login:'):
 t.write(b'admin\r'); out=read()
 if out.rstrip().endswith('Password:'): t.write(b'admin\r'); out=read()
if out.rstrip().endswith('#'):
 for cmd in ['show firewall policy','show firewall address','show firewall service custom']:
  t.write(cmd.encode()+b'\r'); print('\n### '+cmd+'\n'+read(),flush=True)
t.close()
PY
for pc in docker27 docker28 docker29; do
 echo "### $pc"
 docker exec "$pc" sh -c 'hostname; cat /etc/os-release; ip -br addr; ip route; netstat -lntup 2>/dev/null || netstat -lnt; ps -eo comm,args | grep -E "apache|nginx|mysql|sshd|ssh[d]|xrdp" | grep -v grep; ls -la /var/www/html 2>/dev/null | head -12'
done
for pc in docker30 docker31; do docker exec "$pc" ip -br addr; done
