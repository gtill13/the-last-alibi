@tool
extends Node2D
class_name ProceduralArtRenderer

## Renderizador genérico de formas 2D descritas por ProceduralArtDefinition.
## Não usa sprites, texturas ou imagens externas.

@export var definition: ProceduralArtDefinition:
	set(value):
		if definition == value:
			return
		_disconnect_definition()
		definition = value
		_connect_definition()
		if is_inside_tree():
			queue_redraw()

func _enter_tree() -> void:
	# Necessário porque nós retirados e reutilizados pelo pool entram na árvore de novo.
	_connect_definition()
	queue_redraw()

func _exit_tree() -> void:
	_disconnect_definition()

func _connect_definition() -> void:
	if definition != null and not definition.changed.is_connected(_on_definition_changed):
		definition.changed.connect(_on_definition_changed)

func _disconnect_definition() -> void:
	if definition != null and definition.changed.is_connected(_on_definition_changed):
		definition.changed.disconnect(_on_definition_changed)

func _on_definition_changed() -> void:
	queue_redraw()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if definition == null:
		warnings.append("Atribua um recurso ProceduralArtDefinition à propriedade Definition.")
	elif definition.commands.is_empty():
		warnings.append("A definição não contém comandos de desenho.")
	return warnings

func _draw() -> void:
	if definition == null:
		return

	draw_set_transform(-definition.pivot, 0.0, Vector2.ONE)
	for index in range(definition.commands.size()):
		_draw_command(definition.commands[index], index)

func _draw_command(command: Dictionary, index: int) -> void:
	var kind := String(command.get("type", ""))
	var color := _read_color(command.get("color", Color.WHITE))

	match kind:
		"rect":
			var position := _read_vector2(command.get("position", Vector2.ZERO))
			var size := _read_vector2(command.get("size", Vector2.ZERO))
			if size.x <= 0.0 or size.y <= 0.0:
				push_warning("Arte '%s': rect #%d tem tamanho inválido." % [String(definition.definition_id), index])
				return
			var filled := bool(command.get("filled", true))
			var width := float(command.get("width", 1.0))
			if filled:
				# Passar "width" com filled=true gera warning no Godot.
				draw_rect(Rect2(position, size), color, true)
			else:
				draw_rect(Rect2(position, size), color, false, width)

		"line":
			var start_point := _read_vector2(command.get("from", Vector2.ZERO))
			var end_point := _read_vector2(command.get("to", Vector2.ZERO))
			var line_width := maxf(float(command.get("width", 1.0)), 0.1)
			draw_line(start_point, end_point, color, line_width, false)

		"circle":
			var center := _read_vector2(command.get("center", Vector2.ZERO))
			var radius := float(command.get("radius", 0.0))
			if radius <= 0.0:
				push_warning("Arte '%s': circle #%d tem raio inválido." % [String(definition.definition_id), index])
				return
			draw_circle(center, radius, color)

		"polygon":
			var points := _read_points(command.get("points", PackedVector2Array()))
			if points.size() < 3:
				push_warning("Arte '%s': polygon #%d precisa de pelo menos 3 pontos." % [String(definition.definition_id), index])
				return
			draw_colored_polygon(points, color)

		_:
			push_warning("Arte '%s': tipo de comando desconhecido '%s' no índice %d." % [String(definition.definition_id), kind, index])

func _read_vector2(value: Variant) -> Vector2:
	if value is Vector2:
		return value
	if value is Vector2i:
		return Vector2(value)
	return Vector2.ZERO

func _read_color(value: Variant) -> Color:
	if value is Color:
		return value
	if value is String:
		return Color.from_string(value, Color.WHITE)
	return Color.WHITE

func _read_points(value: Variant) -> PackedVector2Array:
	var result := PackedVector2Array()
	if value is PackedVector2Array:
		return value
	if value is Array:
		for point in value:
			if point is Vector2:
				result.append(point)
			elif point is Vector2i:
				result.append(Vector2(point))
	return result
