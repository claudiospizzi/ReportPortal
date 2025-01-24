<#
    .SYNOPSIS
        Connect to the report portal server. It will optionally return the
        session object.

    .DESCRIPTION
        Connect to the report portal server using the REST API. It stores the
        session within the module context and optionally returns the session
        object.
        The authentication is performed with OAuth and the provided username and
        password. The access token is then used to get the api token, wich is
        longer lasting.

    .EXAMPLE
        PS C:\> Connect-RPServer -Url 'https://reportportal.contoso.com' -Credential 'user' -ProjectName 'demo'
        Connect to the Contoso report portal server and the demo project.
#>
function Connect-RPServer
{
    [CmdletBinding()]
    param
    (
        # Url to the report portal server.
        [Parameter(Mandatory = $true)]
        [System.Uri]
        $Url,

        # The report portal user credentials.
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        # Project name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ProjectName,

        # Return the session object.
        [Parameter(Mandatory = $false)]
        [Switch]
        $PassThru
    )

    Write-Verbose ('Connect to the report portal server {0}#{1}' -f $Url.GetLeftPart('Authority'), $ProjectName)

    # Using OAuth to request the access token
    $tokenRequest = @{
        Method          = 'Post'
        Uri             = '{0}/uat/sso/oauth/token' -f $Url.GetLeftPart('Authority')
        ContentType     = 'application/x-www-form-urlencoded'
        Headers         = @{ Authorization = 'Basic {0}' -f ([System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(('ui:uiman')))) }
        Body            = 'grant_type=password&username={0}&password={1}' -f $Credential.UserName, $Credential.GetNetworkCredential().Password
        UseBasicParsing = $true
        Verbose         = $false
        ErrorAction     = 'Stop'
    }
    $tokenResult = Invoke-RestMethod @tokenRequest

    # Use the api token to test the project access
    $projectRequest = @{
        Method          = 'Get'
        Uri             = '{0}/api/v1/project/{1}' -f $Url.GetLeftPart('Authority'), $ProjectName
        ContentType     = 'application/json'
        Headers         = @{ Authorization = 'Bearer {0}' -f $tokenResult.access_token }
        UseBasicParsing = $true
        Verbose         = $false
        ErrorAction     = 'Stop'
    }
    $projectResult = Invoke-RestMethod @projectRequest

    # Project access is ok, set the session object to the cache
    $Script:RPSession = [PSCustomObject] @{
        PSTypeName = 'ReportPortal.Session'
        Url        = $Url.GetLeftPart('Authority')
        Project    = $projectResult.ProjectName
        Token      = $tokenResult.access_token
    }

    if ($PassThru.IsPresent)
    {
        Write-Output $Script:RPSession
    }
}
