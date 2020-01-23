function ConvertFrom-RPException
{
    param
    (
        # Error record.
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    $message = $ErrorRecord.Exception.InnerException.Message
    $message = ([System.String] $message).Split("`n")[1]

    if ($message -match '^Response Body: (?<Error>.*)$')
    {
        $rpError = $Matches['Error'] | Convertfrom-Json

        $exception     = [System.Exception]::new($rpError.message)
        $errorCategory = [System.Management.Automation.ErrorCategory]::NotSpecified

        [System.Management.Automation.ErrorRecord]::new($exception, $rpError.error_code, $errorCategory, $ErrorRecord.TargetObject)
    }
    else
    {
        Write-Output $ErrorRecord
    }
}
