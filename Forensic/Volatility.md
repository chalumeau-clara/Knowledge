CheatSheet :  https://repository.root-me.org/Forensic/EN%20-%20Volatility%20cheatsheet%20v2.4.pdf
https://github.com/volatilityfoundation/volatility/wiki/Command-Reference
python3.12.exe .\vol.py -f .\ch2.dmp

Find Computer Name : 
```
vol.py -f ch2.dmp imageinfo
```

![[Pasted image 20230618172759.png]]

```
vol.py -f ch2.dmp --profile=Win7SP1x86_23418 hivelist
```
![[Pasted image 20230618172957.png]]

```
vol.py -f ch2.dmp --profile=Win7SP1x86_23418 printkey -o 0x8b21c008 -K 'ControlSet001\Control\ComputerName\ComputerName'
```

![[Pasted image 20230618173013.png]]

---

Find password : 
```
vol.py -f ch2.dmp --profile=Win7SP1x86_23418 hashdump -y 0x8b21c008 -s 0x9aad6148 > hash.txt
```
where 0x9aad6148 is \SystemRoot\System32\Config\SAM
```
cat hash.txt
```
![[Pasted image 20230618175519.png]]
---

View process : 
pslist
psscan
pstree
psxview -R