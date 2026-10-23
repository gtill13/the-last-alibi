extends SceneTree

## Executor headless das suítes de teste unitário e de integração.
## Uso: "$GODOT_BIN" --headless --path . -s res://tests/framework/test_runner.gd

const SUITE_DIRS: Array[String] = ["res://tests/unit", "res://tests/integration"]

var _passed: int = 0
var _failed: int = 0
var _discovered_tests: int = 0
var _discovered_suites: int = 0


func _initialize() -> void:
	# Configurar InputMap para testes (move_left/move_right usados pelo Investigador).
	_input_map_add_action("move_left", KEY_A)
	_input_map_add_action("move_right", KEY_D)
	_input_map_add_action("interact", KEY_E)
	_input_map_add_action("open_notebook", KEY_N)
	_input_map_add_action("cancel", KEY_ESCAPE)
	_input_map_add_action("confirm", KEY_ENTER)

	for suite_dir: String in SUITE_DIRS:
		_run_directory(suite_dir)

	if _discovered_tests == 0:
		push_error("Nenhum método de teste foi encontrado; a execução não pode ser considerada aprovada.")
		_failed += 1

	print("== Resultado: %d passaram, %d falharam (%d suítes, %d testes descobertos) ==" % [
		_passed, _failed, _discovered_suites, _discovered_tests
	])
	quit(1 if _failed > 0 else 0)


func _input_map_add_action(action_name: String, keycode: int) -> void:
	var input_map = InputMap
	if not input_map.has_action(action_name):
		input_map.add_action(action_name)
	var event = InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	input_map.action_add_event(action_name, event)


func _run_directory(suite_dir: String) -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(suite_dir)):
		push_error("Diretório de suítes inexistente: %s" % suite_dir)
		_failed += 1
		return

	var file_names: Array[String] = []
	for file_name: String in DirAccess.get_files_at(suite_dir):
		if file_name.ends_with(".gd"):
			file_names.append(file_name)
	file_names.sort()

	for file_name: String in file_names:
		_run_suite(suite_dir.path_join(file_name))


func _run_suite(script_path: String) -> void:
	var script: GDScript = load(script_path) as GDScript
	if script == null:
		push_error("Não foi possível carregar a suíte: %s" % script_path)
		_failed += 1
		return
	if not script.can_instantiate():
		push_error("A suíte não pode ser instanciada: %s" % script_path)
		_failed += 1
		return

	var instance: Object = script.new()
	if not instance is UnitTestCase:
		push_error("A suíte deve herdar de UnitTestCase: %s" % script_path)
		_failed += 1
		return

	var suite: UnitTestCase = instance as UnitTestCase
	var test_methods: Array[String] = []
	for method_info: Dictionary in suite.get_method_list():
		var method_name: String = str(method_info.get("name", ""))
		if method_name.begins_with("test_"):
			test_methods.append(method_name)
	test_methods.sort()

	if test_methods.is_empty():
		push_error("A suíte não possui métodos test_: %s" % script_path)
		_failed += 1
		return

	_discovered_suites += 1
	for method_name: String in test_methods:
		_discovered_tests += 1
		suite.clear_results()
		suite.call(method_name)
		var failures: Array[String] = suite.take_failures()
		if failures.is_empty():
			_passed += 1
			print("[PASS] %s::%s" % [script_path.get_file(), method_name])
		else:
			_failed += 1
			for failure: String in failures:
				print("[FAIL] %s::%s — %s" % [script_path.get_file(), method_name, failure])
