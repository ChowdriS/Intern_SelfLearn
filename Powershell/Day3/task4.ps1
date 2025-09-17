$service = "Spooler"

$status = & launchctl list | Where-Object { $_ -match $service }

if ($status) {
    Write-Host "Print Spooler service is RUNNING"
} else {
    Write-Host "Print Spooler service is NOT running. Restarting..."
    & launchctl stop $service
    & launchctl start $service
    Write-Host "Print Spooler service restarted."
}
