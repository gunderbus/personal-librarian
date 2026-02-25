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
