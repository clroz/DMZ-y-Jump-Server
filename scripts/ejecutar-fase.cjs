// Ejecuta un script de este repositorio por SSH y adjunta los comandos versionados.
const fs=require('node:fs'), path=require('node:path');
const {Client}=require(process.env.SSH2_MODULE || 'ssh2');
const root=path.resolve(__dirname,'..');
let script=fs.readFileSync(path.resolve(process.argv[2]),'utf8').replace(/\r\n/g,'\n');
script=script.replaceAll('@@CLIENTES_DHCP@@',fs.readFileSync(path.join(__dirname,'activar-dhcp-clientes.sh'),'utf8').replace(/\r\n/g,'\n'));
for(const [token,file] of Object.entries({FWPOL:'fortigate-politicas.txt',CAJA:'caja.html',INVENTARIO:'inventario.html'}))
 script=script.replaceAll(`@@${token}@@`,fs.readFileSync(path.join(root,'configs',file)).toString('base64'));
for(const [token,file] of Object.entries({FGT:'fortigate-redes.txt',SW2:'switch2-redes.txt',SW3:'switch3-redes.txt'}))
 script=script.replaceAll(`@@${token}@@`,fs.readFileSync(path.join(root,'configs',file)).toString('base64'));
if(!process.env.PNET_AUDIT_PASSWORD) throw Error('Falta PNET_AUDIT_PASSWORD');
if(process.env.FGT_PASSWORD) script="export FGT_PASSWORD='"+process.env.FGT_PASSWORD.replaceAll("'", "'\\''")+"'\n"+script;
if(process.env.DMZ_START_AT) script='export DMZ_START_AT='+Number(process.env.DMZ_START_AT)+'\n'+script;
const conn=new Client();
conn.on('ready',()=>conn.exec('bash -s',(err,stream)=>{
 if(err){console.error(err.message);conn.end();process.exitCode=1;return;}
 stream.on('data',d=>process.stdout.write(d));stream.stderr.on('data',d=>process.stderr.write(d));
 stream.on('close',code=>{process.exitCode=code||0;conn.end();});stream.end(script);
}));
conn.on('error',err=>{console.error(err.message);process.exitCode=1;});
conn.connect({host:'192.168.22.132',username:'root',password:process.env.PNET_AUDIT_PASSWORD,readyTimeout:15000});
