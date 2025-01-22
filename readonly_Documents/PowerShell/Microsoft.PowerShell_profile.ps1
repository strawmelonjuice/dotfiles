# Some features here are commented out because powershell is terribly slow.
# Thank you for coming to my ted talk.

# Check powershell version
if (!$PSVersionTable.PSVersion.toString().startsWith("7"))
{
  Write-Host "Powershell version" $PSVersionTable.PSVersion "was detected. Running pwsh instead."
  pwsh
  Write-Host "Exiting Powershell..."
  Stop-Process -Id $PID -Force -PassThru
}

# Define functions
function quit
{ exit
}function advancedstub
{ 
  . ($ENV:Userprofile + "\Documents\PowerShell\moreadvancedprofile.ps1")
}


## Starship
#Write-Host "Loading Starship..."
#Invoke-Expression (&starship init powershell)

# Aliases
Write-Host "Defining aliases..."
if (test-path alias:cls)
{
  Remove-Item alias:cls
}
new-alias cls clear
if (test-path alias:q)
{
  Remove-Item alias:q
}
new-alias q quit
if (test-path alias:qa)
{
  Remove-Item alias:qa
}
new-alias qa quit
if (test-path alias:stub)
{
  Remove-Item alias:stub
}
new-alias stub advancedstub


# Zoxide
Write-Host "Loading Zoxide..."
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
# if (test-path alias:cd) {
#    Remove-Item alias:cd
# }
# new-alias cd z

#Write-Host "Preparing fastfetch..."
#Write-Host ""

#fastfetch
