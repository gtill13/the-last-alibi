extends Resource
class_name DossierSubmission

@export var accused_suspect_id: StringName = &""
@export var submitted_evidence_ids: Array[StringName] = []
@export var submitted_record_ids: Array[StringName] = []
@export var player_reasoning_note: String = ""

func clear() -> void:
    accused_suspect_id = &""
    submitted_evidence_ids.clear()
    submitted_record_ids.clear()
    player_reasoning_note = ""
