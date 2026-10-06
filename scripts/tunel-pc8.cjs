// Tunel SSH local para el escritorio RDP de PC8. No guarda contrasenas.
// Requiere ssh2 y PNET_AUDIT_PASSWORD en el entorno.
const net = require('node:net');
const {Client} = require(process.env.SSH2_MODULE || 'ssh2');
const conn = new Client();
const server = net.createServer(socket => {
  socket.on('error', () => socket.destroy());
  conn.forwardOut('127.0.0.1', socket.remotePort || 0, '10.177.0.6', 3389, (err, stream) => {
    if (err) { console.error(err.message); socket.destroy(); return; }
    stream.on('error', () => socket.destroy());
    socket.pipe(stream).pipe(socket);
    socket.on('close', () => stream.destroy());
  });
});
server.on('error', err => { console.error(err.message); conn.end(); process.exitCode=1; });
conn.on('ready', () => server.listen(13389, '127.0.0.1', () => console.log('LISTO 127.0.0.1:13389 -> PC8 10.177.0.6:3389')));
conn.on('error', err => { console.error(err.message); server.close(); process.exitCode=1; });
conn.on('close', () => { server.close(); process.exit(); });
for (const signal of ['SIGINT', 'SIGTERM']) process.on(signal, () => {server.close(); conn.end();});
if (!process.env.PNET_AUDIT_PASSWORD) throw new Error('Falta PNET_AUDIT_PASSWORD');
conn.connect({host:'192.168.22.132',port:22,username:'root',password:process.env.PNET_AUDIT_PASSWORD,readyTimeout:15000,keepaliveInterval:15000,keepaliveCountMax:3});
