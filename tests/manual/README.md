# Verificação manual — The Last Alibi

Roteiro para conferir, numa sessão gráfica, o que os testes headless não cobrem.

## Como executar (sessão gráfica)

```bash
export GODOT_BIN="/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
"$GODOT_BIN" --path .
```

## Driver temporário de interface (xdotool + spectacle)

O driver abaixo é temporário (remover antes do commit). Ele inicia o jogo em
janela 1280×720, tira screenshots com `spectacle` e simula cliques/teclas com
`xdotool` para validar o fluxo: menu → início do caso → caderno → dossiê.

```bash
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/home/till/Projects/the-last-alibi"
GODOT_BIN="${GODOT_BIN:-/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64}"
OUT_DIR="${PROJECT_DIR}/tests/manual/screenshots"
mkdir -p "$OUT_DIR"

"$GODOT_BIN" --path "$PROJECT_DIR" --window-size 1280x720 &
GODOT_PID=$!
sleep 6

# Aguarda a janela do Godot aparecer
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

# 2. Nível de investigação (deve abrir após Start Case)
screenshot "02_investigation"
xdotool key --window "$WIN_ID" n
sleep 1
screenshot "03_notebook"
xdotool key --window "$WIN_KEY" Escape 2>/dev/null || xdotool key --window "$WIN_ID" Escape
sleep 0.5

# 3. Encerra
kill "$GODOT_PID" 2>/dev/null || true
```

> **Nota:** o driver acima usa `spectacle` (captura de janela) e `xdotool` (teclas/mouse sintéticos). A janela deve estar em 1280×720 e o foco deve estar no Godot. Os scripts temporários são removidos antes do commit.

## Checklist — Fase 0 (projeto executável + Git)

- [ ] O projeto abre no Godot 4.7.2 sem erros de parser.
- [ ] O menu principal mostra "THE LAST ALIBI", "Start Case" e "Quit".
- [ ] "Start Case" navega até o nível de investigação.
- [ ] "Quit" fecha o jogo fora do editor e não quebra dentro do editor.
- [ ] A segunda execução mantém o fluxo correto.
- [ ] O overlay de debug pode ser ativado por tecla (quando implementado).

## Checklist — Fase 1 (movimento + interação)

- [ ] O investigador anda para esquerda e direita (`A`/`D` ou setas).
- [ ] O investigador não atravessa o piso/obstáculos.
- [ ] O prompt de interação aparece ao aproximar de um objeto/NPC/saída.
- [ ] O prompt desaparece ao se afastar.
- [ ] Se dois objetos estiverem próximos, a interação selecionada é clara e previsível.
- [ ] Pressionar `E` uma única vez não dispara duas interações.

## Checklist — Fase 2 (exame + evidências)

- [ ] Examinar um objeto abre um painel com título, descrição e opções.
- [ ] Registrar evidência adiciona ao caderno; fechar/abrir caderno mantém o dado.
- [ ] A mesma evidência não pode ser registrada duas vezes.
- [ ] Reiniciar o caso cria sessão nova sem evidências da tentativa anterior.

## Checklist — Fase 3 (entrevistas + gravações)

- [ ] Pelo menos 3 personagens podem ser entrevistados.
- [ ] Respostas e perguntas feitas aparecem no registro correto.
- [ ] Tópico bloqueado fica indisponível até o requisito ser cumprido.
- [ ] Sair da entrevista e voltar não apaga respostas registradas.
- [ ] O caderno indica de qual pessoa é cada gravação.

## Checklist — Fase 4 (saída + montagem de dossiê)

- [ ] Jogador pode concluir com dossiê vazio ou fraco.
- [ ] Suspeito escolhido é registrado corretamente.
- [ ] O dossiê contém somente itens selecionados.
- [ ] Clicar duas vezes em enviar não inicia dois julgamentos.
- [ ] Cancelar antes da confirmação volta à edição sem perda de seleção.

## Checklist — Fase 5 (julgamento determinístico)

- [ ] O mesmo dossiê produz sempre o mesmo resultado.
- [ ] O avaliador pode ser testado sem abrir cenas (testes headless verdes).
- [ ] Provas não anexadas não influenciam a avaliação.
- [ ] Um dossiê vazio nunca resulta em condenação correta por acidente.
- [ ] O relatório diferencia veredito judicial e acerto da investigação.
- [ ] O texto explica pelo menos uma razão concreta para o resultado.

## Checklist — Fase 6 (caso vertical slice completo)

- [ ] É possível completar uma tentativa de começo a fim.
- [ ] Nenhuma pista obrigatória fica inacessível por problema de colisão ou prompt.
- [ ] É possível acusar cada um dos 3 suspeitos e obter resolução sem crash.
- [ ] O relatório do julgamento é coerente com as escolhas feitas.
- [ ] O estado de uma tentativa não vaza para a próxima.

## Observações

- Cada fase tem sua própria seção de checklist; os itens são marcados na sessão gráfica de encerramento da fase.
- O driver temporário (cliques/teclas sintéticos com xdotool + screenshots com spectacle) deve ser removido antes do commit.
- A sessão gráfica deve ser conduzida em janela 1280×720, sem `ERROR:`/`SCRIPT ERROR:` no log do Godot.
