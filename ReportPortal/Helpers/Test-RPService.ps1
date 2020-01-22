<#
    .SYNOPSIS
        Test if the Report Portal service is valid.
#>
function Test-RPService
{
    [OutputType([ReportPortal.Client.Service])]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [ReportPortal.Client.Service]
        $Service
    )

    if ($null -ne $Service)
    {
        return $Service
    }
    elseif ($null -ne $Script:RPService)
    {
        return $Script:RPService
    }
    else
    {
        throw 'No valid Report Portal cached service found!'
    }
}
