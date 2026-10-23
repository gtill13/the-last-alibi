extends CharacterBody2D
class_name InvestigatorController

@export var move_speed: float = 220.0

var velocity: Vector2 = Vector2.ZERO

# Sinal emitido quando o jogador pressiona a tecla de interação (one-shot).
signal interact_pressed

func _physics_process(delta: float) -> void:
    # Decisão 3: deslizamento lateral puro, sem gravidade nem plataforma.
    var direction: float = Input.get_axis("move_left", "move_right")
    velocity.x = direction * move_speed
    velocity.y = 0.0
    move_and_slide()

func _input(event: InputEvent) -> void:
    # Decisão 4: one-shot por evento de pressionamento — evita disparo duplo.
    if event is InputEventKey and event.pressed and event.keycode == KEY_E:
        interact_pressed.emit()

func get_interaction_direction() -> Vector2:
    # Retorna a direção visual do investigador (útil para animação futura).
    if velocity.x > 0:
        return Vector2.RIGHT
    elif velocity.x < 0:
        return Vector2.LEFT
    return Vector2.RIGHT
