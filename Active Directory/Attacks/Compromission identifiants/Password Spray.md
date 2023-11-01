Sources : 
https://www.netwrix.com/password_spraying_tutorial_defense.html
### What is it ?

Password spray attacks just try very few common passwords on a lot of accounts.


![[Pasted image 20231010205610.png]]


Compromise a local administrator account


### How to make a password spray of user account ? 

Tool : https://github.com/vanhauser-thc/thc-hydra

 - Make a list of all the usernames and password that will be targeted.
`users.lst` `passwords.lst`

 - Run Hydra

```powershell
.\hydra.exe -V -F -L .\users.lst -P .\passwords.lst SRV01 rdp.
```

The argument  :
-f parameter tells **Hydra** to stop the attack as soon as it has found a password.

Result : 
![[Pasted image 20231021182617.png]]

Work when connected via file explorer : `\\SRV01\C$` connect with `SRV01\administrator`|`Passw0rd!`
now connected to the administrative share **C$** as the local administrator of **SRV01**.

### What are the trace we have left ?

Go to **Event Viewer (Local)** > **Windows Logs** > **Security**.
Filter Current Log to the EventID 4625

 > The event **4625** is generated when a failed authentication takes place on the system. It tells you information about:
   > - The type of logon that was attempted
   > - The account for which the authentication was
   > - The reason for the failure
   > - The source IP of the authentication attempt
   > - The authentication protocol for the attempt The detail of all errors codes for the event 4625 can be found in the 🔗 [security event documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4625).

Filter Current Log to the EventID 4624

 >  The event **4624** is generated when a successful connection takes place on the system. Like for the 4625, it has a lot of interesting details 🔗 [security event documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624).
 
On  **XML** tab and click the **Edit query manually**
This filter is looking for both the events 4624 and 4625, for network logon only and from the IP address of the attackers.

`<QueryList> <Query Id="0" Path="Security"> <Select Path="Security"> Event[ System[ (EventID=4624) or (EventID=4625) ] and EventData[ Data[@Name="LogonType"]=3 and Data[@Name="IpAddress"]="192.168.1.31" ] ] </Select> </Query> </QueryList>` And click **OK**.

 You should see the following pattern: ![EVENTS1.png](https://labondemand.blob.core.windows.net/content/lab127270/EVENTS1.png) 
 Multiple failures followed by a success.

Configuration of the audit policy : 
```powershell
auditpol /get /subcategory:Logon
```

![[Pasted image 20231021184627.png]]


## How to make a password spray on domain accounts passwords

Tool : https://github.com/vanhauser-thc/thc-hydra

 - Make a list of all the usernames and password that will be targeted.
`domainusers.lst` `passwords.lst`

 - Run Hydra

```powershell
.\hydra.exe -V -F -L .\domainusers.lst -P .\passwords.lst SRV01 rdp CONTOSO
```

The argument  :

The **CONTOSO** string at the end of the command tells **Hydra** to use the CONTOSO domain for the account instead of a local account database.

### What are the trace we have left ?

#### On the server : 

Go to **Event Viewer (Local)** > **Windows Logs** > **Security**.
Filter Current Log with the XML query : 

`<QueryList> <Query Id="0" Path="Security"> <Select Path="Security"> Event[ System[ (EventID=4624) or (EventID=4625) ] and EventData[ Data[@Name="LogonType"]=3 and Data[@Name="TargetUserName"]="pierre" ] ] </Select> </Query> </QueryList>` .

You should see a series of failed logon (event ID **4625**) followed by a success (event ID **4624**)

#### On the DC : 
### Task 3 - Check the traces left of DC01

**Event Viewer (Local)** > **Windows Logs** > **Security**.
Filter Current Log to the EventID 4776
Look like this:
![[Pasted image 20231021190044.png]]


 >The event 4776 is what a domain controller logs when it deals with an NTLM passthrough authentication. Detail about the error code is available in the 🔗 [event 4776 documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4776).

 >Note that it does not tell you through which server the authentication went through. In our case we know since we did the attack. In a real environment, if server targeted during the attack is not covered by some sort of monitoring solution, you would not know where it is coming from. To correct this, we are going to use NTLM auditing.

 
 **Run** then `gpmc.msc` (**Group Policy Management**)

**Group Policy Management** > **Forest: contoso.com** > **Domains** > **contoso.com** and expand **Domain controllers**. 
Right click on the **Default Domain Controller Policy** and click **Edit**.

In the **Group Policy Management Editor** window, navigate to **Default Domain Controller Policy [DC01.CONTOSO.COM]** > **Computer Configuration** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security option**. Change the following settings according to this table:

    |Setting|Value|
    |---|---|
    |Network security: Restrict NTLM: Outgoing NTLM traffic to remote servers|**Audit all**|
    |Network security: Restrict NTLM: Audit NTLM authentication in this domain|**Enable all**|
    |Network security: Restrict NTLM: Audit Incoming NTLM Traffic|**Enable auditing for all accounts**|
    
    Make sure you pick the right setting and the correct value in the different drop down menus.

Execute `gpupdate`.

**Event Viewer (Local)** > **Windows Logs** > **Applications and Services Logs** > **Microsoft** > **Windows** > **NTLM** > **Operational**. 
You should see events **8004** which will tell you the IP address through which the NTLM authentication has been through. Here we can see **SRV01**:
![[Pasted image 20231021190459.png]]
