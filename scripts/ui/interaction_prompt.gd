extends Control
class_name InteractionPrompt

var current_target_id: StringName = &""

func show_prompt(target_id: StringName) -> void:
    current_target_id = target_id
    var label = $PromptLabel
    label.text = "[E] Interagir"
    visible = true

func hide_prompt() -> void:
    current_target_id = &""
    visible = false
