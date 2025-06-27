#!/bin/bash

# Install.sh gets ran by github codespaces automatically

# Bootstrap the dotfiles repository and if successful, run the smart install script.

curl -fsSL https://raw.githubusercontent.com/strawmelonjuice/dotfiles/main/bootstrap.sh | bash && 
bash "$HOME/.local/share/chezmoi/shellscripts/executable_smart_install.sh" --use-bitwarden --use-mise --use-chezmoi

