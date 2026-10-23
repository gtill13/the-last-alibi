extends Area2D
class_name SuspectNPC

signal interview_requested(suspect_id: StringName, display_name: String)

@export var suspect_id: StringName = &""
@export var display_name: String = "Suspeito"
@export var interaction_label: String = "Entrevistar"

func _ready() -> void:
    interaction_requested.connect(_on_interaction_requested)
    if DebugIdLabel != null:
        DebugIdLabel.text = str(interactable_id)

func _on_interaction_requested(id: StringName) -> void:
    if id == interactable_id:
        interview_requested.emit(suspect_id, display_name)
