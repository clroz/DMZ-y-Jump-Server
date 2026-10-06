#!/usr/bin/env bash
sed -n '1,100p' /etc/apparmor.d/usr.sbin.mysqld 2>/dev/null || true
aa-status --profiled 2>/dev/null | grep -i mysqld || true
docker inspect --format 'AppArmor={{.AppArmorProfile}} image={{.Config.Image}}' docker29
