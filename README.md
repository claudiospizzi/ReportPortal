[![PowerShell Gallery - ReportPortal](https://img.shields.io/badge/PowerShell_Gallery-ReportPortal-0072C6.svg)](https://www.powershellgallery.com/packages/ReportPortal)
[![GitHub - Release](https://img.shields.io/github/release/claudiospizzi/ReportPortal.svg)](https://github.com/claudiospizzi/ReportPortal/releases)
[![AppVeyor - master](https://img.shields.io/appveyor/ci/claudiospizzi/ReportPortal/master.svg)](https://ci.appveyor.com/project/claudiospizzi/ReportPortal/branch/master)

# ReportPortal PowerShell Module

PowerShell module to interact with the [Report Portal].

## Introduction

With this module, a test execution can be uploaded to the Report Portal. The
module is tested against Report Portal version 3. The module supports creating
launches, tests and test steps.

The following example shows a whole test run, of course without proper error
handling. But it is recommended to put the *Stop-* cmdlet into the finally
block, so that the started launches and items always will be stopped at the end.

```powershell
$service = Connect-RPServer -ComputerName 'reportportal' -Port 8080 -ProjectName 'My Project' -UserId '1a9e5a43-3f84-4752-ba50-b8aa9e3f67fd'

try
{
    $launch = Start-RPLaunch -Service $service -Name 'My Launch'

    try
    {
        $suite = Start-RPTestItem -Service $service -Launch $launch -Name 'My Suite' -Type Suite

        try
        {
            $test = Start-RPTestItem -Service $service -Launch $launch -Parent $suite -Name 'My Test' -Type Test

            try
            {
                $step = Start-RPTestItem -Service $service -Launch $launch -Parent $test -Name 'My Step' -Type Step
            }
            finally
            {
                Stop-RPTestItem -Service $service -TestItem $step
            }
        }
        finally
        {
            Stop-RPTestItem -Service $service -TestItem $test
        }
    }
    finally
    {
        Stop-RPTestItem -Service $service -TestItem $suite
    }
}
finally
{
    Stop-RPLaunch -Service $service -Launch $launch
}
```

## Features

* **Connect-RPServer**  
  Connect to the report portal service. It will return the service object.

* **Get-RPLaunch**  
  Get all report portal launches.

* **Start-RPLaunch**  
  Start a new report portal launch.

* **Stop-RPLaunch**  
  Finish a previously started report portal launch.

* **Remove-RPLaunch**  
  Remove an existing report portal launch.

* **Get-RPTestItem**  
  Get all test items.

* **Start-RPTestItem**  
  Start a new report portal test item.

* **Stop-RPTestItem**  
  Finish an existing report portal test item.

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
* [Pester], [PSScriptAnalyzer] and [psake] PowerShell Modules

[PowerShell Gallery]: https://www.powershellgallery.com/packages/ReportPortal
[GitHub Releases]: https://github.com/claudiospizzi/ReportPortal/releases
[Installing a PowerShell Module]: https://msdn.microsoft.com/en-us/library/dd878350

[CHANGELOG.md]: CHANGELOG.md

[Visual Studio Code]: https://code.visualstudio.com/
[PowerShell Extension]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell
[Pester]: https://www.powershellgallery.com/packages/Pester
[PSScriptAnalyzer]: https://www.powershellgallery.com/packages/PSScriptAnalyzer
[psake]: https://www.powershellgallery.com/packages/psake

[Report Portal]: http://reportportal.io/
