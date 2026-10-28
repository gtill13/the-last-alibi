#!/usr/bin/env bash
# Gera as capturas oficiais do Art Lab da Fase 1.
# Usa o driver Godot tools/capture_art_lab.gd e valida as dimensões com ImageMagick.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64}"
OUT_DIR="${PROJECT_DIR}/tests/manual/screenshots/art-lab"
CAPTURE_SCRIPT="res://tools/capture_art_lab.gd"

mkdir -p "$OUT_DIR"

if [[ ! -x "$GODOT_BIN" ]]; then
	echo "Godot não encontrado: $GODOT_BIN" >&2
	exit 2
fi

if ! command -v magick >/dev/null 2>&1; then
	echo "ImageMagick (magick) não encontrado; necessário para validar as capturas." >&2
	exit 2
fi

capture() {
	local width="$1"
	local height="$2"
	local mode="$3"
	local name="$4"
	local fullscreen="${5:-}"
	local output="$OUT_DIR/$name.png"
	local -a godot_flags=(--display-driver x11)
	local -a driver_args=()

	if [[ "$fullscreen" == "fullscreen" ]]; then
		godot_flags+=(--fullscreen)
		driver_args+=(fullscreen)
	fi

	"$GODOT_BIN" "${godot_flags[@]}" --path "$PROJECT_DIR" \
		-s "$CAPTURE_SCRIPT" -- \
		"$width" "$height" "$mode" "$output" "${driver_args[@]}"

	local dimensions
	dimensions="$(magick identify -format "%wx%h" "$output")"
	if [[ "$dimensions" != "${width}x${height}" ]]; then
		echo "Captura em resolução inesperada: $output ($dimensions)" >&2
		exit 1
	fi
}

capture 1280 720 game art_lab_1280x720_4x
capture 1280 720 1x art_lab_1280x720_1x
capture 1920 1080 game art_lab_1920x1080_6x fullscreen

echo "Capturas do Art Lab em: $OUT_DIR"
