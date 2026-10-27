class_name InvestigatorController
extends CharacterBody2D

## Movimento lateral puro, sem salto ou gravidade. A interação é emitida uma
## vez por pressionamento da ação do InputMap; key echo é ignorado.

signal interact_pressed

@export_range(50.0, 500.0, 10.0) var move_speed: float = 220.0


func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * move_speed
	velocity.y = 0.0
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact_pressed.emit()
		var viewport := get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()


func get_interaction_direction() -> Vector2:
	if velocity.x > 0.0:
		return Vector2.RIGHT
	if velocity.x < 0.0:
		return Vector2.LEFT
	return Vector2.RIGHT
