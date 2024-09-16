Write-Host "Powershell version" $PSVersionTable.PSVersion "was detected. Running pwsh instead."
pwsh
Write-Host "Exiting Powershell..."
Stop-Process -Id $PID -Force -PassThru
