# Mar's dotfiles

## About

### Package manager

Mains _[mise](https://mise.jdx.dev/)_ as a local package/dependency manager. 

#### System package manager

Mains _[paru](https://github.com/Morganamilo/paru)_ AUR helper for arch based distro's, which is the only distro where that has a preference.


### Editor

I use mostly _[Neovim](https://neovim.io/)_, but am liking _[Helix](https://helix-editor.com/)_ as well, 
it's current lack of extensibility is my reason for not transitioning to it.

My Neovim is derived from the _[LazyVim](https://www.lazyvim.org/)_ distrobution, but heavily modified.

I also have configurations for _[Zed](https://zed.dev/)_ as I use it when I needed too.

### Terminal

I use several terminal emulators depending on the system, since my raspberry pi doesn't always play nice with wezterm:
- _[WezTerm](https://wezfurlong.org/wezterm/)_ - GPU-accelerated cross-platform terminal
- _[Alacritty](https://alacritty.org/)_ - Cross-platform, GPU-accelerated terminal


For terminal multiplexing, I use _[Zellij](https://zellij.dev/)_.

### System Tools

Various CLI tools that make the experience better:
- _[Eza](https://github.com/eza-community/eza)_ - Modern replacement for `ls`
- _[Bat](https://github.com/sharkdp/bat)_ - Cat clone with syntax highlighting
- _[Fzf](https://github.com/junegunn/fzf)_ - Fuzzy finder
- _[Ripgrep](https://github.com/BurntSushi/ripgrep)_ - Fast grep alternative
- _[Zoxide](https://github.com/ajeetdsouza/zoxide)_ - Smarter cd command
- _[Difftastic](https://difftastic.wilfred.me.uk/)_ - Structural diff tool
- _[Fastfetch](https://github.com/fastfetch-cli/fastfetch)_ - System information tool
- _[Lazygit](https://github.com/jesseduffield/lazygit)_ - Git TUI
- _[GitHub CLI](https://cli.github.com/)_ - GitHub command line tool
- _[JJ](https://github.com/martinvonz/jj)_ - Git-compatible VCS

### Shell

I main _[Fish](https://fishshell.com/)_, with _[Zsh](https://www.zsh.org/)_ as a fallback option. On Windows _[`pwsh`](https://docs.microsoft.com/en-us/powershell/)_ (Powershell 7+) is used, instead of _`powershell`_ (Powershell 5-) or _`CMD`_.
In all shells I use regularly, a bunch of helpers for cli operations is created, as well as a _[Starship](https://starship.rs/)_ prompt and a _[Hyfetch](https://github.com/hykilpikonna/hyfetch)_-powered landing screen.

### Window management
#### Linux

On Linux, these dotfiles provide configuration for my beloved _[Hyprland](https://hyprland.org/)_ and _[Niri](https://github.com/YaLTeR/niri)_ setups, but I myself have long not 
used either due to changing hardware and other personal reasons. I keep both configs however, because I'm sure I'll 
be back for them some day. Currently I'm daily driving both _[KDE Plasma](https://kde.org/plasma-desktop/)_ and _[GNOME](https://www.gnome.org/)_. _[Cosmic](https://github.com/pop-os/cosmic-epoch)_ is great too but not as much for me.

#### Windows

If you've snooped around, you know I have _[komorebi](https://github.com/LGUG2Z/komorebi)_ and ahk files in here to turn Windows 11 into a Hyprland like experience.
I don't really often do, as fighting with Windows makes tired. Those files are marked for deletion at some point.
I do however use lots of _[Powertoys](https://github.com/microsoft/PowerToys)_ when on Windows, making it at least tolerable.

## Set-up

### Generally

Generally I system-install _[chezmoi](https://www.chezmoi.io/)_ and fish, then do something along the lines of

```sh
chezmoi init ssh://git@git.strawmelonjuice.com/strawmelonjuice/dotfiles.git --apply # First round
curl https://mise.run | sh # install mise...
~/.local/bin/mise install # ...mise install!
~/.local/bin/mise x -- bun install -g @bitwarden/cli # Install Bitwarden CLI for secret management
bw login # making sure the vault is logged into before running the auto unlocker
chsh # to fish
fish # continue in fish
y # To set up auto unlock, then enter password, obviously.

# TODO: Need to update this whenever I go with Hyprland/Niri again, because those have a lot of system dependencies I can't think of right now.

# and usually I'd:
reboot now
```

#### For arch-based distro's

```bash
pacman -S gcc cmake fish chezmoi # chezmoi can be locally installed as well but if we're at it
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd
rm -rf ./paru
```

#### For Fedora Silverblue
```bash 
rpm-ostree install fish phosh squeekboard
```

## Old dotfiles

The dotfiles from before my move off github and this cleanup can be found in `.dotfiles-old`. Unpack that and git clone it and you're able to see the full history of the old dotfiles. They're messy.