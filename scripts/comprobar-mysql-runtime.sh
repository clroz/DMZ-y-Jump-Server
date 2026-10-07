#!/usr/bin/env bash
set -u
docker exec docker29 sh -c '
echo "--- Procesos ---"
ps -eo pid,comm,args | grep -E "[m]ysqld|[m]ysqld_safe" || true
echo "--- Confinamiento del binario alternativo ---"
for f in /proc/[0-9]*/exe; do
  x=$(readlink "$f" 2>/dev/null || true)
  if [ "$x" = /usr/local/sbin/mysqld-infra1 ]; then
    p=${f#/proc/}; p=${p%/exe}
    printf "PID %s exe=%s profile=" "$p" "$x"
    cat "/proc/$p/attr/current" 2>/dev/null || true
  fi
done
echo "--- Socket/port ---"
ls -l /var/run/mysqld 2>/dev/null || true
ss -lnt 2>/dev/null | grep -E ":3306([[:space:]]|$)" || true
echo "--- Error log ---"
tail -35 /var/log/mysql/error.log 2>/dev/null || true
'
