### Brute force valid usernames using Kerberos

```powershell
nmap.exe -p 88 --script krb5-enum.users --script-args krb5-enum-users.realm=" contoso.com"
```


