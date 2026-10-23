extends Interactable
class_name ExitPoint

signal exit_requested

@export var confirm_text: String = "Encerrar a visita e montar o dossiê?"

func _ready() -> void:
    super._ready()
    interaction_requested.connect(_on_interaction_requested)
    if debug_label != null:
        debug_label.text = str(interactable_id)

func _on_interaction_requested(id: StringName) -> void:
    if id == interactable_id:
        exit_requested.emit()
