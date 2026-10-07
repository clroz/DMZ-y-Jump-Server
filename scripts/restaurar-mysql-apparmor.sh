#!/usr/bin/env bash
set -euo pipefail
profile=/etc/apparmor.d/usr.sbin.mysqld
local_profile=/etc/apparmor.d/local/usr.sbin.mysqld
backup=$(ls -1t /etc/apparmor.d/local/usr.sbin.mysqld.bak.* 2>/dev/null | head -1)
test -n "$backup" || { echo 'No se encontró backup local de AppArmor' >&2; exit 1; }
cp -a "$backup" "$local_profile"
apparmor_parser -r "$profile"
echo "Perfil restaurado desde backup; regla AUFS retirada."
