#!/usr/bin/env bash
set -euo pipefail
container=docker29

# Idempotente: prepara el binario alternativo/config y arranca solo si está detenido.
docker exec "$container" sh -c '
set -eu
cnf=/etc/mysql/mysql.conf.d/mysqld.cnf
if ! test -x /usr/local/sbin/mysqld-infra1; then
  cp -p /usr/sbin/mysqld /usr/local/sbin/mysqld-infra1
fi
if ! grep -qE "^[[:space:]]*basedir[[:space:]]*=" "$cnf"; then
  sed -i "/^\[mysqld\]/a basedir = /usr" "$cnf"
fi
if grep -qE "^[[:space:]]*bind-address[[:space:]]*=" "$cnf"; then
  sed -i -E "s/^[[:space:]]*bind-address[[:space:]]*=.*/bind-address = 0.0.0.0/" "$cnf"
else
  sed -i "/^\[mysqld\]/a bind-address = 0.0.0.0" "$cnf"
fi
if grep -qE "^[[:space:]]*mysqlx-bind-address[[:space:]]*=" "$cnf"; then
  sed -i -E "s/^[[:space:]]*mysqlx-bind-address[[:space:]]*=.*/mysqlx-bind-address = 127.0.0.1/" "$cnf"
else
  sed -i "/^\[mysqld\]/a mysqlx-bind-address = 127.0.0.1" "$cnf"
fi
mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld
'

if ! docker exec "$container" timeout 3 mysqladmin --protocol=socket ping 2>/dev/null | grep -q 'mysqld is alive'; then
  docker exec "$container" /usr/local/sbin/mysqld-infra1 \
    --defaults-file=/etc/mysql/my.cnf --basedir=/usr --user=mysql --daemonize
fi

ready=0
for attempt in $(seq 1 10); do
  if docker exec "$container" timeout 3 mysqladmin --protocol=socket ping 2>/dev/null | grep -q 'mysqld is alive'; then
    echo "MySQL respondió al ping local (intento $attempt)."
    ready=1
    break
  fi
  sleep 2
done
test "$ready" -eq 1 || {
  docker exec "$container" sh -c 'tail -30 /var/log/mysql/error.log 2>/dev/null || true'
  exit 1
}

docker exec "$container" mysql --protocol=socket --user=root -e "
CREATE DATABASE IF NOT EXISTS infra1_demo;
USE infra1_demo;
CREATE TABLE IF NOT EXISTS productos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(24) NOT NULL UNIQUE,
  nombre VARCHAR(80) NOT NULL,
  precio DECIMAL(10,2) NOT NULL,
  existencia INT NOT NULL DEFAULT 0
);
INSERT IGNORE INTO productos (codigo,nombre,precio,existencia)
VALUES ('LAB-001','Producto de demostración',25.00,10);
SELECT id,codigo,nombre,precio,existencia FROM productos;
"

docker exec "$container" mysql --protocol=socket --user=root -NBe \
  "SELECT @@version,@@bind_address,@@basedir,@@datadir;"
docker exec "$container" ss -lnt | grep -E ':3306([[:space:]]|$)'
