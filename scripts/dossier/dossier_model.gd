extends RefCounted
class_name DossierModel

var submission: DossierSubmission = DossierSubmission.new()

func select_suspect(suspect_id: StringName) -> void:
    submission.accused_suspect_id = suspect_id

func toggle_evidence(evidence_id: StringName) -> void:
    if submission.submitted_evidence_ids.has(evidence_id):
        submission.submitted_evidence_ids.erase(evidence_id)
    else:
        submission.submitted_evidence_ids.append(evidence_id)

func toggle_record(record_id: StringName) -> void:
    if submission.submitted_record_ids.has(record_id):
        submission.submitted_record_ids.erase(record_id)
    else:
        submission.submitted_record_ids.append(record_id)

func clear_selection() -> void:
    submission.clear()

func get_submission() -> DossierSubmission:
    return submission
