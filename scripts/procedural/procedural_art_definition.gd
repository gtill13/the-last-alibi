@tool
extends Resource
class_name ProceduralArtDefinition

## Dados reutilizáveis para descrever uma peça de arte procedural.
## Coordenadas e dimensões são expressas em unidades locais do Node2D.

@export var definition_id: StringName = &"unnamed_art":
	set(value):
		definition_id = value
		emit_changed()

@export var logical_size: Vector2i = Vector2i(32, 32):
	set(value):
		logical_size = Vector2i(maxi(value.x, 1), maxi(value.y, 1))
		emit_changed()

## Ponto local usado como origem do prefab. Ex.: base central dos pés do personagem.
@export var pivot: Vector2 = Vector2.ZERO:
	set(value):
		pivot = value
		emit_changed()

@export var commands: Array[Dictionary] = []:
	set(value):
		commands = value
		emit_changed()

## Útil quando uma ferramenta altera comandos existentes por referência.
func touch() -> void:
	emit_changed()
