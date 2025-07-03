# -----------------------------------------------------
# Bitwarden Shell Functions
# -----------------------------------------------------

# Convenient wrapper functions for Bitwarden CLI
if type -q bw
    # Path to the bitwarden helper script
    set BW_HELPER "$HOME/shellscripts/bitwarden_helper.sh"

    # Quick Bitwarden functions
    function bw-get
        if test -f "$BW_HELPER"
            "$BW_HELPER" get $argv
        else
            echo (bw get item $argv[1] 2>/dev/null | jq -r '.login.password // .notes // "Not found"')
        end
    end

    function bw-login
        if test -f "$BW_HELPER"
            "$BW_HELPER" login
        else
            bw login
        end
    end

    function bw-unlock
        if test -f "$BW_HELPER"
            "$BW_HELPER" unlock
        else
            set -x BW_SESSION (bw unlock --raw)
        end
    end

    function bw-status
        if test -f "$BW_HELPER"
            "$BW_HELPER" status
        else
            bw status
        end
    end

    # Copy secret to clipboard (requires xclip/pbcopy)
    function bw-copy
        set secret (bw-get $argv[1])
        if test "$secret" != "Not found" -a "$secret" != "BW_NOT_AVAILABLE"
            if type -q xclip
                echo "$secret" | xclip -selection clipboard
                echo "Secret copied to clipboard"
            else if type -q pbcopy
                echo "$secret" | pbcopy
                echo "Secret copied to clipboard"
            else
                echo "Clipboard utility not available. Secret: $secret"
            end
        else
            echo "Secret not found: $argv[1]"
        end
    end

    # Generate and copy a random password
    function bw-generate
        set length (or $argv[1] 20)
        if type -q bw
            set password (bw generate --length "$length")
            if type -q xclip
                echo "$password" | xclip -selection clipboard
                echo "Generated password copied to clipboard"
            else if type -q pbcopy
                echo "$password" | pbcopy
                echo "Generated password copied to clipboard"
            else
                echo "Generated password: $password"
            end
        end
    end
end