<#
    .SYNOPSIS
        Test if the current context should be supressed.
#>
function Test-RPDslSupression
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        # The report portal context.
        [Parameter(Mandatory = $true)]
        [PSTypeName('ReportPortal.Context')]
        $Context
    )

    $path = $Context.Launch.Name

    if ($null -ne $Context.Suite)
    {
        $path = '{0}/{1}' -f $path, $Context.Suite.Name
    }

    if ($null -ne $Context.Tests -and $Context.Tests.Count -gt 0)
    {
        $testNames = @($Context.Tests.Name)
        [System.Array]::Reverse($testNames)
        foreach ($testName in $testNames)
        {
            $path = '{0}/{1}' -f $path, $testName
        }
    }

    foreach ($currentSuppression in $Context.Suppression)
    {
        if ($path -match $currentSuppression)
        {
            return $true
        }
    }

    return $false
}
