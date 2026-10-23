extends Interactable
class_name InspectableObject

@export var evidence_id: StringName = &""
@export var object_title: String = "Objeto"
@export var description_found: String = "Um objeto sem interesse relevante."
@export var already_registered_message: String = "Já registrada no caderno."
@export var examination_prompt: String = "Examinar"

# Emitido quando o jogador pede para examinar este objeto.
signal examine_requested(evidence_id: StringName, title: String, description: String)

func _ready() -> void:
    super._ready()
    interaction_requested.connect(_on_interaction_requested)
    if debug_label != null:
        debug_label.text = str(interactable_id)

func _on_interaction_requested(id: StringName) -> void:
    if id == interactable_id:
        examine_requested.emit(evidence_id, object_title, description_found)
