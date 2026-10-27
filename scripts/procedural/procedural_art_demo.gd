extends Node2D

## Demo visual do sistema de arte procedural.
## Tudo na cena é desenhado por comandos geométricos; não há sprites.
## [1] e [2] trocam a definição da mesa para provar que o renderer é data-driven.

const DESK_VARIANTS: Array[String] = [
	"res://art/definitions/hotel_desk.tres",
	"res://art/definitions/hotel_desk_alt.tres",
]

@onready var desk_art: ProceduralArtRenderer = $Props/HotelDesk/Art
@onready var variant_label: Label = $UI/VariantLabel

var _variant_index := 0


func _ready() -> void:
	_apply_variant(0)


func _unhandled_key_input(event: InputEvent) -> void:
	if not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1:
			_apply_variant(0)
		KEY_2:
			_apply_variant(1)


func _apply_variant(index: int) -> void:
	if index < 0 or index >= DESK_VARIANTS.size():
		return
	var definition := load(DESK_VARIANTS[index]) as ProceduralArtDefinition
	if definition == null:
		return
	_variant_index = index
	desk_art.definition = definition
	variant_label.text = (
		"Mesa: %s  ·  [1] madeira clara  [2] madeira escura"
		% String(definition.definition_id)
	)
