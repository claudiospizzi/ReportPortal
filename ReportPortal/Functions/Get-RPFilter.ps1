<#
    .SYNOPSIS
        Get the report portal filter object.

    .DESCRIPTION
        Use the REST api and the filter endpoint to query for the existing
        filter and return them as PowerShell objects.

    .OUTPUTS
        ReportPortal.Filter.
#>
function Get-RPFilter
{
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # Filter name.
        [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
        [System.Int32]
        $Id,

        # Filter name.
        [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
        [System.String]
        $Name
    )

    $Session = Test-RPSession -Session $Session

    switch ($PSCmdlet.ParameterSetName)
    {
        'All'  { $requestPath = 'filter?' }
        'Id'   { $requestPath = "filter?filter.eq.id=$Id" }
        'Name' { $requestPath = "filter?filter.eq.name=$Name" }
    }

    for ($start = 1; $null -eq $result -or $result.page.totalPages -ge $start; $start++)
    {
        $result = Invoke-RPRequest -Session $Session -Method 'Get' -Path "$requestPath&page.page=$start&page.size=20" -ErrorAction 'Stop'

        foreach ($resultItem in $result.content)
        {
            [PSCustomObject] @{
                PSTypeName  = 'ReportPortal.Filter'
                Id          = $resultItem.id
                Name        = $resultItem.name
                Owner       = $resultItem.owner
                Share       = $resultItem.share
                Conditions  = $resultItem.conditions | ForEach-Object { [PSCustomObject] @{ Field = $_.filteringField; Condition = $_.condition; Value = $_.value } }
            }
        }
    }
}
