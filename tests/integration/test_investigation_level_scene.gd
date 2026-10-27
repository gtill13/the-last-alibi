extends UnitTestCase

## Nível de investigação (Fase 1): cena real com piso/limites, câmera filha do
## jogador, scanner circular, três alvos e prompt integrado ao controlador.

const LEVEL_SCENE_PATH := "res://scenes/investigation/investigation_level.tscn"


func _instantiate_level():
	var tree := Engine.get_main_loop() as SceneTree
	var scene: PackedScene = load(LEVEL_SCENE_PATH)
	var level = scene.instantiate()
	tree.root.add_child(level)
	return level


func test_level_scene_loads_player_camera_and_scanner() -> void:
	var level = _instantiate_level()
	assert_true(level is InvestigationController, "cena raiz é InvestigationController")

	var investigator = level.get_node("Actors/Investigator")
	assert_not_null(investigator, "investigador presente")
	assert_true(investigator is CharacterBody2D, "investigador é CharacterBody2D")

	var camera = level.get_node("Actors/Investigator/Camera2D")
	assert_not_null(camera, "câmera presente")
	assert_eq(camera.get_parent(), investigator, "câmera é filha do investigador")
	assert_true(camera.enabled, "câmera habilitada")
	assert_eq(camera.limit_left, 0, "limite esquerdo da câmera")
	assert_eq(camera.limit_right, 2400, "limite direito cobre a fase larga")

	var scanner = level.get_node("Actors/Investigator/InteractionScanner")
	assert_not_null(scanner, "scanner de interação presente")
	assert_eq(scanner.get_parent(), investigator, "scanner é filho do investigador")
	level.free()


func test_scanner_range_comes_from_circle_shape() -> void:
	var level = _instantiate_level()
	var scanner = level.get_node("Actors/Investigator/InteractionScanner")
	var shape_node: CollisionShape2D = scanner.get_node("CollisionShape2D")
	assert_not_null(shape_node.shape, "scanner tem forma de colisão")
	assert_true(shape_node.shape is CircleShape2D, "forma do scanner é círculo")
	assert_eq(shape_node.shape.radius, 90.0, "raio de interação é 90")
	assert_eq(scanner.get_interaction_range(), 90.0, "scanner lê o raio da forma")
	level.free()


func test_player_collision_layers_match_world_and_interactables() -> void:
	var level = _instantiate_level()
	var investigator: CharacterBody2D = level.get_node("Actors/Investigator")
	assert_eq(investigator.collision_layer, 2, "jogador está na camada Player")
	assert_eq(investigator.collision_mask, 1, "jogador colide com World")

	var floor_body: StaticBody2D = level.get_node("Environment/Floor")
	assert_eq(floor_body.collision_layer, 1, "piso está na camada World")
	assert_not_null(floor_body.get_node("CollisionShape2D").shape, "piso tem colisão")

	var boundary: StaticBody2D = level.get_node("Environment/LeftBoundary")
	assert_not_null(boundary.get_node("CollisionShape2D").shape, "limite esquerdo tem colisão")

	var scanner: Area2D = level.get_node("Actors/Investigator/InteractionScanner")
	assert_eq(scanner.collision_mask, 4, "scanner detecta a camada Interactable")
	level.free()


func test_level_has_three_unique_interactables() -> void:
	var level = _instantiate_level()
	var interactables = level.get_node("Interactables")
	assert_eq(interactables.get_child_count(), 3, "três alvos de teste")

	var ids: Array[StringName] = []
	for child in interactables.get_children():
		assert_true(child is Interactable, "filho é Interactable")
		assert_false(child.interactable_id == &"", "alvo tem ID preenchido")
		assert_true(child.is_in_group("interactables"), "alvo está no grupo interactables")
		assert_false(ids.has(child.interactable_id), "ID não duplicado")
		ids.append(child.interactable_id)

	assert_true(ids.has(&"evidence_broken_glass"), "vidro quebrado presente")
	assert_true(ids.has(&"suspect_mara"), "Mara presente")
	assert_true(ids.has(&"exit_apartment"), "saída presente")
	level.free()


func test_prompt_updates_for_nearest_target_in_real_level() -> void:
	var level = _instantiate_level()
	var investigator = level.get_node("Actors/Investigator")
	var scanner = level.get_node("Actors/Investigator/InteractionScanner")
	var glass = level.get_node("Interactables/BrokenGlass")
	var prompt = level.get_node("HUD/InteractionPrompt")

	investigator.global_position = glass.global_position + Vector2(10.0, 0.0)
	scanner.register_interactable(glass)
	scanner._physics_process(0.016)

	assert_eq(scanner.get_current_target(), glass, "vidro é o alvo mais próximo")
	assert_true(prompt.visible, "prompt fica visível")
	assert_eq(
		prompt.get_node("PromptLabel").text,
		"[E] Examinar — Vidro quebrado",
		"prompt mostra ação e nome"
	)
	level.free()


func test_exact_distance_tie_prefers_lower_id_in_real_level() -> void:
	var level = _instantiate_level()
	var investigator = level.get_node("Actors/Investigator")
	var scanner = level.get_node("Actors/Investigator/InteractionScanner")
	var glass = level.get_node("Interactables/BrokenGlass")
	var mara = level.get_node("Interactables/Mara")
	var prompt = level.get_node("HUD/InteractionPrompt")

	investigator.global_position = Vector2.ZERO
	glass.global_position = Vector2(-50.0, 0.0)
	mara.global_position = Vector2(50.0, 0.0)
	scanner.register_interactable(mara)
	scanner.register_interactable(glass)
	scanner._physics_process(0.016)

	assert_eq(scanner.get_current_target(), glass, "empate exato: vence o ID lexicograficamente menor")
	assert_eq(
		prompt.get_node("PromptLabel").text,
		"[E] Examinar — Vidro quebrado",
		"prompt corresponde ao alvo vencedor do empate"
	)
	level.free()


func test_deactivated_active_target_clears_prompt_in_real_level() -> void:
	var level = _instantiate_level()
	var investigator = level.get_node("Actors/Investigator")
	var scanner = level.get_node("Actors/Investigator/InteractionScanner")
	var glass = level.get_node("Interactables/BrokenGlass")
	var prompt = level.get_node("HUD/InteractionPrompt")

	investigator.global_position = glass.global_position
	scanner.register_interactable(glass)
	scanner._physics_process(0.016)
	assert_eq(scanner.get_current_target(), glass, "vidro é o alvo ativo antes da desativação")
	assert_true(prompt.visible, "prompt visível antes da desativação")

	glass.is_interactable = false
	scanner._physics_process(0.016)
	assert_null(scanner.get_current_target(), "alvo desativado deixa de ser selecionável")
	assert_false(prompt.visible, "prompt desaparece ao desativar o alvo")
	level.free()


func test_queued_free_active_target_clears_prompt_in_real_level() -> void:
	var level = _instantiate_level()
	var investigator = level.get_node("Actors/Investigator")
	var scanner = level.get_node("Actors/Investigator/InteractionScanner")
	var glass = level.get_node("Interactables/BrokenGlass")
	var prompt = level.get_node("HUD/InteractionPrompt")

	investigator.global_position = glass.global_position
	scanner.register_interactable(glass)
	scanner._physics_process(0.016)
	assert_eq(scanner.get_current_target(), glass, "vidro é o alvo ativo antes do queue_free")
	assert_true(prompt.visible, "prompt visível antes do queue_free")

	glass.queue_free()
	scanner._physics_process(0.016)
	assert_null(scanner.get_current_target(), "alvo em queue_free deixa de ser selecionável")
	assert_false(scanner._nearby_targets.has(glass), "referência inválida removida da lista")
	assert_false(prompt.visible, "prompt desaparece ao liberar o alvo")
	level.free()
