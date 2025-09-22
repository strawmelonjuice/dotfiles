# Bitwarden Helper for PowerShell
# This module helps manage Bitwarden CLI integration

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    
    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments = @()
)

# Configuration
$Script:BW_SESSION_FILE = "$env:TEMP\bw-session"
$Script:BW_PASSWORD_FILE = "$env:USERPROFILE\.bitwarden_password"

# Colors for output
function Write-BWLog {
    param([string]$Message)
    Write-Host "[BW] $Message" -ForegroundColor Green
}

function Write-BWWarn {
    param([string]$Message)
    Write-Host "[BW WARN] $Message" -ForegroundColor Yellow
}

function Write-BWError {
    param([string]$Message)
    Write-Host "[BW ERROR] $Message" -ForegroundColor Red
}

# Check if Bitwarden CLI is installed
function Test-BWCli {
    if (-not (Get-Command bw -ErrorAction SilentlyContinue)) {
        Write-BWWarn "Bitwarden CLI not found. Installing..."
        Install-BWCli
    }
}

# Install Bitwarden CLI
function Install-BWCli {
    try {
        # Try Bun first (if available), then package manager, then npm fallback
        if (Get-Command bun -ErrorAction SilentlyContinue) {
            Write-BWLog "Installing Bitwarden CLI via Bun..."
            bun install -g @bitwarden/cli
        } else {
            Write-BWError "Cannot install Bitwarden CLI automatically. Please install manually."
            Write-Host "Visit: https://bitwarden.com/download/" -ForegroundColor Cyan
            return $false
        }
        
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
        return $true
    } catch {
        Write-BWError "Failed to install Bitwarden CLI: $_"
        return $false
    }
}

# Login to Bitwarden
function Invoke-BWLogin {
    $email = $env:BW_EMAIL
    
    if (-not $email) {
        $email = Read-Host "Enter your Bitwarden email"
    }
    
    if ($env:BW_SERVER) {
        bunx --bun bw config server $env:BW_SERVER
    }
    
    Write-BWLog "Logging in to Bitwarden..."
    try {
        bunx --bun bw login $email
        return $true
    } catch {
        Write-BWError "Failed to login to Bitwarden: $_"
        return $false
    }
}

# Unlock Bitwarden and save session
function Invoke-BWUnlock {
    # Try to use password file first (silent for automated operations)
    if (Test-Path $Script:BW_PASSWORD_FILE) {
        try {
            $session = bunx --bun bw unlock --passwordfile $Script:BW_PASSWORD_FILE --raw 2>$null
            if ($session -and $session.Trim() -ne "") {
                # Save session to file for reuse
                $session | Out-File -FilePath $Script:BW_SESSION_FILE -Encoding UTF8 -NoNewline
                $env:BW_SESSION = $session
                return $true
            } else {
                Write-BWWarn "Password file seems invalid, removing it"
                Remove-Item $Script:BW_PASSWORD_FILE -ErrorAction SilentlyContinue
            }
        } catch {
            Write-BWWarn "Password file seems invalid, removing it"
            Remove-Item $Script:BW_PASSWORD_FILE -ErrorAction SilentlyContinue
        }
    }
    
    # Fall back to interactive unlock
    Write-BWLog "Unlocking Bitwarden vault..."
    $password = Read-Host "Enter your Bitwarden master password" -AsSecureString
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    try {
        $session = echo $passwordText | bunx --bun bw unlock --raw 2>$null
        if ($session -and $session.Trim() -ne "") {
            # Password works, save it for future use
            $passwordText | Out-File -FilePath $Script:BW_PASSWORD_FILE -Encoding UTF8 -NoNewline
            
            # Save session to file for reuse
            $session | Out-File -FilePath $Script:BW_SESSION_FILE -Encoding UTF8 -NoNewline
            $env:BW_SESSION = $session
            
            Write-BWLog "Password saved for future automatic unlocking"
            Write-BWLog "Bitwarden vault unlocked successfully"
            return $true
        } else {
            Write-BWError "Failed to unlock Bitwarden vault - incorrect password"
            return $false
        }
    } catch {
        Write-BWError "Failed to unlock Bitwarden vault: $_"
        return $false
    } finally {
        # Clear password from memory
        $passwordText = $null
        [System.GC]::Collect()
    }
}

# Setup password file for automatic unlocking
function Set-BWPasswordFile {
    if (Test-Path $Script:BW_PASSWORD_FILE) {
        $response = Read-Host "Password file already exists. Replace it? (y/N)"
        if ($response -notmatch "^[Yy]$") {
            Write-BWLog "Password file setup cancelled"
            return $true
        }
    }
    
    $password = Read-Host "Enter your Bitwarden master password" -AsSecureString
    $passwordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    
    try {
        # Test the password
        $session = echo $passwordText | bunx --bun bw unlock --raw 2>$null
        if ($session -and $session.Trim() -ne "") {
            $passwordText | Out-File -FilePath $Script:BW_PASSWORD_FILE -Encoding UTF8 -NoNewline
            
            # Save session for current shell and future use
            $session | Out-File -FilePath $Script:BW_SESSION_FILE -Encoding UTF8 -NoNewline
            $env:BW_SESSION = $session
            
            Write-BWLog "Password file created successfully at $Script:BW_PASSWORD_FILE"
            Write-BWLog "Future operations will use this password automatically"
            Write-BWLog "Session is now active in current shell"
            return $true
        } else {
            Write-BWError "Invalid password. Password file not created."
            return $false
        }
    } catch {
        Write-BWError "Invalid password. Password file not created."
        return $false
    } finally {
        # Clear password from memory
        $passwordText = $null
        [System.GC]::Collect()
    }
}

# Load existing session
function Get-BWSession {
    if (Test-Path $Script:BW_SESSION_FILE) {
        try {
            $sessionToken = Get-Content $Script:BW_SESSION_FILE -Raw
            $sessionToken = $sessionToken.Trim()
            
            # Test if session is still valid using the session token
            $env:BW_SESSION = $sessionToken
            $result = bunx --bun bw list items --length 1 2>$null
            if ($LASTEXITCODE -eq 0) {
                bunx --bun bw sync --session $sessionToken >$null
                return $true
            } else {
                # Session expired, remove the file silently
                Remove-Item $Script:BW_SESSION_FILE -ErrorAction SilentlyContinue
                $env:BW_SESSION = $null
            }
        } catch {
            Remove-Item $Script:BW_SESSION_FILE -ErrorAction SilentlyContinue
            $env:BW_SESSION = $null
        }
    }
    return $false
}

# Get a secret from Bitwarden
function Get-BWSecret {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ItemName,
        
        [string]$Field = "password"
    )
    
    if (-not (Assert-BWSession)) {
        Write-BWError "Cannot access Bitwarden vault"
        return $null
    }
    
    try {
        $items = bunx --bun bw list items --search $ItemName 2>$null | ConvertFrom-Json
        if ($items -and $items.Count -gt 0) {
            $itemId = $items[0].id
            $result = bunx --bun bw get $Field $itemId 2>$null
            if ($LASTEXITCODE -eq 0) {
                return $result
            } else {
                Write-BWError "Failed to get $Field for $ItemName"
                return $null
            }
        } else {
            Write-BWError "Item '$ItemName' not found in Bitwarden vault"
            return $null
        }
    } catch {
        Write-BWError "Failed to search for item '$ItemName': $_"
        return $null
    }
}

# Ensure we have a valid Bitwarden session
function Assert-BWSession {
    # Try to load existing session first
    if (Get-BWSession) {
        return $true
    }
    
    try {
        $status = bunx --bun bw status 2>$null | ConvertFrom-Json
        if ($status.status -eq "unlocked") {
            # Already unlocked, try to get session
            if (-not (Get-BWSession)) {
                return Invoke-BWUnlock
            }
            return $true
        } elseif ($status.status -eq "locked") {
            return Invoke-BWUnlock
        } else {
            # Need to login first
            if (Invoke-BWLogin) {
                return Invoke-BWUnlock
            }
            return $false
        }
    } catch {
        Write-BWError "Failed to check Bitwarden status: $_"
        return $false
    }
}

# Initialize Bitwarden for PowerShell session
function Initialize-BWSession {
    param([bool]$Interactive = $true)
    
    if (-not (Get-Command bw -ErrorAction SilentlyContinue)) {
        return $false
    }
    
    # Check if we have a valid session already
    if (Get-BWSession) {
        return $true
    }
    
    # Check if password file exists
    if (-not (Test-Path $Script:BW_PASSWORD_FILE) -and $Interactive) {
        $response = Read-Host "Bitwarden password file not found. Set up automatic unlock? (y/N)"
        if ($response -match "^[Yy]$") {
            return Set-BWPasswordFile
        } else {
            Write-Host "Skipping Bitwarden setup. You can set it up later with:" -ForegroundColor Cyan
            Write-Host "  . '$PSScriptRoot\Bitwarden-Helper.ps1' setup-password" -ForegroundColor Cyan
            return $false
        }
    }
    
    # Try to unlock with existing password file
    if (Test-Path $Script:BW_PASSWORD_FILE) {
        try {
            $status = bunx --bun bw status 2>$null | ConvertFrom-Json
            if ($status.status -eq "locked") {
                return Invoke-BWUnlock
            }
        } catch {
            # Status check failed, might not be logged in
            return $false
        }
    }
    
    return $false
}

# Main command dispatcher
switch ($Command.ToLower()) {
    "install" {
        Test-BWCli
    }
    "login" {
        Test-BWCli
        Invoke-BWLogin
    }
    "unlock" {
        Test-BWCli
        Invoke-BWUnlock
    }
    "setup-password" {
        Test-BWCli
        Set-BWPasswordFile
    }
    "get" {
        Test-BWCli
        if ($Arguments.Count -gt 0) {
            $field = if ($Arguments.Count -gt 1) { $Arguments[1] } else { "password" }
            Get-BWSecret -ItemName $Arguments[0] -Field $field
        } else {
            Write-BWError "Usage: get <item> [field]"
        }
    }
    "session" {
        Test-BWCli
        Assert-BWSession
    }
    "status" {
        if (Get-Command bw -ErrorAction SilentlyContinue) {
            bunx --bun bw status
        } else {
            Write-Host "Bitwarden CLI not installed"
        }
    }
    "init" {
        Initialize-BWSession -Interactive $true
    }
    "help" {
        Write-Host @"
Bitwarden Helper for PowerShell

Usage: . Bitwarden-Helper.ps1 <command> [arguments]

Commands:
    install         Install Bitwarden CLI
    login          Login to Bitwarden
    unlock         Unlock Bitwarden vault
    setup-password Set up automatic password file for unlocking
    get <item> [field]  Get a secret from Bitwarden
    session        Ensure valid session exists
    status         Show Bitwarden status
    init           Initialize Bitwarden for current session
    help           Show this help

Environment Variables:
    BW_EMAIL       Your Bitwarden email
    BW_SERVER      Custom Bitwarden server URL
    BW_SESSION     Current session token (set automatically)

Password File:
    The script can use ~/.bitwarden_password for automatic unlocking.
    Use 'setup-password' command to create this file securely.

Examples:
    . Bitwarden-Helper.ps1 install
    . Bitwarden-Helper.ps1 login
    . Bitwarden-Helper.ps1 setup-password
    . Bitwarden-Helper.ps1 get "GitHub Token"
    . Bitwarden-Helper.ps1 get "SSH Key" "private_key"

Functions available after sourcing:
    Get-BWSecret "ItemName" ["field"]
    Initialize-BWSession
    Assert-BWSession
"@
    }
    default {
        Write-BWError "Unknown command: $Command"
        Write-Host "Use 'help' to see available commands."
    }
}
