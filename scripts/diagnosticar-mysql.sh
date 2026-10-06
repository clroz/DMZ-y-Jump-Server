#!/usr/bin/env bash
docker exec docker29 sh -c 'id; readlink -f /usr/sbin/mysqld; ls -l /usr/sbin/mysqld /lib/x86_64-linux-gnu/libpthread.so.0 /lib/x86_64-linux-gnu/libpthread-2.31.so 2>&1; stat -c "%A %a %n" /usr/sbin/mysqld /lib/x86_64-linux-gnu/libpthread-2.31.so /lib/x86_64-linux-gnu/ld-2.31.so 2>&1; ldd /usr/sbin/mysqld 2>&1 | head -25; dpkg-query -S /usr/sbin/mysqld 2>&1; ls -l /var/lib/mysql; find /var/lib/mysql -maxdepth 1 -type f -printf "%f %s bytes\n" | head'
printf '\n--- Kernel security denials ---\n'
dmesg 2>/dev/null | grep -iE 'apparmor=.*DENIED.*(mysqld|libpthread)' | tail -10 || true
