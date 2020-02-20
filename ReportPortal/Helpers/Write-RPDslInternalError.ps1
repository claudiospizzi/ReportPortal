<#
    .SYNOPSIS
        Add an error to the report portal if possible, which describes the
        internal error occured during the test execution.
#>
function Write-RPDslInternalError
{
    [CmdletBinding()]
    param
    (
        # The report portal launch.
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # The parent test item.
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [PSTypeName('ReportPortal.TestItem')]
        $Parent,

        # The message to write.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Launch', 'Suite', 'Test', 'Step')]
        [System.String]
        $Scope,

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
    if ($null -eq $Launch)
    {
        return
    }

    # Create the failed test item step log entry, optionally add the parent item
    # if specified and not null.
    $addTestItemStep = @{
        Launch     = $Launch
        Name       = "Internal $Scope Error"
        Status     = 'Failed'
        LogMessage = ''
    }
    if ($null -ne $Parent)
    {
        $addTestItemStep['Parent'] = $Parent
    }
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
