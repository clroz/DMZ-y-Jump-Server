#!/usr/bin/env bash
set -euo pipefail
docker exec docker29 sh -c 'grep -n basedir /etc/mysql/mysql.conf.d/mysqld.cnf || true; for f in /proc/[0-9]*/exe; do x=$(readlink "$f" 2>/dev/null || true); if [ "$x" = /usr/local/sbin/mysqld-infra1 ]; then p=${f#/proc/}; p=${p%/exe}; echo "SIGTERM PID $p"; kill -TERM "$p" || true; fi; done; sleep 3; ps -eo pid,comm,args | grep -E "[m]ysqld-infra1" || true'
