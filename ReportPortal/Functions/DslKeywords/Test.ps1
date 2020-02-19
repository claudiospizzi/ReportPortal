<#
    .SYNOPSIS
        A report portal test.

    .DESCRIPTION
        This DSL keyword will create a new test in the report portal launch. The
        fixture is then invoked within a Pester Context block.
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

        # Attributes or tags.
        [Parameter(Mandatory = $false)]
        [Alias('Tags')]
        [System.String[]]
        $Tag = @()
    )

    # Quit the function if not part of a launch.
    if ($null -eq $Script:RPLaunch -or $null -eq $Script:RPStack)
    {
        throw 'Test block must be placed inside a Launch block!'
    }

    try
    {
        # Start the test within the report portal
        $test = Start-RPTestItem -Launch $Script:RPLaunch -Parent $Script:RPStack.Peek() -Type 'Test' -Name $Name -Attribute $Tag -ErrorAction 'Stop'
        $Script:RPStack.Push($test)

        Write-RPDslInformation -Launch $Script:RPLaunch -Stack $Script:RPStack -Message 'Start'

        # Now call the Pester Context block. This block won't throw any
        # exceptions, because they are handled inside the Pester block. This is
        # why we have to access the internal Pester varialbe to get and log the
        # exception to the report portal in the finally block.
        Pester\Context @PSBoundParameters

        # Try to catch internal errors in the Pester execution by extracting the
        # Pester state variable, get the last test result and throw it if it has
        # failed.
        $pesterTestResult = (& (Get-Module 'Pester') Get-Variable -Name 'Pester' -ValueOnly).TestResult[-1]
        if ($pesterTestResult.Context -like "*$Name" -and $pesterTestResult.Name -like 'Error occurred in * block')
        {
            Write-RPDslInternalError -Launch $Script:RPLaunch -Parent $test -Scope 'Test' -ErrorMessage $pesterTestResult.FailureMessage -ErrorStackTrace $pesterTestResult.StackTrace
        }
    }
    catch
    {
        Write-RPDslInternalError -Launch $Script:RPLaunch -Parent $test -Scope 'Test' -ErrorRecord $_
    }
    finally
    {
        Write-RPDslInformation -Launch $Script:RPLaunch -Stack $Script:RPStack -Message 'Stop'

        # Try to stop the test, ignore any error
        Stop-RPTestItem -TestItem $test -ErrorAction 'SilentlyContinue'

        # Remove the test from the stack
        if ($null -ne $test -and $Script:RPStack.Count -gt 0 -and $Script:RPStack.Peek().Guid -eq $test.Guid)
        {
            $Script:RPStack.Pop() | Out-Null
        }
    }
}
