#!/usr/bin/env bash
set -euo pipefail
echo '--- Crear/verificar base de demostración por socket local ---'
docker exec docker29 mysql --protocol=socket --user=root -e "CREATE DATABASE IF NOT EXISTS infra1_demo; USE infra1_demo; CREATE TABLE IF NOT EXISTS productos (id INT AUTO_INCREMENT PRIMARY KEY,codigo VARCHAR(24) NOT NULL UNIQUE,nombre VARCHAR(80) NOT NULL,precio DECIMAL(10,2) NOT NULL,existencia INT NOT NULL DEFAULT 0); INSERT IGNORE INTO productos (codigo,nombre,precio,existencia) VALUES ('LAB-001','Producto de demostración',25.00,10); SELECT id,codigo,nombre,precio,existencia FROM productos;"
tcp_test() { node=$1; docker exec "$node" sh -c 'command -v bash >/dev/null && command -v timeout >/dev/null' || return 2; docker exec "$node" bash -c 'timeout 3 bash -c "echo > /dev/tcp/192.168.30.4/3306"' >/dev/null 2>&1; }
echo '--- Acceso TCP esperado desde servidores DMZ ---'
for node in docker27 docker28; do if tcp_test "$node"; then echo "$node -> 192.168.30.4:3306 permitido"; else echo "$node -> 192.168.30.4:3306 FALLÓ"; exit 1; fi; done
echo '--- Bloqueo TCP esperado desde VLAN de usuarios ---'
for node in docker30 docker31; do if tcp_test "$node"; then echo "$node -> 192.168.30.4:3306 INESPERADAMENTE permitido"; exit 1; else rc=$?; if [ "$rc" -eq 2 ]; then echo "$node no tiene herramientas para probar TCP"; exit 1; else echo "$node -> 192.168.30.4:3306 bloqueado"; fi; fi; done
echo '--- Estado de servicio ---'
docker exec docker29 mysql --protocol=socket --user=root -NBe "SELECT @@version,@@bind_address,@@basedir,@@datadir,@@mysqlx_bind_address,@@mysqlx_port;"
docker exec docker29 ss -lnt | grep -E ':(3306|33060)([[:space:]]|$)'
docker exec docker29 sh -c 'for f in /proc/[0-9]*/exe; do x=$(readlink "$f" 2>/dev/null || true); if [ "$x" = /usr/local/sbin/mysqld-infra1 ]; then p=${f#/proc/}; p=${p%/exe}; printf "AppArmor efectivo: "; cat "/proc/$p/attr/current"; fi; done'
