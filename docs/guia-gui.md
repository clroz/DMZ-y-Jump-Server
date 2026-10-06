# Recorrido de demostración por GUI

Usa el escritorio de PC8 para entrar a FortiGate en `http://192.168.20.1`.
Toma las capturas mientras abres estas pantallas:

1. **Dashboard → Status:** muestra que FortiGate está activo y usa FortiOS 7.0.9.
2. **Network → Interfaces:** expande port1 para mostrar VLAN10 `192.168.10.1/25` y VLAN20 `192.168.20.1/25`; muestra port2 como DMZ `192.168.30.1/28`.
3. **Network → DHCP Server:** muestra los rangos `.10` a `.126` para VLAN10 y VLAN20.
4. **Policy & Objects → Firewall Policy:** muestra en orden las reglas `VLAN10-BLOQUEA-INVENTARIO`, `VLAN10-CAJA-WEB`, `VLAN20-ADMIN-WEB-Y-SSH` y `DMZ-BLOCK-SALIDA`.
5. Desde PC7, abre primero `http://192.168.30.2`, que muestra Caja, y luego `http://192.168.30.3`, que queda bloqueado.
6. **Log & Report → Forward Traffic:** filtra Source `192.168.10.10`, Destination `192.168.30.3` y Action `deny`. Abre Details para mostrar Policy ID `10` y `VLAN10-BLOQUEA-INVENTARIO`.
7. Vuelve a PC8, demuestra que ambas páginas abren y conecta por SSH a `192.168.30.2`.

Reemplaza cualquier captura de ejemplo con capturas de esta ejecución en `evidencias/capturas/`; elimina de las imágenes tokens, contraseñas y cualquier URL personal del navegador.
