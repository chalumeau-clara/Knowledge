
Using SMBv1 nmap.exe -p 445 --script smb-enum-sessions.nse --script-args smbuser=nomraluser,smbpass=password DC01

Using NetSess.exe NetSess.exe DC01

Using PowerShell Invoke-NetSessionEnum -HostName DC01

Protection - Limit SMB enumeration to local admins on member servers - Limit SMB enumeration to domain admins on domain controllers