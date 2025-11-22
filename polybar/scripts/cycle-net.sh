#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/polybar-current-net"

# Get all interface names (exclude loopback)
mapfile -t INTERFACES < <(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
[ ${#INTERFACES[@]} -eq 0 ] && exit

# Read current interface, fallback to first
CURRENT_IF="${INTERFACES[0]}"
if [[ -f "$STATE_FILE" ]]; then
    tmp=$(<"$STATE_FILE")
    [[ " ${INTERFACES[*]} " =~ " $tmp " ]] && CURRENT_IF="$tmp"
fi

# Find next interface
NEXT_IF="${INTERFACES[0]}"
for i in "${!INTERFACES[@]}"; do
    if [[ "${INTERFACES[$i]}" == "$CURRENT_IF" ]]; then
        NEXT_IF="${INTERFACES[$(( (i + 1) % ${#INTERFACES[@]} ))]}"
        break
    fi
done

# Save next interface
echo "$NEXT_IF" > "$STATE_FILE"

# Refresh Polybar module
polybar-msg hook eth 1 >/dev/null
