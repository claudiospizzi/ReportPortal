<#
    .SYNOPSIS
        A report portal launch.

    .DESCRIPTION
        This DSL keyword will use the already startet launch or will start and
        finish a new launch with the specified name, to invoke all test steps.
        If the Launch is not specified at all, null or an empty string, the test
        will be invoked in Pester but without any Report Portal interaction.
#>
function Launch
{
    [CmdletBinding()]
    param
    (
        # Name of the launch. A new launch will be started and stopped.
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Name')]
        [AllowEmptyString()]
        [System.String]
        $Name,

        # Use the already started launch. It will not be stopped after testing.
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Launch')]
        [AllowNull()]
        [PStypeName('ReportPortal.Launch')]
        $Launch,

        # Test content.
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [System.Management.Automation.ScriptBlock]
        $Fixture,

        # List of test steps to be suppressed.
        [Parameter(Mandatory = $false)]
        [System.String[]]
        $Suppression = @(),

        # Tags used as attributes.
        [Parameter(Mandatory = $false)]
        [Alias('Tags')]
        [System.String[]]
        $Tag = @()
    )

    $ErrorActionPreference = 'Stop'

    try
    {
        # Create a DSL context object to hold the current execution context for
        # this launch. This will be cleared in the finally block.
        $Script:RPContext = Initialize-RPDslContext -Name $Name -Launch $Launch -Suppression $Suppression

        # Invoke the fixture without the report portal, only native Pester.
        if ($null -eq $Script:RPContext -or $Script:RPContext.Mode -eq 'None')
        {
            try
            {
                $Script:RPContext.PesterPath.Push('Launch')

                Pester\Describe -Name 'Launch' -Fixture $Fixture
            }
            finally
            {
                $Script:RPContext.PesterPath.Pop() | Out-Null
            }
            return
        }

        try
        {
            # In active mode, we start and step a new launch.
            if ($Script:RPContext.Mode -eq 'Active')
            {
                $Script:RPContext.Launch = Start-RPLaunch -Name $Name -Attribute $Tag
            }

            Write-RPDslVerbose -Context $Script:RPContext -Message 'Start'

            # We wrap the launch fixture into a describe block, so that the
            # direct child Suite and Test fixtures which are specified in the
            # $Fixture can get internal error from within the Pester module.
            # This won't work for errors happening in the $Fixture and are not
            # wrapped into a Pester block. That's why we have to wrap the
            # $Fixture in an try/catch and write the error directly to the
            # report portal from the Describe block.
            Pester\Describe -Name $Script:RPContext.Launch.Name -Fixture {
                try
                {
                    & $Fixture
                }
                catch
                {
                    Add-RPDslErrorStep -Context $Script:RPContext -ErrorRecord $_
                    throw $_
                }
            }
        }
        catch
        {
            Add-RPDslErrorStep -Context $Script:RPContext -ErrorRecord $_
        }
        finally
        {
            Write-RPDslVerbose -Context $Script:RPContext -Message 'Stop'

            # In active mode, we start and step a new launch.
            if ($Script:RPContext.Mode -eq 'Active')
            {
                $Script:RPContext.Launch = Stop-RPLaunch -Launch $Script:RPContext.Launch -PassThru
            }
        }
    }
    finally
    {
        $Script:RPContext = $null
    }
}
