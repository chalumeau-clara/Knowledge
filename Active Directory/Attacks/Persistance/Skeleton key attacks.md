
(ING) LAB 5 - Domination and persistence

2 Hr 56 Min Remaining

Instructions Resources Help  100%

## Exercise 5 - Skeleton key attacks [optional]

In the physical world, a skeleton key is a key designed to fit many locks. In the identity world, a skeleton key is like having a password that works on many accounts on the top of the actual password.

**Miss Red**, in this exercise you are going patch the KDC service on a the domain controller using mimikatz in a way that a skeleton key (or generic password) will always be accepted regardless of the user you try it against.

To make the exercise faster, we've already downloaded mimikatz on the domain controller. In a real attack scenario, the attacker will have to find a way to get the mimikatz stuff onto the DC without being seen.

### Task 1 - Patch the KDC with the skeleton key

Patching the DC means that you will inject your skeleton key in the KDC service's memory.

1. Log on to **[DC01](https://labclient.labondemand.com/Instructions/6e093b8a-2f3b-4901-9748-814f5963167c?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\katrina.mendoza.adm`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![2022menu.png](https://labondemand.blob.core.windows.net/content/lab127864/2022menu.png), click on **Command Prompt (Admin)** and confirm **Yes** in the User Account Control popup if you see any.
    
3. In the command prompt run `cd \Tools\mimikatz` then run `mimikatz.exe`
    
    The prompt's title should be renamed **mimikatz 2.2.0 x64 (oe.eo)**.
    
4. In the same prompt, run `privilege::debug` and then `misc::skeleton`
    
    You should see the following: ![skel1.png](https://labondemand.blob.core.windows.net/content/lab127864/skel1.png)
    
    📝 What happens in the prompt if you type the command coffee?
    

The default skeleton key is **mimikatz**. Now you can log in with any accounts with either their real password or this skeleton key.

### Task 2 - Try the skeleton key

Let's try to log on on SRV01 with **Mister Blue**'s account but with the skeleton key

1. Log on to **[SRV01](https://labclient.labondemand.com/Instructions/6e093b8a-2f3b-4901-9748-814f5963167c?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\blue`|
    |⚠️ Password|`mimikatz`|
    
2. You should be in using the skeleton key (as long as DC01 was used for the authentication).
    
    📝 Can you still open a connection with the real user's password?
    

The mimikatz patch will die at next reboot, but other malware might be using some persistence mechanisms to do the same thing. Pretty scary stuff eh?

100% Tasks Complete

PreviousNext

Live Chat