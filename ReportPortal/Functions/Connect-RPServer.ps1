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
    [OutputType([ReportPortal.Client.Service])]
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
        $UserId
    )

    # Ensure the url is valid, by using the scheme and authority and append the
    # api query path
    $Url = '{0}/api/v1' + $Url.GetLeftPart('Authority')

    [ReportPortal.Client.Service]::new($uri, $ProjectName, $UserId)
}
