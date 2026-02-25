#!/bin/sh

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/personal-librarian"
CONFIG_FILE="$CONFIG_DIR/config"

# Ensure config path exists on first run.
mkdir -p "$CONFIG_DIR"
[ -f "$CONFIG_FILE" ] || : > "$CONFIG_FILE"

# Load saved preferences.
. "$CONFIG_FILE"

# Example default preference.
: "${THEME:=dark}"

# Get a preference value for a given key in config.
get_pref() {
  key="$1"
  grep "^${key}=" "$CONFIG_FILE" | cut -d= -f2- || echo ""
}

# Save/overwrite one preference key in config.
set_pref() {
  key="$1"
  value="$2"

  tmp_file="$CONFIG_FILE.tmp"
  if [ -s "$CONFIG_FILE" ]; then
    grep -v "^${key}=" "$CONFIG_FILE" > "$tmp_file" || true
  else
    : > "$tmp_file"
  fi
  printf "%s=%s\n" "$key" "$value" >> "$tmp_file"
  mv "$tmp_file" "$CONFIG_FILE"
}

if [ "$1" = "get" ]; then
  get_pref "$2"
elif [ "$1" = "set" ]; then
  set_pref "$2" "$3"
elif [ "$1" = "library" ]; then
  folder="$(get_pref folder)"
  if [ -z "$folder" ]; then
    echo "No folder set. Use: $0 set folder /path/to/folder"
    exit 1
  fi

  if [ ! -d "$folder" ]; then
    echo "Folder does not exist: $folder"
    exit 1
  fi

  find "$folder" -maxdepth 1 -type f | sed 's#.*/##' | sort
else
  echo "Usage: $0 get <key> | set <key> <value> | library"
fi
