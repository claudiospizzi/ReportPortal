<#
    .SYNOPSIS
        Start a new report portal launch.

    .DESCRIPTION
        This command will create a new empty report portal launch. The start
        time by default is now, but can be overritten. The attributes must be
        specified by a colon seperator, e.g. 'Key:Value'.
#>
function Start-RPLaunch
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # Launch name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # Launch start time.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $StartTime = (Get-Date),

        # The launch attributes.
        [Parameter(Mandatory = $false)]
        [System.String[]]
        $Attribute
    )

    $Session = Test-RPSession -Session $Session

    Write-Verbose ('Start a report portal launch with name {0}' -f $Name)

    $launchStartRequest = [PSCustomObject] @{
        name        = $Name
        startTime   = ConvertTo-ReportPortalDateTime -DateTime $StartTime
        attributes  = @(ConvertTo-ReportPortalAttribute -Attribute $Attribute)
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Start Launch'))
    {
        $launchStartResult = Invoke-RPRequest -Session $Session -Method 'Post' -Path 'launch' -Body $launchStartRequest -ErrorAction 'Stop'

        Get-RPLaunch -Session $Session -Id $launchStartResult.Id
    }
}
