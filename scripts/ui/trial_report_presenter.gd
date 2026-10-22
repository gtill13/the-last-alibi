extends Node
class_name TrialReportPresenter

signal trial_closed

@export var report_node: Control

func show_report(verdict_data: Dictionary) -> void:
    if report_node != null:
        report_node.show()
        # A cena de trial_report preenche os labels com base em verdict_data.

func close_report() -> void:
    if report_node != null:
        report_node.hide()
    trial_closed.emit()
