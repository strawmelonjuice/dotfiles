#!/bin/bash
# Relaunch the touch keyboard
# kill the keyboard
killall wvkbd-mobintl
# restart the keyboard
wvkbd-mobintl -L 400
