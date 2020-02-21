<#
    .SYNOPSIS
        Add an error to the report portal if possible, which describes the
        internal error occured during the test execution.
#>
function Add-RPDslErrorStep
{
    [CmdletBinding()]
    param
    (
        # The report portal context.
        [Parameter(Mandatory = $true)]
        [PSTypeName('ReportPortal.Context')]
        $Context,

        # The occured error as ErrorRecord object.
        [Parameter(Mandatory = $true, ParameterSetName = 'ErrorRecord')]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord,

        # The error message.
        [Parameter(Mandatory = $true, ParameterSetName = 'ErrorMessage')]
        [System.String]
        $ErrorMessage,

        # The error stack trace.
        [Parameter(Mandatory = $true, ParameterSetName = 'ErrorMessage')]
        [System.String]
        $ErrorStackTrace
    )

    # Do nothing if we don't have a launch.
    if ($null -eq $Context -or $null -eq $Context.Launch -or $Context.Mode -eq 'None')
    {
        return
    }

    # The splat to create a new test item error log.
    $addTestItemStep = @{
        Launch     = $Context.Launch
        Name       = 'Internal {0} Error'
        Status     = 'Failed'
        LogMessage = 'Unknown'
    }

    # Depending on the level, add a better name and a parent item.
    if ($null -ne $Context.Tests -and $Context.Tests.Count -gt 0)
    {
        $addTestItemStep['Name'] = $addTestItemStep['Name'] -f 'Test'
        $addTestItemStep['Parent'] = $Context.Tests.Peek()
    }
    elseif ($null -ne $Context.Suite)
    {
        $addTestItemStep['Name'] = $addTestItemStep['Name'] -f 'Suite'
        $addTestItemStep['Parent'] = $Context.Suite
    }
    else
    {
        $addTestItemStep['Name'] = $addTestItemStep['Name'] -f 'Launch'
    }

    # Extract failure information from the error record or the explicitly
    # specified error message and stack trace.
    if ($PSCmdlet.ParameterSetName -eq 'ErrorRecord')
    {
        $addTestItemStep['LogMessage'] = "{0}`n{1}" -f $ErrorRecord, $ErrorRecord.ScriptStackTrace
    }
    if ($PSCmdlet.ParameterSetName -eq 'ErrorMessage')
    {
        $addTestItemStep['LogMessage'] = "{0}`n{1}" -f $ErrorMessage, $ErrorStackTrace
    }

    Add-RPTestItemStep @addTestItemStep
}
