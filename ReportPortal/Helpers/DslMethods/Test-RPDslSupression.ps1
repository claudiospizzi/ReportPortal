<#
    .SYNOPSIS
        Test if the current context should be supressed.
#>
function Test-RPDslSuppression
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

    if ($Context.Mode -eq 'None')
    {
        # Use the Pester stack and join all elements together to create the path
        # to the test name.
        $pathNames = $Context.PesterPath.ToArray()
        [System.Array]::Reverse($pathNames)
        $path = $pathNames -join '/'
    }
    else
    {
        # Use the report portal elements like Launch, Suite, Test and Step to
        # produce the path, which is then matched against the suppression.
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
