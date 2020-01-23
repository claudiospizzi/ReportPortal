<#
    .SYNOPSIS
        Get a specific report portal launch.

    .DESCRIPTION
        Use the id of the launch to get the current status of the launch object.
#>
function Get-RPLaunch
{
    [CmdletBinding()]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # Optional launch id.
        [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
        [System.String]
        $Id
    )

    $Session = Test-RPSession -Session $Session

    Write-Verbose ('Get the report portal launch with id {0}' -f $Id)

    if ($PSCmdlet.ParameterSetName -eq 'Id')
    {
        $launchResult = Invoke-RPRequest -Session $Session -Method 'Get' -Path "launch/$Id" -ErrorAction 'Stop'

        [PSCustomObject] @{
            PSTypeName  = 'ReportPortal.Launch'
            Id          = $launchResult.id
            Guid        = $launchResult.uuid
            Name        = $launchResult.name
            Number      = $launchResult.number
            Status      = $launchResult.status
            StartTime   = ConvertFrom-ReportPortalDateTime -Timestamp $launchResult.startTime
            EndTime     = ConvertFrom-ReportPortalDateTime -Timestamp $launchResult.endTime
        }
    }
}
