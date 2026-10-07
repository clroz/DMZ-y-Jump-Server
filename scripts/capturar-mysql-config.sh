#!/usr/bin/env bash
set -euo pipefail
docker exec docker29 cat /etc/mysql/mysql.conf.d/mysqld.cnf
