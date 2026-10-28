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


func _make_profile() -> ProceduralStyleProfile:
	var palette := ProceduralPalette.new()
	palette.palette_id = &"test_palette"
	palette.colors = {"amber": Color(0.7, 0.5, 0.25, 1.0)}
	var profile := ProceduralStyleProfile.new()
	profile.profile_id = &"test_profile"
	profile.palette = palette
	return profile


func test_color_key_resolves_through_style_profile() -> void:
	var renderer := ProceduralArtRenderer.new()
	renderer.style_profile = _make_profile()
	var command := {"color_key": "amber", "alpha": 1.0}

	assert_eq(
		renderer._read_command_color(command),
		Color(0.7, 0.5, 0.25, 1.0),
		"color_key resolve pela paleta do perfil"
	)
	renderer.free()


func test_color_key_without_profile_uses_raw_color() -> void:
	var renderer := ProceduralArtRenderer.new()
	var command := {
		"color_key": "amber",
		"color": Color(0.1, 0.2, 0.3, 1.0),
	}

	assert_eq(
		renderer._read_command_color(command),
		Color(0.1, 0.2, 0.3, 1.0),
		"sem perfil, color_key não substitui a cor crua"
	)
	renderer.free()


func test_missing_color_key_uses_raw_color_fallback() -> void:
	var renderer := ProceduralArtRenderer.new()
	renderer.style_profile = _make_profile()
	var command := {
		"color_key": "missing",
		"color": Color(0.2, 0.3, 0.4, 1.0),
	}

	assert_eq(
		renderer._read_command_color(command),
		Color(0.2, 0.3, 0.4, 1.0),
		"chave ausente usa a cor crua como fallback"
	)
	renderer.free()


func test_command_alpha_multiplies_color_alpha_and_is_clamped() -> void:
	var renderer := ProceduralArtRenderer.new()
	renderer.style_profile = _make_profile()

	assert_eq(
		renderer._read_command_color({"color_key": "amber", "alpha": 0.5}),
		Color(0.7, 0.5, 0.25, 0.5),
		"alpha multiplica o canal alfa"
	)
	assert_eq(
		renderer._read_command_color({"color_key": "amber", "alpha": -1.0}),
		Color(0.7, 0.5, 0.25, 0.0),
		"alpha negativo é limitado a zero"
	)
	assert_eq(
		renderer._read_command_color({"color_key": "amber", "alpha": 2.0}),
		Color(0.7, 0.5, 0.25, 1.0),
		"alpha acima de um é limitado a um"
	)
	renderer.free()


func test_style_profile_is_connected_when_renderer_enters_tree() -> void:
	var renderer := ProceduralArtRenderer.new()
	var profile := _make_profile()
	renderer.style_profile = profile
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(renderer)

	assert_true(renderer.is_inside_tree(), "renderer está na árvore")
	assert_true(
		profile.changed.is_connected(renderer._on_style_profile_changed),
		"perfil avisa o renderer quando muda"
	)
	renderer.free()
