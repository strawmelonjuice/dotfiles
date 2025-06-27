# Windows PowerShell profile that redirects to PowerShell 7
Write-Host "Windows PowerShell detected. Launching PowerShell 7 for better experience..."
if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    pwsh
    exit
} else {
    Write-Host "PowerShell 7 not found. Please install it for the best experience."
    Write-Host "You can install it with: winget install Microsoft.PowerShell"
    
    # Basic Oh My Posh setup for Windows PowerShell as fallback
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        if (Get-Command starship -ErrorAction SilentlyContinue) {
            Invoke-Expression (&starship init powershell)
        }
    } else {
        [Console]::WriteLine("Powershell version " + $PSVersionTable.PSVersion + " detected. For PowerShell 7, run pwsh instead.")
    }
}
