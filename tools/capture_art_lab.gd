extends SceneTree

## Captura o Art Lab em uma resolução de janela e em um dos dois modos de escala.
## Uso:
##   godot --path . -s res://tools/capture_art_lab.gd -- \
##     1280 720 game tests/manual/screenshots/art-lab/art_lab_1280x720_4x.png
##
## Argumentos: largura altura modo( game | 1x ) caminho_do_png [fullscreen]
## O mesmo diretório recebe também uma captura crua de 320×180 com sufixo _raw.png.
## Para 1920×1080, execute com --display-driver x11 --fullscreen e informe fullscreen.

const LAB_SCENE := "res://scenes/art_lab/procedural_art_lab.tscn"


func _initialize() -> void:
	_run()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() < 4:
		push_error("Uso: -- <largura> <altura> <game|1x> <saida.png>")
		quit(2)
		return

	var width := int(args[0])
	var height := int(args[1])
	var mode := String(args[2]).to_lower()
	var output_path := String(args[3])
	var use_fullscreen := args.size() >= 5 and String(args[4]).to_lower() == "fullscreen"
	if width <= 0 or height <= 0:
		push_error("Resolução inválida: %dx%d" % [width, height])
		quit(2)
		return
	if mode != "game" and mode != "1x":
		push_error("Modo inválido: %s (use game ou 1x)" % mode)
		quit(2)
		return

	if use_fullscreen:
		root.mode = Window.MODE_FULLSCREEN
	else:
		root.size = Vector2i(width, height)

	var scene := load(LAB_SCENE) as PackedScene
	if scene == null:
		push_error("Não foi possível carregar %s" % LAB_SCENE)
		quit(2)
		return
	var lab := scene.instantiate() as ProceduralArtLab
	if lab == null:
		push_error("A cena do laboratório não é um ProceduralArtLab.")
		quit(2)
		return
	root.add_child(lab)

	# Espera o layout, o SubViewport e a barra de paleta estabilizarem.
	for _frame in range(4):
		await process_frame

	if mode == "1x":
		lab.set_1x(true)
		for _frame in range(2):
			await process_frame

	await RenderingServer.frame_post_draw

	var image := root.get_texture().get_image()
	if image.get_width() != width or image.get_height() != height:
		push_error(
			"Captura em resolução inesperada: %dx%d (pedido %dx%d)"
			% [image.get_width(), image.get_height(), width, height]
		)
		quit(2)
		return
	var save_error := image.save_png(output_path)
	if save_error != OK:
		push_error("Falha ao salvar %s (erro %d)" % [output_path, save_error])
		quit(2)
		return
	print("Captura: %s (%dx%d, modo %s)" % [output_path, image.get_width(), image.get_height(), mode])

	var raw_path := output_path.get_basename() + "_raw.png"
	var raw_image := lab.game_viewport.get_texture().get_image()
	var raw_error := raw_image.save_png(raw_path)
	if raw_error != OK:
		push_error("Falha ao salvar %s (erro %d)" % [raw_path, raw_error])
		quit(2)
		return
	print("Viewport cru: %s (%dx%d)" % [raw_path, raw_image.get_width(), raw_image.get_height()])

	quit(0)
