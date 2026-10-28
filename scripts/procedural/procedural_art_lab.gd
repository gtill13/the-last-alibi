extends Control
class_name ProceduralArtLab

## Laboratório visual da Fase 1.
## A cena lógica tem 320×180; o TextureRect principal amplia com filtro nearest.
## Tab alterna entre a escala de jogo e a prévia 1×.

const PROFILE_PATH := "res://art/procedural/profiles/ps1_noir_profile.tres"
const LOGICAL_SIZE := Vector2i(320, 180)
const SWATCH_HEIGHT := 22.0

@export var style_profile: ProceduralStyleProfile
@export var start_in_1x: bool = false

@onready var game_viewport: SubViewport = $GameViewport
@onready var scene_root: Node2D = $GameViewport/Scene
@onready var main_display: TextureRect = $MainDisplay
@onready var palette_list: HBoxContainer = $UI/PaletteBar/Margin/PaletteList
@onready var scale_label: Label = $UI/ScaleLabel

var _is_1x := false


func _ready() -> void:
	if style_profile == null:
		style_profile = load(PROFILE_PATH) as ProceduralStyleProfile
	if style_profile == null:
		push_error("ProceduralArtLab: perfil de estilo não encontrado em %s." % PROFILE_PATH)

	_apply_profile_to_renderers()
	_connect_style_profile()
	_setup_viewport()
	_populate_palette()
	_update_scale_label()

	if start_in_1x:
		set_1x(true)

	var window := get_window()
	if window != null and not window.size_changed.is_connected(_update_scale_label):
		window.size_changed.connect(_update_scale_label)

	_refresh_viewport.call_deferred()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_TAB, KEY_P:
				set_1x(not _is_1x)
				get_viewport().set_input_as_handled()


func set_1x(value: bool) -> void:
	_is_1x = value
	if main_display != null:
		main_display.stretch_mode = (
			TextureRect.STRETCH_KEEP_CENTERED
			if value
			else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		)
	_update_scale_label()


func get_effective_scale(window_size: Vector2i) -> int:
	var factor_x := int(window_size.x / LOGICAL_SIZE.x)
	var factor_y := int(window_size.y / LOGICAL_SIZE.y)
	return maxi(1, mini(factor_x, factor_y))


func get_scale_text() -> String:
	var window := get_window()
	var window_size := window.size if window != null else Vector2i.ZERO
	var factor := get_effective_scale(window_size)
	var mode := "1× lógico" if _is_1x else "%d×" % factor
	return "320×180 lógico  ·  janela %d×%d  ·  %s  ·  nearest" % [
		window_size.x, window_size.y, mode
	]


func _apply_profile_to_renderers() -> void:
	for renderer in _get_renderers():
		renderer.style_profile = style_profile


func _get_renderers() -> Array[ProceduralArtRenderer]:
	var renderers: Array[ProceduralArtRenderer] = []
	for node in scene_root.find_children("*", "", true, false):
		if node is ProceduralArtRenderer:
			renderers.append(node)
	return renderers


func _connect_style_profile() -> void:
	if style_profile != null and not style_profile.changed.is_connected(_on_style_profile_changed):
		style_profile.changed.connect(_on_style_profile_changed)


func _on_style_profile_changed() -> void:
	_populate_palette()
	_refresh_viewport.call_deferred()


func _setup_viewport() -> void:
	game_viewport.size = LOGICAL_SIZE
	game_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	main_display.texture = game_viewport.get_texture()
	main_display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	main_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	main_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	main_display.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _refresh_viewport() -> void:
	if game_viewport != null:
		game_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func _populate_palette() -> void:
	for child in palette_list.get_children():
		palette_list.remove_child(child)
		child.queue_free()

	if style_profile == null or style_profile.palette == null:
		return

	for color_name: String in style_profile.get_color_names():
		var color := style_profile.get_color(color_name)
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_theme_constant_override("separation", 3)

		var swatch := Control.new()
		swatch.custom_minimum_size = Vector2(0, SWATCH_HEIGHT)
		swatch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var border := ColorRect.new()
		border.color = Color(0.772549, 0.741176, 0.65098, 0.28)
		border.set_anchors_preset(Control.PRESET_FULL_RECT)
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		swatch.add_child(border)

		var fill := ColorRect.new()
		fill.color = color
		fill.anchor_right = 1.0
		fill.anchor_bottom = 1.0
		fill.offset_left = 1.0
		fill.offset_top = 1.0
		fill.offset_right = -1.0
		fill.offset_bottom = -1.0
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		swatch.add_child(fill)

		var label := Label.new()
		label.text = "%s\n%s" % [color_name, color.to_html(false)]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 10)
		label.add_theme_color_override("font_color", Color(0.772549, 0.741176, 0.65098, 1))
		label.add_theme_color_override("font_outline_color", Color(0.035294, 0.051, 0.071, 1))
		label.add_theme_constant_override("outline_size", 2)

		column.add_child(swatch)
		column.add_child(label)
		palette_list.add_child(column)


func _update_scale_label() -> void:
	if scale_label != null:
		scale_label.text = get_scale_text()
