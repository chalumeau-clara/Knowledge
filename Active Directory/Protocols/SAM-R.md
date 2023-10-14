Security account manager remote protocol (SAM-R) is a protocol that allows the remote management of users, groups and other security principals

An attacker can exploit this protocol to enumerate accounts and groups for a server, workstation or a Domain Controller

Pre-Windows 2000 Compatible Access group ▪ Although possible, restricting Authenticated Users from performing SAM-R queries on domain controllers will impact systems and applications compatibility Remove the Anonymous Logon security principal from the Pre-Windows 2000 Compatible Access group


## SAM enumeration examples

### Using net.exe 
net.exe users /domain 
net.exe groups /domain

### Anonymous SAM-R enumeration with nmap.exe 
nmap.exe --script smb-enum-users.nse -p 445 10.0.0.10

### SAM-R enumeration with nmap.exe 
nmap.exe --script smb-enum-users.nse --script-args smbuser=normaluser,smbpass=password -p 445 10.0.0.10


Protection - Limit SAMR enumeration to local admins only on member servers - Make sure anonymous SAMR is disable on domain controllers
