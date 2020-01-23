<#
    .SYNOPSIS
        Test if the Report Portal session is valid. If not or if it's null,
        return the cached session or throw an exception.
#>
function Test-RPSession
{
    [CmdletBinding()]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [PSTypeName('ReportPortal.Session')]
        $Session
    )

    if ($null -ne $Session)
    {
        return $Session
    }
    elseif ($null -ne $Script:RPSession)
    {
        return $Script:RPSession
    }
    else
    {
        throw 'No valid Report Portal session found!'
    }
}
