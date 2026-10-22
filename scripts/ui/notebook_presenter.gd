extends Node
class_name NotebookPresenter

signal notebook_closed

@export var notebook_node: Control

func open_notebook() -> void:
    if notebook_node != null:
        notebook_node.show()

func close_notebook() -> void:
    if notebook_node != null:
        notebook_node.hide()
    notebook_closed.emit()
