class_name Interactable
extends Area2D

## Zona detectável de um alvo de interação. A área não bloqueia o jogador;
## colisões físicas devem usar um StaticBody2D separado.

signal interaction_requested(target: Interactable)

@export var interactable_id: StringName = &""
@export var interaction_label: String = "Interagir"
@export var display_name: String = "Objeto"
@export var is_interactable: bool = true
@export var show_debug_id: bool = true

var outline_node: Node2D = null
var debug_label: Label = null


func _ready() -> void:
	outline_node = get_node_or_null("Outline") as Node2D
	debug_label = get_node_or_null("DebugIdLabel") as Label
	_set_outline_visible(false)
	_set_debug_label_visible(false)


func can_interact() -> bool:
	return (
		is_interactable
		and is_inside_tree()
		and not is_queued_for_deletion()
	)


func request_interaction() -> void:
	if can_interact():
		interaction_requested.emit(self)


func set_highlighted(highlighted: bool) -> void:
	_set_outline_visible(highlighted)
	_set_debug_label_visible(highlighted and show_debug_id)


func get_prompt_action() -> String:
	return interaction_label


func get_prompt_name() -> String:
	return display_name


func _set_outline_visible(is_visible: bool) -> void:
	if outline_node != null:
		outline_node.visible = is_visible


func _set_debug_label_visible(is_visible: bool) -> void:
	if debug_label != null:
		debug_label.visible = is_visible
