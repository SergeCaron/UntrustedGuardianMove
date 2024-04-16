##******************************************************************
## Revision date: 2024.04.15
##
## Copyright (c) 2023-2024 PC-Évolution enr.
## This code is licensed under the GNU General Public License (GPL).
##
## THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
## ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
## IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
## PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
##
##******************************************************************

# Based on "Migrating local VM owner certificates for VMs with vTPM - Microsoft Community Hub"
# See https://techcommunity.microsoft.com/t5/virtualization/migrating-local-vm-owner-certificates-for-vms-with-vtpm/ba-p/382406

Write-Host
# Sanity check: do not impact Host Guardian Services
If ($(Get-HgsClientConfiguration).Mode -ne "Local") {
	Write-Warning "Host guardian Services not running in Local mode: do not proceed!"
	Read-Host "Press ENTER to exit"
	Exit 911
}

Write-Warning "This code has the following destructive actions:"
Write-Warning "- Install/Replace the current Untrusted Guardian for this hypervisor"
Write-Warning "- Install/Replace certificates in the local machine certificate store"
Write-Warning ""
Write-Warning "Use at your own risk!"
Write-Host

# Default Guardian name in Local mode
$GuardianName = 'UntrustedGuardian'

# Display available Shielded VM certificates
Get-ChildItem "Cert:\LocalMachine\Shielded VM Local Certificates"

# Get the location of the encryption and signing certificates
# Do not presume both are in the same location
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
	InitialDirectory = [Environment]::GetFolderPath('Desktop') 
	Filter           = 'Certificates (*encryption.pfx)|*encryption.pfx'
	Title            = 'Please locate the encryption certificate for this host'
}
$null = $FileBrowser.ShowDialog()
If ($FileBrowser.FileName -eq "") {
	Read-Host "Press ENTER to exit"
	Exit 911
}
$EncryptionCertificate = Get-Item $FileBrowser.FileName

Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
	# Stay within above directory even if this is ian insecure assumption.
	Filter = 'Certificates (*signing.pfx)|*signing.pfx'
	Title  = 'Please locate the signing certificate for this host'
}
$null = $FileBrowser.ShowDialog()
If ($FileBrowser.FileName -eq "") {
	Read-Host "Press ENTER to exit"
	Exit 911
}

$SigningCertificate = Get-Item $FileBrowser.FileName

Try {
	Write-Host "--------- Guardian in service ----------"
	$(Get-HgsGuardian -Name $GuardianName -ErrorAction Stop).EncryptionCertificate
	$(Get-HgsGuardian -Name $GuardianName -ErrorAction Stop).SigningCertificate
	Write-Host "----------------------------------------"
	If (-not $(Read-Host "Enter 'Yes' to continue and remove existing Guardian, anything else to exit").tolower().StartsWith('yes')) {
		Exit 911
	}

	Remove-HgsGuardian -Name $GuardianName -ErrorAction Continue
}
Catch {
	Write-Warning "There is no Host Guardian Certificates on this system."
}

$CertificatePassword = Read-Host -Prompt 'Please enter the password that was used to secure the certificate files' -AsSecureString

$NewGuardian = New-HgsGuardian -Name $GuardianName -SigningCertificate "$SigningCertificate" -SigningCertificatePassword $CertificatePassword -EncryptionCertificate "$EncryptionCertificate" -EncryptionCertificatePassword $CertificatePassword -AllowExpired -AllowUntrustedRoot
Write-Host "-------- Replacement Guardian ----------"
$NewGuardian.EncryptionCertificate
$NewGuardian.SigningCertificate
Write-Host "----------------------------------------"

Write-Host "Done!"
