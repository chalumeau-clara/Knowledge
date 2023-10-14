
Kerberos

rubeus.exe dump /user:katrina.mendoza.adm /service:krbtgt

rubeus.exe ptt /ticket:


Extract the TGT from the LSASS memory 
	▪ This requires the seDebugPrivilege 
	▪ Requires that the targeted identity has cached its credentials 
Inject the TGT into your current session 
	▪ Either locally, or later on other systems by exporting it to a file 
	▪ The “new” ticket is used to request new service tickets 
Does not trigger any failed authentication attempts

This is possible because the hash is in the memory Needed for Single Sign-On


Attack’s pre-requisites Protection - A victim is connected to the system, or a service is running under a user account - seDebugPrivilege, or LSASS memory dump 
Protection
- Healthy administration practices (do not connect to untrusted systems with privileged accounts, use RDP restricted mode or remote credential guard)