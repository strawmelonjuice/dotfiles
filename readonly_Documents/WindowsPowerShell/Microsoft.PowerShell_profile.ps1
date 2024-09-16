
function quit { exit }


# Check powershell version
if (!$PSVersionTable.PSVersion.toString().startsWith("7")) {
    Write-Host "Powershell version" $PSVersionTable.PSVersion "was detected. Running pwsh instead."
    pwsh
    Write-Host "Exiting Powershell..."
    Stop-Process -Id $PID -Force -PassThru
}

# Checking installed packages
$packages = @("ajeetdsouza.zoxide", "Starship.Starship", "Neovim.Neovim", "Fastfetch-cli.Fastfetch")
$packages | ForEach-Object {
winget list -q $_ | Out-Null
if ($?) {
    # Write-Host "$_ installed"
} else {
        Write-Host "Package $_ not found. Installing..."
        winget install $_
    }
}


# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
if (test-path alias:z) {
    Remove-Item alias:z
}
new-alias cd z
Write-Host "Zoxide loaded."

# Other aliases

if (test-path alias:cls) {
    Remove-Item alias:cls
}
new-alias cls clear
if (test-path alias:q) {
    Remove-Item alias:q
}
new-alias q quit
if (test-path alias:qa) {
    Remove-Item alias:qa
}
Remove-Item alias:qa
new-alias qa quit

Write-Host "========================================================"

fastfetch
