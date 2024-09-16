# Check powershell version
if (!$PSVersionTable.PSVersion.toString().startsWith("7")) {
clear
    Write-Host "Powershell version $PSVersionTable.PSVersion was detected. Running pwsh instead."
    pwsh
    exit
}

# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item alias:cd
new-alias cd z
echo "Zoxide loaded."

# Other aliases
Remove-Item alias:cls
new-alias cls clear

Remove-Item alias:q
new-alias q exit

Remove-Item alias:qa
new-alias qa exit
