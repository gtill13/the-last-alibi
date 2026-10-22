extends Node
class_name DossierPresenter

signal dossier_submitted(submission: DossierSubmission)
signal dossier_cancelled

@export var dossier_node: Control

func open_dossier() -> void:
    if dossier_node != null:
        dossier_node.show()

func close_dossier() -> void:
    if dossier_node != null:
        dossier_node.hide()

func submit_dossier(submission: DossierSubmission) -> void:
    dossier_submitted.emit(submission)

func cancel_dossier() -> void:
    dossier_cancelled.emit()
