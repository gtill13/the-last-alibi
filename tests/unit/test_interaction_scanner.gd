extends UnitTestCase

## InteractionScanner (Fase 1): detecção por distância, desempate
## determinístico por ID, desregistro automático e descarte de inválidos.

var interactable_script: GDScript = load("res://scripts/interactables/interactable.gd")


func _make_scanner(radius: float) -> InteractionScanner:
	var scanner := InteractionScanner.new()
	var shape_node := CollisionShape2D.new()
	shape_node.name = "CollisionShape2D"
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape_node.shape = circle
	scanner.add_child(shape_node)
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(scanner)
	return scanner


func _make_interactable(id: StringName, x: float, y: float = 0.0) -> Interactable:
	var obj := interactable_script.new() as Interactable
	obj.interactable_id = id
	obj.interaction_label = "Interagir"
	obj.display_name = str(id)
	obj.is_interactable = true
	obj.position = Vector2(x, y)
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(obj)
	return obj


func test_selects_closest_interactable() -> void:
	var scanner := _make_scanner(100.0)
	var a := _make_interactable(&"obj_a", 10.0)
	var b := _make_interactable(&"obj_b", 50.0)
	scanner.register_interactable(a)
	scanner.register_interactable(b)

	scanner._physics_process(0.016)
	assert_eq(scanner.get_current_target(), a, "objeto mais próximo (10) vence")

	scanner.free()
	a.free()
	b.free()


func test_tiebreaker_by_id_lexicographic() -> void:
	var scanner := _make_scanner(100.0)
	var a := _make_interactable(&"obj_zebra", 10.0)
	var b := _make_interactable(&"obj_alpha", 10.0)
	scanner.register_interactable(a)
	scanner.register_interactable(b)

	scanner._physics_process(0.016)
	assert_eq(scanner.get_current_target(), b, "empate de distância: vence ID menor (alpha)")

	scanner.free()
	a.free()
	b.free()


func test_out_of_range_not_selected() -> void:
	var scanner := _make_scanner(10.0)
	var far := _make_interactable(&"obj_far", 1000.0)
	scanner.register_interactable(far)

	scanner._physics_process(0.016)
	assert_null(scanner.get_current_target(), "fora de alcance não é selecionado")

	scanner.free()
	far.free()


func test_unregister_interactable_removes_from_scanner() -> void:
	var scanner := _make_scanner(100.0)
	var obj := _make_interactable(&"obj_temp", 10.0)
	scanner.register_interactable(obj)
	scanner._physics_process(0.016)
	assert_true(scanner.get_current_target() == obj, "objeto registrado é alvo")

	scanner.unregister_interactable(obj)
	assert_null(scanner.get_current_target(), "objeto desregistrado não é mais alvo")

	scanner.free()
	obj.free()


func test_deactivated_target_is_not_selected() -> void:
	var scanner := _make_scanner(100.0)
	var obj := _make_interactable(&"obj_off", 10.0)
	scanner.register_interactable(obj)
	scanner._physics_process(0.016)
	assert_true(scanner.get_current_target() == obj, "objeto ativo é selecionado")

	obj.is_interactable = false
	scanner._physics_process(0.016)
	assert_null(scanner.get_current_target(), "alvo desativado deixa de ser selecionável")

	scanner.free()
	obj.free()


func test_queued_target_is_pruned_without_invalid_reference() -> void:
	var scanner := _make_scanner(100.0)
	var obj := _make_interactable(&"obj_free", 10.0)
	scanner.register_interactable(obj)
	scanner._physics_process(0.016)
	assert_true(scanner.get_current_target() == obj, "objeto ativo é selecionado")

	obj.queue_free()
	scanner._physics_process(0.016)
	assert_null(scanner.get_current_target(), "alvo em queue_free deixa de ser selecionado")
	assert_false(scanner._nearby_targets.has(obj), "referência inválida removida")

	scanner.free()
	if is_instance_valid(obj):
		obj.free()


func test_range_comes_from_circle_shape() -> void:
	var scanner := _make_scanner(90.0)
	assert_eq(scanner.get_interaction_range(), 90.0, "alcance lido do CircleShape2D")
	scanner.free()
