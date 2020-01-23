<#
    .SYNOPSIS
        Start a new report portal test item.

    .DESCRIPTION
        ..
#>
function Start-RPTestItem
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        # The report portal service.
        [Parameter(Mandatory = $false)]
        [PSTypeName('ReportPortal.Session')]
        $Session,

        # The report portal launch.
        [Parameter(Mandatory = $true)]
        [PSTypeName('ReportPortal.Launch')]
        $Launch,

        # The parent test item, can be null for root elements.
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [PSTypeName('ReportPortal.TestItem')]
        $Parent,

        # Test item type.
        [Parameter(Mandatory = $true)]
        [ValidateSet('Suite', 'Test', 'Step')]
        [System.String]
        $Type,

        # Test item name.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        # Test item start time.
        [Parameter(Mandatory = $false)]
        [System.DateTime]
        $StartTime = (Get-Date),

        # The test item attributes.
        [Parameter(Mandatory = $false)]
        [System.String[]]
        $Attribute
    )

    $Session = Test-RPSession -Session $Session

    Write-Verbose ('Start a report portal test item with name {0} and type {1}' -f $Name, $Type.ToLower())

    $testItemStartRequest = [PSCustomObject] @{
        name        = $Name
        launchUuid  = $Launch.Guid
        type        = $Type.ToUpper()
        startTime   = ConvertTo-ReportPortalDateTime -DateTime $StartTime
        attributes  = @(ConvertTo-ReportPortalAttribute -Attribute $Attribute)
    }

    $path = 'item'
    if ($PSBoundParameters.ContainsKey('Parent'))
    {
        $path = 'item/{0}' -f $Parent.Guid
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Start Test Item'))
    {
        $testItemStartResult = Invoke-RPRequest -Session $Session -Method 'Post' -Path $path -Body $testItemStartRequest -ErrorAction 'Stop'

        Get-RPTestItem -Session $Session -Id $testItemStartResult.id
    }



#     "codeRef": "string",
#     "hasStats": true,
#     "parameters": [
#       {
#         "key": "string",
#         "value": "string"
#       }
#     ],
#     "retry": true,
#     "testCaseHash": 0,
#     "testCaseId": "string",
#     "uniqueId": "string"
#   }




    #     # Test item description.
    #     [Parameter(Mandatory = $false)]
    #     [System.String]
    #     $Description,

    #     # Test item start time.
    #     [Parameter(Mandatory = $false)]
    #     [System.DateTime]
    #     $StartTime = (Get-Date),

    #     # Test item tags.
    #     [Parameter(Mandatory = $false)]
    #     [System.String[]]
    #     $Tags
    # )

    # try
    # {
    #     $model = [ReportPortal.Client.Requests.StartTestItemRequest]::new()
    #     $model.LaunchId    = $Launch.Uuid
    #     $model.Name        = $Name
    #     $model.Type        = $Type
    #     $model.Description = $Description
    #     $model.StartTime   = $StartTime.ToUniversalTime()
    #     $model.Tags        = $Tags

    #     if ($PSCmdlet.ShouldProcess($null, 'Start Test Item'))
    #     {
    #         if ($null -eq $Parent)
    #         {
    #             $testItem = $Service.StartTestItemAsync($model).GetAwaiter().GetResult()
    #         }
    #         else
    #         {
    #             $testItem = $Service.StartTestItemAsync($Parent.Id, $model).GetAwaiter().GetResult()
    #         }

    #         Get-RPTestItem -Service $Service -Id $testItem.Id
    #     }
    # }
    # catch
    # {
    #     ConvertFrom-RPException -ErrorRecord $_ | Write-Error
    # }
}




#   {
#     "attributes": [
#       {
#         "key": "string",
#         "system": true,
#         "value": "string"
#       }
#     ],
#     "codeRef": "string",
#     "description": "string",
#     "hasStats": true,
#     "launchUuid": "string",
#     "name": "string",
#     "parameters": [
#       {
#         "key": "string",
#         "value": "string"
#       }
#     ],
#     "retry": true,
#     "startTime": "2020-01-22T23:20:35.401Z",
#     "testCaseHash": 0,
#     "testCaseId": "string",
#     "type": "SUITE",
#     "uniqueId": "string"
#   }
#   P