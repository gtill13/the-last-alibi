extends Area2D
class_name Interactable

signal interaction_requested(interactable_id: StringName)

@export var interactable_id: StringName = &""
@export var interaction_label: String = "Interagir"
@export var is_interactable: bool = true
@export var show_debug_id: bool = true

# Nó de contorno visual (definido na cena filha via @onready).
var outline_node: Node2D = null
# Label de depuração com o ID estável.
var debug_label: Label = null

func _ready() -> void:
    if not is_interactable:
        monitoring = false
    # Tenta encontrar nós de contorno e debug definidos na cena filha.
    outline_node = get_node_or_null("Outline")
    debug_label = get_node_or_null("DebugIdLabel")
    _set_outline_visible(false)
    _set_debug_label_visible(false)

func request_interaction() -> void:
    if is_interactable:
        interaction_requested.emit(interactable_id)

# Chamado pelo scanner quando este interagível se torna o alvo ativo (próximo).
func set_highlighted(highlighted: bool) -> void:
    _set_outline_visible(highlighted)
    _set_debug_label_visible(highlighted and show_debug_id)

func _set_outline_visible(visible: bool) -> void:
    if outline_node != null:
        outline_node.visible = visible

func _set_debug_label_visible(visible: bool) -> void:
    if debug_label != null:
        debug_label.visible = visible
