extends Control
class_name NotebookScreenUI

signal notebook_closed

@onready var evidence_list: ItemList = $Panel/EvidenceList
@onready var interview_list: ItemList = $Panel/InterviewList
@onready var close_button: Button = $Panel/CloseButton
@onready var tab_container: TabContainer = $Panel/TabContainer

var notebook_model: NotebookModel

func _ready() -> void:
    visible = false
    close_button.pressed.connect(_on_close_pressed)
    tab_container.tab_changed.connect(_on_tab_changed)

func bind_model(model: NotebookModel) -> void:
    notebook_model = model
    _refresh()

func _refresh() -> void:
    if notebook_model == null:
        return
    evidence_list.clear()
    for entry in notebook_model.get_collected_evidence_titles():
        evidence_list.add_item(entry["title"])
        evidence_list.set_item_metadata(evidence_list.get_item_count() - 1, entry["id"])
        evidence_list.add_subitem(entry["description"], -1, False)

    interview_list.clear()
    for entry in notebook_model.get_interview_summaries():
        interview_list.add_item("Entrevista — %s" % [entry["suspect_id"]])
        interview_list.set_item_metadata(interview_list.get_item_count() - 1, entry["id"])

func _on_tab_changed(idx: int) -> void:
    pass

func _on_close_pressed() -> void:
    visible = false
    notebook_closed.emit()
