[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/ReportPortal?label=PowerShell%20Gallery&logo=PowerShell)](https://www.powershellgallery.com/packages/ReportPortal)
[![Gallery Downloads](https://img.shields.io/powershellgallery/dt/ReportPortal?label=Downloads&logo=PowerShell)](https://www.powershellgallery.com/packages/ReportPortal)
[![GitHub Release](https://img.shields.io/github/v/release/claudiospizzi/ReportPortal?label=Release&logo=GitHub&sort=semver)](https://github.com/claudiospizzi/ReportPortal/releases)
[![GitHub CI Build](https://img.shields.io/github/actions/workflow/status/claudiospizzi/ReportPortal/ci.yml?label=CI%20Build&logo=GitHub)](https://github.com/claudiospizzi/ReportPortal/actions/workflows/ci.yml)

# ReportPortal PowerShell Module

PowerShell module to interact with the [Report Portal](https://reportportal.io/).

## Introduction

With this module, a test execution can be uploaded to the Report Portal. The
module is tested against Report Portal version 5. The module supports creating
launches, tests items (suites, tests, steps) and test logs.

The following example shows a whole test run, of course without proper error
handling. But it is recommended to put the *Stop-* cmdlet into the finally
block, so that the started launches and items always will be stopped at the end.

```powershell
Connect-RPServer -Url 'https://reportportal' -ProjectName 'MyProject' -Credential 'myuser'

try
{
    $launch = Start-RPLaunch -Name 'Demo' -Attribute 'Foo:Bar', 'Hello:World'

    try
    {
        $suite = Start-RPTestItem -Launch $launch -Type 'Suite' -Name 'Suite 1'

        try
        {
            $test = Start-RPTestItem -Launch $launch -Parent $suite -Type 'Test' -Name 'Test 1'

            try
            {
                $step = Start-RPTestItem -Launch $launch -Parent $test -Type 'Step' -Name 'Step 1'

                Add-RPLog -TestItem $step -Level 'Info' -Message 'My Info Message'
                Add-RPLog -TestItem $step -Level 'Error' -Message 'My Error Message'
            }
            finally
            {
                Stop-RPTestItem -TestItem $step
            }
        }
        finally
        {
            Stop-RPTestItem -TestItem $test
        }
    }
    finally
    {
        Stop-RPTestItem -TestItem $suite
    }
}
finally
{
    Stop-RPLaunch -Launch $launch
}
```

## Features

* **Connect-RPServer**  
  Connect to the report portal server.

* **Disconnect-RPServer**  
  Disconnect from the report portal server.

* **Get-RPLaunch**  
  Get a specific report portal launch.

* **Start-RPLaunch**  
  Start a new report portal launch.

* **Stop-RPLaunch**  
  Finish a previously started report portal launch.

* **Remove-RPLaunch**  
  Remove a previously finished report portal launch.

* **Get-RPTestItem**  
  Get a test item by id.

* **Start-RPTestItem**  
  Start a new report portal test item.

* **Stop-RPTestItem**  
  Finish an existing report portal test item.

* **Add-RPLog**  
  Add a log entry to the test item.

## Versions

Please find all versions in the [GitHub Releases] section and the release notes
in the [CHANGELOG.md] file.

## Installation

Use the following command to install the module from the [PowerShell Gallery],
if the PackageManagement and PowerShellGet modules are available:

```powershell
# Download and install the module
Install-Module -Name 'ReportPortal'
```

Alternatively, download the latest release from GitHub and install the module
manually on your local system:

1. Download the latest release from GitHub as a ZIP file: [GitHub Releases]
2. Extract the module and install it: [Installing a PowerShell Module]

## Requirements

The following minimum requirements are necessary to use this module, or in other
words are used to test this module:

* Windows PowerShell 5.1
* Windows Server 2016 / Windows 10

## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code] with the [PowerShell Extension]
* [Pester], [PSScriptAnalyzer], [InvokeBuild] and [InvokeBuildHelper] modules

[PowerShell Gallery]: https://www.powershellgallery.com/packages/InvokeBuildHelper
[GitHub Releases]: https://github.com/claudiospizzi/PSInvokeBuildHelper/releases
[Installing a PowerShell Module]: https://msdn.microsoft.com/en-us/library/dd878350

[CHANGELOG.md]: CHANGELOG.md

[Visual Studio Code]: https://code.visualstudio.com/
[PowerShell Extension]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell
[Pester]: https://www.powershellgallery.com/packages/Pester
[PSScriptAnalyzer]: https://www.powershellgallery.com/packages/PSScriptAnalyzer
[InvokeBuild]: https://www.powershellgallery.com/packages/InvokeBuild
[InvokeBuildHelper]: https://www.powershellgallery.com/packages/InvokeBuildHelper
