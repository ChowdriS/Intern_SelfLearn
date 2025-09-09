New-Item -Path . -Name "Log1" -ItemType Directory
Set-Location .\Log1

ps | Out-File ./services.csv

Write-Host "Log file created with Services information."
