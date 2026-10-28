extends UnitTestCase

## Perfil de estilo: resolução lógica, delegação de paleta, sinal changed,
## validação e referência externa usada pelo Art Lab.

const PROFILE_PATH := "res://art/procedural/profiles/ps1_noir_profile.tres"
const PALETTE_PATH := "res://art/procedural/palettes/palette_noir_hotel.tres"

var _profile_changed_count := 0


func _on_profile_changed() -> void:
	_profile_changed_count += 1


func _make_palette() -> ProceduralPalette:
	var palette := ProceduralPalette.new()
	palette.palette_id = &"test_palette"
	palette.colors = {
		"ink": Color(0.1, 0.2, 0.3, 1.0),
		"paper": "#c5bda6",
	}
	return palette


func test_profile_delegates_color_lookup_to_palette() -> void:
	var profile := ProceduralStyleProfile.new()
	profile.profile_id = &"test_profile"
	profile.palette = _make_palette()

	assert_true(profile.has_color("ink"), "perfil encontra cor na paleta")
	assert_eq(profile.get_color("ink"), Color(0.1, 0.2, 0.3, 1.0), "perfil retorna a cor da paleta")
	assert_eq(profile.get_color("missing", Color.RED), Color.RED, "perfil usa fallback")
	assert_eq(profile.get_color_names().size(), 2, "perfil expõe os nomes da paleta")


func test_profile_without_palette_uses_fallback() -> void:
	var profile := ProceduralStyleProfile.new()
	assert_false(profile.has_color("ink"), "sem paleta não há cores")
	assert_eq(profile.get_color("ink", Color.RED), Color.RED, "sem paleta usa fallback")
	assert_true(profile.get_color_names().is_empty(), "sem paleta não há nomes")


func test_palette_change_propagates_to_profile() -> void:
	var palette := _make_palette()
	var profile := ProceduralStyleProfile.new()
	profile.palette = palette
	profile.changed.connect(_on_profile_changed)
	_profile_changed_count = 0

	palette.colors = {"ink": Color.WHITE}

	assert_eq(_profile_changed_count, 1, "mudança na paleta emite changed no perfil")
	profile.changed.disconnect(_on_profile_changed)


func test_profile_validation_reports_missing_palette() -> void:
	var profile := ProceduralStyleProfile.new()
	profile.profile_id = &""
	var errors := profile.validate()
	assert_true(errors.size() >= 2, "sem ID e sem paleta acumula erros")

	profile.profile_id = &"test_profile"
	profile.palette = _make_palette()
	assert_true(profile.validate().is_empty(), "perfil completo é válido")


func test_generated_profile_values_and_external_palette() -> void:
	var profile := load(PROFILE_PATH) as ProceduralStyleProfile
	assert_not_null(profile, "perfil do laboratório carrega")
	if profile == null:
		return

	assert_eq(profile.profile_id, &"ps1_noir", "perfil tem ID estável")
	assert_eq(profile.logical_resolution, Vector2i(320, 180), "resolução lógica é 320×180")
	assert_eq(profile.logical_pixel_step, 1, "passo lógico é 1")
	assert_eq(profile.color_quantization_levels, 16, "quantização inicial é 16 níveis")
	assert_eq(profile.seed, 1337, "seed é determinística")
	assert_true(profile.use_hard_shadows, "sombras duras estão ativas")
	assert_false(profile.use_procedural_texture, "textura procedural fica para fase posterior")
	assert_true(profile.validate().is_empty(), "perfil gerado não tem erros")

	assert_not_null(profile.palette, "perfil tem paleta")
	if profile.palette == null:
		return
	assert_eq(profile.palette.resource_path, PALETTE_PATH, "perfil referencia a paleta externa")
	assert_eq(profile.get_color("amber"), Color.html("#b98243"), "perfil resolve a cor âmbar")
