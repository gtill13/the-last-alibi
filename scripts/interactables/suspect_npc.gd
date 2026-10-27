extends Interactable
class_name SuspectNPC

signal interview_requested(suspect_id: StringName, display_name: String)

@export var suspect_id: StringName = &""


func _ready() -> void:
	super._ready()
	interaction_requested.connect(_on_interaction_requested)
	if debug_label != null:
		debug_label.text = str(interactable_id)


func _on_interaction_requested(target: Interactable) -> void:
	if target == self:
		interview_requested.emit(suspect_id, display_name)
