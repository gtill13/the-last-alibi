extends Control
class_name InteractionPrompt

var current_target_id: StringName = &""

# Decisão 5: texto dinâmico por tipo do interagível.
func show_prompt(target_id: StringName, interaction_label: String = "Interagir") -> void:
    current_target_id = target_id
    var label = $PromptLabel
    label.text = "[E] %s" % [interaction_label]
    visible = true

func hide_prompt() -> void:
    current_target_id = &""
    visible = false
