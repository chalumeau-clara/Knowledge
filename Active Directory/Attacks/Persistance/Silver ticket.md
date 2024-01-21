To see : 
[[Kerberos]]
[[PAC - Privilege Attribute Certificate]]

Source : 
https://en.hackndo.com/kerberos-silver-golden-tickets/



TGS is encrypted with NT hash of the account running this process. 
Then, if an attacker manages to extract the password or NT hash of a service account, he can forge a service ticket (TGS) by choosing the information he wants to put in it in order to access that service, without asking the KDC. It is the attacker who builds this ticket. It is this forged ticket that is called **Silver Ticket**.