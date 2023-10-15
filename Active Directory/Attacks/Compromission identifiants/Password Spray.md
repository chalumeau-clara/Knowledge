**Password spray attacks just try very few common passwords on a lot of accounts.**
(ING) LAB 3 - The compromise of credentials

4 Hours Remaining

Instructions Resources Help  100%

## Exercise 1 - Compromise a local administrator account

We are still working on the same contoso.com environment composed of the following machines:

- **DC01** a domain controller for contoso.com running Windows Server 2016 in the HQ Active Directory site
- **DC02** a domain controller for contoso.com running Windows Server 2022 in the Beijin Active Directory site
- **SRV01** a domain joined server member of the contoso.com domain running Windows Server 2022
- **CLI01** a domain joined client member of the contoso.com domain running Windows 11

In this exercise, **Miss Red** will try to get into SRV01 by guessing the local administrator account's password. And **Mister Blue** will try to make the environment more resistant to this attack.

### Task 1 - Password spray the admin account of SRV01

Welcome back **Miss Red**! In this exercise you will use **Hydra** to conduct a password spray against the local administrator account of **SRV01**.

1. Log on to **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127270/11menu.png) and click on **Windows Terminal (Admin)**.
    
3. Change the current directory by typing `cd \Tools\THC-Hydra` and hit **Enter**.
    
4. Run the following command `Get-Content .\users.lst`. This list has all the usernames that will be targeted during the attack.
    
    📝 What is the first name of this list?
    
5. Run the following command `Get-Content .\passwords.lst`. This list has all the passwords that will be attempted during the attack.
    
6. Run **Hydra** by executing `.\hydra.exe -V -F -L .\users.lst -P .\passwords.lst SRV01 rdp`.
    
    > The **-f** parameter tells **Hydra** to stop the attack as soon as it has found a password.
    
    And here we go, we found it: ![FOUND.png](https://labondemand.blob.core.windows.net/content/lab127270/FOUND.png)
    
7. Let's put it to the test now and open a **File Explorer** window. In the address bar, type `\\SRV01\C$` and hit **Enter**. You should be presented with an authentication pop-up. Use the freshly guessed credentials:
    
    |||
    |---|---|
    |Username|`SRV01\administrator`|
    |Password|`Passw0rd!`|
    
    Note that you were prompted because your current account **CONTOSO\red** doesn't not have the permission to connect to the **C$** of **SRV01**.
    
8. Close the **File Explorer** window.
    
    You are now connected to the administrative share **C$** as the local administrator of **SRV01**. Let's tell **Mister Blue** all about it!
    
9. Close the session by right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127270/11menu.png), clicking on **Shut down or sign out** and selecting **Sign out**.
    
    ⚠️ Do not forget to close **Miss Red**'s session before continuing.
    

### Task 2 - Checking the traces left on SRV01

1. Log on to **[SRV01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Event Viewer**.
    
3. In the **Event Viewer** window, navigate to **Event Viewer (Local)** > **Windows Logs** > **Security**.
    
4. On the **Actions** pane, click on **Filter Current Log…** and where you see type `4625` and click **OK**. Review the failed attempts.
    
5. Double click on one of the events and look for the **Logon Type** property.
    
    Here are the most common Logon Types
    
    |Logon Type|Title|Description|
    |---|---|---|
    |2|Interactive|A user logged on to this computer.|
    |3|Network|A user or computer logged on to this computer from the network.|
    |10|RemoteInteractive|A user logged on to this computer remotely using Terminal Services or Remote Desktop.|
    
    > The event **4625** is generated when a failed authentication takes place on the system. It tells you information about:
    > 
    > - The type of logon that was attempted
    > - The account for which the authentication was
    > - The reason for the failure
    > - The source IP of the authentication attempt
    > - The authentication protocol for the attempt The detail of all errors codes for the event 4625 can be found in the 🔗 [security event documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4625).
    
    [more...](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)
    
6. On the **Actions** pane, click again on **Filter Current Log…** and where you see type `4624` and click **OK**. Review the successful connections.
    
    > The event **4624** is generated when a successful connection takes place on the system. Like for the 4625, it has a lot of interesting details 🔗 [security event documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4624).
    
7. On the **Actions** pane, click again on **Filter Current Log…**. In the **Filter Current Log** window, select the **XML** tab and click the **Edit query manually** check box. Acknowledge the pop-up without reading it, I mean, who has time to read pop-up… Just click **Yes**.
    
8. Select the XML filter in the window and delete it.
    
9. Type the following filter instead: `<QueryList> <Query Id="0" Path="Security"> <Select Path="Security"> Event[ System[ (EventID=4624) or (EventID=4625) ] and EventData[ Data[@Name="LogonType"]=3 and Data[@Name="IpAddress"]="192.168.1.31" ] ] </Select> </Query> </QueryList>` And click **OK**.
    
    This filter is looking for both the events 4624 and 4625, for network logon only and from the IP address of **CLI01**. You should see the following pattern: ![EVENTS1.png](https://labondemand.blob.core.windows.net/content/lab127270/EVENTS1.png) Multiple failures followed by a success.
    
10. Note that we see those events because the Windows audit policy is configured to log them. To verify that, you right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Windows PowerShell (Admin)**.
    
11. Run the following command `auditpol /get /subcategory:Logon`. You should see the following output: ![audit1.png](https://labondemand.blob.core.windows.net/content/lab127270/audit1.png)
    
    📝 What is the command to list all audit categories?
    

Well, that's nice to see all that… Let's make it harder for **Miss Red**.

0% Tasks Complete

PreviousNext: Exercise 2 - Secure...

Live Chat



(ING) LAB 3 - The compromise of credentials

4 Hours Remaining

Instructions Resources Help  100%

## Exercise 2 - Secure the local administrator account

In this exercise, you will see different strategies to secure the local administrator account of a Windows machine. Note that those strategies help address attack against credentials as well as lateral movement. The biggest protection for the local administrator account is [LAPS](https://support.microsoft.com/en-us/topic/microsoft-security-advisory-local-administrator-password-solution-laps-now-available-may-1-2015-404369c3-ea1e-80ff-1e14-5caafb832f53). But we are going to see that one in the next lab. In this exercise, **Mister Blue** will try to make it harder to guess and use le local administrator account.

### Task 1 - Password policy for member servers

All Windows machines apply at least the **Default Domain Policy**. This group policy contains a security section called **Password Policy** which when applied on a domain controller governs the password policies for domain users, but when applied a member governs the password policy for local users. Unlike for domain users, local users on member machines do not have **Fine Grained Password Policies**. It means that all local users apply the winning password policy on the local system. Also, since the password policies are evaluated at the time the password was set, if the password of a local account was not reset since the local system joined the domain, it is possible that it has a weaker policy than what the **Default Domain Policy** dictates.

Let's see the password policy on **SRV01**.

1. If that's not the case already, log on to **[SRV01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. You should still have a PowerShell console opened, if that's not the case right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Windows PowerShell (Admin)**. Execute the following command in the console: `net accounts`. Review the policy settings.
    
    Note that the local administrator account, the one with the SID finishing in **-500**, can still be used when it is locked out.
    
    Let's increase the minimum password lenght from 7 to 14.
    
3. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Run**.
    
4. In the **Run** window, type `gpedit.msc` and click **OK**.
    
5. In the **Local Group Policy Editor** window, navigate to **Local Computer Policy** > **Computer Configuration** > **Windows Settings** > **Security Settings** > **Account Policies** > **Password Policy**. Can you modify any of the settings?
    
    ❓ Do you know why you cannot modify those settings? **Click here to see the answer**.
    
    Close the **Local Group Policy Editor** window.
    
6. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Run**.
    
7. In the **Run** window, type `gpmc.msc` and click **OK**.
    
8. In the **Group Policy Management** window, navigate to **Group Policy Management** > **Forest: contoso.com** > **Domains** > **contoso.com**. Right click on the **Default Domain Policy** and click **Edit**.
    
9. In the **Group Policy Management Editor** window, navigate to **Default Domain Policy [DC01.CONTOSO.COM]** > **Computer Configuration** > **Windows Settings** > **Security Settings** > **Account Policies** > **Password Policy**. Double click on Minimum password length and type 14 instead of 7 characters. Click **OK**.
    
10. Close the **Group Policy Management Editor** window.
    
11. Go back to your PowerShell console and type `Invoke-GPUpdate -RandomDelayInMinutes:$false` then execute `net accounts`. Note that now the minimum password lenght is 14.
    
    This does not affect the existing accounts. If you want to make sure your local administrator account for which the password was found is using a 14 characters long password, you will need to reset it.
    
12. Still in the console, execute `net user administrator LongPassword!`. This should fail because the password is only 13 characters long. Now execute `net user administrator LongPassword1!`, this should work.
    
    You effectively changed the local administrator password to `LongPassword1!`.
    

### Task 2 - Restrict the local administrator account usage

Well, now we hope that the password spray will fail… One way to make things even more complicated for the attacker is to restrict from where we can use local administrator accounts. Then, even if **Miss Red** finds the password, she will not be able to use the account unless she is already connected directly to **SRV01**.

1. We stay on **[SRV01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `gpedit.msc` and click **OK**.
    
4. In the **Local Group Policy Editor** window, navigate to **Local Computer Policy** > **Computer Configuration** > **Windows Settings** > **Security Settings** > **Local Policies** > **User Right Assignment**. Double click on **Deny access to this computer from the network**. Click **Add User or Group…**. In the popup, click the **Locations…** button and select **SRV01**. Now in the **Enter the object names to select** section, type `Local account and member of Administrators group`, click **Check Names** and click **OK**. Click **OK** to close the **Deny access to this computer from the network Properties** window.
    
5. Close the **Local Group Policy Editor** window.
    

Let's tell **Miss Red** to try again to use the account.

### Task 3 - Verify local administrator login restriction

1. Log on to **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. If you already have **File Explorer** windows opened, close them. Open a new **File Explorer** window and type the following in the address bar: `\\SRV01\C$`.
    
3. In the authentication prompt, try the following credentials
    
    |||
    |---|---|
    |Username|`SRV01\administrator`|
    |Password|`Passw0rd!`|
    
    This should fail as **Mister Blue** changed the password. But eh, **Miss Red** was kind enough to give you the new password.
    
4. In the authentication prompt, try the new password:
    
    |||
    |---|---|
    |Username|`SRV01\administrator`|
    |Password|`LongPassword1!`|
    
5. This time it should fail with a different error message: ![URAPOP1.png](https://labondemand.blob.core.windows.net/content/lab127270/URAPOP1.png)
    

### Task 4 - Check the security log on SRV01

1. Go back on **[SRV01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Event Viewer**.
    
3. In the **Event Viewer** window, navigate to **Event Viewer (Local)** > **Windows Logs** > **Security**.
    
4. On the **Actions** pane, click on **Filter Current Log…** and where you see type `4625` and click **OK**. Review the last failed attempt. ![15B.png](https://labondemand.blob.core.windows.net/content/lab127270/15B.png)
    
    📝 What is the status code in the failure information section of the event?
    
    > Although that looks like a great feature, it can be tricky to deploy in production as local accounts are sometimes expected to be used by helpdesk members and server operators. But they should not. Local accounts often don't have a centralized audit log (unless there is a SIEM collecting all machines security logs). Local accounts are often use for persistence, so even if you can't fully restrict them, you should closely monitor all local account management and activities.
    
    [more...](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)
    

0% Tasks Complete

PreviousNext: Exercise 3 - Attack...

Live Chat



(ING) LAB 3 - The compromise of credentials

4 Hours Remaining

Instructions Resources Help  100%

## Exercise 3 - Attack domain accounts' passwords

**Mister Blue** has locked down remote access for local accounts on **SRV01**. Well, not a problem for **Miss Red**, let's attack domain accounts instead.

### Task 1 - Password spray domain accounts through SRV01

Welcome back **Miss Red**! In this exercise you will use **Hydra** to conduct a password spray against the domain administrator account through **SRV01**.

1. Log on to **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127270/11menu.png) and click on **Windows Terminal (Admin)**.
    
3. Change the current directory by typing `cd \Tools\THC-Hydra` and hit **Enter**.
    
4. Run the following command `Get-Content .\domainusers.lst`. This list has all the usernames that will be targeted during the attack. Which in our case is just two **administrator** and **pierre**.
    
5. Run the following command `Get-Content .\passwords.lst`. This list has all the passwords that will be attempted during the attack.
    
    📝 How many passwords are in this list?
    
6. Run **Hydra** by executing `.\hydra.exe -V -F -L .\domainusers.lst -P .\passwords.lst SRV01 rdp CONTOSO`. Note the results.
    
    > The **CONTOSO** string at the end of the command tells **Hydra** to use the CONTOSO domain for the account instead of a local account database.
    

It is time to report to **Mister Blue** that we have found something.

❓ What should the blue team do if the red team confirmed a password was guess during a red team exercise? **Click here to see the answer**.[](https://learn.microsoft.com/en-US/troubleshoot/windows-server/windows-security/new-setting-modifies-ntlm-network-authentication)

### Task 2 - Check the traces left of SRV01

Welcome back **Mister Blue** let check what we can on **SRV01** on these attempts.

1. If that's not the case already, log on to **[SRV01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. If the **Event Viewer** is not already open, right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Event Viewer**. Then navigate to **Event Viewer (Local)** > **Windows Logs** > **Security**.
    
3. On the **Actions** pane, click again on **Filter Current Log…**. In the **Filter Current Log** window, select the **XML** tab and click the **Edit query manually** check box. Acknowledge the pop-up by clicking **Yes**.
    
4. Select the XML filter in the window and delete it.
    
5. Type the following filter instead: `<QueryList> <Query Id="0" Path="Security"> <Select Path="Security"> Event[ System[ (EventID=4624) or (EventID=4625) ] and EventData[ Data[@Name="LogonType"]=3 and Data[@Name="TargetUserName"]="pierre" ] ] </Select> </Query> </QueryList>` And click **OK**.
    
    You should see a series of failed logon (event ID **4625**) followed by a success (event ID **4624**)
    

### Task 3 - Check the traces left of DC01

Regular member servers are not always covered by a SIEM or auditing reporting solution. For domain controllers, that's another story. They are often covered by such solution. So, let's check what we see on them.

1. Log on to **[DC01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Event Viewer**.
    
3. In the **Event Viewer** window, navigate to **Event Viewer (Local)** > **Windows Logs** > **Security**.
    
4. On the **Actions** pane, click on **Filter Current Log…** and where you see type `4776` and click **OK**.
    
5. Open any of the event **4776**. They should look like this: ![ID4776.png](https://labondemand.blob.core.windows.net/content/lab127270/ID4776.png) You can see the account name, the client where it comes from (here that's the real name of the workstation **CLI01**, but that can be spoofed as it is at the discretion of the client to provide this string during authentication).
    
    📝 What is the error code for wrong password?
    
    > The event 4776 is what a domain controller logs when it deals with an NTLM passthrough authentication. Detail about the error code is available in the 🔗 [event 4776 documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4776).
    
    Note that it does not tell you through which server the authentication went through. In our case we know since we did the attack. In a real environment, if server targeted during the attack is not covered by some sort of monitoring solution, you would not know where it is coming from. To correct this, we are going to use NTLM auditing.
    
6. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Run**.
    
7. In the **Run** window, type `gpmc.msc` and click **OK**.
    
8. In the **Group Policy Management** window, navigate to **Group Policy Management** > **Forest: contoso.com** > **Domains** > **contoso.com** and expand **Domain controllers**. Right click on the **Default Domain Controller Policy** and click **Edit**.
    
9. In the **Group Policy Management Editor** window, navigate to **Default Domain Controller Policy [DC01.CONTOSO.COM]** > **Computer Configuration** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security option**. Change the following settings according to this table:
    
    |Setting|Value|
    |---|---|
    |Network security: Restrict NTLM: Outgoing NTLM traffic to remote servers|**Audit all**|
    |Network security: Restrict NTLM: Audit NTLM authentication in this domain|**Enable all**|
    |Network security: Restrict NTLM: Audit Incoming NTLM Traffic|**Enable auditing for all accounts**|
    
    Make sure you pick the right setting and the correct value in the different drop down menus.
    
10. Close the **Group Policy Management Editor** window.
    
11. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Command Prompt (Admin)**.
    
12. In the command prompt window, execute `gpupdate`.
    
    > We used the PowerShell cmdLet **Invoke-GPUpdate** earlier in this lab. **gpupdate** is the command line version of it.
    
    Now let's ask **Miss Red** to do it again.
    
13. Go back on **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
14. If you don't already have a **Windows Terminal** window opened on **C:\Tools\THC-Hydra**, right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127270/11menu.png) and click on **Windows Terminal (Admin)**. In the console, change the current directory by typing `cd \Tools\THC-Hydra` and hit **Enter**.
    
15. Run **Hydra** by executing `.\hydra.exe -V -F -L .\domainusers.lst -P .\passwords.lst SRV01 rdp CONTOSO`.
    
    Now let's see what we see on the domain controller.
    
16. Log back on **[DC01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
17. In the **Event Viewer**, navigate to **Event Viewer (Local)** > **Windows Logs** > **Applications and Services Logs** > **Microsoft** > **Windows** > **NTLM** > **Operational**. You should see events **8004** which will tell you the IP address through which the NTLM authentication has been through. Here we can see **SRV01**: ![NTLM8004.png](https://labondemand.blob.core.windows.net/content/lab127270/NTLM8004.png)
    

0% Tasks Complete

PreviousNext: Exercise 4 - Protect...

Live Chat


(ING) LAB 3 - The compromise of credentials

4 Hours Remaining

Instructions Resources Help  100%

## Exercise 3 - Attack domain accounts' passwords

**Mister Blue** has locked down remote access for local accounts on **SRV01**. Well, not a problem for **Miss Red**, let's attack domain accounts instead.

### Task 1 - Password spray domain accounts through SRV01

Welcome back **Miss Red**! In this exercise you will use **Hydra** to conduct a password spray against the domain administrator account through **SRV01**.

1. Log on to **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127270/11menu.png) and click on **Windows Terminal (Admin)**.
    
3. Change the current directory by typing `cd \Tools\THC-Hydra` and hit **Enter**.
    
4. Run the following command `Get-Content .\domainusers.lst`. This list has all the usernames that will be targeted during the attack. Which in our case is just two **administrator** and **pierre**.
    
5. Run the following command `Get-Content .\passwords.lst`. This list has all the passwords that will be attempted during the attack.
    
    📝 How many passwords are in this list?
    
6. Run **Hydra** by executing `.\hydra.exe -V -F -L .\domainusers.lst -P .\passwords.lst SRV01 rdp CONTOSO`. Note the results.
    
    > The **CONTOSO** string at the end of the command tells **Hydra** to use the CONTOSO domain for the account instead of a local account database.
    

It is time to report to **Mister Blue** that we have found something.

❓ What should the blue team do if the red team confirmed a password was guess during a red team exercise? **Click here to see the answer**.[](https://learn.microsoft.com/en-US/troubleshoot/windows-server/windows-security/new-setting-modifies-ntlm-network-authentication)

### Task 2 - Check the traces left of SRV01

Welcome back **Mister Blue** let check what we can on **SRV01** on these attempts.

1. If that's not the case already, log on to **[SRV01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. If the **Event Viewer** is not already open, right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Event Viewer**. Then navigate to **Event Viewer (Local)** > **Windows Logs** > **Security**.
    
3. On the **Actions** pane, click again on **Filter Current Log…**. In the **Filter Current Log** window, select the **XML** tab and click the **Edit query manually** check box. Acknowledge the pop-up by clicking **Yes**.
    
4. Select the XML filter in the window and delete it.
    
5. Type the following filter instead: `<QueryList> <Query Id="0" Path="Security"> <Select Path="Security"> Event[ System[ (EventID=4624) or (EventID=4625) ] and EventData[ Data[@Name="LogonType"]=3 and Data[@Name="TargetUserName"]="pierre" ] ] </Select> </Query> </QueryList>` And click **OK**.
    
    You should see a series of failed logon (event ID **4625**) followed by a success (event ID **4624**)
    

### Task 3 - Check the traces left of DC01

Regular member servers are not always covered by a SIEM or auditing reporting solution. For domain controllers, that's another story. They are often covered by such solution. So, let's check what we see on them.

1. Log on to **[DC01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Event Viewer**.
    
3. In the **Event Viewer** window, navigate to **Event Viewer (Local)** > **Windows Logs** > **Security**.
    
4. On the **Actions** pane, click on **Filter Current Log…** and where you see type `4776` and click **OK**.
    
5. Open any of the event **4776**. They should look like this: ![ID4776.png](https://labondemand.blob.core.windows.net/content/lab127270/ID4776.png) You can see the account name, the client where it comes from (here that's the real name of the workstation **CLI01**, but that can be spoofed as it is at the discretion of the client to provide this string during authentication).
    
    📝 What is the error code for wrong password?
    
    > The event 4776 is what a domain controller logs when it deals with an NTLM passthrough authentication. Detail about the error code is available in the 🔗 [event 4776 documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-4776).
    
    Note that it does not tell you through which server the authentication went through. In our case we know since we did the attack. In a real environment, if server targeted during the attack is not covered by some sort of monitoring solution, you would not know where it is coming from. To correct this, we are going to use NTLM auditing.
    
6. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Run**.
    
7. In the **Run** window, type `gpmc.msc` and click **OK**.
    
8. In the **Group Policy Management** window, navigate to **Group Policy Management** > **Forest: contoso.com** > **Domains** > **contoso.com** and expand **Domain controllers**. Right click on the **Default Domain Controller Policy** and click **Edit**.
    
9. In the **Group Policy Management Editor** window, navigate to **Default Domain Controller Policy [DC01.CONTOSO.COM]** > **Computer Configuration** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security option**. Change the following settings according to this table:
    
    |Setting|Value|
    |---|---|
    |Network security: Restrict NTLM: Outgoing NTLM traffic to remote servers|**Audit all**|
    |Network security: Restrict NTLM: Audit NTLM authentication in this domain|**Enable all**|
    |Network security: Restrict NTLM: Audit Incoming NTLM Traffic|**Enable auditing for all accounts**|
    
    Make sure you pick the right setting and the correct value in the different drop down menus.
    
10. Close the **Group Policy Management Editor** window.
    
11. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127270/2022menu.png) and click on **Command Prompt (Admin)**.
    
12. In the command prompt window, execute `gpupdate`.
    
    > We used the PowerShell cmdLet **Invoke-GPUpdate** earlier in this lab. **gpupdate** is the command line version of it.
    
    Now let's ask **Miss Red** to do it again.
    
13. Go back on **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
14. If you don't already have a **Windows Terminal** window opened on **C:\Tools\THC-Hydra**, right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127270/11menu.png) and click on **Windows Terminal (Admin)**. In the console, change the current directory by typing `cd \Tools\THC-Hydra` and hit **Enter**.
    
15. Run **Hydra** by executing `.\hydra.exe -V -F -L .\domainusers.lst -P .\passwords.lst SRV01 rdp CONTOSO`.
    
    Now let's see what we see on the domain controller.
    
16. Log back on **[DC01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
17. In the **Event Viewer**, navigate to **Event Viewer (Local)** > **Windows Logs** > **Applications and Services Logs** > **Microsoft** > **Windows** > **NTLM** > **Operational**. You should see events **8004** which will tell you the IP address through which the NTLM authentication has been through. Here we can see **SRV01**: ![NTLM8004.png](https://labondemand.blob.core.windows.net/content/lab127270/NTLM8004.png)
    

0% Tasks Complete

PreviousNext: Exercise 4 - Protect...

Live Chat