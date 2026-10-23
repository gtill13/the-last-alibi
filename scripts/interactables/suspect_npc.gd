extends Interactable
class_name SuspectNPC

signal interview_requested(suspect_id: StringName, display_name: String)

@export var suspect_id: StringName = &""
@export var display_name: String = "Suspeito"

func _ready() -> void:
    super._ready()
    interaction_requested.connect(_on_interaction_requested)
    if debug_label != null:
        debug_label.text = str(interactable_id)

func _on_interaction_requested(id: StringName) -> void:
    if id == interactable_id:
        interview_requested.emit(suspect_id, display_name)
