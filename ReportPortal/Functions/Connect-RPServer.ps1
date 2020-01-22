<#
    .SYNOPSIS
        Connect to the report portal service. It will return the service object.

    .DESCRIPTION
        Use the ReportPortal.Client library to connect to the report portal
        services.
#>
function Connect-RPServer
{
    [CmdletBinding()]
    [Alias('Connect-RPService')]
    param
    (
        # Url to the report portal server.
        [System.Uri]
        $Url,

        # Project name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProjectName,

        # Unique identifier.
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserId,

        # Return the service object.
        [Parameter(Mandatory = $false)]
        [switch]
        $PassThru
    )

    # Ensure the url is valid, by using the scheme and authority and append the
    # api query path
    $Url = [System.Uri] ('{0}/api/v1' -f $Url.GetLeftPart('Authority'))

    # Connect to the report portal service
    $Script:RPService = [ReportPortal.Client.Service]::new($Url, $ProjectName, $UserId)

    if ($PassThru.IsPresent)
    {
        Write-Output $Script:RPService
    }
}
