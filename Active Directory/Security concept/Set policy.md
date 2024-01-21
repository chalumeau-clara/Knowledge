
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
    
