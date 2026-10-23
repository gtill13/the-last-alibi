extends UnitTestCase

## InteractionScanner (Fase 1): detecção por distância, desempate
## determinístico por ID, desregistro automático ao sair de cena.

# Carrega o script Interactable explicitamente para garantir resolução da classe.
var interactable_script: GDScript = load("res://scripts/interactables/interactable.gd")

func _make_interactable(id: StringName, x: float) -> Area2D:
	var obj: Area2D = interactable_script.new() as Area2D
	obj.interactable_id = id
	obj.interaction_label = "Interagir"
	obj.is_interactable = true
	obj.global_position = Vector2(x, 0)
	return obj


func test_selects_closest_interactable() -> void:
	var scanner = InteractionScanner.new()
	scanner.interaction_range = 100.0

	var player = Node2D.new()
	player.global_position = Vector2(0, 0)
	scanner.player_node = player

	var a = _make_interactable(&"obj_a", 10.0)
	var b = _make_interactable(&"obj_b", 50.0)
	scanner.register_interactable(a)
	scanner.register_interactable(b)

	scanner._physics_process(0.016)
	assert_eq(scanner.get_current_target(), a, "objeto mais próximo (10) vence")


func test_tiebreaker_by_id_lexicographic() -> void:
	var scanner = InteractionScanner.new()
	scanner.interaction_range = 100.0

	var player = Node2D.new()
	player.global_position = Vector2(0, 0)
	scanner.player_node = player

	var a = _make_interactable(&"obj_zebra", 10.0)
	var b = _make_interactable(&"obj_alpha", 10.0)
	scanner.register_interactable(a)
	scanner.register_interactable(b)

	scanner._physics_process(0.016)
	assert_eq(scanner.get_current_target(), b, "empate de distância: vence ID menor (alpha)")


func test_out_of_range_not_selected() -> void:
	var scanner = InteractionScanner.new()
	scanner.interaction_range = 10.0

	var player = Node2D.new()
	player.global_position = Vector2(0, 0)
	scanner.player_node = player

	var far = _make_interactable(&"obj_far", 1000.0)
	scanner.register_interactable(far)

	scanner._physics_process(0.016)
	assert_null(scanner.get_current_target(), "fora de alcance não é selecionado")


func test_unregister_interactable_removes_from_scanner() -> void:
	var scanner = InteractionScanner.new()
	scanner.interaction_range = 100.0

	var player = Node2D.new()
	player.global_position = Vector2(0, 0)
	scanner.player_node = player

	var obj = _make_interactable(&"obj_temp", 10.0)
	scanner.register_interactable(obj)
	scanner._physics_process(0.016)
	assert_true(scanner.get_current_target() == obj, "objeto registrado é alvo")

	scanner.unregister_interactable(obj)
	assert_null(scanner.get_current_target(), "objeto desregistrado não é mais alvo")
