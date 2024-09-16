# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item alias:cd
new-alias cd z
echo "Zoxide loaded."

# Other aliases
Remove-Item alias:cls
new-alias cls clear

# Exit aliases
function ex{exit}
new-alias q ex
new-alias qa ex

# Loading Starship
Invoke-Expression (&starship init powershell)
echo "Starship loaded."



