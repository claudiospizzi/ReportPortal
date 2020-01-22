<#
    .SYNOPSIS
        Finish a previously started report portal launch.

    .DESCRIPTION
        Call the FinishLaunchAsync() method on the service object to finish the
        existing launch in the report portal. The method will be invoked
        synchronously.
#>
function Stop-RPLaunch
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([ReportPortal.Client.Models.Launch])]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [ReportPortal.Client.Service]
        $Service,

        # The launch id to finish.
        [Parameter(Mandatory = $true, ParameterSetName = 'Uuid')]
        [System.String]
        $Uuid,

        # The launch to finish.
        [Parameter(Mandatory = $true, ParameterSetName = 'Launch')]
        [ReportPortal.Client.Models.Launch]
        $Launch,

        # Launch end time.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $EndTime = (Get-Date),

        # Force the finish action.
        [Parameter(Mandatory = $false)]
        [switch]
        $Force,

        # Return the updated launch object.
        [Parameter(Mandatory = $false)]
        [switch]
        $PassThru
    )

    $Service = Test-RPService -Service $Service

    try
    {
        $model = [ReportPortal.Client.Requests.FinishLaunchRequest]::new()
        $model.EndTime = $EndTime.ToUniversalTime()

        if ($PSCmdlet.ParameterSetName -eq 'Launch')
        {
            $Uuid = $Launch.Uuid
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Finish Launch'))
        {
            $Service.FinishLaunchAsync($Id, $model, $Force.IsPresent).GetAwaiter().GetResult() | Out-Null

            if ($PassThru.IsPresent)
            {
                Get-RPLaunch -Service $Service -Id $Id
            }
        }
    }
    catch
    {
        ConvertFrom-RPException -ErrorRecord $_ | Write-Error
    }
}
