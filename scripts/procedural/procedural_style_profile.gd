@tool
extends Resource
class_name ProceduralStyleProfile

## Configuração visual compartilhada por definições procedurais.
## A paleta é um recurso separado para que trocar cores não exija editar cada peça.

@export var profile_id: StringName = &"unnamed_profile":
	set(value):
		profile_id = value
		emit_changed()

@export var palette: ProceduralPalette:
	set(value):
		if palette == value:
			return
		_disconnect_palette()
		palette = value
		_connect_palette()
		emit_changed()

@export var logical_resolution: Vector2i = Vector2i(320, 180):
	set(value):
		logical_resolution = Vector2i(maxi(value.x, 1), maxi(value.y, 1))
		emit_changed()

@export_range(1, 8, 1) var logical_pixel_step: int = 1:
	set(value):
		logical_pixel_step = maxi(value, 1)
		emit_changed()

@export var outline_color: Color = Color("#090D12"):
	set(value):
		outline_color = value
		emit_changed()

@export var shadow_color: Color = Color("#090D12"):
	set(value):
		shadow_color = value
		emit_changed()

@export var highlight_color: Color = Color("#C5BDA6"):
	set(value):
		highlight_color = value
		emit_changed()

@export_range(0.0, 1.0, 0.01) var dither_strength: float = 0.0:
	set(value):
		dither_strength = clampf(value, 0.0, 1.0)
		emit_changed()

@export_range(0.0, 1.0, 0.01) var noise_strength: float = 0.0:
	set(value):
		noise_strength = clampf(value, 0.0, 1.0)
		emit_changed()

@export_range(2, 256, 1) var color_quantization_levels: int = 16:
	set(value):
		color_quantization_levels = maxi(value, 2)
		emit_changed()

@export var use_hard_shadows: bool = true:
	set(value):
		use_hard_shadows = value
		emit_changed()

@export var use_procedural_texture: bool = false:
	set(value):
		use_procedural_texture = value
		emit_changed()

@export var seed: int = 1337:
	set(value):
		seed = value
		emit_changed()


func _init() -> void:
	_connect_palette()


func _connect_palette() -> void:
	if palette != null and not palette.changed.is_connected(_on_palette_changed):
		palette.changed.connect(_on_palette_changed)


func _disconnect_palette() -> void:
	if palette != null and palette.changed.is_connected(_on_palette_changed):
		palette.changed.disconnect(_on_palette_changed)


func _on_palette_changed() -> void:
	emit_changed()


func get_color(key: String, fallback: Color = Color.WHITE) -> Color:
	if palette == null:
		return fallback
	return palette.get_color(key, fallback)


func has_color(key: String) -> bool:
	return palette != null and palette.has_color(key)


func get_color_names() -> Array[String]:
	if palette == null:
		return []
	return palette.get_color_names()


func validate() -> PackedStringArray:
	var errors := PackedStringArray()
	if String(profile_id).strip_edges().is_empty():
		errors.append("O perfil precisa de um profile_id.")
	if palette == null:
		errors.append("O perfil precisa de uma ProceduralPalette.")
	else:
		errors.append_array(palette.validate())
	if logical_resolution.x <= 0 or logical_resolution.y <= 0:
		errors.append("A resolução lógica precisa ser positiva.")
	if logical_pixel_step < 1:
		errors.append("O passo lógico precisa ser pelo menos 1.")
	if color_quantization_levels < 2:
		errors.append("A quantização precisa de pelo menos 2 níveis.")
	return errors
