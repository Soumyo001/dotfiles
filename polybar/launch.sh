#!/usr/bin/env bash

# Kill existing Polybar instances
killall -q polybar

# Wait until processes are dead
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar
polybar main &


