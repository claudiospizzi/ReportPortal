<#
    .SYNOPSIS
        Format a comment before the Pester It block.

    .DESCRIPTION
        The comment must be wrapped into a block comment and start right before
        the It block definition.
#>
function Format-RPDslItComment
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    try
    {
        # Use reflection on the call stack of PowerShell to get the comment
        # block above the function itself. This is how the call stack locks
        # like:
        # [0]: Format-RPDslItComment   This function itself.
        # [1]: Step                    ReportPortal test step function.
        # [2]: <ScriptBlock>           The actual test script block.
        # [3]: DescribeImpl            Pester internal function implementing context.
        # [4]: Context                 Pester internal function wrapping implementation.
        # [5]: Test                    ReportPortal test function.
        # ...
        [System.Management.Automation.CallStackFrame[]] $callStack = Get-PSCallStack

        # Select the element with id 2, so the element containing the actual
        # test function implementation. It will also point to the script full
        # path and line number of the implementation.
        $scriptBlockFrame = $callStack | Select-Object -First 1 -Skip 2
        if ($null -eq $scriptBlockFrame)
        {
            throw "Call stack frame number 3 (index 2) not found!"
        }

        $scriptFullName   = $scriptBlockFrame.ScriptName
        $scriptLineNumber = $scriptBlockFrame.ScriptLineNumber

        # Read the content of the script file up to the line before the script
        # block, this is where the comment should end. Then reverse the array
        # for parsing.
        [System.String[]] $scriptContent = Get-Content -Path $scriptFullName -TotalCount ($scriptLineNumber - 1) -Encoding 'UTF8'
        [System.Array]::Reverse($scriptContent)

        # Check for a single line comment block.
        if ($scriptContent[0].Trim().StartsWith('<#') -and $scriptContent[0].Trim().EndsWith('#>'))
        {
            $comment = $scriptContent[0].Trim()
            $comment = $comment.Substring(2, $comment.Length -4).Trim()
            return $comment
        }

        # Check for a multi line comment block.
        if ($scriptContent[0].Trim() -eq '#>')
        {
            $comment = ''
            for ($i = 1; $i -lt $scriptContent.Count; $i++)
            {
                # If we have reached the end of the script block, exit the
                # loop. Else append the new text to the comment.
                $scriptContentLine = $scriptContent[$i].Trim()
                if ($scriptContentLine -eq '<#') { break }
                $comment = "{0}`n{1}" -f $scriptContentLine, $comment
            }
            return $comment
        }

        # IMPORTANT
        # This option is actually disabled because the content can be markdown
        # and this is problematic with single line comments.

        # # Check if we have a comment line.
        # if ($scriptContent[0].Trim().StartsWith('# '))
        # {
        #     $comment = ''
        #     for ($i = 0; $i -lt $scriptContent.Count; $i++)
        #     {
        #         # As long as the line starts with a comment, add it to the
        #         # output. Else stop the loop.
        #         $scriptContentLine = $scriptContent[$i].Trim()
        #         if (-not $scriptContentLine.StartsWith('# ')) { break }
        #         $comment = '{0} {1}' -f $scriptContentLine.Substring(2), $comment
        #     }
        #     return $comment
        # }

        return 'Test step description not found.'
    }
    catch
    {
        return "Error generating the test step description.`n`n```````n$_`n``````"
    }
}
