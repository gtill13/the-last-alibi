# M1 — Registro de testes (movimento, câmera e interação)

> **Fase:** 1 — Movimento lateral, câmera e interação por proximidade  
> **Data da execução:** 26/10/2026  
> **Escopo:** somente o M1 descrito em `DETALHAMENTO_FASE_1.md`.  
> **Resultado geral:** aprovado no escopo do M1, com as limitações registradas ao final.

## Ambiente

| Item | Valor |
|---|---|
| Sistema | Linux |
| Godot | `4.7.2.stable.official.ed1daf0bf` (build de ferramentas, X11) |
| Executável | `/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64` |
| Sessão gráfica | `DISPLAY=:1`, janela 1280×720 |
| Entrada sintética | `xdotool` para foco/teclas pontuais e auxiliar XTest para manter teclas pressionadas |
| Captura | ImageMagick `import -window <id>` |

## Resumo

- **Testes automatizados:** `35 passaram, 0 falharam` em 8 suítes; processo terminou com código `0`.
- **Cena real em headless:** carregou e executou 5 frames sem `ERROR`, `SCRIPT ERROR`, erro de parse ou recurso ausente.
- **Sessão gráfica:** T01–T06, T08, T09 e T12–T14 executados na janela real. T07, T10 e T11 foram validados por testes de integração na cena real, porque dependem de posicionamento exato ou de manipulação destrutiva de nós.
- **Log da sessão gráfica:** sem `ERROR`, `SCRIPT ERROR`, `WARNING` ou falha de recurso; exatamente 3 linhas de interação para 3 acionamentos de E (um pressionamento, um E segurado por 2 s e um acionamento após troca rápida de alvo).

## Como reproduzir

```bash
cd /home/till/Projects/the-last-alibi
./tests/run_tests.sh
```

Cena do nível diretamente, sem interface:

```bash
"/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64" \
  --headless --path . \
  res://scenes/investigation/investigation_level.tscn --quit-after 5
```

Sessão gráfica:

```bash
"/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64" \
  --path . --log-file /tmp/opencode/manual_game.log
```

As capturas desta execução estão em `tests/manual/screenshots/fase1/`.

## Testes automatizados

Resultado integral: `== Resultado: 35 passaram, 0 falharam (8 suítes, 35 testes descobertos) ==`

Cobertura relevante para o M1:

| Área | Testes |
|---|---|
| Movimento | velocidade padrão 220, `CharacterBody2D`, `velocity.x`, `velocity.y == 0` |
| Interação one-shot | um evento por pressionamento, release não repete, key echo ignorado, tecla fora da ação não interage |
| Scanner | alvo mais próximo, desempate por ID, fora de alcance, alvo desativado, `queue_free`, desregistro, raio lido do `CircleShape2D` |
| Prompt | oculto sem alvo, visível com alvo, texto com ação e nome, oculto para alvo desativado |
| Cena real | piso/limites, câmera filha do jogador, limites da câmera, camadas de colisão, três IDs únicos, prompt integrado |
| Casos destrutivos em cena real | empate exato de distância, desativação do alvo ativo e `queue_free()` do alvo ativo |

Testes de integração adicionados nesta validação:

- `test_investigation_level_scene.gd::test_exact_distance_tie_prefers_lower_id_in_real_level`
- `test_investigation_level_scene.gd::test_deactivated_active_target_clears_prompt_in_real_level`
- `test_investigation_level_scene.gd::test_queued_free_active_target_clears_prompt_in_real_level`

## Plano manual T01–T14

| ID | Teste | Método e evidência | Resultado |
|---|---|---|---|
| T01 | Iniciar a cena | Cena real headless com `--quit-after 5` terminou com código 0 e log limpo; entrada gráfica pelo menu iniciou o nível em `x=180`, prompt oculto e sem erros. Evidência: `f1_02_level_start.png`. | **Passou** |
| T02 | Pressionar A/D e setas | D por 1 s: `180 → 400` (+220 px). A por 1 s: `400 → 180` (−220 px). Seta direita por 0,5 s: +110 px. Seta esquerda por 0,5 s: −110 px. Evidências: `f1_03_move_right.png`, `f1_04_move_left.png`, `f1_04b_arrow_right.png`, `f1_04c_arrow_left.png`. | **Passou** |
| T03 | Segurar uma direção por 5 s | D mantido por 8 s: parou no limite direito em `x=2331`. A mantido por 12 s: parou no limite esquerdo em `x=69`. `screen_y` permaneceu `559,5` em todas as capturas; o jogador não atravessou piso ou paredes. Evidências: `f1_13_right_boundary.png`, `f1_14_left_boundary.png`. | **Passou** |
| T04 | Entrar no alcance de um alvo | Em `x≈703`, a cerca de 57 px do vidro, o prompt mostrou `[E] Examinar — Vidro quebrado`, com contorno e ID `evidence_broken_glass`. Evidência: `f1_05_prompt_glass.png`. | **Passou** |
| T05 | Sair do alcance | Em `x=624`, fora do raio de 90 px dos dois alvos próximos, o prompt ficou oculto e nenhum alvo permaneceu ativo. Evidência: `f1_09_prompt_hidden.png`. | **Passou** |
| T06 | Aproximar-se de dois alvos | Em `x=836`, Mara (`x=860`) ficou mais próxima que o vidro (`x=760`) e foi selecionada; prompt `[E] Entrevistar — Mara`. Evidência: `f1_08_nearest_mara.png`. | **Passou** |
| T07 | Dois alvos com a mesma distância | Teste de integração na cena real posiciona jogador em `(0,0)`, vidro em `(-50,0)` e Mara em `(50,0)`; vence `evidence_broken_glass`, o menor ID lexicográfico, e o prompt corresponde a ele. Na sessão gráfica, medições consecutivas mostraram o vidro ativo em `x=807` e Mara ativa em `x=811`; a captura final em `x=811` está em `f1_10_tie_midpoint.png`. O empate exato não é reproduzível de forma confiável por temporização de teclado. | **Passou** (automatizado em cena real) |
| T08 | Pressionar E uma vez | Um pressionamento gerou exatamente 1 nova linha `[INVESTIGAÇÃO]`; a mensagem exibida foi `Examinado: Vidro quebrado`. Evidência: `f1_06_interact_once.png`. | **Passou** |
| T09 | Segurar E por 2 s | E mantido por 2 s gerou exatamente 1 nova linha `[INVESTIGAÇÃO]` e uma mensagem `Já examinada: Vidro quebrado`; não houve repetição por key echo. Evidência: `f1_07_hold_e.png`. | **Passou** |
| T10 | Desativar o alvo ativo | Teste de integração na cena real: com o vidro ativo e prompt visível, `is_interactable = false` faz o scanner devolver `null` e o prompt desaparecer no frame seguinte. | **Passou** (automatizado em cena real) |
| T11 | Executar `queue_free()` no alvo ativo | Teste de integração na cena real: após `queue_free()` do vidro, o scanner remove a referência, não seleciona alvo inválido e oculta o prompt, sem erro de instância inválida. | **Passou** (automatizado em cena real) |
| T12 | Percorrer o cenário de ponta a ponta | A câmera acompanhou o jogador: em `x=1495`, jogador em `screen_x=639,5` e câmera em `855,5`; no limite direito, `camera_left=1120,5`; no esquerdo, `0,5`. HUD e prompt permaneceram fixos. Evidências: `f1_15_camera_mid.png`, `f1_13_right_boundary.png`, `f1_14_left_boundary.png`. | **Passou** |
| T13 | Alternar rapidamente entre alvos | Sequência D/A/D terminou com o vidro ativo em `x=803`; E produziu `Já examinada: Vidro quebrado`, correspondendo ao alvo mostrado. Evidência: `f1_12_rapid_interact.png`. | **Passou** |
| T14 | Reiniciar a cena várias vezes | Três ciclos completos de iniciar o jogo e entrar no caso; em todos o jogador iniciou em `x=180`, prompt oculto e log sem erros ou conexões duplicadas. Evidências: `f1_restart_1.png` a `f1_restart_3.png`. | **Passou** |

## Critérios de aceite adicionais

| Critério | Evidência | Resultado |
|---|---|---|
| Sem erros de parse ou referências quebradas | Cena real headless e suíte completa com código 0 | **Passou** |
| Movimento em `_physics_process()` + `move_and_slide()` | Implementação e teste `test_physics_process_sets_velocity_x` | **Passou** |
| Alcance lido do `CircleShape2D` (raio 90) | `test_scanner_range_comes_from_circle_shape` e `test_range_comes_from_circle_shape` | **Passou** |
| IDs únicos e preenchidos | `test_level_has_three_unique_interactables` | **Passou** |
| Prompt e `DebugMessage` fixos na tela | `CanvasLayer` da HUD; capturas em posições diferentes de câmera | **Passou** |
| Sem referência inválida ao liberar alvo | testes de scanner e de cena real com `queue_free()` | **Passou** |
| Log da sessão sem erros/warnings novos | `/tmp/opencode/manual_scenario.log` filtrado | **Passou** |

## Limitações conhecidas

1. **Sem linha de visão:** a seleção usa proximidade e não verifica paredes. O cenário do M1 é aberto e não coloca alvos atrás de paredes, conforme permitido na seção 8 do detalhamento. Um `RayCast2D` só deve ser adicionado quando houver um caso real que exija bloqueio por parede.
2. **Empate exato de distância:** validado por teste de integração determinístico, não por temporização de teclado na sessão gráfica.
3. **T10 e T11:** validados por testes de integração na cena real, pois exigem desativar/liberar o nó ativo; não foram reproduzidos por atalho de teclado.
4. **Escopo:** o M1 entrega apenas feedback de depuração na interação. Caderno, entrevistas, dossiê e julgamento pertencem a fases posteriores e não foram avaliados aqui, embora a cena real já os instancie.
5. **Status do caso:** o rótulo `Caso: —` da HUD pertence ao fluxo de fases posteriores e não é atualizado no M1.
6. **Arte e áudio:** placeholders apenas; sem arte, animação, música ou efeitos finais.

## Correções necessárias durante a validação

- Os arquivos `.tres` de suspeitos tinham `[sub_resource]` sem `type` e fora de ordem; foram reescritos no formato canônico do Godot 4.
- Os testes atribuíam arrays sem tipo a propriedades `Array[T]`; os fixtures agora usam arrays tipados, eliminando `SCRIPT ERROR`s que antes eram mascarados pelo filtro do runner.
- O teste de dossiê vazio não adicionava o suspeito ao caso, então o avaliador retornava `INCONCLUSIVE` antes de exercitar a regra de dossiê vazio; o fixture foi corrigido.
- `NotebookScreenUI` chamava `ItemList.add_subitem()`, método inexistente no Godot 4; a descrição agora vai no tooltip do item.
- Uma única interação de exame gerava duas mensagens de depuração; agora gera uma mensagem consolidada, mantendo o requisito de um resultado por pressionamento.
