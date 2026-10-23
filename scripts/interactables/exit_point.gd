extends Area2D
class_name ExitPoint

signal exit_requested

@export var interaction_label: String = "Encerrar investigação"
@export var confirm_text: String = "Encerrar a visita e montar o dossiê?"

func _ready() -> void:
    interaction_requested.connect(_on_interaction_requested)
    if DebugIdLabel != null:
        DebugIdLabel.text = str(interactable_id)

func _on_interaction_requested(id: StringName) -> void:
    if id == interactable_id:
        exit_requested.emit()
