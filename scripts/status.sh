#!/bin/sh

# The battery device name may be BAT1, BAT2, etc. Check your system.
BATTERY_PATH="/sys/class/power_supply/BAT0"

# --- Get Info ---
BAT_CAPACITY=$(cat "$BATTERY_PATH/capacity" 2>/dev/null)
BAT_STATUS=$(cat "$BATTERY_PATH/status" 2>/dev/null)

# --- Set Icon/Text ---
ICON="?"
if [ "$BAT_STATUS" = "Charging" ]; then
    ICON="⚡"
elif [ "$BAT_STATUS" = "Full" ]; then
    ICON="🔋"
else
    # Choose icon based on percentage (requires a font with these icons, e.g., Nerd Font)
    if [ "$BAT_CAPACITY" -le 10 ]; then
        ICON=""  # Empty
    elif [ "$BAT_CAPACITY" -le 35 ]; then
        ICON=""  # Low
    elif [ "$BAT_CAPACITY" -le 65 ]; then
        ICON=""  # Medium
    elif [ "$BAT_CAPACITY" -le 90 ]; then
        ICON=""  # High
    else
        ICON=""  # Full
    fi
fi

# --- Combine Output ---
# Output a single line: [Icon] [Percentage] | [Time]
TIME_INFO=$(date "+%H:%M | %b %d")

echo "$ICON $BAT_CAPACITY% | $TIME_INFO"
