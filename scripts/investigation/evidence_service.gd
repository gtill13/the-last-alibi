extends RefCounted
class_name EvidenceService

signal evidence_registered(evidence_id: StringName)

var case_session: CaseSession

func register_evidence(evidence_id: StringName) -> bool:
    if case_session == null:
        push_error("EvidenceService: CaseSession não definido.")
        return false
    var success: bool = case_session.register_evidence(evidence_id)
    if success:
        evidence_registered.emit(evidence_id)
    return success

func has_evidence(evidence_id: StringName) -> bool:
    if case_session == null:
        return false
    return case_session.has_evidence(evidence_id)

func get_collected_ids() -> Array[StringName]:
    if case_session == null:
        return []
    return case_session.collected_evidence_ids.duplicate()
