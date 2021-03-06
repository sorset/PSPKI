function Show-CertificateTrustList {
<#
.ExternalHelp PSPKI.Help.xml
#>
[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Security.Cryptography.X509Certificates.X509CTL]$CTL
	)
	
	process {
		$CTL.ShowUI()
	}
}