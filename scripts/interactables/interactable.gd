extends Area2D
class_name Interactable

signal interaction_requested(interactable_id: StringName)

@export var interactable_id: StringName = &""
@export var interaction_label: String = "Interagir"
@export var is_interactable: bool = true
@export var show_debug_label: bool = false

func _ready() -> void:
    if not is_interactable:
        monitoring = false

func request_interaction() -> void:
    if is_interactable:
        interaction_requested.emit(interactable_id)

func set_debug_visible(visible: bool) -> void:
    show_debug_label = visible
