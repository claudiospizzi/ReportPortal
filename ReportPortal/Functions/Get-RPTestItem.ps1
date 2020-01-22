<#
    .SYNOPSIS
        Get all test items.

    .DESCRIPTION
        Call the GetTestItemAsync() or GetTestItemsAsync() methods on the
        service object to get all test items. The method will be invoked
        synchronously.
#>
function Get-RPTestItem
{
    [CmdletBinding(DefaultParameterSetName = 'None')]
    [OutputType([ReportPortal.Client.Models.TestItem])]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [ReportPortal.Client.Service]
        $Service,

        # Optional test item id.
        [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
        [System.String]
        $Id,

        # Optional test item name.
        [Parameter(Mandatory = $false, ParameterSetName = 'Name')]
        [SupportsWildcards()]
        [System.String]
        $Name
    )

    $Service = Test-RPService -Service $Service

    try
    {
        if ($PSCmdlet.ParameterSetName -eq 'Id')
        {
            $Service.GetTestItemAsync($Id).GetAwaiter().GetResult()
        }
        else
        {
            $testItems = @()

            $filterOption = [ReportPortal.Client.Filtering.FilterOption]::new()
            $filterOption.Paging = [ReportPortal.Client.Filtering.Paging]::new(1, 300)

            do
            {
                $result = $Service.GetTestItemsAsync($filterOption).GetAwaiter().GetResult()
                $filterOption.Paging.Number++

                $testItems += $result.TestItems
            }
            while ($result.Page.Number -lt $result.Page.TotalPages)

            # Filter all test items by name
            if ($PSBoundParameters.ContainsKey('Name'))
            {
                $testItems = $testItems | Where-Object { $_.Name -like $Name }
            }

            Write-Output $testItems
        }
    }
    catch
    {
        ConvertFrom-RPException -ErrorRecord $_ | Write-Error
    }
}
