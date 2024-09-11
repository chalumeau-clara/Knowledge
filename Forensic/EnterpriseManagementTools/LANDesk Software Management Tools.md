website : www.landesk.com/products/management-suite

Manage software inventory

Interesting component : 

**Software License Monitoring SLM**

> Tracks the execution history of every application run on a system and provides a wealth of information, such as the date and time an application ran, file attributes of the executable, and the user account that ran it.

### Registry Keys

reg : **SOFTWARE** 
```LANDesk\ManagementSuite\WinClient\SoftwareMonitoring\MonitorLog``` contains subkeys for each of the applications executed on a system and recorded by SLM

![[Images/Pasted image 20240804160508.png]]


### Parsing Monitor log registry keys

[SLM Browser](community.landesk.com/support/docs/DOC-7062) : parse only on live system
[RegRipper plugin](code.google.com/p/regripper) : 
- Landesk.pl : parse an exported registry in addition to a live system
- landesk_slm.pl : parse more fields [python-version](github.com/jprosco/registry-tools) 

## Look for

Gather information about application running in the network

- Use frequency analysis on Total Runs Attackers sometimes run their utilities
only once on a system before deleting them. Using frequency analysis to find
software with a low value for Total Runs may help you identify malware on the
system.
- Identify suspicious paths of execution Attackers frequently use the same path
to execute their malware from, whether it’s a temporary directory or a specific
directory. For example, any execution of software from the root of the Windows
Recycle Bin directory has a high probability of being malicious.
- Use timeline analysis to identify a date of compromise Look for clustering of
Last Run time values of legitimate Windows applications such as net.exe, net1
.exe, cmd.exe, and at.exe. Casual users of a system will infrequently use these
built-in Windows utilities, but an attacker is highly likely to use them within a
short time period. These utilities may be indicative of lateral movement
involving the compromised system.
- Identify suspicious usernames Use the Current User value to identify the user
account that last ran a specific executable. User accounts that have a low number
of applications recorded may be malicious and indicative of lateral movement.
Try to identify accounts that shouldn’t normally access a system, and look for
evidence of software execution. Pay particular attention to applications run by
elevated accounts, such as domain administrators.
- Identify executables that no longer exist on the file system Use the paths of
the executables recorded by LANDesk SLM to identify deleted files. Although
legitimate applications such as installers may execute and delete temporary
executables, analysis of these deleted files might lead you to attacker activity.
