<#
    .SYNOPSIS
        Remove an existing report portal launch.

    .DESCRIPTION
        Call the DeleteLaunchAsync() method on the service object to remove the
        existing launch from the report portal. The method will be invoked
        synchronously.
#>
function Remove-RPLaunch
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [ReportPortal.Client.Service]
        $Service,

        # The launch id to remove.
        [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
        [System.String]
        $Id,

        # The launch to remove.
        [Parameter(Mandatory = $true, ParameterSetName = 'Launch')]
        [ReportPortal.Client.Models.Launch]
        $Launch,

        # Force the removal.
        [Parameter(Mandatory = $false)]
        [switch]
        $Force
    )

    $Service = Test-RPService -Service $Service

    try
    {
        if ($PSCmdlet.ParameterSetName -eq 'Launch')
        {
            $Id = $Launch.Id
        }

        if ($Force.IsPresent)
        {
            Stop-RPLaunch -Service $service -Id $Id -Force
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Remove Launch'))
        {
            $Service.DeleteLaunchAsync($Id).GetAwaiter().GetResult() | Out-Null
        }
    }
    catch
    {
        ConvertFrom-RPException -ErrorRecord $_ | Write-Error
    }
}
