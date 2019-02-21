<#
    .SYNOPSIS
        Connect to the report portal service.

    .DESCRIPTION
        .
#>
function Connect-RPService
{
    [CmdletBinding()]
    [OutputType([ReportPortal.Client.Service])]
    param
    (
        # Report portal computer name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ComputerName,

        # Report portal port.
        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Port,

        # Option to switch SSL.
        [Parameter(Mandatory = $false)]
        [switch]
        $UseSSL,

        # Project name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProjectName,

        # Unique identifier.
        [Parameter(Mandatory = $true)]
        [System.String]
        $UserId
    )

    if ($UseSSL.IsPresent)
    {
        $uri = 'https://{0}:{1}/api/v1' -f $ComputerName, $Port
    }
    else
    {
        $uri = 'http://{0}:{1}/api/v1' -f $ComputerName, $Port
    }

    $service = [ReportPortal.Client.Service]::new($uri, $ProjectName, $UserId)

    Write-Output $service
}
