extends SceneTree

## Gera a paleta, o perfil de estilo e as definições do Art Lab da Fase 1.
## Uso:
##   godot --headless --path . -s res://tools/generate_art_lab.gd
##
## As definições usam "color_key" em vez de "color" para que a paleta possa
## ser trocada no .tres sem editar o renderer ou cada comando.

const PALETTE_DIR := "res://art/procedural/palettes"
const PROFILE_DIR := "res://art/procedural/profiles"
const ENV_DIR := "res://art/procedural/definitions/environments"
const PROP_DIR := "res://art/procedural/definitions/props"
const CHAR_DIR := "res://art/procedural/definitions/characters"


func _initialize() -> void:
	for directory in [PALETTE_DIR, PROFILE_DIR, ENV_DIR, PROP_DIR, CHAR_DIR]:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))

	var palette_path := PALETTE_DIR.path_join("palette_noir_hotel.tres")
	var palette := _make_palette()
	_save(palette, palette_path)

	# Recarrega a paleta salva para que o perfil use uma referência externa
	# (ExtResource), não uma cópia embutida. Trocar a paleta passa a afetar o perfil.
	var saved_palette := ResourceLoader.load(palette_path) as ProceduralPalette
	if saved_palette == null:
		push_error("Não foi possível recarregar a paleta salva: %s" % palette_path)
		quit(1)
		return

	var profile := _make_profile(saved_palette)
	_save(profile, PROFILE_DIR.path_join("ps1_noir_profile.tres"))

	_save(_backdrop(), ENV_DIR.path_join("hotel_reception_lab_backdrop.tres"))
	_save(_desk(), PROP_DIR.path_join("lab_reception_desk.tres"))
	_save(_lamp(), PROP_DIR.path_join("lab_wall_lamp.tres"))
	_save(_envelope(), PROP_DIR.path_join("lab_envelope.tres"))
	_save(_detective(), CHAR_DIR.path_join("lab_detective.tres"))

	quit(0)


func _save(resource: Resource, path: String) -> void:
	var error := ResourceSaver.save(resource, path)
	if error != OK:
		push_error("Falha ao salvar %s (erro %d)" % [path, error])
	else:
		print("Gerado: %s" % path)


func _make_palette() -> ProceduralPalette:
	var palette := ProceduralPalette.new()
	palette.palette_id = &"palette_noir_hotel"
	palette.colors = {
		"shadow_deep": Color.html("#090D12"),
		"shadow_wall": Color.html("#151C24"),
		"wall": Color.html("#303236"),
		"wood_dark": Color.html("#49342D"),
		"wood_mid": Color.html("#75513D"),
		"green_muted": Color.html("#414A43"),
		"wine": Color.html("#4A292D"),
		"amber": Color.html("#B98243"),
		"ivory": Color.html("#C5BDA6"),
		"red_muted": Color.html("#793C3B"),
	}
	palette.display_order = [
		"shadow_deep",
		"shadow_wall",
		"wall",
		"wood_dark",
		"wood_mid",
		"green_muted",
		"wine",
		"amber",
		"ivory",
		"red_muted",
	]
	return palette


func _make_profile(palette: ProceduralPalette) -> ProceduralStyleProfile:
	var profile := ProceduralStyleProfile.new()
	profile.profile_id = &"ps1_noir"
	profile.palette = palette
	profile.logical_resolution = Vector2i(320, 180)
	profile.logical_pixel_step = 1
	profile.outline_color = palette.get_color("shadow_deep")
	profile.shadow_color = palette.get_color("shadow_deep")
	profile.highlight_color = palette.get_color("ivory")
	profile.dither_strength = 0.0
	profile.noise_strength = 0.0
	profile.color_quantization_levels = 16
	profile.use_hard_shadows = true
	profile.use_procedural_texture = false
	profile.seed = 1337
	return profile


func _rect(
	position: Vector2,
	size: Vector2,
	color_key: String,
	alpha: float = 1.0,
	filled: bool = true,
	width: float = 1.0
) -> Dictionary:
	return {
		"type": "rect",
		"position": position,
		"size": size,
		"color_key": color_key,
		"alpha": alpha,
		"filled": filled,
		"width": width,
	}


func _line(from: Vector2, to: Vector2, color_key: String, width: float = 1.0, alpha: float = 1.0) -> Dictionary:
	return {
		"type": "line",
		"from": from,
		"to": to,
		"color_key": color_key,
		"width": width,
		"alpha": alpha,
	}


func _circle(center: Vector2, radius: float, color_key: String, alpha: float = 1.0) -> Dictionary:
	return {
		"type": "circle",
		"center": center,
		"radius": radius,
		"color_key": color_key,
		"alpha": alpha,
	}


func _polygon(points: Array[Vector2], color_key: String, alpha: float = 1.0) -> Dictionary:
	return {
		"type": "polygon",
		"points": PackedVector2Array(points),
		"color_key": color_key,
		"alpha": alpha,
	}


func _definition(
	id: StringName,
	size: Vector2i,
	pivot: Vector2,
	commands: Array[Dictionary]
) -> ProceduralArtDefinition:
	var definition := ProceduralArtDefinition.new()
	definition.definition_id = id
	definition.logical_size = size
	definition.pivot = pivot
	definition.commands = commands
	return definition


func _backdrop() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	# Parede e faixa superior mais escura.
	commands.append(_rect(Vector2(0, 0), Vector2(320, 122), "wall"))
	commands.append(_rect(Vector2(0, 0), Vector2(320, 44), "shadow_wall"))
	commands.append(_line(Vector2(0, 44), Vector2(320, 44), "shadow_deep", 1.0, 0.6))

	# Painéis verticais discretos.
	for x in [40.0, 80.0, 120.0, 160.0, 200.0, 240.0, 280.0]:
		commands.append(_line(Vector2(x, 44), Vector2(x, 96), "shadow_deep", 1.0, 0.35))

	# Rodapé de madeira.
	commands.append(_rect(Vector2(0, 96), Vector2(320, 26), "wood_dark"))
	commands.append(_rect(Vector2(0, 94), Vector2(320, 3), "wood_mid"))
	commands.append(_line(Vector2(0, 98), Vector2(320, 98), "shadow_deep", 1.0, 0.45))
	commands.append(_rect(Vector2(0, 120), Vector2(320, 3), "shadow_deep", 0.85))

	# Piso.
	commands.append(_rect(Vector2(0, 123), Vector2(320, 57), "shadow_deep"))
	for y in [134.0, 146.0, 160.0, 174.0]:
		commands.append(_line(Vector2(0, y), Vector2(320, y), "shadow_wall", 1.0, 0.55))
	commands.append(_line(Vector2(0, 180), Vector2(112, 123), "shadow_wall", 1.0, 0.35))
	commands.append(_line(Vector2(320, 180), Vector2(208, 123), "shadow_wall", 1.0, 0.35))

	# Tapete.
	commands.append(_polygon([
		Vector2(96, 180), Vector2(224, 180), Vector2(210, 123), Vector2(110, 123)
	], "wine"))
	commands.append(_line(Vector2(110, 123), Vector2(96, 180), "red_muted", 1.0, 0.8))
	commands.append(_line(Vector2(210, 123), Vector2(224, 180), "red_muted", 1.0, 0.8))
	commands.append(_line(Vector2(108, 140), Vector2(212, 140), "red_muted", 1.0, 0.35))
	commands.append(_line(Vector2(104, 158), Vector2(216, 158), "red_muted", 1.0, 0.35))

	# Luz quente projetada no piso pela luminária.
	commands.append(_polygon([
		Vector2(214, 123), Vector2(312, 123), Vector2(330, 180), Vector2(190, 180)
	], "amber", 0.05))

	# Porta.
	commands.append(_rect(Vector2(10, 50), Vector2(56, 72), "wood_dark"))
	commands.append(_rect(Vector2(14, 54), Vector2(48, 68), "shadow_deep"))
	commands.append(_rect(Vector2(18, 58), Vector2(40, 28), "wood_dark"))
	commands.append(_rect(Vector2(18, 90), Vector2(40, 28), "wood_dark"))
	commands.append(_rect(Vector2(20, 60), Vector2(36, 24), "shadow_wall", 0.55))
	commands.append(_rect(Vector2(20, 92), Vector2(36, 24), "shadow_wall", 0.55))
	commands.append(_line(Vector2(14, 54), Vector2(14, 122), "wood_mid", 1.0, 0.7))
	commands.append(_circle(Vector2(54, 88), 2.0, "amber"))

	# Quadro de avisos.
	commands.append(_rect(Vector2(72, 56), Vector2(20, 18), "wood_mid"))
	commands.append(_rect(Vector2(74, 58), Vector2(16, 14), "ivory"))
	commands.append(_line(Vector2(77, 62), Vector2(87, 62), "wall", 1.0, 0.8))
	commands.append(_line(Vector2(77, 65), Vector2(85, 65), "wall", 1.0, 0.8))
	commands.append(_line(Vector2(77, 68), Vector2(88, 68), "wall", 1.0, 0.8))

	# Relógio.
	commands.append(_circle(Vector2(160, 36), 9.0, "shadow_deep"))
	commands.append(_circle(Vector2(160, 36), 7.0, "ivory"))
	commands.append(_line(Vector2(160, 36), Vector2(160, 31), "shadow_deep", 1.0))
	commands.append(_line(Vector2(160, 36), Vector2(164, 38), "shadow_deep", 1.0))
	commands.append(_circle(Vector2(160, 36), 1.0, "shadow_deep"))

	# Sombra atrás da recepção.
	commands.append(_rect(Vector2(178, 96), Vector2(124, 26), "shadow_deep", 0.25))

	return _definition(&"hotel_reception_lab_backdrop", Vector2i(320, 180), Vector2.ZERO, commands)


func _desk() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	# Sombra de contato.
	commands.append(_polygon([
		Vector2(-4, 34), Vector2(4, 30), Vector2(116, 30), Vector2(124, 34),
		Vector2(116, 38), Vector2(4, 38)
	], "shadow_deep", 0.55))

	# Corpo e tampo.
	commands.append(_rect(Vector2(0, 6), Vector2(120, 28), "wood_dark"))
	commands.append(_rect(Vector2(4, 10), Vector2(112, 22), "shadow_wall"))
	commands.append(_rect(Vector2(0, 2), Vector2(120, 6), "wood_mid"))
	commands.append(_line(Vector2(0, 2), Vector2(120, 2), "ivory", 1.0, 0.35))

	# Gavetas e puxadores.
	commands.append(_rect(Vector2(8, 13), Vector2(48, 9), "wood_dark"))
	commands.append(_rect(Vector2(64, 13), Vector2(48, 9), "wood_dark"))
	commands.append(_line(Vector2(8, 17), Vector2(56, 17), "shadow_deep", 1.0, 0.7))
	commands.append(_line(Vector2(64, 17), Vector2(112, 17), "shadow_deep", 1.0, 0.7))
	commands.append(_circle(Vector2(32, 17), 1.5, "amber"))
	commands.append(_circle(Vector2(88, 17), 1.5, "amber"))

	# Pernas.
	commands.append(_rect(Vector2(6, 32), Vector2(6, 4), "shadow_deep"))
	commands.append(_rect(Vector2(108, 32), Vector2(6, 4), "shadow_deep"))

	# Livro-caixa e chave.
	commands.append(_rect(Vector2(12, -1), Vector2(26, 3), "ivory"))
	commands.append(_line(Vector2(14, 0), Vector2(36, 0), "wall", 1.0, 0.8))
	commands.append(_line(Vector2(46, -1), Vector2(54, -1), "amber", 1.0))
	commands.append(_circle(Vector2(55, -1), 1.5, "amber"))

	return _definition(&"lab_reception_desk", Vector2i(120, 38), Vector2(60, 34), commands)


func _lamp() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	# Halo e cone de luz.
	commands.append(_circle(Vector2(12, 16), 18.0, "amber", 0.06))
	commands.append(_polygon([
		Vector2(2, 16), Vector2(22, 16), Vector2(32, 54), Vector2(-8, 54)
	], "amber", 0.045))

	# Suporte, cúpula e lâmpada.
	commands.append(_rect(Vector2(10, 14), Vector2(4, 16), "shadow_deep"))
	commands.append(_polygon([
		Vector2(2, 6), Vector2(22, 6), Vector2(25, 16), Vector2(-1, 16)
	], "wood_dark"))
	commands.append(_line(Vector2(2, 6), Vector2(22, 6), "amber", 1.0, 0.8))
	commands.append(_circle(Vector2(12, 17), 2.0, "ivory"))

	return _definition(&"lab_wall_lamp", Vector2i(24, 30), Vector2(12, 30), commands)


func _envelope() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	commands.append(_polygon([
		Vector2(0, 8), Vector2(2, 6), Vector2(16, 6), Vector2(18, 8),
		Vector2(16, 10), Vector2(2, 10)
	], "shadow_deep", 0.4))
	commands.append(_rect(Vector2(0, 0), Vector2(18, 8), "ivory"))
	commands.append(_line(Vector2(0, 0), Vector2(9, 4), "wall", 1.0, 0.8))
	commands.append(_line(Vector2(18, 0), Vector2(9, 4), "wall", 1.0, 0.8))
	commands.append(_circle(Vector2(9, 4), 1.5, "red_muted"))

	return _definition(&"lab_envelope", Vector2i(18, 10), Vector2(9, 8), commands)


func _detective() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	# Sombra de contato.
	commands.append(_polygon([
		Vector2(-4, 60), Vector2(2, 56), Vector2(30, 56), Vector2(36, 60),
		Vector2(30, 64), Vector2(2, 64)
	], "shadow_deep", 0.55))

	# Pernas e sapatos.
	commands.append(_rect(Vector2(10, 42), Vector2(5, 16), "shadow_deep"))
	commands.append(_rect(Vector2(17, 42), Vector2(5, 16), "shadow_deep"))
	commands.append(_rect(Vector2(7, 56), Vector2(10, 4), "shadow_deep"))
	commands.append(_rect(Vector2(15, 56), Vector2(10, 4), "shadow_deep"))

	# Sobretudo e brilho de contorno.
	commands.append(_polygon([
		Vector2(6, 20), Vector2(26, 20), Vector2(28, 44), Vector2(24, 52),
		Vector2(20, 44), Vector2(16, 50), Vector2(12, 44), Vector2(8, 52),
		Vector2(4, 44)
	], "shadow_wall"))
	commands.append(_line(Vector2(26, 20), Vector2(28, 44), "amber", 1.0, 0.35))

	# Cinto, camisa e gravata.
	commands.append(_rect(Vector2(6, 38), Vector2(20, 3), "wood_dark"))
	commands.append(_rect(Vector2(14, 38), Vector2(4, 3), "amber"))
	commands.append(_polygon([
		Vector2(12, 20), Vector2(20, 20), Vector2(16, 28)
	], "ivory"))
	commands.append(_polygon([
		Vector2(15, 24), Vector2(17, 24), Vector2(18, 34), Vector2(16, 38),
		Vector2(14, 34)
	], "red_muted"))

	# Braços e mãos.
	commands.append(_polygon([
		Vector2(6, 22), Vector2(2, 38), Vector2(6, 42), Vector2(11, 26)
	], "shadow_wall"))
	commands.append(_polygon([
		Vector2(26, 22), Vector2(30, 38), Vector2(26, 42), Vector2(21, 26)
	], "shadow_wall"))
	commands.append(_circle(Vector2(4, 42), 2.0, "wood_mid"))
	commands.append(_circle(Vector2(28, 42), 2.0, "wood_mid"))

	# Pescoço, cabeça e sombra do rosto.
	commands.append(_rect(Vector2(13, 17), Vector2(6, 4), "wood_mid"))
	commands.append(_polygon([
		Vector2(10, 9), Vector2(22, 9), Vector2(24, 15), Vector2(21, 20),
		Vector2(11, 20), Vector2(8, 15)
	], "wood_mid"))
	commands.append(_polygon([
		Vector2(17, 9), Vector2(22, 9), Vector2(24, 15), Vector2(21, 20),
		Vector2(17, 20)
	], "wood_dark"))
	commands.append(_circle(Vector2(13, 15), 0.8, "shadow_deep"))
	commands.append(_circle(Vector2(19, 15), 0.8, "shadow_deep"))

	# Chapéu.
	commands.append(_rect(Vector2(4, 8), Vector2(24, 3), "shadow_deep"))
	commands.append(_rect(Vector2(9, 0), Vector2(14, 9), "shadow_deep"))
	commands.append(_rect(Vector2(9, 6), Vector2(14, 2), "wood_dark"))
	commands.append(_line(Vector2(4, 8), Vector2(28, 8), "wood_mid", 1.0, 0.5))

	return _definition(&"lab_detective", Vector2i(32, 64), Vector2(16, 60), commands)
