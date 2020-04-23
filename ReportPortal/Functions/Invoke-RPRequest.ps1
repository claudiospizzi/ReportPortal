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
    [CmdletBinding(DefaultParameterSetName = 'Simple')]
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

        # Scope of the request url.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Project', 'Global')]
        [System.String]
        $Scope = 'Project',

        # The body object, if it is required.
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSObject]
        $Body,

        # Page number if we return paged output.
        [Parameter(Mandatory = $true, ParameterSetName = 'Paged')]
        [System.Int32]
        $PageNumber,

        # Page size, should not be bigger than 300.
        [Parameter(Mandatory = $true, ParameterSetName = 'Paged')]
        [System.Int32]
        $PageSize
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

    # Add paging if specified
    if ($PSCmdlet.ParameterSetName -eq 'Paged')
    {
        $requestSplat['Uri'] = '{0}?page.page={1}&page.size={2}' -f $requestSplat['Uri'], $PageNumber, $PageSize
    }

    # Optionally, add the body parameter
    if ($PSBoundParameters.ContainsKey('Body'))
    {
        $requestSplat['Body'] = $Body | ConvertTo-Json -Compress
    }

    # If we have the global scope, update the uri
    if ($Scope -eq 'Global')
    {
        $requestSplat['Uri'] = '{0}/api/v1/{1}' -f $Session.Url, $Path
    }

    Write-Verbose ('{0} {1}' -f $requestSplat.Method.ToUpper(), $requestSplat.Uri)

    Invoke-RestMethod @requestSplat
}
