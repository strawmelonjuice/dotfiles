#!/usr/bin/env sh
HYPRGAMEMODE=$(hyprctl getoption decoration:shadow:enabled | awk 'NR==1{print $2}')
if [ "$HYPRGAMEMODE" = 1 ]; then
  hyprctl --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 0;\
        keyword decoration:rounding 0;\
        keyword decoration:active_opacity 1;\
        keyword decoration:inactive_opacity 1"
  hyprctl notify -1 10000 "rgb(ff1ea3)" "" " Performance Mode Enabled"
  exit

fi
hyprctl notify -1 10000 "rgb(ff1ea3)" "" " Performance Mode Disabled"
hyprctl reload
