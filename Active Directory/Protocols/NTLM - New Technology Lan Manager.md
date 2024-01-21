
Sources : 
https://en.hackndo.com/pass-the-hash/#ntlm-protocol

Tools : 
https://github.com/fortra/impacket/blob/master/impacket/examples/secretsdump.py#L1124
https://github.com/gentilkiwi/mimikatz/blob/master/mimikatz/modules/kuhl_m_lsadump.c

Authentication protocol used in Microsoft environments : allows a user to prove their identity to a server in order to use a service offered by this server.

There are two possible scenarios:

- Either the user uses the credentials of a local account of the server, in which case the server has the user’s secret in its local database and will be able to authenticate the user;
- Or in an Active Directory environment, the user uses a domain account during authentication, in which case the server will have to ask the domain controller to verify the information provided by the user.

In both cases, authentication begins with a **challenge/response** phase between the client and the server.

1. **Negotiation** : The client tells the server that it wants to authenticate to it ([NEGOTIATE_MESSAGE](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nlmp/b34032e5-3aae-4bc6-84c3-c6d80eadf7f2)).
2. **Challenge** : The server sends a challenge to the client. This is nothing more than a 64-bit random value that changes with each authentication request ([CHALLENGE_MESSAGE](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nlmp/801a4681-8809-4be9-ab0d-61dcfe762786)).
3. **Response** : The client encrypts the previously received challenge using a hashed version of its password as the key, and returns this encrypted version to the server, along with its username and possibly its domain ([AUTHENTICATE_MESSAGE](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nlmp/033d32cc-88f9-4483-9bf2-b273055038ce)).

![[Pasted image 20231013154325.png]]

An exemple with wireshark : 
![[Pasted image 20231023212451.png]]


To avoid storing user passwords in clear text on the server. It’s the password’s hash that is stored instead. This hash is now the **NT hash**, which is nothing but the result of the [MD4](https://fr.wikipedia.org/wiki/MD4) function, **without salt**, nothing.

```
NThash = MD4(password)
```

### Local account
The server has knowledge of this account, and it has a copy of the account’s secret.
In order to perform this operation, the server needs to store the local users and the hash of their password. The name of this database is the **SAM** (Security Accounts Manager). 
The [[SAM]] can be found in the registry, especially with the `regedit` tool, but only when accessed as **SYSTEM**. It can be opened as **SYSTEM** with [psexec](https://docs.microsoft.com/en-us/sysinternals/downloads/psexec):

```
psexec.exe -i -s regedit.exe
```
![[Pasted image 20231023213524.png]]
A copy is also on disk in `C:\Windows\System32\SAM`.

SAM and SYSTEM databases can be backed up to extract the user’s hashed passwords database.

First we save the two databases in a file

```powershell
reg.exe save hklm\sam save.save
reg.exe save hklm\system system.save
```

Then, we can use [secretsdump.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/secretsdump.py) to extract these hashes

```powershell
secretsdump.py -sam sam.save -system system.save LOCAL
```

![[Pasted image 20231023213653.png]]


![[Pasted image 20231023213731.png]]
Since the server sends a challenge (**1**) and the client encrypts this challenge with the hash of its secret and then sends it back to the server with its username (**2**), the server will look for the hash of the user’s password in its SAM database (**3**). Once it has it, it will also encrypt the challenge previously sent with this hash (**4**), and compare its result with the one returned by the user. If it is the same (**5**) then the user is authenticated! Otherwise, the user has not provided the correct secret.
### Domain account
The server has no knowledge of this account or its secret. It will have to delegate authentication to the domain controller.

Use the **Netlogon** service, which is able to establish a secure connection with the domain controller. This secure connection is called **Secure Channel**. This secure connection is possible because the server knows its own password, and the domain controller knows the hash of the server’s password. They can safely exchange a session key and communicate securely.

I won’t go into details, but the idea is that the server will send different elements to the domain controller in a structure called [NETLOGON_NETWORK_INFO](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nrpc/e17b03b8-c1d2-43a1-98db-cf8d05b9c6a8):

- The client’s username (Identity)
- The challenge previously sent to the client (LmChallenge)
- The response to the challenge sent by the client (NtChallengeResponse)

The domain controller will look for the user’s NT hash in its database. For the domain controller, it’s not in the SAM, since it’s a domain account that tries to authenticate. This time it is in a file called **NTDS.DIT**, which is the database of all domain users. Once the NT hash is retrieved, it will compute the expected response with this hash and the challenge, and will compare this result with the client’s response.

A message will then be sent to the server ([NETLOGON_VALIDATION_SAM_INFO4](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-nrpc/bccfdba9-0c38-485e-b751-d4de1935781d)) indicating whether or not the client is authenticated, and it will also send a bunch of information about the user. This is the same information that is found in the [PAC](https://beta.hackndo.com/kerberos-silver-golden-tickets/#pac) when [Kerberos authentication](https://beta.hackndo.com/kerberos/) is used.

So to summarize, here is the verification process with a domain controller.

![[Pasted image 20231023213904.png]]

Same as before, the server sends a challenge (**1**) and the client **jsnow** encrypts this challenge with the hash of its secret and sends it back to the server along with its username and the domain name (**2**). This time the server will send this information to the domain controller in a **Secure Channel** using the **Netlogon** service (**3**). Once in possession of this information, the domain controller will also encrypt the challenge using the user’s hash, found in its NTDS.DIT database (**4**), and will then be able to compare its result with the one returned by the user. If it is the same (**5**) then the user is authenticated. Otherwise, the user has not provided the right secret. In both cases, the domain controller transmits the information to the server (**6**).

