<#
    .SYNOPSIS
        Convert from a JSON string to a valid DateTime object.
#>
function ConvertFrom-ReportPortalDateTime
{
    [CmdletBinding()]
    param
    (
        # The timestamp.
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [System.Int64]
        $Timestamp
    )

    if ($null -ne $Timestamp -and 0 -ne $Timestamp)
    {
        # Start with the unix timestamp
        $dateTime = [System.DateTime]::new(1970, 1, 1, 0, 0, 0, 0, 'Utc')

        # Add the milliseconds
        $dateTime = $dateTime.AddMilliseconds($Timestamp)

        # We use local time to display
        $dateTime.ToLocalTime()
    }
}
