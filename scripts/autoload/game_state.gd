extends Node
class_name GameState

# Estado mínimo que sobrevive a transições de cena.
var current_case_id: StringName = &""
var game_phase: String = "menu" # menu, briefing, investigation, dossier, trial, results
var last_trial_result: Dictionary = {}
var save_version: int = 1

func reset_case_state() -> void:
    current_case_id = &""
    game_phase = "menu"
    last_trial_result = {}
