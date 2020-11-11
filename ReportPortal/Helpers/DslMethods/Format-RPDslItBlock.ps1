<#
    .SYNOPSIS
        Format a Pester It block for the debug log in the Report Portal.
#>
function Format-RPDslItBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        # The test name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # The test script block.
        [Parameter(Mandatory = $true)]
        [ScriptBlock]
        $Test
    )

    $ErrorActionPreference = 'Stop'

    try
    {
        $testLines = @($Test.ToString().Split("`n"))

        $spaceList = @()

        for ($i = 0; $i -lt $testLines.Count; $i++)
        {
            $testLines[$i] = $testLines[$i].Replace("`r", '')

            if ([System.String]::IsNullOrWhiteSpace($testLines[$i]))
            {
                continue
            }

            # Add the number of trailing spaces to the space list
            $spaceList += $testLines[$i].Length - $testLines[$i].TrimStart().Length
        }

        # Not select the minimum space count
        $spaceToTrim = $spaceList | Measure-Object -Minimum | Select-Object -ExpandProperty 'Minimum'

        # First line, the It block definition
        $lines = @()

        # Try to add every line
        foreach ($testLine in $testLines)
        {
            if ($testLine.Length -gt $spaceToTrim)
            {
                $lines += '    {0}' -f $testLine.Substring($spaceToTrim)
            }
            else
            {
                $lines += $testLine
            }
        }

        # Add opening and closing including the code block
        $lines[0]  = "``````powershell`nIt '{0}' {{{1}" -f $Name, $lines[0]
        $lines[-1] = "{0}}}`n``````" -f $lines[-1].TrimStart()

        return ($lines -join "`n")
    }
    catch
    {
        return ("It '{0}' {{{1}}}" -f $Name, $Test)
    }
}
