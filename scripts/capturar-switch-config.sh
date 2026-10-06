#!/usr/bin/env bash
python3 -u - <<'PY'
import telnetlib,time,re
for port,label in [(30025,'SW-USUARIOS'),(30026,'SW-DMZ')]:
 t=telnetlib.Telnet('127.0.0.1',port,5)
 def read(timeout=20):
  out=''; end=time.time()+timeout
  while time.time()<end:
   time.sleep(.15); d=t.read_very_eager().decode(errors='replace'); out+=d
   if '--More--' in d: t.write(b' ')
   if re.search(r'(?:Switch|SW-[^\r\n]*)(?:\([^\r\n]*)?[>#]\s*$',out): return out
  raise RuntimeError(label+': no se recibio prompt')
 t.write(b'\r'); out=read();
 if out.rstrip().endswith('>'): t.write(b'enable\r'); out=read()
 t.write(b'terminal length 0\r'); read()
 t.write(b'show running-config\r'); out=read(25)
 out=re.sub(r'(?im)^.*(?:password|secret|private-key).*\r?\n','[CREDENCIAL OCULTA]\n',out)
 print('\n========== '+label+' ==========\n'+out,flush=True)
 t.close()
PY
