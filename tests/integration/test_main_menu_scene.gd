extends UnitTestCase

## Menu principal (Fase 0): cena autônoma, botões Start Case e Quit,
## criação da investigação sem encerrar o runner.

const MENU_SCENE_PATH := "res://scenes/app/main_menu.tscn"


func _instantiate_menu():
	var tree := Engine.get_main_loop() as SceneTree
	var scene: PackedScene = load(MENU_SCENE_PATH)
	var menu = scene.instantiate()
	tree.root.add_child(menu)
	return menu


func test_menu_scene_loads_with_title() -> void:
	var menu = _instantiate_menu()
	assert_true(menu is Control, "cena raiz é um Control")
	var title: Label = menu.get_node("Container/TitleLabel")
	assert_eq(title.text, "THE LAST ALIBI")
	menu.free()


func test_menu_exposes_start_and_quit_buttons() -> void:
	var menu = _instantiate_menu()
	var start: Button = menu.get_node("Container/ButtonStart")
	var quit: Button = menu.get_node("Container/ButtonQuit")
	assert_eq(start.text, "Start Case")
	assert_eq(quit.text, "Quit")
	assert_eq(start.focus_mode, Control.FOCUS_ALL, "Start Case é focável por teclado")
	assert_eq(quit.focus_mode, Control.FOCUS_ALL, "Quit é focável por teclado")
	menu.free()


func test_start_button_is_present_and_focusable() -> void:
	var menu = _instantiate_menu()
	var start: Button = menu.get_node("Container/ButtonStart")
	assert_eq(start.text, "Start Case")
	assert_eq(start.focus_mode, Control.FOCUS_ALL, "Start Case é focável por teclado")
	menu.free()
