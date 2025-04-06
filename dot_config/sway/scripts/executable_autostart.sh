#!/bin/env bash
# This script is used to start the executable files on the right workspaces
swaymsg "workspace 2; exec ~/shellscripts/browser.sh"
sleep 1 && swaymsg "workspace 3; exec discord"
sleep 4 && swaymsg "workspace 4; exec tidal-hifi"

sleep 2 && swaymsg "workspace 1"
