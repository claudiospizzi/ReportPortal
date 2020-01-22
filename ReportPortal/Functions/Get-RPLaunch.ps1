<#
    .SYNOPSIS
        Get all report portal launches.

    .DESCRIPTION
        Call the GetLaunchAsync() or GetLaunchesAsync() methods on the service
        object to get all existing launches. The method will be invoked
        synchronously.
#>
function Get-RPLaunch
{
    [CmdletBinding(DefaultParameterSetName = 'None')]
    [OutputType([ReportPortal.Client.Models.Launch])]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [ReportPortal.Client.Service]
        $Service,

        # Optional launch id.
        [Parameter(Mandatory = $false, ParameterSetName = 'Id')]
        [System.String]
        $Id,

        # Optional launch name.
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
            $Service.GetLaunchAsync($Id).GetAwaiter().GetResult()
        }
        else
        {
            $launches = @()

            $filterOption = [ReportPortal.Client.Filtering.FilterOption]::new()
            $filterOption.Paging = [ReportPortal.Client.Filtering.Paging]::new(1, 300)

            do
            {
                $result = $Service.GetLaunchesAsync($filterOption, $false).GetAwaiter().GetResult()
                $filterOption.Paging.Number++

                $launches += $result.Launches
            }
            while ($result.Page.Number -lt $result.Page.TotalPages)

            # Filter all launches by name
            if ($PSBoundParameters.ContainsKey('Name'))
            {
                $launches = $launches | Where-Object { $_.Name -like $Name }
            }

            Write-Output $launches
        }
    }
    catch
    {
        ConvertFrom-RPException -ErrorRecord $_ | Write-Error
    }
}
