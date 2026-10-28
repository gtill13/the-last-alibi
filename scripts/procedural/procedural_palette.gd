@tool
extends Resource
class_name ProceduralPalette

## Paleta nomeada compartilhada pelo perfil de estilo e pelas definições de arte.
## As cores são valores Color; os nomes são usados pelos comandos "color_key".

@export var palette_id: StringName = &"unnamed_palette":
	set(value):
		palette_id = value
		emit_changed()

@export var colors: Dictionary = {}:
	set(value):
		colors = value
		emit_changed()

## Ordem usada por ferramentas e pelo Art Lab. Cores fora da lista vêm depois.
@export var display_order: Array[String] = []:
	set(value):
		display_order = value
		emit_changed()


func get_color(key: String, fallback: Color = Color.WHITE) -> Color:
	if not colors.has(key):
		return fallback
	var value: Variant = colors[key]
	if value is Color:
		return value
	if value is String:
		return Color.from_string(value, fallback)
	return fallback


func has_color(key: String) -> bool:
	return colors.has(key)


func get_color_names() -> Array[String]:
	var names: Array[String] = []
	for key: String in display_order:
		if colors.has(key) and not names.has(key):
			names.append(key)
	for key: Variant in colors.keys():
		var name := String(key)
		if not names.has(name):
			names.append(name)
	return names


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if String(palette_id).strip_edges().is_empty():
		errors.append("A paleta precisa de um palette_id.")
	if colors.is_empty():
		errors.append("A paleta está vazia.")
	for key: Variant in colors.keys():
		var name := String(key).strip_edges()
		if name.is_empty():
			errors.append("A paleta contém uma chave vazia.")
			continue
		var value: Variant = colors[key]
		if not (value is Color) and not (value is String):
			errors.append("A cor '%s' precisa ser Color ou String hexadecimal." % name)
		elif value is String and not Color.html_is_valid(String(value)):
			errors.append("A cor '%s' não é um hexadecimal válido: %s" % [name, String(value)])
	return errors
