# Check powershell version
if (!$PSVersionTable.PSVersion.toString().startsWith("7")) {
    Write-Host "Powershell version" $PSVersionTable.PSVersion "was detected. Running pwsh instead."
    pwsh
    Write-Host "Exiting Powershell..."
    Stop-Process -Id $PID -Force -PassThru
}

# Define functions
function quit { exit }
function make-link ($target, $link) {
    New-Item -Path $link -ItemType SymbolicLink -Value $target
}

# Check if Windows
if ($IsWindows) {
    # Checking installed packages
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
        "Gleam.Gleam"
    	)
    $packages | ForEach-Object {
    winget list -q $_ | Out-Null
    if ($?) {
        # Write-Host "$_ installed"
    } else {
            Write-Host "Package $_ not found. Installing..."
            winget install $_
        }
    }

    # Create symbolic links
    make-link ($ENV:UserProfile + "\.config\nvim") ($ENV:LocalAppdata + "\nvim")

}

# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })
if (test-path alias:cd) {
    Remove-Item alias:cd
}
new-alias cd z
Write-Host "Zoxide loaded."

# Starship
Invoke-Expression (&starship init powershell)
echo "Starship loaded."

# Other aliases

if (test-path alias:cls) {
    Remove-Item alias:cls
}
new-alias cls clear
if (test-path alias:q) {
    Remove-Item alias:q
}
new-alias q quit
if (test-path alias:qa) {
    Remove-Item alias:qa
}
new-alias qa quit

Write-Host ""

fastfetch
