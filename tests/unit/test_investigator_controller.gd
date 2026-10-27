extends UnitTestCase

## Investigador (Fase 1): movimento lateral puro, velocidade padrão,
## interação pela ação do InputMap e one-shot por pressionamento (sem echo).


func _make_investigator() -> InvestigatorController:
	var investigator := InvestigatorController.new()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(investigator)
	return investigator


func test_investigator_default_move_speed() -> void:
	var investigator := InvestigatorController.new()
	assert_eq(investigator.move_speed, 220.0, "velocidade padrão é 220")
	investigator.free()


func test_investigator_is_character_body2d() -> void:
	var investigator := InvestigatorController.new()
	assert_true(investigator is CharacterBody2D, "investigador herda CharacterBody2D")
	investigator.free()


func test_physics_process_sets_velocity_x() -> void:
	var investigator := _make_investigator()
	Input.action_press("move_right")
	investigator._physics_process(0.016)
	Input.action_release("move_right")

	assert_eq(investigator.velocity.x, investigator.move_speed, "direita aplica velocidade positiva")
	assert_eq(investigator.velocity.y, 0.0, "movimento é horizontal puro")
	investigator.free()


func test_interact_action_emitted_once_per_press() -> void:
	var investigator := _make_investigator()
	var calls := [0]
	investigator.interact_pressed.connect(func() -> void: calls[0] += 1)

	var press := InputEventAction.new()
	press.action = "interact"
	press.pressed = true
	investigator._unhandled_input(press)
	assert_eq(calls[0], 1, "interact_pressed emitido exatamente uma vez")

	var release := InputEventAction.new()
	release.action = "interact"
	release.pressed = false
	investigator._unhandled_input(release)
	assert_eq(calls[0], 1, "não emite novamente no release")
	investigator.free()


func test_key_echo_does_not_repeat_interaction() -> void:
	var investigator := _make_investigator()
	var calls := [0]
	investigator.interact_pressed.connect(func() -> void: calls[0] += 1)

	var echo := InputEventKey.new()
	echo.physical_keycode = KEY_E
	echo.pressed = true
	echo.echo = true
	investigator._unhandled_input(echo)
	assert_eq(calls[0], 0, "key echo não repete a interação")
	investigator.free()


func test_unrelated_key_does_not_interact() -> void:
	var investigator := _make_investigator()
	var calls := [0]
	investigator.interact_pressed.connect(func() -> void: calls[0] += 1)

	var event := InputEventKey.new()
	event.physical_keycode = KEY_Q
	event.pressed = true
	investigator._unhandled_input(event)
	assert_eq(calls[0], 0, "tecla fora da ação interact não interage")
	investigator.free()
