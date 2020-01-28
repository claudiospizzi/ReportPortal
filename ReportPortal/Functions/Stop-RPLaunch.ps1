<#
    .SYNOPSIS
        Finish a previously started report portal launch.

    .DESCRIPTION
        Use the api call /finish to gracafully finish a previously started
        launch. If not, the The end date will be set to now, if not specified.
#>
function Stop-RPLaunch
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # The report portal session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # The launch to finish.
        [Parameter(Mandatory = $true)]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # Launch end time.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $EndTime = (Get-Date),

        # The test result.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Passed', 'Failed', 'Skipped', 'Interrupted')]
        [System.String]
        $Status = 'Passed',

        # Force a launch to finish.
        [Parameter(Mandatory = $false)]
        [Switch]
        $Force,

        # Return the updated launch object.
        [Parameter(Mandatory = $false)]
        [Switch]
        $PassThru
    )

    $Session = Test-RPSession -Session $Session

    Write-Verbose ('Stop a report portal launch with id {0}' -f $Launch.Guid)

    $launchStopRequest = [PSCustomObject] @{
        endTime = ConvertTo-ReportPortalDateTime -DateTime $EndTime
        status  = $Status.ToUpper()
    }

    $action = '{0}/finish' -f $Launch.Guid
    if ($Force.IsPresent)
    {
        $action = "{0}/stop" -f $Launch.Id
    }

    if ($PSCmdlet.ShouldProcess($Launch.Guid, 'Stop Launch'))
    {
        Invoke-RPRequest -Session $Session -Method 'Put' -Path "launch/$action" -Body $launchStopRequest -ErrorAction 'Stop' | Out-Null

        if ($PassThru.IsPresent)
        {
            Get-RPLaunch -Session $Session -Id $Launch.Id
        }
    }
}
