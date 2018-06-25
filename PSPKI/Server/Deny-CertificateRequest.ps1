function Deny-CertificateRequest {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('SysadminsLV.PKI.Utils.IServiceOperationResult')]
[CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            if ($_.GetType().FullName -eq "PKI.CertificateServices.DB.RequestRow") {$true} else {$false}
        })]$Request
    )
    begin {
        $ConfigString = ""
        $CertAdmin = New-Object -ComObject CertificateAuthority.Admin
    }
    process {
        if ((Ping-ICertAdmin $Request.ConfigString)) {
            # if this is first item in pipeline, then $ConfigString is null.
            # cache new config string and instantiate ICertAdmin.
            # do the same if config string doesn't match cached one.
            if (!$ConfigString -or ($ConfigString -ne $Request.ConfigString)) {
                $ConfigString = $Request.ConfigString
                [PKI.Utils.CryptographyUtils]::ReleaseCom($CertAdmin)
                $CertAdmin = New-Object -ComObject CertificateAuthority.Admin
            }
            try {
                $CertAdmin.DenyRequest($Request.ConfigString,$Request.RequestID)
                New-Object SysadminsLV.PKI.Utils.ServiceOperationResult -ArgumentList `
                    0,
                    "Successfully denied request with ID = $($Request.RequestID).",
                    $Request.RequestID				            
            } catch {
                New-Object SysadminsLV.PKI.Utils.ServiceOperationResult -ArgumentList `
                    $_.Exception.InnerException.InnerException.HResult -Property @{
                        InnerObject = $Request.RequestID
                    }
            }
        } else {Write-ErrorMessage -Source ICertAdminUnavailable -ComputerName $Request.ComputerName}
    }
    end {
        [PKI.Utils.CryptographyUtils]::ReleaseCom($CertAdmin)
    }
}