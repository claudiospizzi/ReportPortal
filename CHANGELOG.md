# Changelog

All notable changes to this project will be documented in this file.

The format is mainly based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## Unreleased

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
