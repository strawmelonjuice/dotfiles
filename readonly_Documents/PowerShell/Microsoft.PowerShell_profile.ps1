# Check powershell version
if (!$PSVersionTable.PSVersion.toString().startsWith("7"))
{
  Write-Host "Powershell version" $PSVersionTable.PSVersion "was detected. Running pwsh instead."
  pwsh
  Write-Host "Exiting Powershell..."
  Stop-Process -Id $PID -Force -PassThru
}

# Initialize Oh My Posh with Starship
[Console]::WriteLine("Initializing Oh My Posh...")
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # Use starship since we have the same config across platforms
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Invoke-Expression (&starship init powershell)
    } else {
        Write-Host "Installing Starship..."
        winget install --id Starship.Starship
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
        if (Get-Command starship -ErrorAction SilentlyContinue) {
            Invoke-Expression (&starship init powershell)
        }
    }
} else {
    Write-Host "Installing Oh My Posh..."
    winget install JanDeDobbeleer.OhMyPosh -s winget
    # Refresh PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
    
    # Install starship as well
    if (-not(Get-Command starship -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Starship..."
        winget install --id Starship.Starship
        # Refresh PATH again
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
    }
    
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Invoke-Expression (&starship init powershell)
    }
}

# -----------------------------------------------------
# POWERSHELL AUTOCOMPLETION SETUP
# -----------------------------------------------------

[Console]::WriteLine("Setting up PowerShell autocompletion...")

# Enhanced completion options
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -BellStyle None

# Key bindings for better completion experience
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Shift+Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+f -Function ForwardWord

# Enable menu navigation with Tab/Shift+Tab
Set-PSReadLineOption -ShowToolTips

# Install and import CompletionPredictor module for enhanced completions
if (-not(Get-Module -ListAvailable -Name CompletionPredictor)) {
    Write-Host "Installing CompletionPredictor module..."
    Install-Module -Name CompletionPredictor -Scope CurrentUser -Force -AllowClobber
}
Import-Module CompletionPredictor

# Install and configure Terminal-Icons for better file listings
if (-not(Get-Module -ListAvailable -Name Terminal-Icons)) {
    Write-Host "Installing Terminal-Icons module..."
    Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -AllowClobber
}
Import-Module Terminal-Icons

# Install PSFzf for fuzzy finding (similar to oh-my-zsh functionality)
if (-not(Get-Module -ListAvailable -Name PSFzf)) {
    Write-Host "Installing PSFzf module..."
    Install-Module -Name PSFzf -Scope CurrentUser -Force -AllowClobber
}
Import-Module PSFzf

# Set up PSFzf key bindings
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'

# Enhanced completion styling
$PSReadLineOptions = @{
    Colors = @{
        Command = 'Green'
        Parameter = 'Gray'
        Operator = 'Magenta'
        Variable = 'Yellow'
        String = 'Blue'
        Number = 'DarkCyan'
        Type = 'Cyan'
        Comment = 'DarkGreen'
    }
}

# Initialise mise
[Console]::WriteLine("Initialising mise-en-place...")
(&mise activate pwsh) | Out-String | Invoke-Expression

# Add Bun to PATH if it exists
$BunPath = "$env:USERPROFILE\.bun\bin"
if (Test-Path $BunPath) {
    if ($env:PATH -notlike "*$BunPath*") {
        $env:PATH = "$BunPath;$env:PATH"
    }
}

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
New-Alias zellij 'wsl SHELL="pwsh.exe" zellij'
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
    eza --icons -L 2 -R --tree --git-ignore
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
    eza --icons -L 2 -R --tree --git-ignore
    git status
  }
}
New-Alias cd banger -Option AllScope -Force
New-Alias cdi bangeri -Option AllScope -Force

if (-not(Get-Command hyfetch -ErrorAction SilentlyContinue)) {
 python -m pip install wheel
 python -m pip install -U pipx
}

# Initialize Bitwarden session
[Console]::WriteLine("Initializing Bitwarden...")
if (Test-Path "$PSScriptRoot\Bitwarden-Helper.ps1") {
    . "$PSScriptRoot\Bitwarden-Helper.ps1" init
    
    # Create convenient aliases for Bitwarden
    function bw-get { 
        param([string]$Item, [string]$Field = "password")
        . "$PSScriptRoot\Bitwarden-Helper.ps1" get $Item $Field
    }
    function bw-unlock { . "$PSScriptRoot\Bitwarden-Helper.ps1" unlock }
    function bw-status { . "$PSScriptRoot\Bitwarden-Helper.ps1" status }
    function bw-setup { . "$PSScriptRoot\Bitwarden-Helper.ps1" setup-password }
}

hyfetch

