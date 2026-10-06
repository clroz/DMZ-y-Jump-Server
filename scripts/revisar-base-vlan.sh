#!/usr/bin/env bash
python3 -u - <<'PY'
import telnetlib,time,re
def receive(t):
 out=''; end=time.time()+18
 while time.time()<end:
  time.sleep(.3); out+=t.read_very_eager().decode(errors='replace')
  if re.search(r'(?:[>#]|\[yes/no\]:|Password:)\s*$',out): break
 return out
for port in (30025,30026):
 print('\nSWITCH CONSOLE',port,flush=True)
 t=telnetlib.Telnet('127.0.0.1',port,5)
 t.write(b'\r')
 out=receive(t); print(out)
 if 'initial configuration dialog' in out:
  t.write(b'no\r'); time.sleep(2); t.write(b'\r'); time.sleep(1)
  out=receive(t); print(out)
 if out.rstrip().endswith('>'):
  t.write(b'enable\r'); out=receive(t); print(out)
 if out.rstrip().endswith('#'):
  for command in ['terminal length 0','show vlan brief','show interfaces trunk','show interfaces status']:
   t.write(command.encode()+b'\r'); print(receive(t),flush=True)
 t.close()
PY
for pc in docker30 docker31; do
 echo "PC: $pc"
 docker exec "$pc" sh -c 'command -v busybox; command -v python3; ls /sbin/*dh* /bin/*dh* /usr/sbin/*dh* 2>/dev/null; route -n' || true
done
