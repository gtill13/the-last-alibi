extends Node
class_name DialoguePresenter

signal dialogue_closed
signal topic_selected(topic_id: StringName)

@export var panel_node: Control

func open_dialogue(suspect_name: String) -> void:
    if panel_node != null:
        panel_node.show()
        # Apresentador apenas expõe; o preenchimento do conteúdo cabe à cena de diálogo.
        pass

func close_dialogue() -> void:
    if panel_node != null:
        panel_node.hide()
    dialogue_closed.emit()
