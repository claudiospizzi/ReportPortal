<#
    .SYNOPSIS
        Get a specific report portal launch.

    .DESCRIPTION
        Use the id of the launch to get the current status of the launch object.
#>
function Get-RPLaunch
{
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # Optional launch id.
        [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
        [System.String]
        $Id
    )

    $Session = Test-RPSession -Session $Session

    $launches = [System.Collections.ArrayList]::new()

    if ($PSCmdlet.ParameterSetName -eq 'All')
    {
        Write-Verbose 'Get all report portal launches'

        for ($i = 1; $i -eq 1 -or $i -le $launchResult.page.totalPages; $i++)
        {
            $launchResult = Invoke-RPRequest -Session $Session -Method 'Get' -Path 'launch' -PageNumber $i -PageSize 50 -ErrorAction 'Stop'

            $launchResult.content | ForEach-Object { $launches.Add($_) | Out-Null }
        }
    }

    if ($PSCmdlet.ParameterSetName -eq 'Id')
    {
        Write-Verbose ('Get the report portal launch with id {0}' -f $Id)

        $launchResult = Invoke-RPRequest -Session $Session -Method 'Get' -Path "launch/$Id" -ErrorAction 'Stop'

        $launches.Add($launchResult) | Out-Null
    }

    foreach ($launch in $launches)
    {
        [PSCustomObject] @{
            PSTypeName  = 'ReportPortal.Launch'
            Id          = $launch.id
            Guid        = $launch.uuid
            Name        = $launch.name
            Type        = 'Launch'
            Number      = $launch.number
            Status      = $launch.status
            StartTime   = ConvertFrom-ReportPortalDateTime -Timestamp $launch.startTime
            EndTime     = ConvertFrom-ReportPortalDateTime -Timestamp $launch.endTime
        }
    }
}
