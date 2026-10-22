#!/usr/bin/env bash
# Driver temporário de interface para sessão gráfica.
# Inicia o jogo, tira screenshots com spectacle e simula teclas com xdotool.
# REMOVER antes do commit (conforme tests/manual/README.md).
set -euo pipefail

PROJECT_DIR="/home/till/Projects/the-last-alibi"
GODOT_BIN="${GODOT_BIN:-/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64}"
OUT_DIR="${PROJECT_DIR}/tests/manual/screenshots"
mkdir -p "$OUT_DIR"

"$GODOT_BIN" --path "$PROJECT_DIR" --window-size 1280x720 &
GODOT_PID=$!
sleep 6

WIN_ID=$(xdotool search --name "The Last Alibi" | head -1)
if [[ -z "$WIN_ID" ]]; then
    echo "Janela do Godot não encontrada" >&2
    kill "$GODOT_PID" 2>/dev/null || true
    exit 1
fi

xdotool windowactivate "$WIN_ID"
sleep 1

screenshot() {
    local name="$1"
    spectacle -b -c -o "$OUT_DIR/$name.png" "$WIN_ID" 2>/dev/null || true
    sleep 0.5
}

# 1. Menu principal
screenshot "01_menu"
xdotool key --window "$WIN_ID" Tab
sleep 0.3
xdotool key --window "$WIN_ID" Return
sleep 2

# 2. Nível de investigação
screenshot "02_investigation"
xdotool key --window "$WIN_ID" n
sleep 1
screenshot "03_notebook"
xdotool key --window "$WIN_ID" Escape
sleep 0.5

# 3. Encerra
kill "$GODOT_PID" 2>/dev/null || true
echo "Screenshots em: $OUT_DIR"
