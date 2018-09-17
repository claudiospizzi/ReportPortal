
Properties {

    $ModuleNames = 'ReportPortal'

    $SourceNames = 'ReportPortal'

    $GalleryEnabled = $true
    $GalleryKey     = Get-VaultSecureString -TargetName 'PS-SecureString-GalleryKey'

    $GitHubEnabled  = $true
    $GitHubRepoName = 'claudiospizzi/ReportPortal'
    $GitHubToken    = Get-VaultSecureString -TargetName 'PS-SecureString-GitHubToken'
}
