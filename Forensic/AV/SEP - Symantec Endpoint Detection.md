
Site : https://www.broadcom.com/products/cybersecurity?inid=us_ps_flyout_prdts_endptprot

Location : ```%ALLUSERSPROFILE%\Application Data\Symantec\Symantec Endpoint
Protection\Logs```

Logs type : plains text separate by a coma

> When Symantec Endpoint Protection detects a threat on a system, in addition to logging to the log file in the Logs directory, it also generates an event in the Windows Application event log. The events will have Event ID 51 and a source of Symantec AntiVirus. The log messages typically start with the phrase “Security Risk Found” and contain a description of the detection signature and the full path of the associated file.

**Good to know**
Attackers create archives or other files that antivirus cannot open due to password protection or other parsing issues.
Many times, the antivirus product will log an error that includes the file name and path. This can be a valuable source of evidence, because it’s likely the attacker has since deleted such files.

### Quarantine File

```%ALLUSERSPROFILE%\Application Data\Symantec\Symantec Endpoint Protection\Quarantine```
Extension .vbn and custom format.
There are two VBN files for each file quarantined. The first contains metadata about the quarantined file, and the second contains an encoded copy of the original file.

Tools Qextract to extarct file from quarantine => on the system
pyqextract.py => not on the system



