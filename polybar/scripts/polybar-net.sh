#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/polybar-current-net"

# Get all interface names (exclude loopback)
mapfile -t INTERFACES < <(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)

# Exit if no interfaces
[ ${#INTERFACES[@]} -eq 0 ] && { echo "No interface"; exit; }

# Read current interface from state file, fallback to first
CURRENT_IF="${INTERFACES[0]}"
if [[ -f "$STATE_FILE" ]]; then
    tmp=$(<"$STATE_FILE")
    [[ " ${INTERFACES[*]} " =~ " $tmp " ]] && CURRENT_IF="$tmp"
fi

# Get IPv4 of current interface, N/A if none
IP=$(ip -4 addr show dev "$CURRENT_IF" 2>/dev/null | awk '/inet /{print $2; exit}' | cut -d/ -f1)
IP=${IP:-"N/A"}

# Save back
echo "$CURRENT_IF" > "$STATE_FILE"

# Output for Polybar
echo "%{F#F0C674}$CURRENT_IF%{F-} $IP"
