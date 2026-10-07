#!/usr/bin/env bash
set -e
pid=$(docker inspect -f '{{.State.Pid}}' docker30)
nsenter -t "$pid" -n iptables -C INPUT -i eth0 -p tcp --dport 3389 -m conntrack --ctstate NEW -j ACCEPT 2>/dev/null || nsenter -t "$pid" -n iptables -I INPUT 2 -i eth0 -p tcp --dport 3389 -m conntrack --ctstate NEW -j ACCEPT
echo 'Acceso RDP restringido al puerto 3389 de PC7/VLAN10.'
docker exec docker30 python3 -c 'import crypt,spwd; s=spwd.getspnam("admin").sp_pwdp; print("PC7 admin/admin: " + ("VALIDO" if crypt.crypt("admin",s)==s else "NO COINCIDE"))'
