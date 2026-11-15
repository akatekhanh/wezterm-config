#!/usr/bin/env bash
# Output "⚡ 85%" (AC) or "🔋 85%" (battery) via pmset. macOS-only; empty on desktops.
info=$(pmset -g batt 2>/dev/null)
pct=$(grep -Eo '[0-9]+%' <<<"$info" | head -1)
[[ -z "$pct" ]] && exit 0
icon="🔋"
grep -q 'AC Power' <<<"$info" && icon="⚡"
printf "%s %s" "$icon" "$pct"
