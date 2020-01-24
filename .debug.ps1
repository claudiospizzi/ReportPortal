
Get-ChildItem -Path $PSScriptRoot -Directory |
    ForEach-Object { '{0}\{1}.psd1'-f $_.FullName, $_.Name } |
        Where-Object { Test-Path -Path $_ } |
            Import-Module -Verbose -Force

<# ------------------ PLACE DEBUG COMMANDS AFTER THIS LINE ------------------ #>

#$VerbosePreference = 'Continue'

$url = 'https://reportportal.arcade.ch'

$session = Connect-RPServer -Url $url -Credential (cred 'https://reportportal.arcade.ch') -ProjectName 'ops_test' -PassThru -Verbose
$session | ft

$launch = Start-RPLaunch -Name 'Demo' -Attribute 'TagA:MyLaunch1', 'TagB:FooBar'
$launch | ft

$launch = Get-RPLaunch -Id $launch.Id
$launch | ft

$suite = Start-RPTestItem -Launch $launch -Type 'Suite' -Name 'Suite 1' -Attribute 'Icinga:Foo', 'Icinga:Bar'
$suite

    $test1 = Start-RPTestItem -Launch $launch -Parent $suite -Type 'Test' -Name 'Test 1' -Attribute 'Icinga:Foo'
    $test1

        $test1a = Start-RPTestItem -Launch $launch -Parent $test1 -Type 'Test' -Name 'Test 1a'
        $test1a

        $step1aa = Start-RPTestItem -Launch $launch -Parent $test1a -Type 'Step' -Name 'Step 1a' -Attribute 'Icinga:Bar'
        $step1aa

        Add-RPLog -TestItem $step1aa -Level 'Trace' -Message 'My Trace Message'
        Add-RPLog -TestItem $step1aa -Level 'Debug' -Message 'My Debug Message'
        Add-RPLog -TestItem $step1aa -Level 'Info' -Message 'My Info Message'
        Add-RPLog -TestItem $step1aa -Level 'Warning' -Message 'My Warning Message'
        Add-RPLog -TestItem $step1aa -Level 'Error' -Message 'My Error Message'
        Add-RPLog -TestItem $step1aa -Level 'Fatal' -Message 'My Fatal Message'

        $step1aa = Stop-RPTestItem -TestItem $step1aa -PassThru
        $step1aa

        $step1b = Start-RPTestItem -Launch $launch -Parent $test1 -Type 'Step' -Name 'Step 1b' -Attribute 'Icinga:Bar'
        $step1b

        $step1b = Stop-RPTestItem -TestItem $step1b -Status 'Failed' -PassThru
        $step1b

    $test1 = Stop-RPTestItem -TestItem $test1 -PassThru
    $test1

    $test2 = Start-RPTestItem -Launch $launch -Parent $suite -Type 'Test' -Name 'Test 2' -Attribute 'Icinga:Foo'
    $test2

        $step2a = Start-RPTestItem -Launch $launch -Parent $test2 -Type 'Step' -Name 'Step 2a' -Attribute 'Icinga:Foo'
        $step2a

        $step2a = Stop-RPTestItem -TestItem $step2a -Status 'Skipped' -PassThru
        $step2a

        $step2b = Start-RPTestItem -Launch $launch -Parent $test2 -Type 'Step' -Name 'Step 2b' -Attribute 'Icinga:Foo'
        $step2b

        $step2b = Stop-RPTestItem -TestItem $step2b -Status 'Interrupted' -PassThru
        $step2b

    $test2 = Stop-RPTestItem -TestItem $test2 -PassThru
    $test2

$suite = Stop-RPTestItem -TestItem $suite -PassThru
$suite

$launch = Stop-RPLaunch -Launch $launch -PassThru
$launch | ft

Read-Host 'Cleanup'

Remove-RPLaunch -Launch $launch

Disconnect-RPServer -Verbose

return





#$service

#$launch1 = Start-RPLaunch -Name 'Demo1' -Description 'My Demo Launch 1' -Tags 'MyLaunchTag'
#$launch2 = Start-RPLaunch -Name 'Demo2' -Description 'My Demo Launch 2' -Tags 'MyLaunchTag'

#$launch1 | ft
#$launch2 | ft

#Get-RPLaunch -Name $launch1.Name | Select-Object -Last 1
#Get-RPLaunch -Uuid $launch2.Uuid


#Stop-RPLaunch -Uuid $launch1.Uuid
#Stop-RPLaunch -Launch $launch2


