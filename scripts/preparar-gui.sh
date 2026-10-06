#!/usr/bin/env bash
set -e
# Acceso inicial temporal por la LAN sin etiquetar; se migrara a VLAN20.
# Ejecutar en el host PNETLab del laboratorio identificado; requiere sesion
# de consola abierta o FGT_PASSWORD en el entorno.
python3 -u - <<'PY'
import telnetlib, time, os, re
t=telnetlib.Telnet('127.0.0.1',30024,timeout=5)
def receive(timeout=8):
    end=time.time()+timeout
    result=''
    while time.time()<end:
        time.sleep(.2)
        data=t.read_very_eager().decode(errors='replace')
        result+=data
        if '--More--' in data:
            t.write(b' ')
        if re.search(r'(?:#|login:|Password:)\s*$',result):
            break
    return result
t.write(b'\r')
out=receive()
if out.rstrip().endswith('login:'):
    t.write(b'admin\r'); out=receive()
    if out.rstrip().endswith('Password:'):
        password=os.environ.get('FGT_PASSWORD')
        if not password: raise SystemExit('Falta FGT_PASSWORD; no se intento autenticar.')
        t.write(password.encode()+b'\r'); out=receive()
if not out.rstrip().endswith('#'): raise SystemExit('No hay sesion administrativa: '+out)
commands=['get system status','show system interface',
 'config system interface','edit port1','set mode static',
 'set ip 192.168.99.1 255.255.255.0','set allowaccess ping https http',
 'set alias ADMIN-TEMP','next','end','show system interface port1']
for command in commands:
    t.write(command.encode()+b'\r')
    out=receive()
    print(out,flush=True)
    if re.search(r'command fail|parse error|unknown action',out,re.I):
        raise SystemExit('Error de CLI; detener y revisar.')
t.close()
PY
# eth1 corresponde al enlace de datos de PC8; no se altera su interfaz eth0.
docker exec docker31 ifconfig eth1 192.168.99.10 netmask 255.255.255.0 up
docker exec docker31 ping -c 3 -W 2 192.168.99.1
docker exec docker31 curl -sS --connect-timeout 5 --max-time 12 -o /dev/null -w 'GUI HTTP: %{http_code}\n' http://192.168.99.1/login
