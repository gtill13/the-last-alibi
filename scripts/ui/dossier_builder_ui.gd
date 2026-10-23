extends Control
class_name DossierBuilderUI

signal dossier_submitted(submission: DossierSubmission)
signal dossier_cancelled

@onready var suspect_selector: OptionButton = $Panel/SuspectSelector
@onready var evidence_selector: ItemList = $Panel/EvidenceSelector
@onready var record_selector: ItemList = $Panel/RecordSelector
@onready var reasoning_note: TextEdit = $Panel/ReasoningNote
@onready var submit_button: Button = $Panel/SubmitButton
@onready var cancel_button: Button = $Panel/CancelButton

var dossier_model: DossierModel
var case_definition: CaseDefinition
var case_session: CaseSession

func bind(model: DossierModel, case_def: CaseDefinition, session: CaseSession) -> void:
    dossier_model = model
    case_definition = case_def
    case_session = session
    _refresh()

func _refresh() -> void:
    suspect_selector.clear()
    if case_definition == null:
        return
    for suspect in case_definition.suspects:
        suspect_selector.add_item(suspect.display_name)
        var idx = suspect_selector.get_item_count() - 1
        suspect_selector.set_item_metadata(idx, suspect.suspect_id)

    evidence_selector.clear()
    if case_session == null:
        return
    for evidence_id in case_session.collected_evidence_ids:
        var evidence = case_definition.get_evidence(evidence_id)
        if evidence != null:
            evidence_selector.add_item(evidence.title)
            var idx = evidence_selector.get_item_count() - 1
            evidence_selector.set_item_metadata(idx, evidence.evidence_id)

    record_selector.clear()
    # Lista gravações disponíveis (simplificado: pega todos os records da sessão)
    for record in case_session.interview_records:
        record_selector.add_item("Entrevista — %s" % [record.suspect_id])
        var idx = record_selector.get_item_count() - 1
        record_selector.set_item_metadata(idx, record.record_id)

func _on_submit_pressed() -> void:
    var submission = dossier_model.get_submission()
    submission.accused_suspect_id = suspect_selector.get_selected_metadata()
    submission.submitted_evidence_ids.clear()
    for i in range(evidence_selector.get_item_count()):
        if evidence_selector.is_selected(i):
            submission.submitted_evidence_ids.append(evidence_selector.get_item_metadata(i))
    submission.submitted_record_ids.clear()
    for i in range(record_selector.get_item_count()):
        if record_selector.is_selected(i):
            submission.submitted_record_ids.append(record_selector.get_item_metadata(i))
    submission.player_reasoning_note = reasoning_note.text
    visible = false
    dossier_submitted.emit(submission)

func _on_cancel_pressed() -> void:
    visible = false
    dossier_cancelled.emit()

func _ready() -> void:
    visible = false
    submit_button.pressed.connect(_on_submit_pressed)
    cancel_button.pressed.connect(_on_cancel_pressed)
