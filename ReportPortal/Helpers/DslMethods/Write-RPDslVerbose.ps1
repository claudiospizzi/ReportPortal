<#
    .SYNOPSIS
        Verbose output for the DSL context execution
#>
function Write-RPDslVerbose
{
    [CmdletBinding()]
    param
    (
        # The report portal context.
        [Parameter(Mandatory = $true)]
        [PSTypeName('ReportPortal.Context')]
        $Context,

        # The message to write.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Message
    )

    $data = '*** [ReportPortal]'

    if ($null -ne $Context)
    {
        if ($null -ne $Context.Launch)
        {
            $data = '{0} [Launch: {1}]' -f $data, $Context.Launch.Name
        }

        if ($null -ne $Context.Suite)
        {
            $data = '{0} [Suite: {1}]' -f $data, $Context.Suite.Name
        }

        if ($null -ne $Context.Tests -and $Context.Tests.Count -gt 0)
        {
            $testNames = @($Context.Tests.Name)
            [System.Array]::Reverse($testNames)
            foreach ($testName in $testNames)
            {
                $data = '{0} [{1}]' -f $data, $testName
            }
        }
    }

    $data = '{0} {1}' -f $data, $Message

    Write-Verbose $data
}
