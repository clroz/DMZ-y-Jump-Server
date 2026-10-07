#!/usr/bin/env bash
set -euo pipefail
if docker exec docker29 timeout 3 mysqladmin --protocol=socket --user=root shutdown; then
  echo 'MySQL recibió shutdown ordenado por socket local.'
else
  echo 'MySQL no respondió al shutdown; revisa su estado antes de forzar la detención.' >&2
  exit 1
fi
