# Evidencias de esta ejecución

`topologia-infra1.svg` representa el cableado comprobado desde el archivo del laboratorio PNETLab. Los ficheros `validacion-*.txt` guardan concesiones DHCP, respuestas y pruebas de acceso. `log-denegacion-inventario-20261006.txt` contiene las entradas de tráfico de FortiGate que muestran la regla 10 denegando HTTP hacia Inventario desde VLAN 10. `switch-running-configs-20261006.txt` incluye los running-config de los dos switches con la línea de credencial ocultada. `running-configs-20261006.txt` incluye las interfaces, DHCP, objetos y políticas del FortiGate; al extraerlo de una sesión que pagina la salida, algunas secciones deben contrastarse con la CLI.

`validacion-mysql-20261006.txt` registra una consulta SQL a `infra1_demo.productos`, la escucha TCP 3306, el acceso desde los dos servidores web de la DMZ y los intentos bloqueados desde PC7 y PC8.

[`../configs/mysqld.cnf`](../configs/mysqld.cnf) es la configuración activa capturada del DB. Expone el protocolo clásico en 3306 y limita el puerto auxiliar MySQL X 33060 a loopback.

Las capturas de GUI y el vídeo final se agregarán después de registrar la demostración desde los escritorios de PC7 y PC8. El README deja el vídeo al inicio como punto de entrada. Las salidas de CLI se complementarán con capturas legibles de la GUI al preparar la entrega.
