
Delegation (or Kerberos forwarding) offers the ability for a service to impersonate a user against another service

## Unconstraint delegation


The user sends its TGT The FrontEnd service uses it to request a service ticket The FE can request ANY service ticket If the FE is compromised, we can access any resources the user has access to
![[Pasted image 20231002101815.png]]

## Constraint delegation
The user sends it TGT The FrontEnd service uses it to request a service ticket The FE can request only service tickets for defined SPNs If the FE is compromised, we can access only to resources the user has access to using the specified SPN (attribute: msDS-AllowedToDelegateTo)


![[Pasted image 20231002101850.png]]

