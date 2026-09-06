#!/usr/bin/env bash
# Install OmarKEYS into Omarchy: symlink the plugin, enable it, wire Hyprland.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_ID="romills.omarkeys"
OLD_ID="romills.keymap"
PLUGIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/${PLUGIN_ID}"
OLD_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins/${OLD_ID}"
BINDINGS="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua"
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --uninstall) UNINSTALL=1 ;;
    -h|--help)
      printf '%s\n' \
        "Usage: ./install.sh [--uninstall]" \
        "  Symlink this repo into Omarchy plugins, enable OmarKEYS," \
        "  and load hyprland.lua from ~/.config/hypr/bindings.lua."
      exit 0
      ;;
    *)
      echo "unknown option: $arg" >&2
      exit 2
      ;;
  esac
done

log() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }

MARKER_BEGIN="-- OmarKEYS"
DOFLE_LINE="dofile((os.getenv(\"HOME\") or \"\") .. \"/.config/omarchy/plugins/${PLUGIN_ID}/hyprland.lua\")"

strip_omarkeys_from_bindings() {
  python3 - "$BINDINGS" "$PLUGIN_ID" <<'PY'
from pathlib import Path
import re, sys

path = Path(sys.argv[1])
plugin_id = sys.argv[2]
text = path.read_text()

patterns = [
    re.compile(r"\n-- OmarKEYS[\s\S]*?\nend\n", re.M),
    re.compile(r"\n-- SUPER\+K was the searchable keybinding menu[\s\S]*?\nend\n", re.M),
    re.compile(
        r"\ndofile\(\(os\.getenv\(\"HOME\"\) or \"\"\) \.\. \"/.config/omarchy/plugins/"
        + re.escape(plugin_id)
        + r"/hyprland\.lua\"\)\n"
    ),
]
for pat in patterns:
    text = pat.sub("\n", text)
text = re.sub(r"\n-- OmarKEYS\n+", "\n", text)
if not text.endswith("\n"):
    text += "\n"
path.write_text(text)
PY
}

if (( UNINSTALL )); then
  if command -v omarchy >/dev/null; then
    omarchy plugin disable "$PLUGIN_ID" >/dev/null 2>&1 || true
    omarchy plugin disable "$OLD_ID" >/dev/null 2>&1 || true
  fi
  if [[ -L $PLUGIN_DIR ]]; then
    rm -f "$PLUGIN_DIR"
    log "removed symlink $PLUGIN_DIR"
  fi
  if [[ -f $BINDINGS ]]; then
    cp "$BINDINGS" "$BINDINGS.bak.$(date +%s)"
    strip_omarkeys_from_bindings
    log "removed OmarKEYS from $BINDINGS"
  fi
  if command -v hyprctl >/dev/null; then
    hyprctl reload >/dev/null || true
  fi
  log "OmarKEYS uninstalled. Restore Super+K with: omarchy refresh hyprland  (only if you want stock bindings back)"
  exit 0
fi

mkdir -p "$(dirname "$PLUGIN_DIR")"
if [[ -e $PLUGIN_DIR && ! -L $PLUGIN_DIR ]]; then
  backup="${PLUGIN_DIR}.bak.$(date +%s)"
  mv "$PLUGIN_DIR" "$backup"
  log "moved existing plugin dir -> $backup"
fi
ln -sfn "$ROOT" "$PLUGIN_DIR"
log "symlinked $PLUGIN_DIR -> $ROOT"

if command -v omarchy >/dev/null; then
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
  omarchy plugin disable "$OLD_ID" >/dev/null 2>&1 || true
  omarchy plugin enable "$PLUGIN_ID"
  log "enabled $PLUGIN_ID"
fi

if [[ -d $OLD_DIR && ! -L $OLD_DIR ]]; then
  log "left old plugin at $OLD_DIR (disabled). Remove it when you like."
fi

if [[ -f $BINDINGS ]]; then
  cp "$BINDINGS" "$BINDINGS.bak.$(date +%s)"
  strip_omarkeys_from_bindings
  printf '\n%s\n%s\n' "$MARKER_BEGIN" "$DOFLE_LINE" >> "$BINDINGS"
  log "wired $BINDINGS -> hyprland.lua"
else
  echo "missing $BINDINGS" >&2
  exit 1
fi

if command -v omarchy >/dev/null; then
  omarchy plugin validate "$ROOT"
fi

if command -v hyprctl >/dev/null; then
  hyprctl reload
  sleep 0.2
  errors="$(hyprctl configerrors || true)"
  if [[ -n ${errors// } ]]; then
    echo "$errors" >&2
    exit 1
  fi
  log "Hyprland reloaded"
fi

log "OmarKEYS ready. Super+K, double-tap Super, or hold Super 1s."
