# Segmentacion de INFRA1

## Proposito

Separar usuarios y servidores mediante VLAN y una DMZ, y controlar en
FortiGate el acceso a Caja, Inventario y administracion SSH. VLAN10 solo
puede abrir la Web de Caja; su acceso a Inventario y al resto de DMZ se
deniega. VLAN20 permite Web y SSH de administracion, pero niega otros
servicios DMZ. La DMZ no tiene salida general a Internet ni acceso a la LAN.

```mermaid
flowchart LR
    PC7[PC7: VLAN 10] ---|Gi0/1| SWU[SW-USUARIOS]
    PC8[PC8: VLAN 20] ---|Gi0/2| SWU
    SWU ---|Gi0/0: trunk 10,20; VLAN1 temporal| FGT[FortiGate port1]
    FGT ---|port2: DMZ /28| SWD[SW-DMZ Gi0/0]
    SWD ---|Gi0/1 VLAN30| CAJA[Web Caja: nodo 5]
    SWD ---|Gi0/2 VLAN30| INV[Web Inventario: nodo 4]
    SWD ---|Gi0/3 VLAN30| DB[DB: nodo 6]
```

| Segmento | Red | Gateway | DHCP |
|---|---|---|---|
| VLAN10 | 192.168.10.0/25 | 192.168.10.1 | .10 a .126 |
| VLAN20 | 192.168.20.0/25 | 192.168.20.1 | .10 a .126 |
| DMZ VLAN30 | 192.168.30.0/28 | 192.168.30.1 | Caja .2, Inventario .3, DB .4, estaticas |

Las VLAN10 y VLAN20 viajan etiquetadas sobre port1. Port2 transporta la DMZ
sin etiqueta: el switch asigna VLAN30 a sus cuatro puertos conectados.
Los switches funcionan en capa 2; FortiGate es el gateway de cada red.

MySQL 8.0.23 corre en `192.168.30.4:3306`. Caja e Inventario, conectadas en
la misma VLAN30, alcanzan ese puerto directamente a traves del switch. Los
usuarios de VLAN10 y VLAN20 pasan por FortiGate y quedan bloqueados al intentar
abrir el puerto 3306. MySQL X se limita a loopback en el servidor. La cuenta
administrativa solo se ha probado por socket local; no se ha creado un usuario
remoto para las aplicaciones.

En los puertos de PCs y servidores se aplican PortFast, BPDU Guard y
port-security (una MAC sticky, violacion restrict). Se deshabilitan los
puertos libres y el acceso VTY remoto. No se habilita enrutamiento entre
VLAN en los switches.

El acceso 192.168.99.1 es temporal. La GUI definitiva de esta fase se
encuentra en 192.168.20.1 desde PC8. La interfaz Docker eth0 mantiene el
escritorio RDP mediante los tuneles locales PC7/PC8; el trafico ordinario por
esa interfaz esta bloqueado en los contenedores para no evadir el FortiGate.

Sin salida externa, el DNS publico y las actualizaciones de Internet no
pueden validarse. Entregar servidores DNS mediante DHCP no proporciona
por si solo conectividad a ellos.

Referencia: [DHCP FortiOS 7.0.9](https://docs.fortinet.com/document/fortigate/7.0.9/cli-reference/57620/config-system-dhcp-server).
