#!/usr/bin/env bash
# Usage: volume-listen.sh <SINK_NAME>
SINK="$1"

print_status() {
  local muted vol
  muted=$(pactl get-sink-mute "$SINK" 2>/dev/null | awk '{print $2}')
  vol=$(pactl get-sink-volume "$SINK" 2>/dev/null | awk 'NR==1{print $5}')
  [[ -z "$vol" ]] && vol="--%"

  if [[ "$muted" == "yes" ]]; then
    # Label in primary, the word "muted" in disabled
    echo "%{F$POLYBAR_DISABLED}muted%{F-}"
  else
    # Everything (label + percentage) in your yellow-ish primary
    echo "%{F$POLYBAR_PRIMARY}VOL %{F-} $vol"
  fi
}

print_status
pactl subscribe | stdbuf -oL grep --line-buffered -E "sink|server" | while read -r _; do
  print_status
done
