<#
    .SYNOPSIS
        Test if the Report Portal session is valid. If not or if it's null,
        return the cached session or throw an exception.
#>
function Write-RPDslInformation
{
    [CmdletBinding()]
    param
    (
        # The report portal launch.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # Stack of test items for the breadcrump.
        [Parameter(Mandatory = $false)]
        [System.Collections.Stack]
        $Stack,

        # The message to write.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Message
    )

    # Basic message prefix.
    $data = '[ReportPortal]'

    # Add the information about the launch.
    if ($PSBoundParameters.Keys -contains 'Launch')
    {
        $data = '{0} [Launch: {1}]' -f $data, $Launch.Name
    }

    # Add the stack breadcrump.
    if ($PSBoundParameters.ContainsKey('Stack') -and $Stack.Count -gt 0)
    {
        $stackList = @($Stack.Name)
        [System.Array]::Reverse($stackList)
        foreach ($stackItem in $stackList)
        {
            $data = '{0} [{1}]' -f $data, $stackItem
        }
    }

    # Add the message itself.
    $data = '{0} {1}' -f $data, $Message

    Write-Information -MessageData $data
}
