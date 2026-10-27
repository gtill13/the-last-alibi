#!/usr/bin/env bash
# Driver visual da demo de arte procedural.
# Abre a cena, captura o estado padrão, troca a definição da mesa (tecla 2)
# e volta para a variante clara (tecla 1). As imagens servem como evidência
# para docs/ARTE_PROCEDURAL.md.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64}"
OUT_DIR="${PROJECT_DIR}/tests/manual/screenshots/procedural-art"
LOG_FILE="${TMPDIR:-/tmp}/opencode/procedural_art_driver.log"
mkdir -p "$OUT_DIR" "$(dirname "$LOG_FILE")"

if [[ ! -x "$GODOT_BIN" ]]; then
    echo "Godot não encontrado: $GODOT_BIN" >&2
    exit 2
fi

"$GODOT_BIN" --path "$PROJECT_DIR" \
    res://scenes/procedural/procedural_art_demo.tscn \
    --log-file "$LOG_FILE" &
GODOT_PID=$!
trap 'kill "$GODOT_PID" 2>/dev/null || true' EXIT

WIN_ID=""
for _ in $(seq 1 40); do
    sleep 0.25
    WIN_ID="$(xdotool search --name "The Last Alibi" 2>/dev/null | tail -1 || true)"
    [[ -n "$WIN_ID" ]] && break
done

if [[ -z "$WIN_ID" ]]; then
    echo "Janela do Godot não encontrada" >&2
    exit 1
fi

# Sem window manager, windowfocus é mais confiável que windowactivate.
xdotool windowfocus --sync "$WIN_ID"
sleep 1.2

screenshot() {
    local name="$1"
    import -window "$WIN_ID" "$OUT_DIR/$name.png"
    sleep 0.4
}

screenshot "p0_default"
xdotool key --clearmodifiers 2
sleep 0.8
screenshot "p1_variant_dark"
xdotool key --clearmodifiers 1
sleep 0.8
screenshot "p2_variant_light"

echo "Capturas da arte procedural em: $OUT_DIR"
echo "Log: $LOG_FILE"
