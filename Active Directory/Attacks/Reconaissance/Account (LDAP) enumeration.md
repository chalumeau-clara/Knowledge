Sources : 
https://attack.mitre.org/techniques/T1087/002/
https://www.netwrix.com/ldap_reconnaissance_active_directory.html

**LDAP reconnaissance** is an internal reconnaissance technique attackers use to discover users, groups and computers in Active Director

## Step of LDAP reco

### Obtain foothold

See Credential access

### Perform reco using LDAP

uses the compromised credentials to authenticate to the VPN and gain network access, and then uses those same credentials to query Active Directory. 

Can enumerate Active Directory using 
- ActiveDirectory PowerShell module
- Automate the discovery using tools like [BloodHound](https://github.com/BloodHoundAD/BloodHound) and [PowerSploit](https://github.com/PowerShellMafia/PowerSploit/tree/master/Recon). 

Uses PowerShell to look for possible passwords in users’ description attributes:
```powershell
PS> Import-Module ActiveDirectory
PS> Get-ADObject -LDAPFilter "(&(objectClass=user)(description=*pass*))" -property * | Select-Object SAMAccountName, Description, DistinguishedName
 
SAMAccountName Description                 DistinguishedName
-------------- -----------                 -----------------
Alice          Password: P@ssw0rd123!      CN=Alice,OU=Users,DC=domain,DC=com
 
PS> 
```

### Use to further obj

Can map out pathways to objectives, such as domain dominance.

## Detect
Moreover, Active Directory does not provide a mechanism for logging the exact queries received; however, some degree of profiling and monitoring for access to specific attributes can be achieved using event [4662](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4662) in the subcategory [Audit Directory Service Access](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/audit-directory-service-access).  
  
Monitoring network traffic received by domain controllers for specific LDAP queries can help you detect adversary activity. The following table shows a small sampling of the kinds of queries that should be infrequent in normal operation but can provide strong signals of adversary activity:  

|   |   |
|---|---|
|**Query**|**Information Collected**|
|(&(ObjectClass=user)(servicePrincipalName=*))|All user objects that have a ServicePrincipalName configured|
|(userAccountControl:1.2.840.113556.1.4.803:=65536)|Objects that have Password Never Expires set|
|(userAccountControl:1.2.840.113556.1.4.803:=4194304)|Objects that do not require Kerberos pre-authentication|
|(sAMAccountType=805306369)|All computer objects|
|(sAMAccountType=805306368)|All user objects|
|(userAccountControl:1.2.840.113556.1.4.803:=8192)|All domain controller objects|
|(primaryGroupID=512)|All Domain Admins using PrimaryGroupID|


## Respond

- Reset the password and disable the user account performing reconnaissance.
- Quarantine the source computer for forensic investigation and eradication and recovery activities.



