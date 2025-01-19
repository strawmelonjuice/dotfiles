#!/bin/env bash
# This script is used to start the executable files on the right workspaces
swaymsg "workspace 2; exec ~/shellscripts/browser.sh"
sleep 2 && swaymsg "workspace 3; exec discord"
sleep 2 && swaymsg "workspace 4; exec spotify"

sleep 5 && swaymsg "workspace 1"
