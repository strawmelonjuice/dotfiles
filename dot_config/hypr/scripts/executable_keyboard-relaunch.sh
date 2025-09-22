#!/bin/bash
# Relaunch the touch keyboard if it crashed

line=$(ps -C wvkbd-mobintl --no-headers)
if [ -z "$line" ]; then
  wvkbd-mobintl -L 300
else
  echo $line >/dev/null
  # Its running, so send it a signal to toggle it up
  kill -34 $(ps -C wvkbd-mobintl)
fi
