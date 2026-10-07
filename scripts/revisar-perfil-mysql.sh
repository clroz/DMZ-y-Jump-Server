#!/usr/bin/env bash
sed -n '1,100p' /etc/apparmor.d/usr.sbin.mysqld 2>/dev/null || true
printf '\n--- Local additions ---\n'
cat /etc/apparmor.d/local/usr.sbin.mysqld 2>/dev/null || true
printf '\n--- Loaded profiles ---\n'
aa-status 2>/dev/null | grep -i -C2 mysqld || true
apparmor_parser --version 2>&1 | head -2 || true
printf '\n--- AUFS denied paths (most recent) ---\n'
dmesg 2>/dev/null | grep -F 'profile="/usr/sbin/mysqld"' | tail -4 || true
docker inspect --format 'AppArmor={{.AppArmorProfile}} image={{.Config.Image}}' docker29
