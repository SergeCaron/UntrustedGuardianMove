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

Write-Warning "This code extracts Shielded VM Certificates without any destructive action."
Write-Host

# Default Guardian name in Local mode
$GuardianName = 'UntrustedGuardian'

# Default output directory and file name prefix
$OutputDirectory = [Environment]::GetFolderPath('Desktop')

# Display available Shielded VM certificates
Get-ChildItem "Cert:\LocalMachine\Shielded VM Local Certificates"

# Get a password to protect the extracted certificates
Write-Host ""
$CertificatePassword = Read-Host -Prompt 'Please enter a password to secure the certificate files' -AsSecureString

Write-Host ""
If ($(Read-Host "Enter 'Yes' to extract all Guardian certificates from this system, anything else to extract the current Guardian").tolower().StartsWith('yes')) {
	$EncryptionCertificates = Get-ChildItem "Cert:\LocalMachine\Shielded VM Local Certificates" | Where-Object { $_.Subject -like "*Encryption*($GuardianName)*" } | Sort-Object NotBefore -Descending
	$SigningCertificates = Get-ChildItem "Cert:\LocalMachine\Shielded VM Local Certificates" | Where-Object { $_.Subject -like "*Signing*($GuardianName)*" } | Sort-Object NotBefore -Descending

	$Index = [math]::Min($SigningCertificates.Count, $EncryptionCertificates.Count)
	Write-Host "Up to $Index Guardians can be salvaged from this system."
	Write-Host

	$Prefix = Read-Host -Prompt 'Please enter a prefix to name the certificate files (default is Hgs): '
	$Prefix = If ( [string]::IsNullOrEmpty( $Prefix ) ) { 'Hgs' } else { $Prefix }$Index = 0

	ForEach ($EncryptionCertificate in $EncryptionCertificates) {
		If ($EncryptionCertificate.HasPrivateKey) {
			ForEach ($SigningCertificate in $($SigningCertificates | Where-Object { $_.NotBefore -eq $EncryptionCertificate.NotBefore })) {
				If ($SigningCertificate.HasPrivateKey) {

					Write-Host "Guardian $Index  $($EncryptionCertificate.Thumbprint)  $($SigningCertificate.Thumbprint)"
					Export-PfxCertificate -Cert $EncryptionCertificate -FilePath "$OutputDirectory\$Prefix$Index-$GuardianName-encryption.pfx" -Password $CertificatePassword | Out-Null
					Export-PfxCertificate -Cert $SigningCertificate -FilePath "$OutputDirectory\$Prefix$Index-$GuardianName-signing.pfx" -Password $CertificatePassword | Out-Null
					$Index++
				}
			}
		}
	}
}
else {
	try	{
		# Get encryption and signing certificates for this guardian
		$guardian = Get-HgsGuardian -Name $GuardianName -ErrorAction Stop

		# Get the actual certificates
		$EncryptionCertificate = Get-Item -Path "Cert:\LocalMachine\Shielded VM Local Certificates\$($guardian.EncryptionCertificate.Thumbprint)" -ErrorAction Stop
		$SigningCertificate = Get-Item -Path "Cert:\LocalMachine\Shielded VM Local Certificates\$($guardian.SigningCertificate.Thumbprint)" -ErrorAction Stop
	}
	catch	{
		# Display localized error message and exit.
		Write-Warning "Unable to find valid certificates for guardian '$GuardianName' on the local system."
		@($Error[0].Exception)
		Exit 911
	}


	if (-not ($encryptionCertificate.HasPrivateKey -and $signingCertificate.HasPrivateKey)) {
		throw 'One or both of the certificates in the guardian do not have private keys. ' + `
			'Please ensure the private keys are available on the local system for this guardian.'
	}
	# Default file name prefix
	$ThisHost = [Environment]::MachineName

	Export-PfxCertificate -Cert $encryptionCertificate -FilePath "$OutputDirectory\$ThisHost-$GuardianName-encryption.pfx" -Password $CertificatePassword | Out-Null
	Export-PfxCertificate -Cert $signingCertificate -FilePath "$OutputDirectory\$ThisHost-$GuardianName-signing.pfx" -Password $CertificatePassword | Out-Null

}

Write-Host
Write-Host "Done!"
