class_name UnitTestCase
extends RefCounted

## Base das suítes de teste. Coleta falhas em vez de abortar.

var _failures: Array[String] = []


func clear_results() -> void:
	_failures.clear()


func take_failures() -> Array[String]:
	var result: Array[String] = _failures.duplicate()
	_failures.clear()
	return result


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		_record("esperava true", message)


func assert_false(condition: bool, message: String = "") -> void:
	if condition:
		_record("esperava false", message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		_record("esperava %s; recebeu %s" % [str(expected), str(actual)], message)


func assert_ne(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual == expected:
		_record("não esperava %s" % str(expected), message)


func assert_null(value: Variant, message: String = "") -> void:
	if value != null:
		_record("esperava null; recebeu %s" % str(value), message)


func assert_not_null(value: Variant, message: String = "") -> void:
	if value == null:
		_record("esperava valor não nulo", message)


func _record(detail: String, message: String) -> void:
	var text: String = detail
	if message != "":
		text += " (%s)" % message
	_failures.append(text)
