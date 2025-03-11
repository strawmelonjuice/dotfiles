#!/bin/bash
chezmoi init --apply
killall hyprpaper
killall -9 waybar
sleep 1
waybar &
hyprpaper &
