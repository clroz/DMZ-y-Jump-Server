#!/usr/bin/env bash
python3 -u - <<'PY'
import telnetlib,time,re,os
def connect(port,password=False):
 t=telnetlib.Telnet('127.0.0.1',port,5)
 def read(timeout=6):
  out=''; end=time.time()+timeout
  while time.time()<end:
   time.sleep(.15); d=t.read_very_eager().decode(errors='replace'); out+=d
   if '--More--' in d: t.write(b' ')
   if re.search(r'(?:#|login:|Password:)\s*$',out): return out
  raise RuntimeError('No prompt on console '+str(port))
 t.write(b'\x03\x03'); time.sleep(.3); t.write(b'end\r'); t.write(b'\r'); out=read()
 if out.rstrip().endswith('login:'):
  t.write(b'admin\r'); out=read()
  if out.rstrip().endswith('Password:'): t.write(os.environ['FGT_PASSWORD'].encode()+b'\r'); out=read()
 if not out.rstrip().endswith('#'):
  if out.rstrip().endswith('>'): t.write(b'enable\r'); out=read()
 if not out.rstrip().endswith('#'): raise RuntimeError('No privileged prompt '+str(port))
 return t,read
for port,name,commands in [
 (30024,'FortiGate',['show system interface','show system dhcp server','show firewall address','show firewall service custom','show firewall service group','show firewall policy']),
 (30025,'SW-USUARIOS',['terminal length 0','show running-config']),
 (30026,'SW-DMZ',['terminal length 0','show running-config'])]:
 t,read=connect(port)
 print('\n========== '+name+' ==========\n')
 for command in commands:
  t.write(command.encode()+b'\r'); out=read()
  out=re.sub(r'(?im)^.*(?:password|secret|private-key|pre-shared-key).*\r?\n','[CREDENCIAL OCULTA]\n',out)
  print(out,flush=True)
 t.close()
PY
