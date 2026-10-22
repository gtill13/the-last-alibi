extends CharacterBody2D
class_name InvestigatorController

@export var move_speed: float = 220.0
@export var interaction_range: float = 60.0

var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
    var direction: float = Input.get_axis("move_left", "move_right")
    velocity.x = direction * move_speed
    # Sem gravidade/plataforma no MVP: movimento lateral restrito ao chão.
    move_and_slide()

func get_interaction_direction() -> Vector2:
    # Retorna a direção visual do investigador (útil para animação futura).
    if velocity.x > 0:
        return Vector2.RIGHT
    elif velocity.x < 0:
        return Vector2.LEFT
    return Vector2.RIGHT
