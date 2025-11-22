#!/usr/bin/env bash
# Usage: mic-listen.sh <SOURCE_NAME>
SRC="$1"

print_status() {
  local muted vol
  muted=$(pactl get-source-mute "$SRC" 2>/dev/null | awk '{print $2}')
  vol=$(pactl get-source-volume "$SRC" 2>/dev/null | awk 'NR==1{print $5}')
  [[ -z "$vol" ]] && vol="--%"

  if [[ "$muted" == "yes" ]]; then
    echo "%{F$POLYBAR_DISABLED}muted%{F-}"
  else
    echo "%{F$POLYBAR_PRIMARY}MIC %{F-} $vol"
  fi
}

print_status
pactl subscribe | stdbuf -oL grep --line-buffered -E "source|server" | while read -r _; do
  print_status
done
