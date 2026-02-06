#!/usr/bin/env bash

BAT="/sys/class/power_supply/BAT0"

PERCENT=$(cat "$BAT/capacity")
STATUS=$(cat "$BAT/status")

# Charging symbol
if [ "$STATUS" = "Charging" ]; then
    CHARGE=""
else
    CHARGE=""
fi

# More granular battery icons (Font Awesome)
#  = empty,  = 1/4,  = 1/2,  = 3/4,  = full
# Now we split into 10% increments for smoother progression

if [ "$PERCENT" -ge 95 ]; then
    ICON=""
elif [ "$PERCENT" -ge 85 ]; then
    ICON=""
elif [ "$PERCENT" -ge 75 ]; then
    ICON=""
elif [ "$PERCENT" -ge 65 ]; then
    ICON=""
elif [ "$PERCENT" -ge 55 ]; then
    ICON=""
elif [ "$PERCENT" -ge 45 ]; then
    ICON=""
elif [ "$PERCENT" -ge 35 ]; then
    ICON=""
elif [ "$PERCENT" -ge 25 ]; then
    ICON=""
elif [ "$PERCENT" -ge 15 ]; then
    ICON=""
else
    ICON=""
fi

echo "$CHARGE $ICON $PERCENT%"
