# Estado de trabajo — 2026-10-06

Laboratorio: DMZ y Jump Server INFRA1. PNETLab: 192.168.22.132.
El usuario autorizo configurar FortiGate por CLI y demostrar por GUI.

## Acceso inicial comprobado

- El acceso temporal inicial fue 192.168.99.1/24. Se retiro al migrar a VLAN20.
- Ahora port1 no tiene IP sin etiqueta y acepta solo ping; la administracion
  HTTPS/HTTP queda en la interfaz VLAN20.
- PC8 (nodo 8, runtime docker31) recibe 192.168.20.10 por DHCP.
- Desde PC8: GUI http://192.168.20.1/login devuelve HTTP 200.
- HTTPS fallo con reinicio de conexion; causa no confirmada.
- FortiOS 7.0.9, licencia de evaluacion valida hasta 2026-10-21 segun el equipo.
- No se agrego nube ni salida a Internet.

## Cableado verificado

| Origen | Destino |
|---|---|
| FortiGate port1 | Switch2 Gi0/0 |
| Switch2 Gi0/1 | PC7 eth1 |
| Switch2 Gi0/2 | PC8 eth1 |
| FortiGate port2 | Switch3 Gi0/0 |
| Switch3 Gi0/1 | Web superior, nodo 5, eth1 |
| Switch3 Gi0/2 | Web inferior, nodo 4, eth1 |
| Switch3 Gi0/3 | DB, nodo 6, eth1 |

## Fase de VLAN, DHCP y DMZ completada

- VLAN10: 192.168.10.1/25; PC7 recibio 192.168.10.10 por DHCP.
- VLAN20: 192.168.20.1/25; PC8 recibio 192.168.20.10 por DHCP.
- GUI actual: http://192.168.20.1 desde PC8, HTTP 200 comprobado.
- La antigua URL 192.168.99.1 no responde desde VLAN20; port1 aun conserva
  su direccion temporal, pendiente de limpiar al terminar la migracion.
- Switch2: SW-USUARIOS; Gi0/0 trunk 1,10,20; Gi0/1 VLAN10; Gi0/2 VLAN20.
- Switch3: SW-DMZ; Gi0/0 a Gi0/3 en VLAN30.
- DMZ: gateway 192.168.30.1/28; Caja .2, Inventario .3, DB .4.
- Ambos PCs y los tres servidores respondieron al ping de su gateway 3/3.
- Caja usa HTTP/HTTPS; Inventario sirve una pagina de laboratorio.
- HTTP VLAN10 -> Caja: 200; VLAN10 -> Inventario: denegado.
- HTTP VLAN20 -> Caja e Inventario: 200; SSH desde VLAN10: denegado; SSH VLAN20 a Caja: permitido.
- Evidencia FortiGate: Policy ID 10, srcip .10.10, dstip .30.3, action deny.
- Trafico de los contenedores por eth0/10.177.0.0/16 bloqueado por iptables;
  PC8 conserva el tunel RDP recibido por el puerto 3389.
- `running-configs-20261006.txt` exporta FortiGate y los dos switches;
  `switch-running-configs-20261006.txt` tiene el running-config IOS completo.
- PortFast, BPDU Guard, port-security sticky y apagado de puertos libres
  aplicados; configuraciones de switches guardadas con write memory.
- Los PCs no incluyen cliente DHCP; se utiliza dhclient del host dentro
  de su namespace de red, con script especifico y sin cambiar DNS del host.
- Configuracion de contenedores aplicada en runtime; persistencia tras
  reinicio pendiente de configurar y verificar.
- Scripts y comandos en scripts/ y configs/; evidencias en evidencias/.

## Pendientes

Completar MySQL. `mysqld` esta instalado con datos previos, pero el perfil
AppArmor `/usr/sbin/mysqld` del host deniega bibliotecas al resolver la
ejecucion desde la capa AUFS del contenedor; no se ha relajado ese perfil.
Persistir IP, iptables y paginas de los contenedores tras reinicio. Resolver salida de actualizaciones:
sin conectividad externa no puede demostrarse acceso a endpoints de Internet.
Agregar capturas de GUI y video. La carpeta local necesita inicializarse
como repositorio y publicarse en GitHub; no se ha confirmado acceso a la cuenta.

Referencia de sintaxis:
https://docs.fortinet.com/document/fortigate/7.0.9/cli-reference/9620/config-system-interface

- PC7 dispone de tunel RDP local 127.0.0.1:13390 verificado; PC8 usa 127.0.0.1:13389.
