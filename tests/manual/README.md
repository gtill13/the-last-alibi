# Verificação manual — The Last Alibi (Fase 1)

Roteiro para conferir, numa sessão gráfica, o que os testes headless não cobrem da Fase 1.

## Como executar (sessão gráfica)

```bash
export GODOT_BIN="/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
"$GODOT_BIN" --path .
```

## Driver temporário de interface (xdotool + spectacle)

```bash
./tests/manual/driver_interface.sh
```

O driver inicia o jogo em 1280×720, tira screenshots com `spectacle` e simula teclas com `xdotool`:
1. Menu → Start Case
2. Nível de investigação (investigador aparece, câmera segue)
3. Movimenta para direita (D)
4. Interage (E) com o alvo mais próximo
5. Movimenta para esquerda (A)
6. Abre caderno (N)
7. Fecha caderno (Esc)

Os screenshots ficam em `tests/manual/screenshots/fase1/`.

---

## Checklist — Fase 1 (movimento + interação)

### Código (headless — `./tests/run_tests.sh`)
- [ ] `test_investigator_controller.gd::test_investigator_default_move_speed` — velocidade padrão 220
- [ ] `test_investigator_controller.gd::test_investigator_is_character_body2d` — herda CharacterBody2D
- [ ] `test_investigator_controller.gd::test_physics_process_sets_velocity_x` — movimento lateral aplica velocidade
- [ ] `test_investigator_controller.gd::test_interact_pressed_emitted_once_per_key_event` — one-shot por tecla E
- [ ] `test_interaction_scanner.gd::test_selects_closest_interactable` — escolhe o mais próximo
- [ ] `test_interaction_scanner.gd::test_tiebreaker_by_id_lexicographic` — desempate por ID determinístico
- [ ] `test_interaction_scanner.gd::test_out_of_range_not_selected` — fora de alcance não é selecionado
- [ ] `test_interaction_scanner.gd::test_unregister_on_exit_tree_removes_from_scanner` — remove ao sair de cena
- [ ] `test_investigation_level_scene.gd::test_level_scene_loads_investigator_and_camera` — cena carrega corretamente
- [ ] `test_investigation_level_scene.gd::test_investigator_has_movement_speed` — velocidade do investigador
- [ ] `test_investigation_level_scene.gd::test_scanner_has_player_node_and_range` — scanner vinculado ao jogador
- [ ] `test_investigation_level_scene.gd::test_hud_has_interaction_prompt` — HUD tem prompt

### Visual (sessão gráfica com driver xdotool/spectacle)
- [ ] O investigador aparece na cena ao iniciar o caso
- [ ] O investigador se move para direita com a tecla D
- [ ] O investigador se move para esquerda com a tecla A
- [ ] O investigador não atravessa o piso/obstáculos
- [ ] O prompt de interação aparece ao aproximar de um objeto/NPC/saída
- [ ] O prompt exibe o texto correto por tipo ("[E] Examinar", "[E] Entrevistar", "[E] Sair")
- [ ] O prompt desaparece ao se afastar do objeto
- [ ] Se dois objetos estiverem próximos, a interação selecionada é clara e previsível (o mais próximo)
- [ ] Pressionar E uma única vez não dispara duas interações
- [ ] A câmera acompanha o investigador sem recortes abruptos
- [ ] O identificador de depuração (ID) aparece sobre o objeto quando próximo
- [ ] O contorno visual diferente aparece sobre o objeto quando próximo
- [ ] Não há referência inválida quando um objeto sai de cena

---

## Observações

- Cada fase tem sua própria seção de checklist; os itens são marcados na sessão gráfica de encerramento da fase.
- O driver temporário (cliques/teclas sintéticos com xdotool + screenshots com spectacle) deve ser removido antes do commit.
- A sessão gráfica deve ser conduzida em janela 1280×720, sem `ERROR:`/`SCRIPT ERROR:` no log do Godot.
