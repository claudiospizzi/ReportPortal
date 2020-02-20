<#
    .SYNOPSIS
        A report portal test step.

    .DESCRIPTION
        This DSL keyword will invoke the real test step, specified in the $Test
        script block. The test step supports the same parameter as a Pester It
        block, because internally we call the Pester It block to invoke the
        test.
#>
function Step
{
    [CmdletBinding(DefaultParameterSetName = 'Normal')]
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

        # Attributes or tags.
        [Parameter(Mandatory = $false)]
        [Alias('Tags')]
        [System.String[]]
        $Tag = @(),

        # Test is pending.
        [Parameter(ParameterSetName = 'Pending')]
        [Switch]
        $Pending,

        # Test is skipped.
        [Parameter(ParameterSetName = 'Skip')]
        [Alias('Ignore')]
        [Switch]
        $Skip
    )

    # Quit the function if not part of a launch and suite or test.
    if ($null -eq $Script:RPLaunch -or $null -eq $Script:RPStack -or $Script:RPStack.Count -eq 0)
    {
        throw 'Step block must be placed inside a Launch and a Suite or Test block!'
    }

    # Recursive call if we use test cases and have more than one case. If this
    # is true, we will remote the TestCases from the bound parameters and call
    # the Step function recursively, once for each test case. With this, we
    # simply have one test per Step run and we can leverage the test suite
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
        # Sum up all tags of the parent definitions
        $Tag += $Script:RPStack.Attributes
        $Tag = $Tag | Select-Object -Unique

        # We can't start the report portal step because we don't know the name
        # of the test step yet, if we use test cases. That's why we store the
        # time before we invoke the Pester block
        $startTime = Get-Date

        # Now call the Pester It block, but without the tag parameter. This
        # block won't throw any exceptions, because they are handled inside the
        # Pester block. This is why we have to access the internal Pester
        # varialbe to get and log the exception to the report portal in the
        # finally block.
        $PSBoundParameters.Remove('Tag') | Out-Null
        Pester\It @PSBoundParameters

        # After invoking the It block of Pester, get the result from the
        # internal state variable.
        $pesterTestResult = (& (Get-Module 'Pester') Get-Variable -Name 'Pester' -ValueOnly).CurrentTestGroup.Actions[-1]
        # $pesterTestResult | format-list * -Force | Out-String | Write-host

        # Start the step within the report portal
        $step = Start-RPTestItem -Launch $Script:RPLaunch -Parent $Script:RPStack.Peek() -Type 'Step' -StartTime $startTime -Name $pesterTestResult.Name -Attribute $Tag -ErrorAction 'Stop'
        $Script:RPStack.Push($step)

        Write-RPDslInformation -Launch $Script:RPLaunch -Stack $Script:RPStack -Message 'Start'

        # For each test, we add the definition of the It block to the report
        # portal log, so that we easy can troubleshoot the errors.
        Add-RPLog -TestItem $step -Level 'Debug' -Message (Format-RPDslItBlock -Name $pesterTestResult.Name -Test $Test)

        # If the test fails, add this error as log entry to the test step.
        if ($pesterTestResult.Result -eq 'Failed')
        {
            Add-RPLog -TestItem $step -Level 'Error' -Message ("{0}`n{1}" -f $pesterTestResult.FailureMessage, $pesterTestResult.StackTrace)
        }

        # Set the status of the test. This is derived from the Pester result
        # status into a report portal result status.
        $stepStatus = $pesterTestResult.Result
        if ($stepStatus -notin 'Passed', 'Failed', 'Skipped')
        {
            $stepStatus = 'Failed'
        }
    }
    catch
    {
        Write-RPDslInternalError -Launch $Script:RPLaunch -Parent $Script:RPStack.Peek() -Scope 'Step' -ErrorRecord $_
    }
    finally
    {
        Write-RPDslInformation -Launch $Script:RPLaunch -Stack $Script:RPStack -Message 'Stop'

        switch ($pesterTestResult.Result)
        {
            'Passed'  { $status = 'Passed' }
            'Failed'  { $status = 'Failed' }
            'Skipped' { $status = 'Skipped' }
            'Pending' { $status = 'Skipped' }
            default   { $status = 'Failed' }
        }

        # Try to stop the test, ignore any error
        Stop-RPTestItem -TestItem $step -Status $status -ErrorAction 'SilentlyContinue'

        # Remove the step from the stack
        if ($null -ne $step -and $Script:RPStack.Count -gt 0 -and $Script:RPStack.Peek().Guid -eq $step.Guid)
        {
            $Script:RPStack.Pop() | Out-Null
        }
    }
}
