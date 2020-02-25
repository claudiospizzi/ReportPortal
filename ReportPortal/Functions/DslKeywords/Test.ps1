<#
    .SYNOPSIS
        A report portal test.

    .DESCRIPTION
        This DSL keyword will create a new test in the report portal launch. The
        fixture is then invoked within a Pester Context block. Test blocks can
        be nested into themself for multiple levels.
#>
function Test
{
    [CmdletBinding()]
    param
    (
        # Name of the test.
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Name,

        # Test content.
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [System.Management.Automation.ScriptBlock]
        $Fixture,

        # Tags used as attributes.
        [Parameter(Mandatory = $false)]
        [Alias('Tags')]
        [System.String[]]
        $Tag = @()
    )

    $ErrorActionPreference = 'Stop'

    # Invoke the fixture without the report portal, only native Pester.
    if ($null -ne $Script:RPContext -and $Script:RPContext.Mode -eq 'None')
    {
        Pester\Context -Name $Name -Fixture $Fixture
        return
    }

    # Quit the function if not part of a suite.
    if ($null -eq $Script:RPContext -or
        $null -eq $Script:RPContext.Launch -or
        $null -eq $Script:RPContext.Suite)
    {
        throw 'Test block must be placed within a Suite block!'
    }

    try
    {
        try
        {
            # The launch and tag sum up behaviour depends, if it's the first test or
            # it's a nested test.
            if ($Script:RPContext.Tests.Count -eq 0)
            {
                # Sum up tags
                $Tag += $Script:RPContext.Suite.Attributes
                $Tag = $Tag | Select-Object -Unique

                $test = Start-RPTestItem -Launch $Script:RPContext.Launch -Parent $Script:RPContext.Suite -Type 'Test' -Name $Name -Attribute $Tag
            }
            else
            {
                # Sum up tags
                $Tag += $Script:RPContext.Suite.Attributes
                $Tag += $Script:RPContext.Tests.Attributes
                $Tag = $Tag | Select-Object -Unique

                $test = Start-RPTestItem -Launch $Script:RPContext.Launch -Parent $Script:RPContext.Tests.Peek() -Type 'Test' -Name $Name -Attribute $Tag
            }

            try
            {
                $Script:RPContext.Tests.Push($test)

                Write-RPDslVerbose -Context $Script:RPContext -Message 'Start'

                # Now call the Pester Context block. This block won't throw any
                # exceptions, because they are handled inside the Pester block.
                # This is why we have to access the internal Pester varialbe to
                # get and log the exception to the report portal in the finally
                # block.
                Pester\Context -Name $Name -Fixture $Fixture

                # Try to catch internal errors in the Pester execution by
                # extracting the Pester state variable, get the last test result
                # and throw it if it has failed.
                $pesterTestResult = (& (Get-Module 'Pester') Get-Variable -Name 'Pester' -ValueOnly).TestResult[-1]
                if ($pesterTestResult.Context -like "*$Name" -and $pesterTestResult.Name -like 'Error occurred in * block')
                {
                    Add-RPDslErrorStep -Context $Script:RPContext -ErrorMessage $pesterTestResult.FailureMessage -ErrorStackTrace $pesterTestResult.StackTrace
                }
            }
            finally
            {
                Write-RPDslVerbose -Context $Script:RPContext -Message 'Stop'

                $Script:RPContext.Tests.Pop() | Out-Null
            }
        }
        finally
        {
            if ($null -ne $test)
            {
                Stop-RPTestItem -TestItem $test
            }
        }
    }
    catch
    {
        Add-RPDslErrorStep -Context $Script:RPContext -ErrorRecord $_
    }
}
