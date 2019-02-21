<#
    .SYNOPSIS
        Start a new report portal launch.

    .DESCRIPTION
        Call the StartLaunchAsync() method on the service object to start a new
        launch in the report portal. The method will be invoked synchronously.
#>
function Start-RPLaunch
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([ReportPortal.Client.Models.Launch])]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $true)]
        [ReportPortal.Client.Service]
        $Service,

        # Launch name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # Launch description.
        [Parameter(Mandatory = $false)]
        [System.String]
        $Description,

        # Launch start time.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $StartTime = (Get-Date),

        # Test item tags.
        [Parameter(Mandatory = $false)]
        [System.String[]]
        $Tags
    )

    try
    {
        $model = [ReportPortal.Client.Requests.StartLaunchRequest]::new()
        $model.Name        = $Name
        $model.Description = $Description
        $model.StartTime   = $StartTime.ToUniversalTime()
        $model.Tags        = $Tags

        if ($PSCmdlet.ShouldProcess($null, 'Start Launch'))
        {
            $launch = $Service.StartLaunchAsync($model).GetAwaiter().GetResult()

            Get-RPLaunch -Service $Service -Id $launch.Id
        }
    }
    catch
    {
        ConvertFrom-RPException -ErrorRecord $_ | Write-Error
    }
}
