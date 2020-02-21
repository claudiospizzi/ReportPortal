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
        [Allownull()]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # List of test steps to be suppressed.
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.String[]]
        $Suppression
    )

    # If the launch was not passed but we have
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
