#!/usr/bin/env bash
python3 -u - <<'PY'
import telnetlib,time,re,os,pathlib
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
for cmd in ['execute log filter reset','execute log filter device memory','execute log filter category 0','execute log filter field srcip 192.168.10.10','execute log display']:
 t.write(cmd.encode()+b'\r'); print('\n'+cmd+'\n'+read(),flush=True)
t.close()
PY
