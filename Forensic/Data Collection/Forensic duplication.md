
> HPA (Host Protected Area) :


DOS/MBR boot sector
EWF/Expert Witness/EnCase image file format

- You can list files and folders with `fls`. Deleted files are mentioned by a `*`
```
fls -r disk1.img 
r/r 5:	Document confidentiel.docx
r/r * 7:	virus.exe
v/v 3270387:	$MBR
v/v 3270388:	$FAT1
v/v 3270389:	$FAT2
V/V 3270390:	$OrphanFiles
```

Extract files with `icat`
```
icat disk1.img 7 > virus_extraction.exe
```


