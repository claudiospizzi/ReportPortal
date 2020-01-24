<#
    .SYNOPSIS
        Get a test item by id.

    .DESCRIPTION
        Call the GetTestItemAsync() or GetTestItemsAsync() methods on the
        service object to get all test items. The method will be invoked
        synchronously.
#>
function Get-RPTestItem
{
    [CmdletBinding()]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # Test item id.
        [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
        [System.String]
        $Id
    )

    $Session = Test-RPSession -Session $Session

    if ($PSCmdlet.ParameterSetName -eq 'Id')
    {
        Write-Verbose ('Get the report portal test item with id {0}' -f $Id)

        $testItemResult = Invoke-RPRequest -Session $Session -Method 'Get' -Path "item/$Id" -ErrorAction 'Stop'
        #Write-Host ($testItemResult | Out-String)
        [PSCustomObject] @{
            PSTypeName  = 'ReportPortal.TestItem'
            Id          = $testItemResult.id
            Guid        = $testItemResult.uuid
            Name        = $testItemResult.name
            ParentId    = $testItemResult.parent
            LaunchId    = $testItemResult.launchId
            Type        = $testItemResult.type
            Status      = $testItemResult.status
            Path        = $testItemResult.path
            StartTime   = ConvertFrom-ReportPortalDateTime -Timestamp $testItemResult.startTime
        }
    }
}
