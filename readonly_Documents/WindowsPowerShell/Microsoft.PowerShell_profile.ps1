Invoke-Expression (& { (zoxide init powershell | Out-String) })
Remove-Item alias:cd
new-alias cd z
echo "Zoxide loaded."

