<#
    .SYNOPSIS
        A report portal suite.

    .DESCRIPTION
        This DSL keyword will create a new suite in the report portal launch.
        The fixture is then invoked within a Pester Context block.
#>
function Suite
{
    [CmdletBinding()]
    param
    (
        # Name of the suite.
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
        throw 'Suite block must be placed inside a Launch block!'
    }

    try
    {
        # Sum up all tags of the parent definitions
        $Tag += $Script:RPStack.Attributes
        $Tag = $Tag | Select-Object -Unique

        # Start the suite within the report portal
        $suite = Start-RPTestItem -Launch $Script:RPLaunch -Type 'Suite' -Name $Name -Attribute $Tag -ErrorAction 'Stop'
        $Script:RPStack.Push($suite)

        Write-RPDslInformation -Launch $Script:RPLaunch -Stack $Script:RPStack -Message 'Start'

        # Now call the Pester Context block, but without the tag parameter. This
        # block won't throw any exceptions, because they are handled inside the
        # Pester block. This is why we have to access the internal Pester
        # varialbe to get and log the exception to the report portal in the
        # finally block.
        $PSBoundParameters.Remove('Tag') | Out-Null
        Pester\Context @PSBoundParameters

        # Try to catch internal errors in the Pester execution by extracting the
        # Pester state variable, get the last test result and throw it if it has
        # failed.
        $pesterTestResult = (& (Get-Module 'Pester') Get-Variable -Name 'Pester' -ValueOnly).TestResult[-1]
        if ($pesterTestResult.Context -like "*$Name" -and $pesterTestResult.Name -like 'Error occurred in * block')
        {
            Write-RPDslInternalError -Launch $Script:RPLaunch -Parent $suite -Scope 'Suite' -ErrorMessage $pesterTestResult.FailureMessage -ErrorStackTrace $pesterTestResult.StackTrace
        }
    }
    catch
    {
        Write-RPDslInternalError -Launch $Script:RPLaunch -Parent $suite -Scope 'Suite' -ErrorRecord $_
    }
    finally
    {
        Write-RPDslInformation -Launch $Script:RPLaunch -Stack $Script:RPStack -Message 'Stop'

        # Try to stop the suite, ignore any error
        Stop-RPTestItem -TestItem $suite -ErrorAction 'SilentlyContinue'

        # Remove the suite from the stack
        if ($null -ne $suite -and $Script:RPStack.Count -gt 0 -and $Script:RPStack.Peek().Guid -eq $suite.Guid)
        {
            $Script:RPStack.Pop() | Out-Null
        }
    }
}
