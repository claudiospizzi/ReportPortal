<#
    .SYNOPSIS
        Start a new report portal test item.

    .DESCRIPTION
        Call the StartTestItemAsync() method on the service object to start a
        new test item in the report portal. The method will be invoked
        synchronously.
#>
function Start-RPTestItem
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([ReportPortal.Client.Models.TestItem])]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $true)]
        [ReportPortal.Client.Service]
        $Service,

        # The report portal launch.
        [Parameter(Mandatory = $true)]
        [ReportPortal.Client.Models.Launch]
        $Launch,

        # The parent test item, can be null.
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [ReportPortal.Client.Models.TestItem]
        $Parent,

        # Test item name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # Test item type.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Suite', 'Test', 'Step')]
        [System.String]
        $Type,

        # Test item description.
        [Parameter(Mandatory = $false)]
        [System.String]
        $Description,

        # Test item start time.
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
        $model = [ReportPortal.Client.Requests.StartTestItemRequest]::new()
        $model.LaunchId    = $Launch.Id
        $model.Name        = $Name
        $model.Type        = $Type
        $model.Description = $Description
        $model.StartTime   = $StartTime.ToUniversalTime()
        $model.Tags        = $Tags

        if ($PSCmdlet.ShouldProcess($null, 'Start Test Item'))
        {
            if ($null -eq $Parent)
            {
                $testItem = $Service.StartTestItemAsync($model).GetAwaiter().GetResult()
            }
            else
            {
                $testItem = $Service.StartTestItemAsync($Parent.Id, $model).GetAwaiter().GetResult()
            }

            Get-RPTestItem -Service $Service -Id $testItem.Id
        }
    }
    catch
    {
        ConvertFrom-RPException -ErrorRecord $_ | Write-Error
    }
}
