#!/usr/bin/env bash
# Driver auxiliar para uma inspeção visual rápida da Fase 1.
# Usa xdotool para foco/teclas e ImageMagick (import) para capturas.
# Não substitui os testes automatizados nem o registro em docs/M1_TESTS.md.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64}"
OUT_DIR="${PROJECT_DIR}/tests/manual/screenshots/fase1"
mkdir -p "$OUT_DIR"

if [[ ! -x "$GODOT_BIN" ]]; then
    echo "Godot não encontrado: $GODOT_BIN" >&2
    exit 2
fi

"$GODOT_BIN" --path "$PROJECT_DIR" --log-file /tmp/opencode/manual_driver.log &
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
sleep 1

screenshot() {
    local name="$1"
    import -window "$WIN_ID" "$OUT_DIR/$name.png"
    sleep 0.4
}

# Avança em pulsos curtos: alguns ambientes não mantêm keydown por muito tempo.
move_right() {
    local pulses="${1:-4}"
    for _ in $(seq 1 "$pulses"); do
        xdotool keydown d
        sleep 0.6
        xdotool keyup d
        sleep 0.1
    done
}

move_left() {
    local pulses="${1:-4}"
    for _ in $(seq 1 "$pulses"); do
        xdotool keydown a
        sleep 0.6
        xdotool keyup a
        sleep 0.1
    done
}

# 1. Menu principal
screenshot "f1_01_menu"
xdotool key Return
sleep 2

# 2. Nível de investigação, jogador na posição inicial
screenshot "f1_02_level_start"

# 3. Aproximação do vidro quebrado e prompt contextual
move_right 4
screenshot "f1_05_prompt_glass"

# 4. Interação única
xdotool key e
sleep 0.5
screenshot "f1_06_interact_once"

# 5. E segurado (key echo não deve repetir)
xdotool keydown e
sleep 2
xdotool keyup e
sleep 0.5
screenshot "f1_07_hold_e"

# 6. Afastamento e ocultação do prompt
move_left 3
screenshot "f1_09_prompt_hidden"

echo "Capturas da Fase 1 em: $OUT_DIR"
