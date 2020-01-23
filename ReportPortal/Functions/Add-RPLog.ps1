<#
    .SYNOPSIS
        Add a log entry to the test item.

    .DESCRIPTION
        ..
#>
function Add-RPLog
{
    [CmdletBinding()]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # The test item to add a log entry.
        [Parameter(Mandatory = $true)]
        [PSTypeName('ReportPortal.TestItem')]
        $TestItem,

        # Log timestamp.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $Time = (Get-Date),

        # The log level. Defaults to info.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Trace', 'Debug', 'Info', 'Warning', 'Error', 'Fatal')]
        [System.String]
        $Level = 'Info',

        # Log message.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Message
    )

    $Session = Test-RPSession -Session $Session

    Write-Verbose ('Add a report portal log entry to item {0}' -f $TestItem.Guid)

    $addLogRequest = @(
        [PSCustomObject] @{
            item_id     = $TestItem.Guid
            time        = ConvertTo-ReportPortalDateTime -DateTime $Time
            level       = $Level.ToUpper()
            message     = $Message
            file        = [PSCustomObject] @{ name = '{0}.log' -f $Level.ToLower() }
        }
    )

    Invoke-RPRequest -Session $Session -Method 'Post' -Path 'log' -Body $addLogRequest -ErrorAction 'Stop' | Out-Null
}
