extends Node2D

## Fixture do teste do cache: registra os hooks de aquisição/liberação.

var acquired_count := 0
var released_count := 0
var state := 0


func on_procedural_cache_acquired() -> void:
	acquired_count += 1


func on_procedural_cache_released() -> void:
	released_count += 1
	state = 0
