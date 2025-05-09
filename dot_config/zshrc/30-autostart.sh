# -----------------------------------------------------
# AUTOSTART
# -----------------------------------------------------

# -----------------------------------------------------
# Starship promt
# -----------------------------------------------------
eval "$(starship init zsh)"

# -----------------------------------------------------
# Hyfetch
# -----------------------------------------------------
if [[ $(tty) == *"pts"* ]]; then
  up=$(awk '{print $1}' /proc/uptime)
  up=${up%.*}
  if [ $up -lt 300 ]; then
    hyfetch
  fi
  if [[ $(ps -o 'cmd=' -p $(ps -o 'ppid=' -p $$)) == "konsole" ]]; then
    echo "You seem to be using Konsole. Tip: use 'control+shift+m' to toggle the menu."
  fi
else
  echo
  if [ -f /bin/qtile ]; then
    echo "Start Qtile X11 with command Qtile"
  fi
  if [ -f /bin/hyprctl ]; then
    echo "Start Hyprland with command Hyprland"
  fi
fi
