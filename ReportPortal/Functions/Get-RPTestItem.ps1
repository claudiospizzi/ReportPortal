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

        [PSCustomObject] @{
            PSTypeName  = 'ReportPortal.TestItem'
            Id          = $testItemResult.id
            Guid        = $testItemResult.uuid
            Name        = $testItemResult.name
            Type        = $testItemResult.type
            ParentId    = $testItemResult.parent
            LaunchId    = $testItemResult.launchId
            Status      = $testItemResult.status
            Path        = $testItemResult.path
            Attributes  = $testItemResult.attributes | ForEach-Object { '{0}:{1}' -f $_.key, $_.value }
            StartTime   = ConvertFrom-ReportPortalDateTime -Timestamp $testItemResult.startTime
        }
    }
}
