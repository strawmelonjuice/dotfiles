# Example: Using Bitwarden in Chezmoi Templates

This document shows how to integrate Bitwarden secrets into your dotfiles templates.

## Basic Usage

### Git Configuration with Bitwarden

Create `dot_gitconfig.tmpl`:

```go-template
[user]
	email = {{ .email | default "mar@strawmelonjuice.com" }}
	name = {{ .name | default "MLC Bloeiman" }}
	{{- $signingkey := output "shellscripts/executable_bitwarden_helper.sh" "template" "Git GPG Key" "key_id" | trim }}
	{{- if and (ne $signingkey "BW_NOT_AVAILABLE") (ne $signingkey "BW_SECRET_NOT_FOUND") }}
	signingkey = {{ $signingkey }}
	{{- end }}

[commit]
	{{- if and (ne $signingkey "BW_NOT_AVAILABLE") (ne $signingkey "BW_SECRET_NOT_FOUND") }}
	gpgsign = true
	{{- end }}

[github]
	{{- $github_user := output "shellscripts/executable_bitwarden_helper.sh" "template" "GitHub" "username" | trim }}
	{{- if and (ne $github_user "BW_NOT_AVAILABLE") (ne $github_user "BW_SECRET_NOT_FOUND") }}
	user = {{ $github_user }}
	{{- end }}
```

### SSH Configuration

Create `private_dot_ssh/config.tmpl`:

```go-template
# Default settings
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentitiesOnly yes

# GitHub
{{- $github_key := output "shellscripts/executable_bitwarden_helper.sh" "template" "GitHub SSH Key" "private_key" | trim }}
{{- if and (ne $github_key "BW_NOT_AVAILABLE") (ne $github_key "BW_SECRET_NOT_FOUND") }}
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
{{- end }}

# Personal server
{{- $server_key := output "shellscripts/executable_bitwarden_helper.sh" "template" "Personal Server SSH" "private_key" | trim }}
{{- if and (ne $server_key "BW_NOT_AVAILABLE") (ne $server_key "BW_SECRET_NOT_FOUND") }}
Host myserver
    HostName {{ output "shellscripts/executable_bitwarden_helper.sh" "template" "Personal Server SSH" "hostname" | trim }}
    User {{ output "shellscripts/executable_bitwarden_helper.sh" "template" "Personal Server SSH" "username" | trim }}
    IdentityFile ~/.ssh/server_ed25519
{{- end }}
```

### Environment Variables

Create `dot_zshrc_secrets.tmpl`:

```go-template
# API Keys and Tokens (only if Bitwarden is available)

{{- $github_token := output "shellscripts/executable_bitwarden_helper.sh" "template" "GitHub Token" | trim }}
{{- if and (ne $github_token "BW_NOT_AVAILABLE") (ne $github_token "BW_SECRET_NOT_FOUND") }}
export GITHUB_TOKEN="{{ $github_token }}"
{{- end }}

{{- $openai_key := output "shellscripts/executable_bitwarden_helper.sh" "template" "OpenAI API Key" | trim }}
{{- if and (ne $openai_key "BW_NOT_AVAILABLE") (ne $openai_key "BW_SECRET_NOT_FOUND") }}
export OPENAI_API_KEY="{{ $openai_key }}"
{{- end }}

{{- $aws_access := output "shellscripts/executable_bitwarden_helper.sh" "template" "AWS Credentials" "access_key" | trim }}
{{- $aws_secret := output "shellscripts/executable_bitwarden_helper.sh" "template" "AWS Credentials" "secret_key" | trim }}
{{- if and (ne $aws_access "BW_NOT_AVAILABLE") (ne $aws_access "BW_SECRET_NOT_FOUND") }}
export AWS_ACCESS_KEY_ID="{{ $aws_access }}"
export AWS_SECRET_ACCESS_KEY="{{ $aws_secret }}"
{{- end }}
```

## Advanced Patterns

### Conditional Configuration

```go-template
{{- $has_bitwarden := ne (output "shellscripts/executable_bitwarden_helper.sh" "status" | trim) "Bitwarden CLI not installed" }}
{{- if $has_bitwarden }}
# Bitwarden is available, use secrets
{{- $db_password := output "shellscripts/executable_bitwarden_helper.sh" "template" "Database" | trim }}
{{- if ne $db_password "BW_SECRET_NOT_FOUND" }}
DATABASE_URL="postgresql://user:{{ $db_password }}@localhost/mydb"
{{- end }}
{{- else }}
# Bitwarden not available, use fallback or skip
# DATABASE_URL="postgresql://user:fallback@localhost/mydb"
{{- end }}
```

### Multiple Fields from One Item

```go-template
{{- $email := output "shellscripts/executable_bitwarden_helper.sh" "template" "Email Account" "username" | trim }}
{{- $password := output "shellscripts/executable_bitwarden_helper.sh" "template" "Email Account" "password" | trim }}
{{- $server := output "shellscripts/executable_bitwarden_helper.sh" "template" "Email Account" "server" | trim }}

{{- if and (ne $email "BW_SECRET_NOT_FOUND") (ne $password "BW_SECRET_NOT_FOUND") }}
# Email configuration
EMAIL_USER="{{ $email }}"
EMAIL_PASS="{{ $password }}"
{{- if ne $server "BW_SECRET_NOT_FOUND" }}
EMAIL_SERVER="{{ $server }}"
{{- end }}
{{- end }}
```

## Bitwarden Item Structure

For the templates to work correctly, structure your Bitwarden items like this:

### GitHub Token Item
- **Name**: "GitHub Token"
- **Username**: your_github_username
- **Password**: ghp_your_token_here
- **Custom Fields**:
  - `username`: your_github_username
  - `token`: ghp_your_token_here

### SSH Key Item
- **Name**: "GitHub SSH Key"
- **Password**: (not used)
- **Custom Fields**:
  - `private_key`: -----BEGIN OPENSSH PRIVATE KEY-----...
  - `public_key`: ssh-ed25519 AAAAC3...
  - `hostname`: github.com

### Database Credentials
- **Name**: "Database"
- **Username**: db_user
- **Password**: db_password
- **Custom Fields**:
  - `host`: localhost
  - `port`: 5432
  - `database`: myapp

## Error Handling

The templates are designed to fail gracefully:

1. **BW_NOT_AVAILABLE**: Bitwarden CLI is not installed
2. **BW_SECRET_NOT_FOUND**: Item or field doesn't exist
3. Empty output: Session expired or other error

Always check for these conditions:

```go-template
{{- $secret := output "shellscripts/executable_bitwarden_helper.sh" "template" "My Secret" | trim }}
{{- if and (ne $secret "BW_NOT_AVAILABLE") (ne $secret "BW_SECRET_NOT_FOUND") (ne $secret "") }}
# Use the secret
SECRET="{{ $secret }}"
{{- else }}
# Fallback or skip
# SECRET="fallback_value"
{{- end }}
```

## Testing Templates

Test your templates without applying:

```bash
# Dry run to see what would be generated
chezmoi execute-template < template_file.tmpl

# Check specific template
chezmoi cat ~/.gitconfig

# Apply single file
chezmoi apply ~/.gitconfig
```

## Security Best Practices

1. **Use `.tmpl` extension** for files containing secrets
2. **Add sensitive files to `.chezmoiignore`** if needed
3. **Test in safe environment first**
4. **Use custom fields in Bitwarden** for structured data
5. **Always check for availability** before using secrets
6. **Use private_ prefix** for files that should have restricted permissions

## Troubleshooting

### Secret not found
1. Check item name in Bitwarden exactly matches template
2. Verify field name exists (case-sensitive)
3. Ensure Bitwarden session is active: `./shellscripts/executable_bitwarden_helper.sh status`

### Template not working
1. Test Bitwarden helper directly: `./shellscripts/executable_bitwarden_helper.sh get "Item Name"`
2. Check template syntax: `chezmoi execute-template < file.tmpl`
3. Enable debug mode: `DEBUG=1 chezmoi apply`
