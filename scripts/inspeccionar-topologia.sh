#!/usr/bin/env bash
# Inspeccion de solo lectura del host PNETLab; no accede a la CLI de FortiGate.
python3 - <<'PY'
import xml.etree.ElementTree as ET
from pathlib import Path
for path in sorted(Path('/opt/unetlab/labs').rglob('*.unl')):
    try:
        root = ET.parse(path).getroot()
    except ET.ParseError:
        continue
    name = root.get('name', '')
    if 'dmz' not in (name + str(path)).lower():
        continue
    print('LAB:', path, 'NAME:', name, 'ID:', root.get('id'))
    for node in root.findall('.//node'):
        print('NODE:', {k: node.get(k) for k in ('id', 'name', 'type', 'template', 'image', 'ethernet', 'console')})
        for interface in node.findall('.//interface'):
            print(' INTERFACE:', {k: interface.get(k) for k in ('id', 'name', 'network_id')})
    for network in root.findall('.//network'):
        print('NETWORK:', {k: network.get(k) for k in ('id', 'name', 'type')})
    print('TOPOLOGY_XML:', ET.tostring(root.find('topology'), encoding='unicode'))
PY
