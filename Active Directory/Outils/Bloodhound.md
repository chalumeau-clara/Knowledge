
Open-source tool used by attackers to visualize control paths leading to identified targets using a Graph database (Neo4j) 
	▪ Ideally to domain admin accounts 
▪ It shows control path for both AD DS and Azure AD 
▪ The collection tool is called Sharpound 
	▪ But you can also inject data collected by other too


(ING) LAB 3 - The compromise of credentials

3 Hr 59 Min Remaining

Instructions Resources Help  100%

(ING) LAB 2 - Reconnaissance actions

1 Hr 59 Min Remaining

Instructions Resources Help  100%

## Exercise 2 - Use BloodHound for recon

Hello **Miss Red**! In this exercise you will use BloodHound and its collection script SharpHound to enumerate objects in Active Directory. Note that although BloodHound could be use for Azure AD recon, we will focus only on on-premises Active Directory in this exercise.

### Task 1 - Run SharpHound

1. Log on to **[CLI01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)**. Use the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. Right click on the Start menu ![11menu.png](https://labondemand.blob.core.windows.net/content/lab127178/11menu.png) and click on **Windows Terminal (Admin)**.
    
3. Change the current directory by typing `cd \Tools\Scripts` and hit **Enter**.
    
    > **cd** is the DOS command to change directory, in PowerShell, **cd** is an alias for the **Set-Location** commandLet. You can type `Get-Alias cd` to confirm it.
    
    📝 ls is an alias for what PowerShell command?
    
4. Display the help menu for **SharpHound** by typing `.\sharphound.exe --?` and hit **Enter**.
    
    > Get familiar with the available options. Specifically the **--collectionmethods**. Each of this collection method will bring a particular type of information. Not all methods are relevant depending of the type of recon you want to perfom. We'll get to that later.
    
5. Run **SharpHound** by executing `.\sharphound.exe --collectionmethods All --skippasswordcheck`
    
    THe collection will take a minute or two.
    
    > The collection should take a minute or so as there are not a lot of objects in your environment. In a production environment, this can take hours and should be optimized for performance and stealth.
    
6. Now we also want to enumerate as many **SRV01**. We are going to create a file that will contain our long list of computer to scan… Well, just one. Execute the following `Write-Output "SRV01.contoso.com" | Out-File computers.lst`
    
7. Run **SharpHound** again but this time by executing `.\sharphound.exe --collectionmethods All --computerfile computers.lst --skippasswordcheck`
    
8. You can see the collection files you have created by running the following command `dir *.zip`.
    
    📝 How many zip files do you see?
    

### Task 2 - Run BloodHound

1. You are still connected to **[CLI01](https://labclient.labondemand.com/Instructions/4c26088d-9e1a-4cc0-8086-b2c2d5f57de4?rc=10#)**. Open the **File Explorer** and navigate to `C:\Tools\BloodHound`. Then double click on the **BloodHound.exe** icon.
    
2. You should see the BloodHound login prompt with the default bolt path `bolt://localhost:7687`. Use the following credentials:
    
    |||
    |---|---|
    |Neo4j Username|`neo4j`|
    |Neo4j Password|`NeverTrustAny1!`|
    
3. You are welcomed with a message telling you there's nothing in the database. Well, let's change that and import the zip files you have created. Click on the **Upload Data** button on the right side ![BH1.png](https://labondemand.blob.core.windows.net/content/lab127178/BH1.png). Navigate to the `C:\Tools\Script` folder, select the first zip file and click **Open**. The import should take a few seconds.
    
4. Click on the **Upload Data** button again and select the second zip file and click **Open**. Then click the small white X next to the popup title **Upload Progress**.
    
5. Click the burger menu on the top left corner ![BH2.png](https://labondemand.blob.core.windows.net/content/lab127178/BH2.png) then click on the **Analysis** tab. Scroll down to the **Shortest Paths** section and click **Find Shortest Path do Domain Admins**. In the popup, click on **DOMAIN ADMIN@CONTOSO.COM**.
    
    You should see something like this:
    
    ![BH3.png](https://labondemand.blob.core.windows.net/content/lab127178/BH3.png)
    
    Spend some time exploring the graph. Note the different types of edges. Some of them were obtained by performing LDAP queries:
    
    - MemberOf
    - Contains
    - GenericAll
    - GPLink
    - …
    
    Some others by SMB enumerations against the DCs
    
    - HasSession
    
    📝 Can you see who has a session and from where?
    
6. On the **Search for a node** on the top left corner, type `SRV01.CONTOSO.COM`. You should see a machine icon in the center of the window. Right click on it and select **Shortest Paths to Here**.
    
    You should see something like this:
    
    ![BH4.png](https://labondemand.blob.core.windows.net/content/lab127178/BH4.png)
    
    This time you can see another type of edge collected by a SAM-R enumeration:
    
    - CanRDP
    
    ❓ Can you guess what it means? **Click here to see the answer**.
    

Good job **Miss Red**! You are now sharing your findings with **Mister Blue**.

0% Tasks Complete

PreviousNext: Exercise 3 - Enable...

Live Chat
## Exercise 8 - Visualize path to domain admins

Hello **Miss Red**, you have found credentials during this second attack phase. Now you own:

- **svc-sql**
- **Pierre**
- **Connie Flores**
- **SRV01** (through the knowledge of the local admin password)

It is time to update BloodHound with your updated knowlegde.

### Task 1 - Udpate BloodHound

1. Log back on **[CLI01](https://labclient.labondemand.com/Instructions/408ee615-f168-4d09-8db9-7640eef31f16?rc=10#)** using the following credentials:
    
    |||
    |---|---|
    |Username|`CONTOSO\red`|
    |Password|`NeverTrustAny1!`|
    
2. If **BloodHound** is not running already, open a **File Explorer**, navigate to `C:\Tools\BloodHound` and double click on **BloodHound.exe**. Using the following credentials:
    
    |||
    |---|---|
    |Neo4j Username|`neo4j`|
    |Neo4j Password|`NeverTrustAny1!`|
    
3. In the **Search of a node** field on the top left, type `SVC-SQL@CONTOSO.COM` and click on the suggestion. In the graph, right click on the gree user icon and in the contextual menu, click **Mark User as Owned**.
    
4. Repeat the same operation for `PIERRE@CONTOSO.COM`, `CONNIE.FLORES@CONTOSO.COM` and `SRV01@CONTOSO.COM`. Now, you should own four identities.
    
5. Click on the burger menu on the top left ![BHBURGER.png](https://labondemand.blob.core.windows.net/content/lab127270/BHBURGER.png) and then click on the **Analysis** tab. In the **Shortest Paths** section, click on **Shorest Paths to Domain Admins from Owned Principals**. Select **DOMAIN ADMINS@CONTOSO.COM** and explore the results.
    
    📝 Why does SRV01 has a $ sign at the end of its name?
    

Hey **Mister Blue**! This is the type of view the attacker have of your environment. Far from the consoles you manage it with right?

0% Tasks Complete

PreviousNext

Live Chat