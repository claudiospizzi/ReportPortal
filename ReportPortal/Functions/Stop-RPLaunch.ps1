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
        [Parameter(Mandatory = $true, ParameterSetName = 'Launch')]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # Launch end time.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $EndTime = (Get-Date),

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

    if ($PSCmdlet.ParameterSetName -eq 'Launch')
    {
        Write-Verbose ('Stop a report portal launch with id {0}' -f $Launch.Guid)

        $id   = $Launch.Id
        $guid = $Launch.Guid
    }

    $launchStopRequest = [PSCustomObject] @{
        endTime = ConvertTo-ReportPortalDateTime -DateTime $EndTime
        status  = 'PASSED'
    }

    $action = "$guid/finish"
    if ($Force.IsPresent)
    {
        $action = "$id/stop"
    }

    if ($PSCmdlet.ShouldProcess($id, 'Stop Launch'))
    {
        Invoke-RPRequest -Session $Session -Method 'Put' -Path "launch/$action" -Body $launchStopRequest -ErrorAction 'Stop' | Out-Null

        if ($PassThru.IsPresent)
        {
            Get-RPLaunch -Session $Session -Id $id
        }
    }
}
