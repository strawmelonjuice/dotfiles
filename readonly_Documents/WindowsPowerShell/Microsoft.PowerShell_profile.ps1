# Zoxide

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item alias:cd
new-alias cd z
echo "Zoxide loaded."

# Other aliases
new-alias q exit
new-alias qa exit
new-alias cls clear
