https://en.hackndo.com/service-principal-name-spn/

```
service_class/hostname_or_FQDN:port/arbitrary_name
```

service_class : generic name for the service 
	Ex : www class.

Ex: 
```
www/WEB-SERVER-01.adsec.local
```


### Classes

- `CIFS` for services related to file sharing,
- `DNS`, `WWW` for Web
- `pooler` which includes printing services.

## Practice 

Powershell script : 
List the SPNs present in Active Directory

```
search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$search.filter = "(servicePrincipalName=*)"
$results = $search.Findall()
foreach($result in $results) {
	$userEntry = $result.GetDirectoryEntry()
	Write-host "Object : " $userEntry.name "(" $userEntry.distinguishedName ")"
	Write-host "List SPN :"        
	foreach($SPN in $userEntry.servicePrincipalName)
	{
		Write-Host $SPN       
	}
	Write-host ""
}
```

List user accounts that have one (or more) SPNs 

```
$search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$search.filter = "(&(objectCategory=person)(objectClass=user)(servicePrincipalName=*))"
$results = $search.Findall()
foreach($result in $results)
{
	$userEntry = $result.GetDirectoryEntry()
	Write-host "User : " $userEntry.name "(" $userEntry.distinguishedName ")"
	Write-host "SPNs"        
	foreach($SPN in $userEntry.servicePrincipalName)
	{
		$SPN       
	}
	Write-host ""
}
```
