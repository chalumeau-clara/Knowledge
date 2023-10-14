
## DNS reconnaissance

Brute force DNS 
nmap.exe --script dns-brute --script-args dns-brute.domain=contoso.com,dnsbrute.srv 10.0.0.10

Enumerate DCs 
nltest.exe /DCLIST:contoso.com

Trigger zone tranfer 
nslookup.exe set d ls –t ALL contoso.com.

