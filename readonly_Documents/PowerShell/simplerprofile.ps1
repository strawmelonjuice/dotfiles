# Zoxide
Write-Host "Loading Zoxide..."
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
# if (test-path alias:cd) {
#    Remove-Item alias:cd
# }
# new-alias cd z
