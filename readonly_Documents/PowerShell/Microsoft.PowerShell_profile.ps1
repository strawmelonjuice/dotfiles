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
@(($ENV:UserProfile + "\.config\helix"), ($ENV:Appdata + "\helix")),
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
      set-link $link[0] $link[1]     }
  }
}
[Console]::WriteLine( "Defining aliases...")
New-Alias cls clear -Option AllScope -Force
New-Alias c clear -Option AllScope -Force
New-Alias q quit -Option AllScope -Force
New-Alias qa quit -Option AllScope -Force
New-Alias hyfetch "C:\Users\mlcbl\AppData\Local\mise\installs\python\3.13.2\Scripts\hyfetch.exe" -Option AllScope -Force
New-Alias nf hyfetch -Option AllScope -Force
New-Alias pf hyfetch -Option AllScope -Force
New-Alias ff fastfetch -Option AllScope -Force
New-Alias hf hyfetch -Option AllScope -Force
New-Alias cat bat -Option AllScope -Force
function els { eza --icons ${args} }
New-Alias ls els -Option AllScope -Force
function ela { eza -l --icons ${args} }
New-Alias la ela -Option AllScope -Force
function ell { eza -al --icon ${args} }
New-Alias ll ell -Option AllScope -Force
function elt { eza -a --tree --level=1 --icons ${args} }
New-Alias lt elt -Option AllScope -Force
function shutdownnow { shutdown /s /t 0 }
New-Alias shutdown shutdownnow -Option AllScope -Force
function rebootnow { shutdown /r /t 0 }
New-Alias reboot rebootnow -Option AllScope -Force
function cargocleanall { cargo-clean-all --keep-days 21 ~ -i ${args} }
New-Alias cargock cargocleanall -Option AllScope -Force


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
    [Console]::WriteLine("Opened git repository: " + $pwd)
    git fetch
    kc
    eza --icons -L 2 -R --tree
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
    [Console]::WriteLine("Opened git repository: " + $pwd)
    git fetch
    kc
    eza --icons -L 2 -R --tree
    git status
  }
}
New-Alias cd banger -Option AllScope -Force
New-Alias cdi bangeri -Option AllScope -Force

if (-not(Get-Command hyfetch -ErrorAction SilentlyContinue)) {
 python -m pip install wheel
 python -m pip install -U pipx
}
hyfetch

