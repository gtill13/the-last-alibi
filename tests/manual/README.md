# Verificação manual — The Last Alibi (Fase 1)

Roteiro para conferir, numa sessão gráfica, o que os testes headless não cobrem do M1.
O registro oficial da execução de 26/10/2026 está em `docs/M1_TESTS.md`.

## Como executar (sessão gráfica)

```bash
export GODOT_BIN="/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
"$GODOT_BIN" --path .
```

No menu, pressione **Enter** para iniciar o caso. Use **A/D** ou as setas para andar, **E** para interagir e **Esc** para fechar diálogos/modais.

## Driver auxiliar (xdotool + ImageMagick)

```bash
./tests/manual/driver_interface.sh
```

O driver:
1. inicia o jogo em 1280×720;
2. foca a janela com `xdotool windowfocus`;
3. captura o menu e o nível com `import -window`;
4. aproxima do vidro em pulsos curtos, interage e verifica prompt/feedback;
5. mantém E por 2 s para conferir que não há repetição por key echo;
6. afasta o jogador e confirma que o prompt some.

As capturas ficam em `tests/manual/screenshots/fase1/` (diretório marcado com `.gdignore`, para o Godot não importar as imagens). O driver é auxiliar: a fonte de verdade são `./tests/run_tests.sh` e o registro em `docs/M1_TESTS.md`.

---

## Checklist — Fase 1 (movimento + interação)

### Automatizado (`./tests/run_tests.sh`)

- [x] `test_investigator_controller.gd::test_investigator_default_move_speed`
- [x] `test_investigator_controller.gd::test_investigator_is_character_body2d`
- [x] `test_investigator_controller.gd::test_physics_process_sets_velocity_x`
- [x] `test_investigator_controller.gd::test_interact_action_emitted_once_per_press`
- [x] `test_investigator_controller.gd::test_key_echo_does_not_repeat_interaction`
- [x] `test_investigator_controller.gd::test_unrelated_key_does_not_interact`
- [x] `test_interaction_scanner.gd::test_selects_closest_interactable`
- [x] `test_interaction_scanner.gd::test_tiebreaker_by_id_lexicographic`
- [x] `test_interaction_scanner.gd::test_out_of_range_not_selected`
- [x] `test_interaction_scanner.gd::test_unregister_interactable_removes_from_scanner`
- [x] `test_interaction_scanner.gd::test_deactivated_target_is_not_selected`
- [x] `test_interaction_scanner.gd::test_queued_target_is_pruned_without_invalid_reference`
- [x] `test_interaction_scanner.gd::test_range_comes_from_circle_shape`
- [x] `test_interaction_prompt.gd::test_prompt_hides_without_target`
- [x] `test_interaction_prompt.gd::test_prompt_shows_action_and_display_name`
- [x] `test_interaction_prompt.gd::test_prompt_hides_for_deactivated_target`
- [x] `test_investigation_level_scene.gd::test_level_scene_loads_player_camera_and_scanner`
- [x] `test_investigation_level_scene.gd::test_scanner_range_comes_from_circle_shape`
- [x] `test_investigation_level_scene.gd::test_player_collision_layers_match_world_and_interactables`
- [x] `test_investigation_level_scene.gd::test_level_has_three_unique_interactables`
- [x] `test_investigation_level_scene.gd::test_prompt_updates_for_nearest_target_in_real_level`
- [x] `test_investigation_level_scene.gd::test_exact_distance_tie_prefers_lower_id_in_real_level`
- [x] `test_investigation_level_scene.gd::test_deactivated_active_target_clears_prompt_in_real_level`
- [x] `test_investigation_level_scene.gd::test_queued_free_active_target_clears_prompt_in_real_level`

### Visual (sessão gráfica)

- [x] O investigador aparece na cena ao iniciar o caso
- [x] O investigador se move para direita com D e seta direita
- [x] O investigador se move para esquerda com A e seta esquerda
- [x] O investigador não atravessa o piso ou os limites laterais
- [x] O prompt aparece ao aproximar do vidro e mostra `[E] Examinar — Vidro quebrado`
- [x] O prompt muda para `[E] Entrevistar — Mara` ao chegar mais perto de Mara
- [x] O prompt desaparece ao se afastar dos alvos
- [x] Pressionar E uma única vez gera um único resultado de depuração
- [x] Segurar E por 2 s não repete a interação
- [x] A câmera acompanha o investigador e respeita os limites do cenário
- [x] O ID de depuração e o contorno aparecem sobre o alvo ativo
- [x] Não há referência inválida ao desativar ou liberar o alvo ativo (teste de integração)

---

## Demo de arte procedural

A demo é independente do M1 e valida o sistema descrito em `docs/ARTE_PROCEDURAL.md`.

```bash
export GODOT_BIN="/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
"$GODOT_BIN" --path . res://scenes/procedural/procedural_art_demo.tscn
```

Na demo, **1** volta para a mesa de madeira clara e **2** troca para a variante escura. Tudo é desenhado por código; não há sprites, texturas ou imagens externas.

### Driver auxiliar

```bash
./tests/manual/driver_procedural_art.sh
```

O driver captura a cena padrão, a variante escura e o retorno à variante clara em `tests/manual/screenshots/procedural-art/`.

### Checklist da demo

- [x] Fundo, mesa, planta, quadro e detetive aparecem sem sprites
- [x] O mesmo renderer desenha todos os objetos
- [x] A tecla 2 troca a definição da mesa e o desenho muda
- [x] A tecla 1 retorna à definição original
- [x] Duas instâncias do mesmo prefab podem ocupar posições independentes
- [x] O cache reutiliza instâncias e respeita o limite do pool (testes automatizados)
- [x] A cena abre em 1280×720 sem erros ou warnings de desenho

## Observações

- O empate exato de distância é validado por teste de integração determinístico; a temporização de teclado não garante posições fracionárias exatas.
- A ausência de bloqueio por linha de visão é uma limitação conhecida do M1: o cenário é aberto e não posiciona alvos atrás de paredes.
- Caderno, entrevistas, dossiê e julgamento pertencem a fases posteriores e não são critério do M1.
