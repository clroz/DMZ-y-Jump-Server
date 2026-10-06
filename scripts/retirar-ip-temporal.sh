#!/usr/bin/env bash
set -e
python3 -u - <<'PY'
import telnetlib,time,re,os
t=telnetlib.Telnet('127.0.0.1',30024,5)
def read(timeout=8):
 out=''; end=time.time()+timeout
 while time.time()<end:
  time.sleep(.15); d=t.read_very_eager().decode(errors='replace'); out+=d
  if '--More--' in d: t.write(b' ')
  if re.search(r'(?:#|login:|Password:)\s*$',out): return out
 raise RuntimeError('FortiGate no devolvio prompt')
t.write(b'\x03\x03'); time.sleep(.3); t.write(b'end\r'); t.write(b'\r'); out=read()
if out.rstrip().endswith('login:'):
 t.write(b'admin\r'); out=read()
 if out.rstrip().endswith('Password:'): t.write(os.environ['FGT_PASSWORD'].encode()+b'\r'); out=read()
if not out.rstrip().endswith('#'): raise RuntimeError('Sin sesion administrativa')
for cmd in ['config system interface','edit port1','unset ip','set allowaccess ping','unset alias','next','end','show system interface port1']:
 t.write(cmd.encode()+b'\r'); out=read()
 if re.search(r'Command fail|parse error|Unknown action',out,re.I): raise RuntimeError(out)
 print(out,flush=True)
t.close()
PY
docker exec docker31 curl -sS --connect-timeout 4 --max-time 8 -o /dev/null -w 'GUI VLAN20 HTTP=%{http_code}\n' http://192.168.20.1/login
