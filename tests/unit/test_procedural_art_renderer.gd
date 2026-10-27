extends UnitTestCase

## Renderer de arte procedural: avisos de configuração, atribuição de definição
## e conversão tolerante de valores vindos de recursos .tres.

func test_renderer_without_definition_warns() -> void:
	var renderer := ProceduralArtRenderer.new()
	var warnings := renderer._get_configuration_warnings()
	assert_eq(warnings.size(), 1, "sem definição deve haver um aviso")
	assert_true(warnings[0].contains("ProceduralArtDefinition"), "aviso cita o recurso esperado")
	renderer.free()


func test_renderer_with_empty_definition_warns() -> void:
	var renderer := ProceduralArtRenderer.new()
	renderer.definition = ProceduralArtDefinition.new()
	var warnings := renderer._get_configuration_warnings()
	assert_eq(warnings.size(), 1, "definição vazia deve avisar")
	assert_true(warnings[0].contains("comandos"), "aviso cita a ausência de comandos")
	renderer.free()


func test_renderer_accepts_definition() -> void:
	var renderer := ProceduralArtRenderer.new()
	var definition := ProceduralArtDefinition.new()
	var commands: Array[Dictionary] = [{
		"type": "rect",
		"position": Vector2.ZERO,
		"size": Vector2(8, 8),
		"color": Color.WHITE,
	}]
	definition.commands = commands
	renderer.definition = definition

	assert_eq(renderer.definition, definition, "renderer guarda a definição")
	assert_eq(renderer.definition.commands.size(), 1, "renderer vê os comandos")
	renderer.free()


func test_renderer_helpers_convert_values() -> void:
	var renderer := ProceduralArtRenderer.new()

	assert_eq(renderer._read_vector2(Vector2i(3, 4)), Vector2(3, 4), "Vector2i vira Vector2")
	assert_eq(renderer._read_vector2("inválido"), Vector2.ZERO, "valor inválido vira zero")
	assert_eq(renderer._read_color("#ff0000"), Color(1, 0, 0), "string vira cor")
	assert_eq(renderer._read_color(Color(0.1, 0.2, 0.3)), Color(0.1, 0.2, 0.3), "cor é preservada")
	assert_eq(renderer._read_color(42), Color.WHITE, "cor inválida vira branco")

	var points := renderer._read_points([Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)])
	assert_eq(points.size(), 3, "array de Vector2 vira PackedVector2Array")
	assert_eq(points[1], Vector2(1, 0), "pontos mantêm os valores")
	renderer.free()
