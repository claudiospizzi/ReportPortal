<#
    .SYNOPSIS
        A report portal launch.

    .DESCRIPTION
        This DSL keyword will use the already startet launch or will start and
        finish a new launch with the specified name, to invoke all test steps.
#>
function Launch
{
    [CmdletBinding()]
    param
    (
        # Name of the launch. A new launch will be started and stopped.
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        # Use the already started launch. It will not be stopped after testing.
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Launch')]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # Test content.
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [System.Management.Automation.ScriptBlock]
        $Fixture,

        # Attributes or tags.
        [Parameter(Mandatory = $false)]
        [Alias('Tags')]
        [System.String[]]
        $Tag = @()
    )

    # Catch all errors happenind in the Launch block.
    $ErrorActionPreference = 'Stop'

    try
    {
        # Just store the passed launch object in the context, if specified. Or
        # start a new launch if only the launch name was specified.
        if ($PSCmdlet.ParameterSetName -eq 'Launch')
        {
            $Script:RPLaunch = $Launch
            $Script:RPStack = [System.Collections.Stack]::new()
            $Script:RPSuite = ''

            $Name = $Script:RPLaunch.Name
        }
        else
        {
            $Script:RPLaunch = Start-RPLaunch -Name $Name -Attribute $Tag -Verbose:$false
            $Script:RPStack = [System.Collections.Stack]::new()
            $Script:RPSuite = ''
        }

        Write-RPDslInformation -Launch $Script:RPLaunch -Message 'Start'

        # We wrap the launch ficture into a describe block, so that the direct
        # child Suite and Test fixtures which are specified in the $Fixture can
        # get internal error from within the Pester module.
        # This won't work for errors happening in the $Fixture and are not
        # wrapped into a Pester block. That's why we have to wrap the $Fixture
        # in an try/catch and write the error directly to the report portal from
        # the Describe block.
        Pester\Describe -Name $Name -Fixture {
            try
            {
                & $Fixture
            }
            catch
            {
                Write-RPDslInternalError -Launch $Script:RPLaunch -Scope 'Launch' -ErrorRecord $_
                throw $_
            }
        }
    }
    catch
    {
        Write-RPDslInternalError -Launch $Script:RPLaunch -Scope 'Launch' -ErrorRecord $_
        throw $_
    }
    finally
    {
        Write-RPDslInformation -Launch $Script:RPLaunch -Message 'Stop'

        # Finish the launch, if it was started within this function
        if ($PSCmdlet.ParameterSetName -contains 'Name')
        {
            $Script:RPLaunch = Stop-RPLaunch -Launch $Script:RPLaunch -PassThru
        }

        $Script:RPLaunch = $null
        $Script:RPStack = $null
        $Script:RPSuite = $null
    }
}
