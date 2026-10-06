#!/usr/bin/env bash
# Comprueba la credencial inicial admin sin mostrar hashes ni modificarlos.
docker exec docker31 python3 -c 'import crypt,spwd; print("PC8 admin/admin: " + ("VALIDO" if crypt.crypt("admin",spwd.getspnam("admin").sp_pwdp)==spwd.getspnam("admin").sp_pwdp else "NO COINCIDE"))'
