# -----------------------------------------------------
# Bitwarden Shell Functions
# -----------------------------------------------------

# Convenient wrapper functions for Bitwarden CLI
if type -q bw
    # Quick Bitwarden functions
    function bw-get
        set item_name $argv[1]
        set field (or $argv[2] "password")

        if not bw-ensure-session
            echo "Cannot access Bitwarden vault"
            return 1
        end

        set item_id "$(bw list items --search "$item_name" | jq -r '.[0].id // empty')"
        if test -n "$item_id"
            bw get "$field" "$item_id" ^ /dev/null
        else
            echo "Item '$item_name' not found in Bitwarden vault"
            return 1
        end
    end

    function bw-login
        set email (or $BW_EMAIL "")
        if test -z "$email"
            echo -n "Enter your Bitwarden email: "
            read -l email
        end

        if test -n "$BW_SERVER"
            bw config server "$BW_SERVER"
        end

        echo "Logging in to Bitwarden..."
        if not bw login "$email"
            echo "Failed to login to Bitwarden"
            return 1
        end
    end
    
    function bw-unlock
        set password_file "$HOME/.bitwarden_password"

        if test -f "$password_file"
            set session "$(bw unlock --passwordfile "$password_file" --raw)"
            if test -n "$session"
                set -Ux BW_SESSION "$session"
                return 0
            else
                echo "Password file seems invalid, removing it"
                rm -f "$password_file"
            end
        end

        echo -n "Enter your Bitwarden master password: "
        read -s -l password

        set session "$(echo "$password" | bw unlock --raw)"
        if test -n "$session"
            echo "$password" > "$password_file"
            chmod 600 "$password_file"
            set -Ux BW_SESSION "$session"
            echo "Bitwarden vault unlocked successfully"
            return 0
        else
            echo "Failed to unlock Bitwarden vault - incorrect password"
            return 1
        end
    end

    # Load existing session 
    function bw-load-session
        set session_file "$HOME/.cache/bw-session"
        if test -f "$session_file"
            set session_token "$(cat "$session_file")"
            if test -n "$session_token" && bw list items --search "" >/dev/null
                set -Ux BW_SESSION "$session_token"
                return 0
            else
                rm -f "$session_file"
            end
        end
        return 1
    end

    # Ensure we have a valid Bitwarden session
    function bw-ensure-session
        # Only try to load session in interactive shells
        if not status is-interactive
            return 1
        end
        
        if bw-load-session
            return 0
        end

        if not bw status | grep -q '"status":"unlocked"'
            if bw status | grep -q '"status":"locked"'
                bw-unlock
            else
                bw-login && bw-unlock
            end
        else
            bw-load-session || bw-unlock
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

    # Template helper: get secret for use in chezmoi templates
    function bw-template-helper
        set item_name $argv[1]
        set field (or $argv[2] "password")

        if not type -q bw
            echo "BW_NOT_AVAILABLE"
            return 0
        end

        if not bw-get-secret "$item_name" "$field" ^ /dev/null
            echo "BW_SECRET_NOT_FOUND"
            return 0
        end
    end
end