<#
    .SYNOPSIS
        Invoke a report portal request.

    .DESCRIPTION
        This command will invoke a request againts the REST api of the report
        portal server. The session is used to determine the project and user
        authentication.
#>
function Invoke-RPRequest
{
    [CmdletBinding()]
    param
    (
        # The report portal session.
        [Parameter(Mandatory = $true)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # The request method.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Get', 'Post', 'Put', 'Delete')]
        [System.String]
        $Method,

        # Relative path of the url.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        # The body object, if it is required.
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSObject]
        $Body
    )

    # Basic reqeust
    $requestSplat = @{
        Method          = $Method
        Uri             = '{0}/api/v1/{1}/{2}' -f $Session.Url, $Session.Project, $Path
        ContentType     = 'application/json'
        Headers         = @{ Authorization = 'Bearer {0}' -f $Session.Token }
        UseBasicParsing = $true
        Verbose         = $false
        ErrorAction     = 'Stop'
    }

    # Optionally, add the body parameter
    if ($PSBoundParameters.ContainsKey('Body'))
    {
        $requestSplat['Body'] = $Body | ConvertTo-Json -Compress
    }

    Write-Verbose ('{0} {1}' -f $requestSplat.Method.ToUpper(), $requestSplat.Uri)

    Invoke-RestMethod @requestSplat
}
