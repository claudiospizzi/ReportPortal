<#
    .SYNOPSIS
        Add a log entry to the launch or test item.

    .DESCRIPTION
        Use this command to add entries to the launch or test item.
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

        # The launch to add a log entry.
        [Parameter(Mandatory = $true, ParameterSetName = 'Launch')]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # The test item to add a log entry.
        [Parameter(Mandatory = $true, ParameterSetName = 'TestItem')]
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
        $Message,

        # Option to set the encoding.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Default', 'UTF8')]
        [System.String]
        $Encoding = 'Default'
    )

    $Session = Test-RPSession -Session $Session

    if ($PSCmdlet.ParameterSetName -eq 'Launch')
    {
        Write-Verbose ('Add a report portal log entry to launch {0}' -f $Launch.Guid)

        $addLogRequest = @(
            [PSCustomObject] @{
                launchUuid  = $Launch.Guid
                time        = ConvertTo-ReportPortalDateTime -DateTime $Time
                level       = $Level.ToUpper()
                message     = $Message
                file        = [PSCustomObject] @{ name = '{0}.log' -f $Level.ToLower() }
            }
        )
    }

    if ($PSCmdlet.ParameterSetName -eq 'TestItem')
    {
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
    }

    Invoke-RPRequest -Session $Session -Method 'Post' -Path 'log' -Body $addLogRequest -ContentType $Encoding -ErrorAction 'Stop' | Out-Null
}
