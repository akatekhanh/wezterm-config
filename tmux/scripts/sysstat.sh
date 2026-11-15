#!/usr/bin/env bash
# Output a compact "CPU x% | RAM y% (used/total)" line for the tmux status bar.
# macOS-only (uses ps / sysctl / memory_pressure).

# --- CPU: sum %cpu across processes, normalize by core count (0-100%) ---
cores=$(sysctl -n hw.ncpu)
cpu=$(ps -A -o %cpu | awk -v c="$cores" 'NR>1 {s+=$1} END {printf "%.0f", s/c}')

# --- RAM ---
mem_total_bytes=$(sysctl -n hw.memsize)
total_gb=$(awk -v b="$mem_total_bytes" 'BEGIN {printf "%.0f", b/1024/1024/1024}')
free_pct=$(memory_pressure 2>/dev/null | awk -F': ' '/System-wide memory free percentage/ {gsub(/%/,"",$2); print $2}')
free_pct=${free_pct:-0}
used_pct=$(awk -v f="$free_pct" 'BEGIN {printf "%.0f", 100 - f}')
used_gb=$(awk -v t="$total_gb" -v u="$used_pct" 'BEGIN {printf "%.1f", t*u/100}')

printf "CPU %s%% | RAM %s%% (%sG/%sG)" "$cpu" "$used_pct" "$used_gb" "$total_gb"
