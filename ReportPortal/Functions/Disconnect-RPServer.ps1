<#
    .SYNOPSIS
        Disconnect from the report portal server.

    .DESCRIPTION
        Disconnect from the report portal server by cleaning the cached session
        of the last connection.

    .EXAMPLE
        PS C:\> Disconnect-RPServer
        Disconnect from the last session.
#>
function Disconnect-RPServer
{
    [CmdletBinding()]
    param ()

    if ($null -ne $Script:RPSession)
    {
        Write-Verbose ('Disconnect from the report portal server {0}#{1}' -f $Script:RPSession.Url, $Script:RPSession.Project)

        $Script:RPSession = $null
    }
}
