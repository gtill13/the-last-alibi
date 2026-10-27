extends UnitTestCase

## Definições de arte procedural: setters, clamp, sinal changed e validade
## dos dados usados pela demo (tipos de comando, cores, pontos e IDs únicos).

const DEFINITION_PATHS: Array[String] = [
	"res://art/definitions/room_background.tres",
	"res://art/definitions/hotel_desk.tres",
	"res://art/definitions/hotel_desk_alt.tres",
	"res://art/definitions/hotel_plant.tres",
	"res://art/definitions/hotel_painting.tres",
	"res://art/definitions/detective.tres",
]

var _changed_count := 0


func _on_definition_changed() -> void:
	_changed_count += 1


func test_definition_setters_emit_changed_and_touch() -> void:
	var definition := ProceduralArtDefinition.new()
	definition.changed.connect(_on_definition_changed)
	_changed_count = 0

	definition.definition_id = &"test_art"
	definition.logical_size = Vector2i(32, 48)
	definition.pivot = Vector2(16, 48)
	var commands: Array[Dictionary] = [{
		"type": "rect",
		"position": Vector2.ZERO,
		"size": Vector2(4, 4),
		"color": Color.WHITE,
	}]
	definition.commands = commands

	assert_eq(_changed_count, 4, "cada setter emite changed")
	_changed_count = 0
	definition.touch()
	assert_eq(_changed_count, 1, "touch emite changed")
	definition.changed.disconnect(_on_definition_changed)


func test_logical_size_is_clamped_to_at_least_one() -> void:
	var definition := ProceduralArtDefinition.new()
	definition.logical_size = Vector2i(0, -10)
	assert_eq(definition.logical_size, Vector2i(1, 1), "tamanho lógico mínimo é 1x1")


func test_commands_can_be_replaced() -> void:
	var definition := ProceduralArtDefinition.new()
	var first: Array[Dictionary] = [{"type": "circle", "center": Vector2.ZERO, "radius": 2.0, "color": Color.WHITE}]
	definition.commands = first
	var second: Array[Dictionary] = [{"type": "line", "from": Vector2.ZERO, "to": Vector2.RIGHT, "color": Color.WHITE, "width": 1.0}]
	definition.commands = second

	assert_eq(definition.commands.size(), 1, "lista de comandos foi substituída")
	assert_eq(String(definition.commands[0].get("type", "")), "line", "novo comando é o esperado")


func test_demo_definitions_are_valid() -> void:
	for path: String in DEFINITION_PATHS:
		var definition := load(path) as ProceduralArtDefinition
		assert_not_null(definition, "%s carrega" % path)
		if definition == null:
			continue
		assert_ne(definition.definition_id, &"", "%s tem ID" % path)
		assert_true(definition.logical_size.x > 0, "%s tem largura lógica positiva" % path)
		assert_true(definition.logical_size.y > 0, "%s tem altura lógica positiva" % path)
		assert_true(definition.pivot.x >= 0.0, "%s tem pivô X não negativo" % path)
		assert_true(definition.pivot.y >= 0.0, "%s tem pivô Y não negativo" % path)
		assert_true(
			definition.pivot.x <= float(definition.logical_size.x),
			"%s tem pivô X dentro do tamanho lógico" % path
		)
		assert_true(
			definition.pivot.y <= float(definition.logical_size.y),
			"%s tem pivô Y dentro do tamanho lógico" % path
		)
		assert_true(definition.commands.size() > 0, "%s tem comandos" % path)
		for index in range(definition.commands.size()):
			_assert_command(definition.commands[index], path, index)


func test_demo_definition_ids_are_unique() -> void:
	var ids: Array[StringName] = []
	for path: String in DEFINITION_PATHS:
		var definition := load(path) as ProceduralArtDefinition
		if definition == null:
			continue
		assert_false(ids.has(definition.definition_id), "%s reutiliza um ID" % path)
		ids.append(definition.definition_id)
	assert_eq(ids.size(), DEFINITION_PATHS.size(), "todas as definições têm ID")


func _assert_command(command: Dictionary, path: String, index: int) -> void:
	var kind := String(command.get("type", ""))
	var context := "%s comando #%d" % [path, index]
	assert_true(
		kind in ["rect", "line", "circle", "polygon"],
		"%s tem tipo suportado" % context
	)
	assert_true(command.get("color") is Color, "%s tem cor" % context)

	match kind:
		"rect":
			assert_true(command.get("position") is Vector2, "%s tem position" % context)
			var size: Vector2 = command.get("size", Vector2.ZERO)
			assert_true(size.x > 0.0 and size.y > 0.0, "%s tem tamanho positivo" % context)
		"line":
			assert_true(command.get("from") is Vector2, "%s tem from" % context)
			assert_true(command.get("to") is Vector2, "%s tem to" % context)
			assert_true(float(command.get("width", 0.0)) > 0.0, "%s tem largura positiva" % context)
		"circle":
			assert_true(command.get("center") is Vector2, "%s tem center" % context)
			assert_true(float(command.get("radius", 0.0)) > 0.0, "%s tem raio positivo" % context)
		"polygon":
			var points: Variant = command.get("points")
			assert_true(points is PackedVector2Array, "%s tem points" % context)
			if points is PackedVector2Array:
				assert_true(points.size() >= 3, "%s tem pelo menos 3 pontos" % context)
