extends UnitTestCase

## Art Lab: viewport lógico 320×180, ampliação nearest, perfil compartilhado,
## paleta visível e cena montada sem imagens externas.

const LAB_SCENE_PATH := "res://scenes/art_lab/procedural_art_lab.tscn"
const PROFILE_PATH := "res://art/procedural/profiles/ps1_noir_profile.tres"
const PALETTE_PATH := "res://art/procedural/palettes/palette_noir_hotel.tres"

const EXPECTED_DEFINITIONS := {
	"Backdrop": &"hotel_reception_lab_backdrop",
	"Detective": &"lab_detective",
	"Desk": &"lab_reception_desk",
	"WallLamp": &"lab_wall_lamp",
	"Envelope": &"lab_envelope",
}


func _instantiate_lab() -> ProceduralArtLab:
	var tree := Engine.get_main_loop() as SceneTree
	var packed := load(LAB_SCENE_PATH) as PackedScene
	assert_not_null(packed, "cena do Art Lab carrega")
	if packed == null:
		return null
	var lab := packed.instantiate() as ProceduralArtLab
	assert_not_null(lab, "cena do Art Lab é um ProceduralArtLab")
	if lab == null:
		return null
	tree.root.add_child(lab)
	return lab


func test_lab_scene_has_expected_nodes() -> void:
	var lab := _instantiate_lab()
	if lab == null:
		return

	assert_not_null(lab.get_node_or_null("GameViewport"), "existe GameViewport")
	assert_not_null(lab.get_node_or_null("GameViewport/Scene"), "existe GameViewport/Scene")
	assert_not_null(lab.get_node_or_null("MainDisplay"), "existe MainDisplay")
	assert_not_null(lab.get_node_or_null("UI/PaletteBar/Margin/PaletteList"), "existe a lista da paleta")
	assert_not_null(lab.get_node_or_null("UI/ScaleLabel"), "existe o rótulo de escala")
	lab.free()


func test_viewport_is_320x180_and_display_uses_nearest() -> void:
	var lab := _instantiate_lab()
	if lab == null:
		return

	assert_eq(lab.game_viewport.size, Vector2i(320, 180), "viewport lógico é 320×180")
	assert_eq(
		lab.game_viewport.render_target_update_mode,
		SubViewport.UPDATE_ONCE,
		"viewport atualiza sob demanda"
	)
	assert_true(lab.main_display.texture is ViewportTexture, "MainDisplay usa a textura do viewport")
	assert_eq(
		lab.main_display.texture_filter,
		CanvasItem.TEXTURE_FILTER_NEAREST,
		"ampliação usa filtro nearest"
	)
	assert_eq(
		lab.main_display.expand_mode,
		TextureRect.EXPAND_IGNORE_SIZE,
		"MainDisplay ignora o tamanho mínimo da textura"
	)
	assert_eq(
		lab.main_display.stretch_mode,
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED,
		"modo de jogo preserva a proporção 16:9"
	)
	lab.free()


func test_effective_scale_is_integer_for_target_windows() -> void:
	var lab := _instantiate_lab()
	if lab == null:
		return

	assert_eq(lab.get_effective_scale(Vector2i(1280, 720)), 4, "1280×720 usa 4×")
	assert_eq(lab.get_effective_scale(Vector2i(1920, 1080)), 6, "1920×1080 usa 6×")
	assert_eq(lab.get_effective_scale(Vector2i(1280, 1080)), 4, "escala usa o menor eixo")
	assert_eq(lab.get_effective_scale(Vector2i(100, 100)), 1, "janelas pequenas nunca usam escala zero")
	lab.free()


func test_1x_toggle_changes_display_mode_and_label() -> void:
	var lab := _instantiate_lab()
	if lab == null:
		return

	lab.set_1x(true)
	assert_eq(
		lab.main_display.stretch_mode,
		TextureRect.STRETCH_KEEP_CENTERED,
		"prévia 1× não amplia a textura"
	)
	assert_true(lab.get_scale_text().contains("1× lógico"), "rótulo indica a prévia 1×")

	lab.set_1x(false)
	assert_eq(
		lab.main_display.stretch_mode,
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED,
		"voltar ao modo de jogo reativa a ampliação"
	)
	lab.free()


func test_lab_uses_profile_and_external_palette() -> void:
	var lab := _instantiate_lab()
	if lab == null:
		return

	assert_not_null(lab.style_profile, "laboratório tem perfil")
	if lab.style_profile == null:
		lab.free()
		return
	assert_eq(lab.style_profile.profile_id, &"ps1_noir", "perfil é o PS1 noir")
	assert_eq(lab.style_profile.logical_resolution, Vector2i(320, 180), "perfil declara 320×180")
	assert_not_null(lab.style_profile.palette, "perfil tem paleta")
	if lab.style_profile.palette != null:
		assert_eq(
			lab.style_profile.palette.resource_path,
			PALETTE_PATH,
			"perfil referencia a paleta externa"
		)
	assert_eq(lab.style_profile.get_color_names().size(), 10, "perfil expõe dez cores")
	lab.free()


func test_all_lab_renderers_share_the_profile() -> void:
	var lab := _instantiate_lab()
	if lab == null:
		return

	var renderers: Array[ProceduralArtRenderer] = []
	for node: Node in lab.scene_root.get_children():
		if node is ProceduralArtRenderer:
			renderers.append(node as ProceduralArtRenderer)

	assert_eq(renderers.size(), EXPECTED_DEFINITIONS.size(), "laboratório tem cinco renderers")
	for renderer: ProceduralArtRenderer in renderers:
		assert_eq(renderer.style_profile, lab.style_profile, "renderer usa o perfil do laboratório")
		assert_not_null(renderer.definition, "renderer tem definição")
		if renderer.definition == null:
			continue
		assert_true(
			renderer.definition.definition_id in EXPECTED_DEFINITIONS.values(),
			"definição %s pertence ao laboratório" % renderer.definition.definition_id
		)
		assert_true(renderer.definition.commands.size() > 0, "definição tem comandos")
	lab.free()


func test_lab_definitions_are_unique_and_use_color_keys() -> void:
	var lab := _instantiate_lab()
	if lab == null:
		return

	var ids: Array[StringName] = []
	for node: Node in lab.scene_root.get_children():
		if not node is ProceduralArtRenderer:
			continue
		var renderer := node as ProceduralArtRenderer
		if renderer.definition == null:
			continue
		assert_false(ids.has(renderer.definition.definition_id), "IDs de definição são únicos")
		ids.append(renderer.definition.definition_id)
		for index in range(renderer.definition.commands.size()):
			var command := renderer.definition.commands[index]
			assert_true(
				not String(command.get("color_key", "")).is_empty(),
				"comando #%d de %s usa color_key" % [index, renderer.definition.definition_id]
			)
			assert_false(command.has("color"), "comando não mistura color e color_key")
	assert_eq(ids.size(), EXPECTED_DEFINITIONS.size(), "todas as definições foram visitadas")
	lab.free()


func test_palette_bar_lists_all_palette_colors_in_order() -> void:
	var lab := _instantiate_lab()
	if lab == null:
		return

	var list := lab.get_node("UI/PaletteBar/Margin/PaletteList") as HBoxContainer
	assert_eq(list.get_child_count(), 10, "barra mostra dez amostras")
	if list.get_child_count() == 0:
		lab.free()
		return

	var first_column := list.get_child(0)
	assert_eq(first_column.get_child_count(), 2, "cada amostra tem cor e rótulo")
	var first_label := first_column.get_child(1) as Label
	assert_not_null(first_label, "segundo filho é um Label")
	if first_label != null:
		assert_true(first_label.text.contains("shadow_deep"), "primeira amostra é shadow_deep")
	lab.free()


func test_palette_bar_updates_when_palette_changes() -> void:
	var packed := load(LAB_SCENE_PATH) as PackedScene
	if packed == null:
		return
	var lab := packed.instantiate() as ProceduralArtLab
	if lab == null:
		return

	var palette := ProceduralPalette.new()
	palette.palette_id = &"test_palette"
	palette.colors = {"first": Color.RED, "second": Color.BLUE}
	palette.display_order = ["first", "second"]
	var profile := ProceduralStyleProfile.new()
	profile.profile_id = &"test_profile"
	profile.palette = palette
	lab.style_profile = profile

	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(lab)

	var list := lab.get_node("UI/PaletteBar/Margin/PaletteList") as HBoxContainer
	var first_label := list.get_child(0).get_child(1) as Label
	assert_true(first_label.text.contains("ff0000"), "primeira amostra começa vermelha")

	palette.colors = {"first": Color.html("#112233"), "second": Color.BLUE}
	var updated_label := list.get_child(0).get_child(1) as Label
	assert_true(updated_label.text.contains("112233"), "amostra acompanha a mudança da paleta")
	lab.free()


func test_lab_scene_has_no_image_assets() -> void:
	var scene_text := FileAccess.get_file_as_string(LAB_SCENE_PATH)
	assert_false(scene_text.is_empty(), "cena do laboratório é legível")
	for extension: String in [".png", ".jpg", ".jpeg", ".webp", ".svg"]:
		assert_false(
			scene_text.to_lower().contains(extension),
			"cena não referencia %s" % extension
		)


func test_lab_definition_resources_have_no_image_assets() -> void:
	var paths: Array[String] = [
		"res://art/procedural/definitions/environments/hotel_reception_lab_backdrop.tres",
		"res://art/procedural/definitions/props/lab_reception_desk.tres",
		"res://art/procedural/definitions/props/lab_wall_lamp.tres",
		"res://art/procedural/definitions/props/lab_envelope.tres",
		"res://art/procedural/definitions/characters/lab_detective.tres",
	]
	for path: String in paths:
		var text := FileAccess.get_file_as_string(path)
		assert_false(text.is_empty(), "%s é legível" % path)
		for extension: String in [".png", ".jpg", ".jpeg", ".webp", ".svg"]:
			assert_false(
				text.to_lower().contains(extension),
				"%s não referencia %s" % [path, extension]
			)
