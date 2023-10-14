
It allows an application to impersonate a user to access other services on its behalf 
	▪ SSO experience for the user 
	▪ End-to-end security and auditing for the user
▪ Unconstraint delegation 
	▪ It allows the service to access everything on behalf the user 
Constraint delegation 
	▪ It allows the service to access only the configured backend services 
▪ Any application and system with the privilege to do Kerberos delegation are ideal targets for attackers 
	▪ Attacker will try to steal the credentials of these accounts to impersonate other accounts 
	▪ Attackers might leverage Kerberos delegation vulnerabilities against unpatched domain controllers


LDAP filters to identify account with delegation

 Machines with unconstrainted delegation 
 (&(objectCategory=computer)(objectClass=computer)(userAccountControl:1.2.840.11 3556.1.4.803:=524288)) 
 
Users with unconstrainted delegation
 (&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1 .4.803:=524288)) 
 
 Computer with constrained delegation and protocol transition enabled
  (&(objectCategory=computer)(objectClass=computer)(userAccountControl:1.2.840.11 3556.1.4.803:=16777216)) 
 
 Users with constrained delegation and protocol transition enabled
 (&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1 .4.803:=16777216))


Attack’s pre-requisites - Control an account with Kerberos delegation permissions - Abuse of an unpatched domain controller

Protection - Remove delegation permissions when not needed - Disable delegation on sensitive users - Use constraint delegation when delegation is required - Disable unconstraint delegation on users, computer and trust - Use Protected Users group (for privileged accounts) - Update all domain controllers