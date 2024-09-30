function set-link ($target, $link)
{
  New-Item -Path $link -ItemType SymbolicLink -Value $target
}

# Check if Windows
if ($IsWindows)
{
  # Checking installed packages
  write-host "Checking installed packages..."
  $packages = @(
    "LLVM.clangd",
    "zig.zig",
    "zigtools.zls",
    "Oven-sh.Bun",
    "Rustlang.Rustup",
    "ajeetdsouza.zoxide",
    "Starship.Starship",
    "Neovim.Neovim",
    "Fastfetch-cli.Fastfetch",
    "twpayne.chezmoi",
    "Mozilla.Firefox.DeveloperEdition",
    "JetBrains.Toolbox",
    "StartIsBack.StartAllBack",
    "bitwarden.bitwarden",
    "JesseDuffield.lazygit",
    "Git.Git",
    "HermannSchinagl.LinkShellExtension",
    "Valve.Steam",
    "Discord.Discord",
    "Gleam.Gleam",
    "Python.Python.3.12",
    "Anaconda.Anaconda3",
    "junegunn.fzf",
    "GitHub.GitHubDesktop",
    "GitHub.cli",
    "BurntSushi.ripgrep.MSVC"
    , "Microsoft.DotNet.Runtime.8",
    "Microsoft.DotNet.AspNetCore.8",
    "Microsoft.DotNet.DesktopRuntime.8",
    "Microsoft.DotNet.SDK.8",
    "Microsoft.NuGet"
  )
  $packages | ForEach-Object {
    winget list -q $_ | Out-Null
    if ($?)
    {
      # Write-Host "$_ installed"
    } else
    {
      Write-Host "Package $_ not found. Installing..."
      winget install $_
    }
  }
  write-host "All packages installed."

  # Create symbolic links
  Write-Host "Creating symbolic links..."
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
      make-link $link[0] $link[1]
    }
  }
}

