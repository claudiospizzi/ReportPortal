<#
    .SYNOPSIS
        Add a test item step with an optional message.

    .DESCRIPTION
        Use this command to add and finish a test item step.
#>
function Add-RPTestItemStep
{
    [CmdletBinding()]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # The report portal launch.
        [Parameter(Mandatory = $true)]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # The parent test item, can be null for root elements.
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [PSTypeName('ReportPortal.TestItem')]
        $Parent,

        # Test item name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # The test result.
        [Parameter(Mandatory = $false)]
        [ValidateSet('Passed', 'Failed', 'Skipped', 'Interrupted')]
        [System.String]
        $Status = 'Passed',

        # Test item log message.
        [Parameter(Mandatory = $true)]
        [System.String]
        $LogMessage
    )

    $Session = Test-RPSession -Session $Session

    Write-Verbose ('Add a report portal test item with name {0} and type step' -f $Name)

    # Start a test item step
    $step = Start-RPTestItem -Session $Session -Launch $Launch -Parent $Parent -Type 'Step' -Name $Name

    # If the log message was specified, just add it to the step
    if ($PSBoundParameters.ContainsKey('LogMessage'))
    {
        if ($Status -eq 'Failed')
        {
            Add-RPLog -Session $Session -TestItem $step -Level 'Error' -Message $LogMessage
        }
        else
        {
            Add-RPLog -Session $Session -TestItem $step -Level 'Info' -Message $LogMessage
        }
    }

    # Stop the test item step
    Stop-RPTestItem -Session $Session -TestItem $step -Status $Status
}
