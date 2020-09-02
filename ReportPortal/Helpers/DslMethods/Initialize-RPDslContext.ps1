<#
    .SYNOPSIS
        Initialize the context for a Report Portal Launch in the DSL.
#>
function Initialize-RPDslContext
{
    param
    (
        # Name of the launch. A new launch will be started and stopped.
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Name,

        # Use the already started launch. It will not be stopped after testing.
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # List of test steps to be suppressed.
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.String[]]
        $Suppression
    )

    # Specify the launch execution modes:
    # - Passive
    #   The launch already exists. Reuse this launch object but passive
    #   indicates, that the launch was startetd externally.
    # - Active
    #   The launch does not exist, but we have a launch name specified, e.g.
    #   it's not an empty string. This means we have to start and stop the
    #   internally.
    # - None
    #   No launch object or name was specified, just execute the tests as if
    #   they were normal Pester tests.
    if ($null -ne $Launch)
    {
        $mode = 'Passive'
    }
    elseif (-not [System.String]::IsNullOrEmpty($Name))
    {
        $mode = 'Active'
    }
    else
    {
        $mode = 'None'
    }

    [PSCustomObject] @{
        PSTypeName  = 'ReportPortal.Context'
        Mode        = $mode
        Launch      = $Launch
        Suite       = $null
        Tests       = $null #[System.Collections.Stack]::new()
        Suppression = $Suppression
    }
}
