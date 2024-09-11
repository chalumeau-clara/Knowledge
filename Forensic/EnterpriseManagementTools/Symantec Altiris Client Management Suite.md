
records the execution history of applications run on a system

AeXAMInventory log

## Metering log

AeXAMInventory.txt

Registry key : `HKLM\SOFTWARE\Altiris\Altiris Agent\InstallDir registry key`

![[Images/Pasted image 20240822185204.png]]

### What to look ?

- Identify executables that do not have version information Malware authors
often strip their executables of identifying information such as the version
information stored in the executable. This prevents signature-based security
products such as antivirus and intrusion detection systems from being able to
identify them with a signature based on this information. Because the Altiris
application metering agent records version information from the PE headers, it
will leave this field blank for executables that don’t contain this information.
Although some legitimate applications don’t contain version information, this is
good place to start when looking for unknown malware on a system.
- Identify suspicious executables by file size Malware, especially backdoors
and utilities, are usually less than a megabyte in size. They’re relatively simple
applications and don’t have a lot of the user interface and error-handling code
found in commercial applications. In addition, an attacker may install the same
backdoor using different file names throughout an environment. Though they
change the name of the file, the size may not change, making it trivial to look for
this value in these logs.
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