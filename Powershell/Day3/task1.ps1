$filePath = "/Users/presidio/Desktop/testfile.txt"

if (Test-Path $filePath) {
    Write-Host "The file exists at $filePath"
} else {
    Write-Host "The file does NOT exist at $filePath"
}
