#!/usr/bin/env bash
set -euo pipefail
# Alias de compatibilidad: el arranque soportado configura basedir y evita duplicados.
exec "$(dirname "$0")/configurar-mysql-infra1.sh"
