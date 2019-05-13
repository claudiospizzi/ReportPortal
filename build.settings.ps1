
Properties {

    $ModuleNames    = 'ReportPortal'
    $ModuleMerge    = $true

    $GalleryEnabled = $true
    $GalleryKey     = Get-VaultSecureString -TargetName 'PowerShell Gallery Key (claudiospizzi)'

    $GitHubEnabled  = $true
    $GitHubRepoName = 'claudiospizzi/ReportPortal'
    $GitHubToken    = Get-VaultSecureString -TargetName 'GitHub Token (claudiospizzi)'
}