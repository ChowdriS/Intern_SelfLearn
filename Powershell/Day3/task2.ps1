$services = @(
    "com.apple.coreservicesd",
    "com.apple.blued",
    "com.apple.Dock"
)

foreach ($svc in $services) {
    $running = launchctl list | ForEach-Object { $_ } | Where-Object { $_ -like "*$svc*" }

    if ($running) {
        Write-Host "Service '$svc' is RUNNING"
    } else {
        Write-Host "Service '$svc' is NOT running"
    }
}
