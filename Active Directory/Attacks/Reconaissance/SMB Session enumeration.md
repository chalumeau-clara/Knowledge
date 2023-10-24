
(ING) LAB 2 - Reconnaissance actions

1 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 6 - Restrict SMB enumeration [optional]

My dear **Mister Blue**. In the data **Miss Red** shared with you, you could see paths such as **HasSession** which were telling you where users were connected from. This was made possible because of SMB enumerations. Well good news, that's an easy fix.

### Task 1 - Check SMB enumeration again

SMB enumeration has very volatile output. Users and machines aren't always connected to domain controllers and attackers have to run it multiple times. Last time **Miss Red** ran it as a part of SharpHound. This time, let's isolate the test.

1. Log on to **[CLI01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. If you don't have a **Windows Terminal** already opened, open a new one by right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127178/11menu.png) and clicking on **Windows Terminal (Admin)**. Else you can use an existing one.
    
3. In the terminal, make sure you are in a PowerShell tab and in the directory **C:\Tools\Scripts**. Run the following script `.\Invoke-NetSessionEnum.ps1 -Hostname DC01` The output should look like this: ![NETSESSION1.png](https://labondemand.blob.core.windows.net/content/lab127178/NETSESSION1.png) If you do not see Lee Mendoza's connection, you can log back in **[SRV01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)** with Lee's account and refresh the Explorer window connected to `\\DC01\SYSVOL`.
    

### Task 2 - Restrict SMB Enumeration with NetCease

Now that you have the confirmation it is open, let's restrict it.

1. Log on to **[DC01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127178/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `powershell` and click **OK**.
    
4. In the PowerShell prompt, run the following cmdLet `Get-Command -Module NetCease` and note the output.
    
    > The module was pre-installed in the lab. If you want to install it on another machine, you can use the cmdLet `Install-Module NetCease`.
    
5. In the same prompt, run the following cmdLet `Get-NetSessionEnumPermission | Out-GridView -Title "SMB permissions"` and note the output. You should see the **NT AUTHORITY\Authentication Users** security principal. That explains why Red's account, although she isn't a privileged account can enumerate sessions. You need to remove **Authenticated Users**. Close the **SMB Permissions** window.
    
    📝 Try to run the previous command without the "| Out-GridView -Title "SMB permissions". What is the difference?
    
6. In the same prompt, run the following cmdLet `Set-NetSessionEnumPermission` and then run `Get-NetSessionEnumPermission | Out-GridView -Title "SMB permissions"`. You should see the difference.
    

> Note: If you have an error maybe it's a problem with how you execute the PowerShell! Try to run it as administrator.

1. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127178/2022menu.png) and click on **Run**.
    
2. In the **Run** window, type `services.msc` and click **OK**.
    
3. In the **Services** console, right click on the **Server** service and click **Restart**. A pop-up will ask you if you want to restart the dependencies, click **Yes**.
    
    > In a production environment, you can't just restart those services at any time, you'll need to plan that carefully to avoid application outages.
    

### Task 3 - Check SMB enumeration one last time

1. Log back on to **[CLI01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. In the terminal, run the following script `.\Invoke-NetSessionEnum.ps1 -Hostname DC01`.
    
    📝 Do you still see connections?
    

0% Tasks Complete

PreviousNext

Live Chat