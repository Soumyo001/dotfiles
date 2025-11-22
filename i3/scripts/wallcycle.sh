#!/usr/bin/env bash

WALLDIR="$HOME/Pictures/wallpapers"

# Change wallpaper every 180 seconds (edit as you like)
INTERVAL=180

while true; do
    for img in "$WALLDIR"/*; do
        feh --bg-fill "$img"
        sleep $INTERVAL
    done
done
