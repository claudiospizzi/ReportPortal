
# Append module path for auto-loading
$Env:PSModulePath = "$PSScriptRoot\Modules;$Env:PSModulePath"

# Import all modules for the debugging session
Get-ChildItem -Path "$PSScriptRoot\Modules" -Directory | ForEach-Object { Remove-Module $_.BaseName -ErrorAction 'SilentlyContinue' }
Get-ChildItem -Path "$PSScriptRoot\Modules" -Directory | ForEach-Object { Import-Module $_.BaseName }

<# ------------------ PLACE DEBUG COMMANDS AFTER THIS LINE ------------------ #>

Set-StrictMode -Version Latest

$service = Connect-RPService -ComputerName '172.21.113.190' -Port 8080 -ProjectName 'operational_validation' -UserId '6bd14384-bb7f-4732-8d92-7f0f04b641a7'

$launch = Start-RPLaunch -Service $service -Name 'My Launch'

$suite = Start-RPTestItem -Service $service -Launch $launch -Name 'My Suite' -Type 'Suite'
$suite

$test = Start-RPTestItem -Service $service -Launch $launch -Parent $suite -Name 'My Test' -Type 'Test'
$test

$step = Start-RPTestItem -Service $service -Launch $launch -Parent $test -Name 'My Step' -Type 'Step'
$step

Stop-RPTestItem -Service $service -TestItem $step
Stop-RPTestItem -Service $service -TestItem $test
Stop-RPTestItem -Service $service -TestItem $suite
Stop-RPLaunch -Service $service -Launch $launch











return

$service = Connect-RPService -ComputerName '172.21.113.190' -Port 8080 -ProjectName 'operational_validation' -UserId '6bd14384-bb7f-4732-8d92-7f0f04b641a7'

$launch = Start-RPLaunch -Service $service -Name 'ARC' -WhatIf
$launch = Start-RPLaunch -Service $service -Name 'ARC'

Stop-RPLaunch -Service $service -Launch $launch -WhatIf
Stop-RPLaunch -Service $service -Launch $launch

Remove-RPLaunch -Service $service -Id $launch.Id -WhatIf
Remove-RPLaunch -Service $service -Launch $launch -WhatIf

Get-RPLaunch -Service $service | ogv

Get-RPLaunch -Service $service | % { Remove-RPLaunch -Service $service -Launch $_ -Force -WhatIf }




