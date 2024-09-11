
# DHCP (Dynamic Host Configuration Protocol)

- Assign IP addr to device connected to network (DHCP Lease)
- Configure other network settings
	- DNS servers
	- default domain names
	- Network Time Protocol (NTP) servers
	- IP routes

Communicate over **UDP** port **67** / **68**

[RFC 2131](https://datatracker.ietf.org/doc/html/rfc2131)

### Common search on dhcp logs

- Search date for IP addr : tell what system was assigned to
- Search all dates for a MAC addr : all IP addr and the associated dates that a system was assigned over time

### Microsoft dhcp

http://technet.microsoft.com/en-us/library/dd183591(v=ws.10).aspx
http://technet.microsoft.com/en-us/library/dd759178.aspx

Logs : ```%windir%\System32\Dhcp ```

![[Images/Pasted image 20240803225207.png]]

```dhcpserverlog-<day>.log``` => 1 week retention /!\\ not good for ir

### ICS DHCP

www.isc.org/downloads/dhcp

free, open-source

log to ```syslog local7``` by default
2 entries : 
- DHCPDISCOVER : request an IP addr
- DHCPOFFER : IP addr offers & client's computer name & MAC addr

![[Images/Pasted image 20240804145538.png]]

# DNS (Domain Name System)

Look up / resolve  host names == determine the IP addr of a website

DNS client resolution on **UDP** port **53**
DNS zone transfer on **TCP** port **53**

[RFC 1034](tools.ietf.org/html/rfc1034)
[RFC 1035](tools.ietf.org/html/rfc1035)

**Resolution process** log are useful in order to :
- The host name that resolution was requested for (query), such as
www.example.com
- The IP address of the client that requested resolution
- The result of the resolution (answer), such as 93.184.216.119

### BIND : ICS Berkeley Internet Domain Name

Off by default 
see how to enable it 
- Just queries
- Answer nd query

### Microsoft DNS 

Off by default

Default folder : ```%systemroot%\system32\dns\dns.txt```

Attention : log file is truncated at each restart or reboot of the system or max size of the file is reach

![[Images/Pasted image 20240804151336.png]]

### Network level DNS logging

Most DNS answers generates log records that span hundred of lines => not feasible

Solution : Network based solution 
- [DNSCAP](www.dns-oarc.net/tools/dnscap) : Can log DNS traffic to pcap file or output dig file
