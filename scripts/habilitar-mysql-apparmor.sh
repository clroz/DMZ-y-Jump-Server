#!/usr/bin/env bash
set -euo pipefail
echo 'No ejecutar: AppArmor 2.12 en PNETLab no puede aislar de forma segura las rutas AUFS desconectadas de este contenedor.' >&2
echo 'El perfil local ya fue restaurado. Usa configurar-mysql-infra1.sh para el workaround documentado.' >&2
exit 2
