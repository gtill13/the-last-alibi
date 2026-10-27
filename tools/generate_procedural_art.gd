extends SceneTree

## Gera as definições .tres usadas na demo de arte procedural.
## Uso:
##   godot --headless --path . -s res://tools/generate_procedural_art.gd
##
## As definições são dados puros: o renderizador não conhece nenhum destes
## objetos, apenas interpreta os comandos geométricos.

const OUT_DIR := "res://art/definitions"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	_save(_room_background(), "room_background.tres")
	_save(_hotel_desk(), "hotel_desk.tres")
	_save(_hotel_desk_alt(), "hotel_desk_alt.tres")
	_save(_hotel_plant(), "hotel_plant.tres")
	_save(_hotel_painting(), "hotel_painting.tres")
	_save(_detective(), "detective.tres")
	quit(0)


func _save(definition: ProceduralArtDefinition, file_name: String) -> void:
	var path := OUT_DIR.path_join(file_name)
	var error := ResourceSaver.save(definition, path)
	if error != OK:
		push_error("Falha ao salvar %s (erro %d)" % [path, error])
	else:
		print("Gerado: %s" % path)


func _rect(position: Vector2, size: Vector2, color: Color, filled: bool = true, width: float = 1.0) -> Dictionary:
	return {
		"type": "rect",
		"position": position,
		"size": size,
		"color": color,
		"filled": filled,
		"width": width,
	}


func _line(from: Vector2, to: Vector2, color: Color, width: float = 1.0) -> Dictionary:
	return {"type": "line", "from": from, "to": to, "color": color, "width": width}


func _circle(center: Vector2, radius: float, color: Color) -> Dictionary:
	return {"type": "circle", "center": center, "radius": radius, "color": color}


func _polygon(points: Array[Vector2], color: Color) -> Dictionary:
	return {"type": "polygon", "points": PackedVector2Array(points), "color": color}


func _definition(id: StringName, size: Vector2i, pivot: Vector2, commands: Array[Dictionary]) -> ProceduralArtDefinition:
	var definition := ProceduralArtDefinition.new()
	definition.definition_id = id
	definition.logical_size = size
	definition.pivot = pivot
	definition.commands = commands
	return definition


func _room_background() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	# Parede e piso.
	commands.append(_rect(Vector2.ZERO, Vector2(1280, 520), Color.html("#1b232e")))
	commands.append(_rect(Vector2(0, 512), Vector2(1280, 10), Color.html("#2b3644")))
	commands.append(_rect(Vector2(0, 520), Vector2(1280, 200), Color.html("#11161c")))
	for x in [320.0, 640.0, 960.0]:
		commands.append(_line(Vector2(x, 0), Vector2(x, 512), Color.html("#232d3a"), 2.0))
	for y in [560.0, 600.0, 640.0, 680.0]:
		commands.append(_line(Vector2(0, y), Vector2(1280, y), Color.html("#182029"), 1.0))

	# Luz fria da janela projetada no piso.
	commands.append(_polygon([
		Vector2(820, 520), Vector2(1100, 520), Vector2(1160, 720), Vector2(760, 720)
	], Color(0.32, 0.45, 0.65, 0.06)))

	# Tapete.
	commands.append(_polygon([
		Vector2(260, 590), Vector2(620, 590), Vector2(660, 690), Vector2(220, 690)
	], Color.html("#2a1f24")))
	commands.append(_polygon([
		Vector2(280, 600), Vector2(600, 600), Vector2(632, 678), Vector2(248, 678)
	], Color.html("#35262c")))
	commands.append(_line(Vector2(280, 600), Vector2(600, 600), Color.html("#4a3540"), 2.0))

	# Porta à esquerda.
	commands.append(_rect(Vector2(50, 250), Vector2(130, 262), Color.html("#2a211d")))
	commands.append(_rect(Vector2(62, 262), Vector2(106, 238), Color.html("#3a2b25")))
	commands.append(_rect(Vector2(70, 270), Vector2(90, 100), Color.html("#33251f")))
	commands.append(_rect(Vector2(70, 380), Vector2(90, 112), Color.html("#33251f")))
	commands.append(_circle(Vector2(70, 390), 4.0, Color.html("#a8843c")))

	# Janela com noite e lua.
	commands.append(_rect(Vector2(860, 110), Vector2(210, 240), Color.html("#2a211d")))
	commands.append(_rect(Vector2(872, 122), Vector2(186, 216), Color.html("#14243a")))
	commands.append(_rect(Vector2(872, 122), Vector2(186, 104), Color.html("#1b2f4a")))
	commands.append(_circle(Vector2(1010, 172), 20.0, Color.html("#e6dcb8")))
	commands.append(_polygon([
		Vector2(872, 300), Vector2(900, 270), Vector2(930, 300), Vector2(960, 250),
		Vector2(990, 300), Vector2(1020, 280), Vector2(1058, 300), Vector2(1058, 338),
		Vector2(872, 338)
	], Color.html("#0d1826")))
	commands.append(_line(Vector2(965, 122), Vector2(965, 338), Color.html("#3a2b25"), 5.0))
	commands.append(_line(Vector2(872, 230), Vector2(1058, 230), Color.html("#3a2b25"), 5.0))
	commands.append(_line(Vector2(860, 110), Vector2(1070, 110), Color.html("#4a3a30"), 3.0))
	commands.append(_rect(Vector2(848, 350), Vector2(234, 12), Color.html("#3a2b25")))

	# Relógio de parede.
	commands.append(_circle(Vector2(700, 150), 28.0, Color.html("#2a2320")))
	commands.append(_circle(Vector2(700, 150), 23.0, Color.html("#d9d2b0")))
	commands.append(_line(Vector2(700, 150), Vector2(700, 136), Color.html("#2a2320"), 2.0))
	commands.append(_line(Vector2(700, 150), Vector2(710, 156), Color.html("#2a2320"), 2.0))

	return _definition(&"room_background", Vector2i(1280, 720), Vector2.ZERO, commands)


func _hotel_desk() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	# Sombra de contato na base (pivô em y=90).
	commands.append(_polygon([
		Vector2(-10, 90), Vector2(10, 84), Vector2(180, 84), Vector2(200, 90),
		Vector2(180, 96), Vector2(10, 96)
	], Color(0, 0, 0, 0.35)))

	# Tampo e corpo.
	commands.append(_rect(Vector2(0, 0), Vector2(190, 16), Color.html("#7a4a38")))
	commands.append(_rect(Vector2(0, 0), Vector2(190, 4), Color.html("#a86a4a")))
	commands.append(_rect(Vector2(8, 16), Vector2(174, 62), Color.html("#4a2d26")))
	commands.append(_rect(Vector2(16, 22), Vector2(158, 48), Color.html("#5a3830")))

	# Gavetas e puxadores.
	for position in [
		Vector2(24, 26), Vector2(24, 46), Vector2(102, 26), Vector2(102, 46)
	]:
		commands.append(_rect(position, Vector2(64 if position.x < 100 else 60, 16), Color.html("#3a241f")))
	for center in [Vector2(56, 34), Vector2(56, 54), Vector2(132, 34), Vector2(132, 54)]:
		commands.append(_circle(center, 3.0, Color.html("#a8843c")))

	# Pernas.
	commands.append(_rect(Vector2(10, 78), Vector2(12, 12), Color.html("#2e1c18")))
	commands.append(_rect(Vector2(168, 78), Vector2(12, 12), Color.html("#2e1c18")))

	# Papéis e caneca.
	commands.append(_rect(Vector2(36, -2), Vector2(38, 10), Color.html("#d9d2b0")))
	commands.append(_rect(Vector2(42, 0), Vector2(32, 8), Color.html("#e8dfbf")))
	commands.append(_line(Vector2(46, 2), Vector2(70, 2), Color.html("#7a7460"), 1.0))
	commands.append(_line(Vector2(46, 4), Vector2(66, 4), Color.html("#7a7460"), 1.0))
	commands.append(_circle(Vector2(86, 4), 5.0, Color.html("#b0b7c0")))
	commands.append(_line(Vector2(91, 2), Vector2(94, 4), Color.html("#b0b7c0"), 2.0))

	# Luminária de mesa.
	commands.append(_rect(Vector2(128, -2), Vector2(24, 4), Color.html("#2a2320")))
	commands.append(_rect(Vector2(138, -30), Vector2(4, 28), Color.html("#2a2320")))
	commands.append(_polygon([
		Vector2(120, -32), Vector2(160, -32), Vector2(168, -12), Vector2(112, -12)
	], Color.html("#d9a441")))
	commands.append(_line(Vector2(120, -32), Vector2(160, -32), Color.html("#f0c060"), 2.0))
	commands.append(_circle(Vector2(140, -14), 6.0, Color.html("#ffe6a8")))

	return _definition(&"hotel_desk", Vector2i(190, 90), Vector2(95, 90), commands)


func _hotel_desk_alt() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	# Sombra de contato na base (pivô em y=90).
	commands.append(_polygon([
		Vector2(-10, 90), Vector2(10, 84), Vector2(180, 84), Vector2(200, 90),
		Vector2(180, 96), Vector2(10, 96)
	], Color(0, 0, 0, 0.35)))

	commands.append(_rect(Vector2(0, 0), Vector2(190, 16), Color.html("#3a2a24")))
	commands.append(_rect(Vector2(0, 0), Vector2(190, 4), Color.html("#6b4a3a")))
	commands.append(_rect(Vector2(8, 16), Vector2(174, 62), Color.html("#2e1c18")))
	commands.append(_rect(Vector2(16, 22), Vector2(158, 48), Color.html("#3a2620")))

	for position in [
		Vector2(24, 26), Vector2(24, 46), Vector2(102, 26), Vector2(102, 46)
	]:
		commands.append(_rect(position, Vector2(64 if position.x < 100 else 60, 16), Color.html("#241512")))
	for center in [Vector2(56, 34), Vector2(56, 54), Vector2(132, 34), Vector2(132, 54)]:
		commands.append(_circle(center, 3.0, Color.html("#c9a45a")))

	commands.append(_rect(Vector2(10, 78), Vector2(12, 12), Color.html("#1e1210")))
	commands.append(_rect(Vector2(168, 78), Vector2(12, 12), Color.html("#1e1210")))

	# Papéis e caneca.
	commands.append(_rect(Vector2(36, -2), Vector2(38, 10), Color.html("#c9c2a0")))
	commands.append(_rect(Vector2(42, 0), Vector2(32, 8), Color.html("#d9d2b0")))
	commands.append(_line(Vector2(46, 2), Vector2(70, 2), Color.html("#6a6450"), 1.0))
	commands.append(_circle(Vector2(86, 4), 5.0, Color.html("#8a929c")))
	commands.append(_line(Vector2(91, 2), Vector2(94, 4), Color.html("#8a929c"), 2.0))

	# Abajur verde de banqueiro.
	commands.append(_rect(Vector2(128, -2), Vector2(24, 4), Color.html("#1e2a24")))
	commands.append(_rect(Vector2(138, -30), Vector2(4, 28), Color.html("#1e2a24")))
	commands.append(_polygon([
		Vector2(120, -32), Vector2(160, -32), Vector2(168, -12), Vector2(112, -12)
	], Color.html("#2f5a4a")))
	commands.append(_line(Vector2(120, -32), Vector2(160, -32), Color.html("#5a9a7a"), 2.0))
	commands.append(_circle(Vector2(140, -14), 6.0, Color.html("#a8e6c0")))

	return _definition(&"hotel_desk_alt", Vector2i(190, 90), Vector2(95, 90), commands)


func _hotel_plant() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	# Sombra de contato na base (pivô em y=120).
	commands.append(_polygon([
		Vector2(5, 120), Vector2(20, 114), Vector2(60, 114), Vector2(75, 120),
		Vector2(60, 126), Vector2(20, 126)
	], Color(0, 0, 0, 0.3)))

	# Vaso.
	commands.append(_polygon([
		Vector2(18, 80), Vector2(62, 80), Vector2(54, 120), Vector2(26, 120)
	], Color.html("#8a4b32")))
	commands.append(_rect(Vector2(14, 74), Vector2(52, 10), Color.html("#a85a3a")))
	commands.append(_rect(Vector2(22, 78), Vector2(36, 4), Color.html("#2a1c18")))

	# Hastes.
	commands.append(_line(Vector2(40, 80), Vector2(30, 40), Color.html("#3f5f3a"), 3.0))
	commands.append(_line(Vector2(40, 80), Vector2(52, 32), Color.html("#3f5f3a"), 3.0))
	commands.append(_line(Vector2(40, 80), Vector2(20, 52), Color.html("#3f5f3a"), 3.0))

	# Folhas.
	commands.append(_polygon([
		Vector2(30, 40), Vector2(14, 30), Vector2(18, 18), Vector2(34, 30)
	], Color.html("#4f7a4a")))
	commands.append(_polygon([
		Vector2(30, 40), Vector2(44, 26), Vector2(56, 32), Vector2(40, 46)
	], Color.html("#5f8a56")))
	commands.append(_polygon([
		Vector2(52, 32), Vector2(64, 20), Vector2(74, 28), Vector2(58, 42)
	], Color.html("#4f7a4a")))
	commands.append(_polygon([
		Vector2(52, 32), Vector2(44, 14), Vector2(56, 10), Vector2(62, 24)
	], Color.html("#5f8a56")))
	commands.append(_polygon([
		Vector2(20, 52), Vector2(6, 44), Vector2(4, 32), Vector2(22, 40)
	], Color.html("#3f6a3a")))
	commands.append(_polygon([
		Vector2(20, 52), Vector2(28, 34), Vector2(38, 38), Vector2(28, 56)
	], Color.html("#5f8a56")))
	commands.append(_circle(Vector2(60, 24), 5.0, Color.html("#d9a441")))

	return _definition(&"hotel_plant", Vector2i(80, 120), Vector2(40, 120), commands)


func _hotel_painting() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	commands.append(_rect(Vector2(6, 6), Vector2(140, 100), Color(0, 0, 0, 0.25)))
	commands.append(_rect(Vector2(0, 0), Vector2(140, 100), Color.html("#a8843c")))
	commands.append(_line(Vector2(0, 0), Vector2(140, 0), Color.html("#d9b45a"), 2.0))
	commands.append(_rect(Vector2(8, 8), Vector2(124, 84), Color.html("#2f3a4a")))
	commands.append(_rect(Vector2(14, 14), Vector2(112, 72), Color.html("#1b232e")))
	commands.append(_rect(Vector2(20, 20), Vector2(100, 60), Color.html("#22304a")))

	# Lua e skyline.
	commands.append(_circle(Vector2(96, 40), 10.0, Color.html("#e6dcb8")))
	commands.append(_polygon([
		Vector2(20, 80), Vector2(20, 64), Vector2(32, 64), Vector2(32, 54),
		Vector2(44, 54), Vector2(44, 70), Vector2(56, 70), Vector2(56, 48),
		Vector2(70, 48), Vector2(70, 66), Vector2(82, 66), Vector2(82, 58),
		Vector2(96, 58), Vector2(96, 72), Vector2(108, 72), Vector2(108, 80)
	], Color.html("#0d1826")))
	commands.append(_line(Vector2(20, 78), Vector2(120, 78), Color.html("#7a2e2e"), 2.0))

	return _definition(&"hotel_painting", Vector2i(140, 100), Vector2(70, 50), commands)


func _detective() -> ProceduralArtDefinition:
	var commands: Array[Dictionary] = []

	# Sombra de contato na base (pivô em y=150).
	commands.append(_polygon([
		Vector2(5, 150), Vector2(20, 144), Vector2(60, 144), Vector2(75, 150),
		Vector2(60, 156), Vector2(20, 156)
	], Color(0, 0, 0, 0.35)))

	# Pernas e sapatos.
	commands.append(_rect(Vector2(24, 100), Vector2(12, 44), Color.html("#2a2320")))
	commands.append(_rect(Vector2(44, 100), Vector2(12, 44), Color.html("#2a2320")))
	commands.append(_rect(Vector2(18, 144), Vector2(22, 6), Color.html("#14100e")))
	commands.append(_rect(Vector2(40, 144), Vector2(22, 6), Color.html("#14100e")))

	# Sobretudo.
	commands.append(_polygon([
		Vector2(12, 60), Vector2(68, 60), Vector2(72, 110), Vector2(60, 122),
		Vector2(52, 100), Vector2(48, 120), Vector2(32, 120), Vector2(28, 100),
		Vector2(20, 122), Vector2(8, 110)
	], Color.html("#b08a5a")))
	commands.append(_line(Vector2(40, 62), Vector2(40, 118), Color.html("#6b4a2f"), 2.0))
	commands.append(_rect(Vector2(16, 92), Vector2(48, 6), Color.html("#6b4a2f")))
	commands.append(_rect(Vector2(36, 91), Vector2(8, 8), Color.html("#c9a45a")))

	# Braços e mãos.
	commands.append(_polygon([
		Vector2(12, 64), Vector2(4, 96), Vector2(10, 100), Vector2(20, 72)
	], Color.html("#9a754a")))
	commands.append(_polygon([
		Vector2(68, 64), Vector2(76, 96), Vector2(70, 100), Vector2(60, 72)
	], Color.html("#9a754a")))
	commands.append(_circle(Vector2(8, 100), 4.0, Color.html("#c9a07a")))
	commands.append(_circle(Vector2(72, 100), 4.0, Color.html("#c9a07a")))

	# Pescoço, cabeça e rosto.
	commands.append(_rect(Vector2(34, 54), Vector2(12, 8), Color.html("#c9a07a")))
	commands.append(_circle(Vector2(40, 42), 13.0, Color.html("#c9a07a")))
	commands.append(_circle(Vector2(35, 42), 1.5, Color.html("#14100e")))
	commands.append(_circle(Vector2(45, 42), 1.5, Color.html("#14100e")))

	# Chapéu.
	commands.append(_rect(Vector2(16, 30), Vector2(48, 6), Color.html("#2a2320")))
	commands.append(_rect(Vector2(24, 12), Vector2(32, 20), Color.html("#2a2320")))
	commands.append(_rect(Vector2(24, 26), Vector2(32, 5), Color.html("#6b4a2f")))

	# Gravata.
	commands.append(_polygon([
		Vector2(36, 56), Vector2(44, 56), Vector2(46, 72), Vector2(40, 80),
		Vector2(34, 72)
	], Color.html("#7a2e2e")))

	return _definition(&"detective", Vector2i(80, 150), Vector2(40, 150), commands)
