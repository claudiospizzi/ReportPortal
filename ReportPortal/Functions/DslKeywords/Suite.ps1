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

        # Tags used as attributes.
        [Parameter(Mandatory = $false)]
        [Alias('Tags')]
        [System.String[]]
        $Tag = @(),

        # An already started suite object.
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [PStypeName('ReportPortal.TestItem')]
        $Suite = $null
    )

    $ErrorActionPreference = 'Stop'

    # Invoke the fixture without the report portal, only native Pester.
    if ($null -ne $Script:RPContext -and $Script:RPContext.Mode -eq 'None')
    {
        try
        {
            $Script:RPContext.PesterPath.Push($Name)

            Pester\Describe -Name $Name -Fixture $Fixture
        }
        finally
        {
            $Script:RPContext.PesterPath.Pop() | Out-Null
        }
        return
    }

    # Quit the function if not part of a launch.
    if ($null -eq $Script:RPContext -or
        $null -eq $Script:RPContext.Launch)
    {
        throw 'Suite block must be placed as direct child within a Launch block!'
    }

    try
    {
        # Sum up tags
        $Tag += "Suite:$Name"
        $Tag = $Tag | Select-Object -Unique

        try
        {
            if (-not $PSBoundParameters.ContainsKey('Suite'))
            {
                $Script:RPContext.Suite = Start-RPTestItem -Launch $Script:RPContext.Launch -Type 'Suite' -Name $Name -Attribute $Tag
            }
            else
            {
                $Script:RPContext.Suite = $Suite
            }

            # Initialize a new stack of tests, used within the suite.
            $Script:RPContext.Tests = [System.Collections.Stack]::new()

            Write-RPDslVerbose -Context $Script:RPContext -Message 'Start'

            # Now call the second Pester Describe block. This block won't throw
            # any exceptions, because they are handled inside the Pester block.
            # This is why we have to access the internal Pester varialbe to get
            # and log the exception to the report portal in the finally block.
            Pester\Describe -Name $Name -Fixture $Fixture

            # Try to catch internal errors in the Pester execution by extracting
            # the Pester state variable, get the last test result and throw it
            # if it has failed.
            $pesterTestResult = (& (Get-Module 'Pester') Get-Variable -Name 'Pester' -ValueOnly).TestResult[-1]
            if ($pesterTestResult.Context -like "*$Name" -and $pesterTestResult.Name -like 'Error occurred in * block')
            {
                Add-RPDslErrorStep -Context $Script:RPContext -ErrorMessage $pesterTestResult.FailureMessage -ErrorStackTrace $pesterTestResult.StackTrace
            }
        }
        finally
        {
            Write-RPDslVerbose -Context $Script:RPContext -Message 'Stop'

            if (-not $PSBoundParameters.ContainsKey('Suite'))
            {
                Stop-RPTestItem -TestItem $Script:RPContext.Suite
            }

            $Script:RPContext.Tests = $null
            $Script:RPContext.Suite = $null
        }
    }
    catch
    {
        Add-RPDslErrorStep -Context $Script:RPContext -ErrorRecord $_
    }
}
