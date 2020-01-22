<#
    .SYNOPSIS
        Disconnect from the report portal service.

    .DESCRIPTION
        Disconnect from the report portal service by just cleaning the cached
        connection. The ReportPortal.Client does not provide a disconnect or
        logout method.
#>
function Disconnect-RPServer
{
    [CmdletBinding()]
    param ()

    $Script:RPService = $null
}
