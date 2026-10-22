#!/usr/bin/env bash
# Importa o projeto e executa os testes em modo headless.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64}"
EXPECTED_GODOT_VERSION="4.7.2.stable.official.ed1daf0bf"

if [[ ! -x "$GODOT_BIN" ]]; then
	echo "Godot não encontrado: $GODOT_BIN" >&2
	echo "Defina GODOT_BIN com o caminho do executável." >&2
	exit 2
fi

ACTUAL_GODOT_VERSION="$("$GODOT_BIN" --version)"
if [[ "$ACTUAL_GODOT_VERSION" != "$EXPECTED_GODOT_VERSION" && "${ALLOW_UNVERIFIED_GODOT:-0}" != "1" ]]; then
	echo "Versão do Godot não validada." >&2
	echo "Esperada: $EXPECTED_GODOT_VERSION" >&2
	echo "Encontrada: $ACTUAL_GODOT_VERSION" >&2
	echo "Após revisar compatibilidade, execute com ALLOW_UNVERIFIED_GODOT=1 para prosseguir." >&2
	exit 3
fi

run_checked() {
	local log_file
	local godot_status
	log_file="$(mktemp)"
	set +e
	"$GODOT_BIN" "$@" 2>&1 | tee "$log_file"
	godot_status=${PIPESTATUS[0]}
	set -e

	if [[ "$godot_status" -ne 0 ]]; then
		echo "Godot terminou com código $godot_status: $*" >&2
		rm -f "$log_file"
		return "$godot_status"
	fi

	if grep -Eiq '(^|[[:space:]])(SCRIPT ERROR|ERROR):' "$log_file"; then
		echo "O log contém erros do Godot; os testes serão considerados reprovados." >&2
		rm -f "$log_file"
		return 1
	fi
	rm -f "$log_file"
}

# Importação/registro de class_name antes da execução do runner.
run_checked --headless --path "$PROJECT_DIR" --editor --quit
run_checked --headless --path "$PROJECT_DIR" -s res://tests/framework/test_runner.gd
