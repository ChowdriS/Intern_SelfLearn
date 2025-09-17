function RestartService {
    param (
        [string]$ServiceName
    )

    launchctl stop $ServiceName

    launchctl start $ServiceName

    Write-Host "Service '$ServiceName' has been restarted."
}

RestartService -ServiceName "com.apple.Dock"
