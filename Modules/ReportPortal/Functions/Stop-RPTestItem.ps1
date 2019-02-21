<#
    .SYNOPSIS
        Finish an existing report portal test item.

    .DESCRIPTION
        Call the FinishTestItemAsync() method on the service object to finish
        the existing launch in the report portal. The method will be invoked
        synchronously.
#>
function Stop-RPTestItem
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([ReportPortal.Client.Models.TestItem])]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $true)]
        [ReportPortal.Client.Service]
        $Service,

        # The test item id to finish.
        [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
        [System.String]
        $Id,

        # The test item to finish.
        [Parameter(Mandatory = $true, ParameterSetName = 'TestItem')]
        [ReportPortal.Client.Models.TestItem]
        $TestItem,

        # Test item end time.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $EndTime = (Get-Date),

        # The test result.
        [Parameter(Mandatory = $false)]
        [ValidateSet('InProgress', 'Passed', 'Failed', 'Skipped', 'Interrupted')]
        [System.String]
        $Status = 'Passed',

        [Parameter(Mandatory = $false)]
        [System.String]
        $Description,

        # Return the updated test item object.
        [Parameter(Mandatory = $false)]
        [switch]
        $PassThru
    )

    try
    {
        $model = [ReportPortal.Client.Requests.FinishTestItemRequest]::new()
        $model.EndTime     = $EndTime.ToUniversalTime()
        $model.Status      = $Status
        $model.Description = $Description

        if ($PSCmdlet.ParameterSetName -eq 'TestItem')
        {
            $Id = $TestItem.Id
        }

        if ($PSCmdlet.ShouldProcess($Id, 'Finish Test Item'))
        {
            $Service.FinishTestItemAsync($Id, $model).GetAwaiter().GetResult() | Out-Null

            if ($PassThru.IsPresent)
            {
                Get-RPTestItem -Service $Service -Id $Id
            }
        }
    }
    catch
    {
        ConvertFrom-RPException -ErrorRecord $_ | Write-Error
    }
}
