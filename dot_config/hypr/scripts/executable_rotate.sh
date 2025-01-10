#!/bin/env bash
if [ -f ~/rotated.temp.lock ] && grep -q "1" ~/rotated.temp.lock; then
  hyprctl keyword monitor ,preferred,auto,1,transform,toggle,0
else
  hyprctl keyword monitor ,preferred,auto,1,transform,toggle,1
fi
