<#
    .SYNOPSIS
        Finish an existing report portal test item.

    .DESCRIPTION
        ...
#>
function Stop-RPTestItem
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # The test item to finish.
        [Parameter(Mandatory = $true, ParameterSetName = 'TestItem')]
        [PSTypeName('ReportPortal.TestItem')]
        $TestItem,

        # Test item end time.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $EndTime = (Get-Date),

        # The test result.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Passed', 'Failed', 'Skipped', 'Interrupted')]
        [System.String]
        $Status = 'Passed',

        # Return the updated test item object.
        [Parameter(Mandatory = $false)]
        [Switch]
        $PassThru
    )

    $Session = Test-RPSession -Session $Session

    Write-Verbose ('Stop the report portal test item with name {0} with status {1}' -f $TestItem.Name, $Status)

    if ($PSCmdlet.ParameterSetName -eq 'TestItem')
    {
        $id = $TestItem.Guid
    }

    $testItemStopRequest = [PSCustomObject] @{
        endTime = ConvertTo-ReportPortalDateTime -DateTime $EndTime
        status  = $status
    }

    if ($PSCmdlet.ShouldProcess($TestItem.Name, 'Stop Test Item'))
    {
        Invoke-RPRequest -Session $Session -Method 'Put' -Path "item/$id" -Body $testItemStopRequest -ErrorAction 'Stop' | Out-Null

        if ($PassThru.IsPresent)
        {
            Get-RPTestItem -Session $Session -Id $id
        }
    }
}
