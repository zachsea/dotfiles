#!/bin/bash

sketchybar --add item glucose right \
  --set glucose update_freq=30 \
  icon=􁁞 \
  script="$PLUGIN_DIR/glucose.sh"
