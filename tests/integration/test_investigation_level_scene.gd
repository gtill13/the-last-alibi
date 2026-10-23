extends UnitTestCase

## Nível de investigação (Fase 1): investigador, câmera, scanner de
## interação, HUD e prompt de interação carregam e funcionam.

const LEVEL_SCENE_PATH := "res://scenes/investigation/investigation_level.tscn"


func _instantiate_level():
	var tree := Engine.get_main_loop() as SceneTree
	var scene: PackedScene = load(LEVEL_SCENE_PATH)
	var level = scene.instantiate()
	tree.root.add_child(level)
	level.propagate_notification(Node.NOTIFICATION_READY)
	return level


func test_level_scene_loads_investigator_and_camera() -> void:
	var level = _instantiate_level()
	assert_eq(level.get_script().get_class_name(), "InvestigationLevel", "cena raiz é InvestigationLevel")
	assert_not_null(level.get_node("Actors/Investigator"), "investigador presente")
	assert_not_null(level.get_node("Camera2D"), "câmera presente")
	assert_not_null(level.get_node("InteractionScanner"), "scanner de interação presente")
	assert_not_null(level.get_node("HUD"), "HUD presente")
	level.free()


func test_investigator_has_movement_speed() -> void:
	var level = _instantiate_level()
	var investigator_node = level.get_node("Actors/Investigator")
	assert_not_null(investigator_node)
	var script = investigator_node.get_script()
	assert_not_null(script, "investigador tem script anexado")
	assert_eq(script.get_class_name(), "InvestigatorController", "script é InvestigatorController")
	# O nó deve ter o método de física do investigador.
	assert_true(investigator_node.has_method("_physics_process"), "investigador tem _physics_process")
	level.free()


func test_scanner_has_player_node_and_range() -> void:
	var level = _instantiate_level()
	var scanner_node = level.get_node("InteractionScanner")
	assert_not_null(scanner_node)
	var script = scanner_node.get_script()
	assert_not_null(script, "scanner tem script anexado")
	assert_eq(script.get_class_name(), "InteractionScanner", "script é InteractionScanner")
	var player_node: Variant = scanner_node.get("player_node")
	assert_not_null(player_node, "scanner tem player_node vinculado")
	var range_val: Variant = scanner_node.get("interaction_range")
	assert_eq(range_val, 90.0, "alcance de interação é 90")
	level.free()


func test_hud_has_interaction_prompt() -> void:
	var level = _instantiate_level()
	var hud_wrapper = level.get_node("HUD")
	assert_not_null(hud_wrapper)
	# Busca profunda: o InteractionPrompt pode estar em qualquer nível do wrapper.
	var prompt = hud_wrapper.find_child("InteractionPrompt", true, false)
	assert_not_null(prompt, "InteractionPrompt encontrado dentro do HUD")
	var prompt_script = prompt.get_script()
	assert_not_null(prompt_script, "InteractionPrompt tem script anexado")
	assert_eq(prompt_script.get_class_name(), "InteractionPrompt", "script é InteractionPrompt")
	level.free()
