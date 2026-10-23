extends UnitTestCase

## Investigador (Fase 1): movimento lateral puro, velocidade padrão,
## one-shot por tecla de interação (sem disparo duplo).

func test_investigator_default_move_speed() -> void:
	var investigator = InvestigatorController.new()
	assert_eq(investigator.move_speed, 220.0, "velocidade padrão é 220")


func test_investigator_is_character_body2d() -> void:
	var investigator = InvestigatorController.new()
	assert_true(investigator is CharacterBody2D, "investigador herda CharacterBody2D")


func test_interact_pressed_emitted_once_per_key_event() -> void:
	var investigator = InvestigatorController.new()
	var calls := [0]
	investigator.interact_pressed.connect(func() -> void: calls[0] += 1)

	var event = InputEventKey.new()
	event.keycode = KEY_E
	event.pressed = true
	investigator._input(event)
	assert_eq(calls[0], 1, "interact_pressed emitido exatamente uma vez")

	event.pressed = false
	investigator._input(event)
	assert_eq(calls[0], 1, "não emite novamente no release")
