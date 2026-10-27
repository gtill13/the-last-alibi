class_name InteractionPrompt
extends Control

## HUD fixa na tela. Recebe apenas o alvo ativo e exibe ação + nome legível.

var current_target_id: StringName = &""

@onready var prompt_label: Label = $PromptLabel


func _ready() -> void:
	hide_prompt()


func show_for_target(target: Interactable) -> void:
	if not is_instance_valid(target) or not target.can_interact():
		hide_prompt()
		return

	current_target_id = target.interactable_id
	prompt_label.text = "[E] %s — %s" % [target.interaction_label, target.display_name]
	visible = true


func hide_prompt() -> void:
	current_target_id = &""
	visible = false
	if prompt_label != null:
		prompt_label.text = ""
