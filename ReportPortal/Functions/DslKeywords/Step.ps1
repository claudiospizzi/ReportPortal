<#
    .SYNOPSIS
        A report portal step.

    .DESCRIPTION
        This DSL keyword will invoke the real test step, specified in the $Test
        script block. The test step supports the same parameter as a Pester It
        block, because internally we call the Pester It block to invoke the
        test.
#>
function Step
{
    [CmdletBinding()]
    param
    (
        # Name of the test step.
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Name,

        # Test definition.
        [Parameter(Mandatory = $false, Position = 1)]
        [ScriptBlock]
        $Test = {},

        # Optionally use test cases.
        [Parameter(Mandatory = $false)]
        [System.Collections.IDictionary[]]
        $TestCases,

        # Tags used as attributes.
        [Parameter(Mandatory = $false)]
        [Alias('Tags')]
        [System.String[]]
        $Tag = @(),

        # Test is pending.
        [Parameter(Mandatory = $false)]
        [Switch]
        $Pending,

        # Test is skipped.
        [Parameter(Mandatory = $false)]
        [Alias('Ignore')]
        [Switch]
        $Skip
    )

    $ErrorActionPreference = 'Stop'

    # Invoke the test without the report portal, only native Pester.
    if ($null -ne $Script:RPContext -and $Script:RPContext.Mode -eq 'None')
    {
        $PSBoundParameters.Remove('Tag') | Out-Null
        if ($Pending.IsPresent -and $Skip.IsPresent)
        {
            $PSBoundParameters.Remove('Pending') | Out-Null
        }
        Pester\It @PSBoundParameters
        return
    }

    # Quit the function if not part of a suite.
    if ($null -eq $Script:RPContext -or
        $null -eq $Script:RPContext.Launch -or
        $null -eq $Script:RPContext.Suite -or
        $null -eq $Script:RPContext.Tests -or
        $Script:RPContext.Tests.Count -eq 0)
    {
        throw 'Step block must be placed within a Test block!'
    }

    # Recursive call if we use test cases and have more than one case. If this
    # is true, we will remote the TestCases from the bound parameters and call
    # the Step function recursively, once for each test case. With this, we
    # simply have one test per Step to run and we can leverage the test suite
    # implementation of Pester.
    if ($PSBoundParameters.ContainsKey('TestCases') -and $TestCases.Count -gt 1)
    {
        $PSBoundParameters.Remove('TestCases') | Out-Null

        foreach ($testCase in $TestCases)
        {
            Step @PSBoundParameters -TestCases $testCase
        }

        return
    }

    try
    {
        # Sum up tags
        $Tag += $Script:RPContext.Suite.Attributes
        $Tag += $Script:RPContext.Tests.Attributes
        $Tag = $Tag | Select-Object -Unique

        # Now call the Pester It block, but without the tag parameter. This
        # block won't throw any exceptions, because they are handled inside the
        # Pester block. This is why we have to access the internal Pester
        # varialbe to get and log the exception to the report portal in the
        # finally block.
        $PSBoundParameters.Remove('Tag') | Out-Null
        if ($Pending.IsPresent -and $Skip.IsPresent)
        {
            $PSBoundParameters.Remove('Pending') | Out-Null
        }
        Pester\It @PSBoundParameters

        # After invoking the It block of Pester, get the result from the
        # internal state variable.
        $pesterTestResult = (& (Get-Module 'Pester') Get-Variable -Name 'Pester' -ValueOnly).CurrentTestGroup.Actions[-1]

        try
        {
            $step = Start-RPTestItem -Launch $Script:RPContext.Launch -Parent $Script:RPContext.Tests.Peek() -Type 'Step' -Name $pesterTestResult.Name -Attribute $Tag

            try
            {
                $Script:RPContext.Tests.Push($step)

                Write-RPDslVerbose -Context $Script:RPContext -Message 'Start'

                # For each test, we add the definition of the It block to the
                # report portal log, so that we easy can troubleshoot the
                # errors.
                Add-RPLog -TestItem $step -Level 'Debug' -Message (Format-RPDslItBlock -Name $pesterTestResult.Name -Test $Test)

                # If the test fails, add this error as log entry to the test step.
                if ($pesterTestResult.Result -eq 'Failed')
                {
                    Add-RPLog -TestItem $step -Level 'Error' -Message ("{0}`n{1}" -f $pesterTestResult.FailureMessage, $pesterTestResult.StackTrace)
                }

                if (Test-RPDslSupression -Context $Script:RPContext)
                {
                    $status = 'Skipped'
                }
                else
                {
                    # Set the status of the test. This is derived from the
                    # Pester result status into a report portal result status.
                    switch ($pesterTestResult.Result)
                    {
                        'Passed'  { $status = 'Passed' }
                        'Failed'  { $status = 'Failed' }
                        'Skipped' { $status = 'Skipped' }
                        'Pending' { $status = 'Skipped' }
                        default   { $status = 'Failed' }
                    }
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
            if ($null -ne $step)
            {
                # If status has not been set, fix it
                if ($null -eq $status)
                {
                    $status = 'Failed'
                }

                Stop-RPTestItem -TestItem $step -Status $status
            }
        }
    }
    catch
    {
        Add-RPDslErrorStep -Context $Script:RPContext -ErrorRecord $_
    }
}
