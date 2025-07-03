# -----------------------------------------------------
# Fish Configuration
# -----------------------------------------------------
set fish_greeting ""
# Load modular Fish configuration files
for file in ~/.config/fish/config/*.fish
    if test -f $file
        source $file
    end
end
