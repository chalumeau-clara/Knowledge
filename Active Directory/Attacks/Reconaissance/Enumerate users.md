
(ING) LAB 2 - Reconnaissance actions

1 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 5 - Enumerate domain users and group anonymously

Hello **Miss Red**! Your collegue and almost nemessis by now **Mister Blue** is hardening the environment based on your input. Let's show him thatou can do even better )or worse) than BloodHound and let's gather intel without using an account.

### Task 1 - Use anonymous SAM-R enumeration

1. Log on to **[CLI01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. If you don't have a **Windows Terminal** already opened, open a new one by right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127178/11menu.png) and clicking on **Windows Terminal (Admin)**. Else you can use an existing one.
    
3. In the terminal, open a new tab by clicking on the chevron and selecting **Command Prompt** like shown in this screenshot:  
    ![TERM1.png](https://labondemand.blob.core.windows.net/content/lab127178/TERM1.png)
    
4. In this new tab, run the following command `nmap --script smb-enum-users -p 445 DC01`. This is essentially doing a SAM-R call and as you can see, we did not specify a user.
    
    > You can run the same command with `-d` to use the debug mode and see in the ouput that we did not authenticate.
    

You send the output to **Mister Blue** with a nice encouragement message "Do better".

### Task 2 - Block anonymous SAM-R enumeration

1. Log on to **[DC01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127178/2022menu.png) and click on **Run**.
    
3. In the **Run** window, type `dsa.msc` and click **OK**.
    
4. In the **Active Directory Users and Computers** window, navigate to **contoso.com** > **Builtin** and double click on the group **Pre-Windows 2000 Compatible Access**. Select the **Members** tab.
    
    > The presence of the security principal **ANONYMOUS LOGON** is the reason why Red's SAM-R enumeration worked without authentication.
    
    📝 Who else is a member of this group in the lab?
    
5. Select **ANONYMOUS LOGON**, click **Remove** and **OK**. If there is a confirmation popup, confirm by clicking **Yes**.
    
6. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127178/2022menu.png) and click on **Run**.
    
7. In the **Run** window, type `services.msc` and click **OK**.
    
8. In the **Services** console, right click on the **Server** service and click **Restart**. A pop-up will ask you if you want to restart the dependencies, click **Yes**.
    

### Task 3 - Check that anonymous SAM-R enumeration is disabled

1. Go back to **[CLI01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. In the command prompt tab, run the following command `nmap --script smb-enum-users -p 445 DC01 -d`.
    
    📝 What is the error message?
    

0% Tasks Complete

PreviousNext: Exercise 6 -...

Live Chat