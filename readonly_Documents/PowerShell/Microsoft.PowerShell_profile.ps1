# Check powershell version
if (!$PSVersionTable.PSVersion.toString().startsWith("7"))
{
  Write-Host "Powershell version" $PSVersionTable.PSVersion "was detected. Running pwsh instead."
  pwsh
  Write-Host "Exiting Powershell..."
  Stop-Process -Id $PID -Force -PassThru
}

# Initialise mise
[Console]::WriteLine("Initialising mise-en-place...")
(&mise activate pwsh) | Out-String | Invoke-Expression

# Define functions
function quit
{ exit
}

function set-link ($target, $link)
{
  New-Item -Path $link -ItemType SymbolicLink -Value $target
}

# Check if Windows
if ($IsWindows)
{
if (-not(Test-Path -path @(($ENV:UserProfile + "\.config\winget-installed-needed")))) {
  # Checking installed packages
  [Console]::WriteLine("Checking installed packages...")
  $packages = @(
    "twpayne.chezmoi",
    "StartIsBack.StartAllBack",
    "Git.Git",
    "HermannSchinagl.LinkShellExtension",
    "Microsoft.DotNet.Runtime.8",
    "Microsoft.DotNet.AspNetCore.8",
    "Microsoft.DotNet.DesktopRuntime.8",
    "Microsoft.DotNet.SDK.8",
    "Microsoft.NuGet",
    "Kitware.CMake"
  )
  $packages | ForEach-Object {
    winget list -q $_ | Out-Null
    if ($?)
    {
      # [Console]::WriteLine("$_ installed")
    } else
    {
     [Console]::WriteLine( "Package $_ not found. Installing...")
      winget install $_
    }
  }
  [Console]::WriteLine("All packages installed. To retrigger this check, run `resetwingetstatus`.")
  New-Item -Path @(($ENV:UserProfile + "\.config\winget-installed-needed"))
}
function dwingetinstalledneeded {
  Remove-Item -Path @(($ENV:UserProfile + "\.config\winget-installed-needed"))
  }
  new-alias resetwingetstatus dwingetinstalledneeded
  # Create symbolic links
  [Console]::WriteLine("Creating symbolic links...")
  $symlinks = @(
    @(($ENV:UserProfile + "\.config\nvim"), ($ENV:LocalAppdata + "\nvim")),
    @(($ENV:UserProfile + "\.config\alacritty"), ($ENV:Appdata + "\Alacritty")),
    @(($ENV:UserProfile + "\.config\zed"), ($ENV:Appdata + "\Zed"))
  )
  foreach ($link in $symlinks)
  {
    if (Test-Path -Path $link[1])
    {
    } else
    {
      set-link $link[0] $link[1]
    }
  }
}
[Console]::WriteLine( "Defining aliases...")
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
[Console]::WriteLine( "Loading Zoxide...")
Invoke-Expression (& { (zoxide init powershell --cmd bang | Out-String) })
function banger() {
if($args.Count -eq 0) {
    bang
} else {
  bang $args[0]
  }
  if (Test-Path -path  "./.git") {
    clear
    git fetch
    kc
    eza --icons -L 2 -R
    git status
  }
}
function bangeri() {
if($args.Count -eq 0) {
    bangi
} else {
  bangi $args[0]
  }
  if (Test-Path -path  "./.git") {
    clear
    git fetch
    kc
    eza --icons -L 2 -R
    git status
  }
}
if (test-path alias:cd) {
   Remove-Item alias:cd
}
new-alias cd banger
new-alias cdi bangeri
new-alias hyfetch C:\Users\mlcbl\AppData\Local\mise\installs\python\3.13.2\Scripts\hyfetch.exe
if (-not(Get-Command hyfetch -ErrorAction SilentlyContinue)) {
 python -m pip install wheel
 python -m pip install -U pipx
}
hyfetch

