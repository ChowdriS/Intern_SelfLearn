$service = "sample service"

try {
    & launchctl stop $service
    Write-Host "Service '$service' stopped successfully."
} catch {
    Write-Host "Failed to stop service '$service'. Error details:"
    Write-Host $_.Exception.Message
}
