#!/usr/bin/env bash
# Driver temporário de interface para sessão gráfica da Fase 1.
# Inicia o jogo, tira screenshots com spectacle e simula teclas com xdotool.
# REMOVER antes do commit (conforme tests/manual/README.md).
set -euo pipefail

PROJECT_DIR="/home/till/Projects/the-last-alibi"
GODOT_BIN="${GODOT_BIN:-/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64}"
OUT_DIR="${PROJECT_DIR}/tests/manual/screenshots/fase1"
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
screenshot "f1_01_menu"
xdotool key --window "$WIN_ID" Tab
sleep 0.3
xdotool key --window "$WIN_ID" Return
sleep 2

# 2. Nível de investigação - investigador aparece, câmera segue
screenshot "f1_02_investigation"

# 3. Movimenta para direita (D) e observa prompt aparecer perto de objetos
xdotool key --window "$WIN_ID" d
sleep 1
screenshot "f1_03_move_right"

# 4. Pressiona E para interagir com o alvo mais próximo
xdotool key --window "$WIN_ID" e
sleep 1
screenshot "f1_04_interact"

# 5. Movimenta para esquerda (A)
xdotool key --window "$WIN_ID" a
sleep 1
screenshot "f1_05_move_left"

# 6. Abre caderno (N)
xdotool key --window "$WIN_ID" n
sleep 1
screenshot "f1_06_notebook"

# 7. Fecha caderno (Esc)
xdotool key --window "$WIN_ID" Escape
sleep 0.5

# 8. Encerra
kill "$GODOT_PID" 2>/dev/null || true
echo "Screenshots da Fase 1 em: $OUT_DIR"
