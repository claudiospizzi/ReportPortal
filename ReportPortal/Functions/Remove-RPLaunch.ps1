<#
    .SYNOPSIS
        Remove a previously finished report portal launch.

    .DESCRIPTION
        Remove an existing launch from the report portal. Important, the launch
        must be finished or stopped before, else the Force switch must be used.
#>
function Remove-RPLaunch
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # The report portal session.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # The launch to remove.
        [Parameter(Mandatory = $true, ParameterSetName = 'Launch')]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # Force a launch to finish before removing.
        [Parameter(Mandatory = $false)]
        [Switch]
        $Force
    )

    $Session = Test-RPSession -Session $Session

    if ($PSCmdlet.ParameterSetName -eq 'Launch')
    {
        Write-Verbose ('Remove the report portal launch with id {0}' -f $Launch.Id)

        $id = $Launch.Id

        if ($Force.IsPresent)
        {
            Stop-RPLaunch -Launch $Launch -Force
        }
    }

    if ($PSCmdlet.ShouldProcess($id, 'Remove Launch'))
    {
        Invoke-RPRequest -Session $Session -Method 'Delete' -Path "launch/$id" -ErrorAction 'Stop' | Out-Null
    }
}
