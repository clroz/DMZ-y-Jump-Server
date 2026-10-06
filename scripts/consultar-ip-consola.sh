#!/usr/bin/env bash
# Consulta de diagnostico solicitada por el usuario; no introduce configuracion.
python3 - <<'PY'
import telnetlib, time, os
t = telnetlib.Telnet('127.0.0.1', 30024, timeout=5)
def read():
    time.sleep(4)
    data=t.read_very_eager().decode('utf-8', errors='replace')
    print(data)
    return data
t.write(b'\r')
out=read()
if '--More--' in out:
    t.write(b' ')
    out=read()
if 'login:' in out.lower():
    t.write(b'admin\r')
    out=read()
    if 'password:' in out.lower():
        t.write(os.environ.get('FGT_PASSWORD', '').encode()+b'\r')
        out=read()
if out.rstrip().endswith('#') and 'password' not in out.lower():
    t.write(b'get system interface physical\r')
    out=read()
    for _ in range(5):
        if '--More--' not in out:
            break
        t.write(b' ')
        out=read()
else:
    print('Consulta detenida: no hay una sesion administrativa disponible; no se modifican credenciales.')
t.close()
PY
