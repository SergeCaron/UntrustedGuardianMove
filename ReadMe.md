# Untrusted Guardian Move

The Host Guardian Service running in local mode on the Hyper-V host is documented here: [Generation 2 virtual machine security settings for Hyper-V](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/learn-more/generation-2-virtual-machine-security-settings-for-hyper-v).

You can move the *Untrusted Guardian* from one Hyper-V host to another **provided you know what you are doing**. There is a single Untrusted Guardian per Hyper-V host and you can lose access to some VMs already using the local *Untrusted Guardian* of the target host.

**Use this code at your own risk.**

The basic idea for the Extractor and Injector scripts comes form *[Migrating local VM owner certificates for VMs with vTPM](https://techcommunity.microsoft.com/t5/virtualization/migrating-local-vm-owner-certificates-for-vms-with-vtpm/ba-p/382406)* and these people saved my hide once ;-). Thank you.

# The Extractor
As its name implies, the script dumps the certificates of the current *Untrusted Guardian* or of all Guardians that were installed on this Hyper-V host. If the later is chosen, the script identifies only the Guardians for which it can find matching signing and encrypting certificates with available private keys.

The script asks for  a password to protect the certificates. A prefix is added to the file names of the certificates: the host name if only the current *Untrusted Guardian* is extracted, a user supplied string otherwise. 

**Caution:**	This script requires **elevated** execution privileges.

Sample output (Stoic and Toothless are two Hyper-V hosts):

````
WARNING: This code extracts Shielded VM Certificates without any destructive action.



   PSParentPath : Microsoft.PowerShell.Security\Certificate::LocalMachine\Shielded VM Local Certificates

Thumbprint                                Subject
----------                                -------
E927BAE7B5ACC99271164ED5288A35C6FA7B852E  CN=Shielded VM Signing Certificate (UntrustedGuardian) (Stoic)
BF95F58579154BDCEF518CC444584A3609AD6C4A  CN=Shielded VM Encryption Certificate (UntrustedGuardian) (Toothless)
804E06FFD9B01F200DF23D1648D7E6964137D23F  CN=Shielded VM Signing Certificate (UntrustedGuardian) (Toothless)
7D4DC33D6FB0D330C13FC93FE8C1EAD2249F5648  CN=Shielded VM Signing Certificate (UntrustedGuardian) (Stoic)
4DD97604EEAC42F1A606066119D5DEDF3E3FA9EA  CN=Shielded VM Encryption Certificate (UntrustedGuardian) (Stoic)
3D6CA6B198C04A35B86802FFD5C27539C40C00A0  CN=Shielded VM Encryption Certificate (UntrustedGuardian) (Stoic)

Please enter a password to secure the certificate files: ************

Enter 'Yes' to extract all Guardian certificates from this system, anything else to extract the current Guardian: yes

Up to 3 Guardians can be salvaged from this system.

Please enter a prefix to name the certificate files (default is Hgs): :
Guardian 0  3D6CA6B198C04A35B86802FFD5C27539C40C00A0  E927BAE7B5ACC99271164ED5288A35C6FA7B852E
Guardian 1  4DD97604EEAC42F1A606066119D5DEDF3E3FA9EA  7D4DC33D6FB0D330C13FC93FE8C1EAD2249F5648
Guardian 2  BF95F58579154BDCEF518CC444584A3609AD6C4A  804E06FFD9B01F200DF23D1648D7E6964137D23F

Done!

````

# The Injector

A Guardian is a pair of certificates for which a private key MUST be available. The script enumerates all available Guardians and the Guardian in service, if any.

On startup, you must locate each certificate of this pair using a file browser. **There is no validation that this pair was generated at the same time by the same issuer: you can easily create a meaningless Guardian.**

You must confirm the removal of an existing Guardian: a reminder that it could be in use by some VM on this host. The PowerShell cmdlet will confirm the removal and strongly suggest to remove its certificates: **you can revert the removal if you keep these certificates, so don't be too quick in cleaning up**. Use the Extractor to recreate the certificates from the store.

**Caution:**	This script requires **elevated** execution privileges.

Sample output (Stoic and Toothless are two Hyper-V hosts):
````
WARNING: This code has the following destructive actions:
WARNING: - Install/Replace the current Untrusted Guardian for this hypervisor
WARNING: - Install/Replace certificates in the local machine certificate store
WARNING:
WARNING: Use at your own risk!



   PSParentPath : Microsoft.PowerShell.Security\Certificate::LocalMachine\Shielded VM Local Certificates

Thumbprint                                Subject
----------                                -------
E927BAE7B5ACC99271164ED5288A35C6FA7B852E  CN=Shielded VM Signing Certificate (UntrustedGuardian) (Stoic)
BF95F58579154BDCEF518CC444584A3609AD6C4A  CN=Shielded VM Encryption Certificate (UntrustedGuardian) (Toothless)
804E06FFD9B01F200DF23D1648D7E6964137D23F  CN=Shielded VM Signing Certificate (UntrustedGuardian) (Toothless)
7D4DC33D6FB0D330C13FC93FE8C1EAD2249F5648  CN=Shielded VM Signing Certificate (UntrustedGuardian) (Stoic)
4DD97604EEAC42F1A606066119D5DEDF3E3FA9EA  CN=Shielded VM Encryption Certificate (UntrustedGuardian) (Stoic)
3D6CA6B198C04A35B86802FFD5C27539C40C00A0  CN=Shielded VM Encryption Certificate (UntrustedGuardian) (Stoic)
--------- Guardian in service ----------
BF95F58579154BDCEF518CC444584A3609AD6C4A  CN=Shielded VM Encryption Certificate (UntrustedGuardian) (Toothless)
804E06FFD9B01F200DF23D1648D7E6964137D23F  CN=Shielded VM Signing Certificate (UntrustedGuardian) (Toothless)
----------------------------------------
Enter 'Yes' to continue and remove existing Guardian, anything else to exit: yes
WARNING: The Guardian has been removed. Manually delete the following certificates associated with the Guardian if they are not otherwise used.
Cert:\LocalMachine\Shielded VM Local Certificates\804E06FFD9B01F200DF23D1648D7E6964137D23F
Cert:\LocalMachine\Shielded VM Local Certificates\BF95F58579154BDCEF518CC444584A3609AD6C4A
Please enter the password that was used to secure the certificate files: ************
-------- Replacement Guardian ----------
BF95F58579154BDCEF518CC444584A3609AD6C4A  CN=Shielded VM Encryption Certificate (UntrustedGuardian) (Toothless)
804E06FFD9B01F200DF23D1648D7E6964137D23F  CN=Shielded VM Signing Certificate (UntrustedGuardian) (Toothless)
----------------------------------------
Done!

````
