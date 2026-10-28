extends UnitTestCase

## Paleta nomeada: leitura, fallback, ordem de exibição e validação.

var _changed_count := 0


func _on_palette_changed() -> void:
	_changed_count += 1


func test_palette_reads_colors_and_fallbacks() -> void:
	var palette := ProceduralPalette.new()
	palette.palette_id = &"test_palette"
	palette.colors = {
		"ink": Color(0.1, 0.2, 0.3, 1.0),
		"paper": "#c5bda6",
	}

	assert_eq(palette.get_color("ink"), Color(0.1, 0.2, 0.3, 1.0), "cor Color é preservada")
	assert_eq(palette.get_color("paper"), Color.html("#c5bda6"), "string hexadecimal vira cor")
	assert_eq(palette.get_color("missing", Color.RED), Color.RED, "chave ausente usa fallback")
	assert_true(palette.has_color("ink"), "has_color encontra a chave")
	assert_false(palette.has_color("missing"), "has_color rejeita chave ausente")


func test_display_order_controls_color_names() -> void:
	var palette := ProceduralPalette.new()
	palette.palette_id = &"test_palette"
	palette.colors = {
		"wall": Color.GRAY,
		"shadow": Color.BLACK,
		"amber": Color.ORANGE,
	}
	palette.display_order = ["shadow", "amber"]

	assert_eq(
		palette.get_color_names(),
		["shadow", "amber", "wall"],
		"ordem explícita vem primeiro; cores restantes vêm depois"
	)


func test_palette_setters_emit_changed() -> void:
	var palette := ProceduralPalette.new()
	palette.changed.connect(_on_palette_changed)
	_changed_count = 0

	palette.palette_id = &"test_palette"
	palette.colors = {"ink": Color.BLACK}
	palette.display_order = ["ink"]

	assert_eq(_changed_count, 3, "cada setter emite changed")
	palette.changed.disconnect(_on_palette_changed)


func test_palette_validation_reports_invalid_entries() -> void:
	var palette := ProceduralPalette.new()
	palette.palette_id = &""
	var errors := palette.validate()
	assert_true(errors.size() >= 2, "paleta sem ID e sem cores acumula erros")

	palette.palette_id = &"test_palette"
	palette.colors = {"bad_hex": "#zzzzzz", "bad_type": 42}
	errors = palette.validate()
	assert_eq(errors.size(), 2, "hex inválido e tipo inválido são reportados")
	assert_true(errors[0].contains("bad_hex") or errors[1].contains("bad_hex"), "erro cita a chave inválida")


func test_generated_palette_is_valid() -> void:
	var palette := load("res://art/procedural/palettes/palette_noir_hotel.tres") as ProceduralPalette
	assert_not_null(palette, "paleta do laboratório carrega")
	if palette == null:
		return

	assert_eq(palette.palette_id, &"palette_noir_hotel", "paleta tem ID estável")
	assert_eq(palette.get_color_names().size(), 10, "paleta do laboratório tem dez cores")
	assert_eq(palette.get_color_names()[0], "shadow_deep", "ordem começa pela sombra profunda")
	assert_eq(palette.get_color("amber"), Color.html("#b98243"), "âmbar é a cor esperada")
	assert_true(palette.validate().is_empty(), "paleta gerada não tem erros de validação")
