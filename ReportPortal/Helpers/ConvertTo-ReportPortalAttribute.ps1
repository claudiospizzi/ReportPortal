<#
    .SYNOPSIS
        Convert the string attributes to report portal attributes.
#>
function ConvertTo-ReportPortalAttribute
{
    [CmdletBinding()]
    param
    (
        # The attributes.
        [Parameter(Mandatory = $false)]
        [AllowEmptyCollection()]
        [System.String[]]
        $Attribute
    )

    foreach ($currentAttribute in $Attribute)
    {
        $currentAttributeParts = $currentAttribute.Split(':', 2)

        if ($currentAttributeParts.Count -eq 2)
        {
            [PSCustomObject] @{
                system = $false
                key    = $currentAttributeParts[0]
                value  = $currentAttributeParts[1]
            }
        }
    }
}
