#!/bin/bash
# Relaunch the touch keyboard if it crashed

line=$(ps aux | grep wvkbd-mobintl)
if [ -z "$line" ]; then
  wvkbd-mobintl -L 400
else
  echo $line >/dev/null
  # Its running, so send it a signal to toggle it up
  kill -34 $(ps -C wvkbd-mobintl)
fi
