#!/bin/bash
# Posh + Starship Installation Script
# This script helps transition from oh-my-zsh to posh while keeping starship

echo "🚀 Transitioning to Oh My Posh + Starship setup..."

# Install Oh My Posh if not already installed
if ! command -v oh-my-posh &> /dev/null; then
    echo "📦 Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
    export PATH=$PATH:$HOME/.local/bin
else
    echo "✅ Oh My Posh already installed"
fi

# Install Starship if not already installed
if ! command -v starship &> /dev/null; then
    echo "🌟 Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh
else
    echo "✅ Starship already installed"
fi

# Install zsh-autosuggestions if not present (replacing oh-my-zsh plugin)
ZSH_AUTOSUGGESTIONS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$ZSH_AUTOSUGGESTIONS_DIR" ] && [ ! -d "/usr/share/zsh-autosuggestions" ]; then
    echo "🔧 Installing zsh-autosuggestions..."
    
    # Try package manager first
    if command -v apt &> /dev/null; then
        sudo apt install zsh-autosuggestions -y
    elif command -v pacman &> /dev/null; then
        sudo pacman -S zsh-autosuggestions --noconfirm
    elif command -v dnf &> /dev/null; then
        sudo dnf install zsh-autosuggestions -y
    else
        # Fallback to manual installation
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
        echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
    fi
else
    echo "✅ zsh-autosuggestions already available"
fi

# Install zsh-syntax-highlighting for better highlighting
if [ ! -d "/usr/share/zsh-syntax-highlighting" ] && [ ! -d ~/.zsh/zsh-syntax-highlighting ]; then
    echo "🎨 Installing zsh-syntax-highlighting..."
    
    # Try package manager first
    if command -v apt &> /dev/null; then
        sudo apt install zsh-syntax-highlighting -y
    elif command -v pacman &> /dev/null; then
        sudo pacman -S zsh-syntax-highlighting --noconfirm
    elif command -v dnf &> /dev/null; then
        sudo dnf install zsh-syntax-highlighting -y
    else
        # Fallback to manual installation
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
        echo "source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
    fi
else
    echo "✅ zsh-syntax-highlighting already available"
fi

echo ""
echo "✨ Installation complete!"
echo ""
echo "🎯 What's changed:"
echo "   • Removed oh-my-zsh theme (keeping plugins functionality)"
echo "   • Added Oh My Posh for cross-platform prompt management"
echo "   • Enabled Starship prompt (your beautiful config is preserved!)"
echo "   • Enhanced zsh options for better experience"
echo "   • Added manual git aliases and utilities"
echo ""
echo "🔄 To apply changes:"
echo "   • Run: chezmoi apply"
echo "   • Restart your terminal or run: source ~/.zshrc"
echo ""
echo "🪟 For Windows PowerShell:"
echo "   • Oh My Posh and Starship will auto-install on first run"
echo "   • Same starship config will be used across all platforms"
echo ""
echo "🗑️  Optional cleanup:"
echo "   • You can remove oh-my-zsh directory if you're happy with the new setup:"
echo "   • rm -rf ~/.oh-my-zsh"
echo ""
echo "Happy shell-ing! 🐚✨"
