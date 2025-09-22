# -----------------------------------------------------
# Customization
# -----------------------------------------------------

# Initialize Starship prompt
starship init fish | source

# Enhanced completion options
# Fish handles completions differently, so no direct translation is needed.

# Directory navigation aliases
alias .. 'cd ..'
alias ... 'cd ../..'
alias .... 'cd ../../..'
alias ..... 'cd ../../../..'

# -----------------------------------------------------
# Clipboard utilities
# -----------------------------------------------------
if type -q xclip
    alias pbcopy 'xclip -selection clipboard'
    alias pbpaste 'xclip -selection clipboard -o'
else if type -q xsel
    alias pbcopy 'xsel --clipboard --input'
    alias pbpaste 'xsel --clipboard --output'
else if type -q wl-copy
    alias pbcopy 'wl-copy'
    alias pbpaste 'wl-paste'
end

function copyfile
    if test -f $argv[1]
        cat $argv[1] | pbcopy
        echo "File $argv[1] copied to clipboard"
    else
        echo "File $argv[1] not found"
    end
end

function copybuffer
    echo $argv | pbcopy
    echo "Command line copied to clipboard"
end
