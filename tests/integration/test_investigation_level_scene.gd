extends UnitTestCase

## Nível de investigação (Fase 1): investigador, câmera, scanner de
## interação e HUD carregam sem erro.

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
	assert_eq(level.get_class(), "InvestigationLevel", "cena raiz é InvestigationLevel")
	assert_not_null(level.get_node("Actors/Investigator"), "investigador presente")
	assert_not_null(level.get_node("Camera2D"), "câmera presente")
	assert_not_null(level.get_node("InteractionScanner"), "scanner de interação presente")
	assert_not_null(level.get_node("HUD"), "HUD presente")
	level.free()


func test_investigator_has_movement_speed() -> void:
	var level = _instantiate_level()
	var investigator = level.get_node("Actors/Investigator")
	assert_not_null(investigator)
	assert_eq(investigator.move_speed, 220.0, "velocidade de movimento padrão")
	level.free()
