
> HPA (Host Protected Area) : The Host Protected Area (HPA) is a reserved section of a hard drive that is hidden from the operating system and typically used for storing diagnostic tools and recovery software.

> DCOs (Drive Configuration Overlays) : Drive Configuration Overlays (DCOs) are firmware-level features on a hard drive that allow for the modification and limitation of the drive's apparent capacity and capabilities, often used for customization or to restrict access to certain areas of the drive.
## Complete Disk Image

Duplicate every addressable allocation unit on the storage medium.

- Include HPA and DCO

## Partition Image

Specify an individual partition or volume as the source for an image.
It is a subset of a complete disk image.
It includes the unallocated space and file slack present within the partition

## Logical Image

Less than an "image" and more of a single copy

Used for
- Specific files are required pursuant to a legal request
- A specific user's file from NAS or SAN device are of interest
- From business critical NAS or SAN is required and ur IR team can not take a disk unit offline to perform a duplication

Tools
- FTK imager
- [EnCase](https://www.opentext.com/en-gb/products/encase-forensic)

## Live system duplication

Creation of an image of media in a system that is actively running.

Used for : 
- Extremely business critical system that cannot be taken down
- Encrypted drives that would not be accessible after the system was shutdown

> Can impact system performance or crash the system
## Output format

Microsoft 
- EWF : FTK imager, EnCase imager

FTKImager
- Raw (dd)
- ENCase (E01/EFW)
- SMART
- AFF

## Traditional duplication

### Hardware Write Blockers

Best way to ensure that source data is not modified => use spe hardware that prohibits **write** command from reaching the drive controller

> All IR should have one

## Software

### dd

> Present in nearly every Unix System

Cons
- No built-in capability to generate and record a cryptographic checksum
- Do not provide feedback

### DCFLdd & DC3dd

> Derived from dd source code

[DCFLdd](https://sourceforge.net/projects/dcfldd/)
[DC3dd](https://sourceforge.net/projects/dc3dd/)

#### Perform a forensic duplication DC3dd

To see recently connected device 

```shell
└─$ dmesg
[...] [sbd] Attached SCSI removable disk
```

Write the image to /mnt/sbd.dd as one single file.
A log of the session is stored to /mnt/sbd.log
```shell
└─$ sudo dc3dd if=/dev/sbd of=/mnt/sdb.dd hash=md5 hlog/mnt/sdb.log
```


