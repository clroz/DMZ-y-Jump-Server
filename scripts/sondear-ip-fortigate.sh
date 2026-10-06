#!/usr/bin/env bash
# Sondeo ARP limitado al enlace interno; no modifica interfaces ni FortiGate.
python3 - <<'PY'
import socket, struct, time
iface = 'vnet5_1'
mac = bytes.fromhex(open('/sys/class/net/'+iface+'/address').read().strip().replace(':',''))
s = socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(0x0806))
s.bind((iface, 0))
s.settimeout(1)
for candidate in ['192.168.1.99', '192.168.1.1', '192.168.10.1', '192.168.22.99']:
    arp = struct.pack('!HHBBH', 1, 0x0800, 6, 4, 1) + mac + socket.inet_aton('0.0.0.0') + bytes(6) + socket.inet_aton(candidate)
    s.send(bytes.fromhex('ffffffffffff') + mac + bytes.fromhex('0806') + arp)
end = time.time()+5
while time.time()<end:
    try:
        packet = s.recv(2048)
    except socket.timeout:
        continue
    if len(packet)>=42 and packet[20:22]==b'\x00\x02':
        print('ARP:', socket.inet_ntoa(packet[28:32]), 'MAC:', ':'.join('%02x'%x for x in packet[22:28]))
s.close()
PY
printf '\n--- Direcciones PC7 ---\n'
docker exec docker30 ifconfig
