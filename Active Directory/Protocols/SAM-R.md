Security account manager remote protocol (SAM-R) is a protocol that allows the remote management of users, groups and other security principals

An attacker can exploit this protocol to enumerate accounts and groups for a server, workstation or a Domain Controller

Pre-Windows 2000 Compatible Access group ▪ Although possible, restricting Authenticated Users from performing SAM-R queries on domain controllers will impact systems and applications compatibility Remove the Anonymous Logon security principal from the Pre-Windows 2000 Compatible Access group


## SAM enumeration examples

### Using net.exe 
net.exe users /domain 
net.exe groups /domain

### Anonymous SAM-R enumeration with nmap.exe 
nmap.exe --script smb-enum-users.nse -p 445 10.0.0.10

### SAM-R enumeration with nmap.exe 
nmap.exe --script smb-enum-users.nse --script-args smbuser=normaluser,smbpass=password -p 445 10.0.0.10


Protection - Limit SAMR enumeration to local admins only on member servers - Make sure anonymous SAMR is disable on domain controllers


(ING) LAB 2 - Reconnaissance actions

1 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 4 - Restrict SAM-R enumeration on a member server

Dear **Mister Blue**. In the data **Miss Red** shared with you, you could see paths such as **CanRDP** to **SRV01**. This means that your member server is not protected against remote SAM enumeration. That's odd because **SRV01** is running Windows Server 2022 and by default only the members of the local adminstrators group can perform this type of enumeration and Red's account isn't a part of it. Maybe someone messed with the default configuration, that would not be the first time… Let's fix this!

### Task 1 - Confirm local group membership

1. Log on to **[SRV01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
    You can use the **Switch User** button on the bottom if necessary.
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127178/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `cmd` and click **OK**.
    
4. In the command prompt window, type `net localgroup "Remote Desktop Users"` and hit **Enter**.
    
    📝 Who is a member of the group?
    

### Task 2 - Correct SRV01 SAM-R configuration

1. Still on **[SRV01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)**, right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127178/2022menu.png) and click on **Run**.
    
2. In the **Run** window, type `gpedit.msc` and click **OK**.
    
3. In the **Local Group Policy Editor** window, navigate to **Local Computer Policy** > **Computer Configuration** > **Windows Settings** > **Security Settings** > **Local Policies** > **Security Options**. Double click on the **Policy** called **Network access: Restrict clients allowed to make remote calls to SAM**. Click on **Edit Security…** and note the current security principals.
    
    This is not the default configuration for Windows Server 2022. Starting Windows Server 2016, only the local Administrators group should be here (when the setting isn't configured, the default applies).
    
4. Select **Authenticated Users**, then click **Remove** and **OK**.
    
    > It might be a good idea to consider using a group policy to enforce the default settings.
    
    📝 Why is using a group policy recommended to use a group policy for these settings?
    

0% Tasks Complete

PreviousNext: Exercise 5 -...

Live Chat