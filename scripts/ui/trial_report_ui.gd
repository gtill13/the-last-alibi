extends Control
class_name TrialReportUI

signal trial_closed

@onready var verdict_label: Label = $Panel/VerdictLabel
@onready var summary_label: Label = $Panel/SummaryLabel
@onready var sections_list: ItemList = $Panel/SectionsList
@onready var retry_button: Button = $Panel/RetryButton
@onready var menu_button: Button = $Panel/MenuButton

func show_report(result: Dictionary) -> void:
    var accused = result["accused_suspect_id"]
    var truth = result["truth_suspect_id"]
    var verdict = result["verdict"]
    var is_correct = result["is_correct_outcome"]
    var summary = result["short_summary"]

    verdict_label.text = "Veredito: %s (acusado: %s | verdade: %s)" % [verdict, accused, truth]
    summary_label.text = summary

    sections_list.clear()
    for section in result["report_sections"]:
        sections_list.add_item("%s: %s" % [section["title"], section["text"]])

    visible = true

func _on_retry_pressed() -> void:
    visible = false
    trial_closed.emit()

func _on_menu_pressed() -> void:
    visible = false
    trial_closed.emit()

func _ready() -> void:
    visible = false
    retry_button.pressed.connect(_on_retry_pressed)
    menu_button.pressed.connect(_on_menu_pressed)
