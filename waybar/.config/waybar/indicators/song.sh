#!/bin/bash

# Max length for title and artist
MAX_LEN=20

player_name=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)
player_status=$(playerctl status 2>/dev/null)

# Function to truncate text and add ellipsis if too long
truncate() {
  local text="$1"
  local length="$2"
  [[ ${#text} -gt $length ]] && text="${text:0:length}…" || true
    echo "$text"
  }

title=$(playerctl metadata --format '{{title}}' 2>/dev/null)
artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null)

  # Apply truncation
  title=$(truncate "$title" $MAX_LEN)
  artist=$(truncate "$artist" $MAX_LEN)

  case "$player_name" in
    spotify)   icon="󰓇" ;;
    firefox)   icon="󰈹" ;;
    mpd)       icon="󰎆" ;;
    chromium)  icon="" ;;
    *)         icon="" ;;
  esac

  song_info="${title} ${icon}  ${artist}"

# Determine class for Waybar styling
if [[ "$player_status" == "Paused" ]]; then
  class="paused"
elif [[ "$player_status" == "Playing" ]]; then
  class="playing"
else
  song_info=""
  class="stopped"
fi

# Output JSON for Waybar
jq -nc --arg text "$song_info" --arg icon "$icon" --arg artist "$artist" --arg title "$title" --arg class "$class" \
  '{text: $text, icon: $icon, artist: $artist, title: $title, class: $class}'
