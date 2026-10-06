#!/usr/bin/env bash
set -e
python3 -u - <<'PY'
import telnetlib,time,re,base64,pathlib,os
backup=pathlib.Path('/root/dmz-infra1-backups')
backup.mkdir(exist_ok=True)
def receive(t):
 result=''; end=time.time()+45
 while time.time()<end:
  time.sleep(.12); chunk=t.read_very_eager().decode(errors='replace'); result+=chunk
  if '--More--' in chunk: t.write(b' ')
  if re.search(r'(?:[>#]|login:|Password:)\s*$',result): return result
 raise RuntimeError('Tiempo de espera agotado; revisar consola sin volcar configuracion.')
for port,encoded,label in [(30024,'@@FGT@@','fortigate'),(30025,'@@SW2@@','switch2'),(30026,'@@SW3@@','switch3')]:
 if port<int(os.environ.get('DMZ_START_AT','30024')): continue
 print('\nAPLICANDO',label,flush=True)
 t=telnetlib.Telnet('127.0.0.1',port,5)
 if port==30024: t.write(b'\x03'); time.sleep(.3)
 t.write(b'\r'); out=receive(t)
 if out.rstrip().endswith('login:'):
  t.write(b'admin\r'); out=receive(t)
  if out.rstrip().endswith('Password:'):
   t.write(os.environ['FGT_PASSWORD'].encode()+b'\r'); out=receive(t)
 if not re.search(r'[>#]\s*$',out): raise RuntimeError('No se pudo autenticar')
 if out.rstrip().endswith('>'): t.write(b'enable\r'); out=receive(t)
 if port!=30024: t.write(b'terminal length 0\r'); receive(t)
 before=''
 for backupcmd in (['show system interface','show system dhcp server'] if port==30024 else ['show running-config']):
  t.write(backupcmd.encode()+b'\r'); before+=receive(t)
 target=backup/(label+'-antes-'+str(int(time.time()))+'.txt')
 target.write_text(before); target.chmod(0o600)
 commands=base64.b64decode(encoded).decode().splitlines()
 for cmd in commands:
  if not cmd.strip(): continue
  time.sleep(.3); t.write(cmd.encode()+b'\r'); out=receive(t)
  if re.search(r'Command fail|parse error|Unknown action|% Invalid|% Incomplete|% Ambiguous|%Error',out,re.I):
   print(out); raise RuntimeError('Error: '+cmd)
 print('OK',label,len(commands),'comandos',flush=True)
 t.close(); time.sleep(1)
 t=telnetlib.Telnet('127.0.0.1',port,5); t.write(b'\r'); receive(t)
 for cmd in (['show system interface VLAN10','show system interface VLAN20','show system interface port2','show system dhcp server'] if port==30024 else ['show vlan brief','show interfaces trunk']):
  t.write(cmd.encode()+b'\r'); print(receive(t),flush=True)
 t.close()
PY
@@CLIENTES_DHCP@@
