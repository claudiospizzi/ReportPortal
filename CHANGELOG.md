# Changelog

All notable changes to this project will be documented in this file.

The format is mainly based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 1.9.0 - 2021-11-24

* Added: Report step description now parses cmdlet-based help keywords

## 1.8.0 - 2021-11-23

* Added: Option to skip not only steps but also tests
* Fixed: The suppression by test name was not working with test cases

## 1.7.1 - 2020-11-12

* Fixed: Not showing the test step description if test cases are used

## 1.7.0 - 2020-11-11

* Added: Info log entry with the test step description

## 1.6.1 - 2020-10-14

* Added: Add suppression parsing for Pester-only mode of a report portal launch

## 1.6.0 - 2020-09-02

* Added: Option to use an existing suite object in the suite command

## 1.5.2 - 2020-05-07

* Fixed: Remove the Hide parameter for the second Pester It call too

## 1.5.1 - 2020-04-28

* Fixed: Remove the Hide parameter if we pass it to the Pester test in the Step

## 1.5.0 - 2020-04-23

* Added: Option to completely skip (hide) a test step
* Added: Option to get all launches, not only one
* Added: Paging option to Invoke-RPRequest

## 1.4.0 - 2020-02-25

* Added: New command Get-RPFilter to get filters
* Fixed: Exit DSL function after invoke Pester when no launch is used

## 1.3.1 - 2020-02-24

* Fixed: When using a launch object, the Describe name was empty

## 1.3.0 - 2020-02-24

* Added: Return attributes in Get-RPTestItem
* Changed: Optimize tag handling for test steps, include parent tags
* Fixed: Allow empty attribute collection for Start-RPTestItem
* Fixed: Error message was not displayed for internal errors

## 1.2.0 - 2020-02-20

* Added: Launch, Suite, Test and Step blocks for the report portal DSL
* Added: Option to invoke generic requests with Invoke-RPRequest

## 1.1.0 - 2020-01-28

* Added: Stop launch with different status than success
* Added: Add the option to log on a launch
* Added: Add function Add-RPTestItemStep

## 1.0.0 - 2020-01-24

* Added: Compatibility with ReportPortal v5
* Changed: Remove ReportPortal.Client.dll and use REST calls

## 0.1.1 - 2019-05-13

* Fixed: Wrong module loader function

## 0.1.0 - 2019-05-13

* Added: Initial release
