#!/usr/bin/env bash
set -euo pipefail
container=docker29
docker exec "$container" sh -c 'for f in /proc/[0-9]*/exe; do x=$(readlink "$f" 2>/dev/null || true); [ "$x" = /usr/local/sbin/mysqld-infra1 ] && { echo "Ya existe mysqld-infra1; cancelando para proteger el datadir." >&2; exit 1; }; done; mkdir -p /var/run/mysqld; chown mysql:mysql /var/run/mysqld'
docker exec "$container" /usr/local/sbin/mysqld-infra1 --defaults-file=/etc/mysql/my.cnf --basedir=/usr --user=mysql --daemonize
sleep 4
docker exec "$container" mysqladmin --connect-timeout=3 --protocol=socket ping
docker exec "$container" mysql --protocol=socket --user=root -NBe "SELECT @@version,@@bind_address,@@basedir,@@datadir;"
docker exec "$container" ss -lnt | grep -E ':3306([[:space:]]|$)'
