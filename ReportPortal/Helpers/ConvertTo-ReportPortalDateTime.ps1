<#
    .SYNOPSIS
        Convert the DateTime object to a JSON valid string.
#>
function ConvertTo-ReportPortalDateTime
{
    [CmdletBinding()]
    param
    (
        # The timestamp.
        [Parameter(Mandatory = $true)]
        [System.DateTime]
        $DateTime
    )

    # We always use universal time
    $DateTime = $DateTime.ToUniversalTime()

    # Now format the result, culture invariant!
    $DateTime.ToString('yyyy-MM-ddTHH:mm:ss.fffZ', [System.Globalization.CultureInfo]::InvariantCulture)
}
