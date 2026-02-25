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
: "${LLM_MODEL:=llama3.2}"

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

describe_file() {
  file_name="$1"
  model="$(get_pref llm_model)"
  [ -n "$model" ] || model="$LLM_MODEL"

  if ! command -v ollama >/dev/null 2>&1; then
    echo "[LLM unavailable] Install ollama or configure your LLM integration."
    return 0
  fi

  prompt="Write a concise 1-2 sentence library description for this file name: ${file_name}. If uncertain, say that the topic is inferred from the title."
  ollama run "$model" "$prompt" 2>/dev/null || echo "[LLM error] Failed to generate description."
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

  find "$folder" -maxdepth 1 -type f | sort | while IFS= read -r path; do
    file_name="$(basename "$path")"
    description="$(describe_file "$file_name")"
    echo "$file_name"
    printf "%s\n" "$description" | sed 's/^/  /'
    echo
  done
else
  echo "Usage: $0 get <key> | set <key> <value> | library"
  echo "Optional: $0 set llm_model <ollama-model-name>"
fi
