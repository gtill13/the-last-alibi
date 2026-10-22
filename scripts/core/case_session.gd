extends RefCounted
class_name CaseSession

# Definição imutável do caso carregado para esta sessão.
var case_definition: CaseDefinition

# Estado mutável da investigação atual.
var collected_evidence_ids: Array[StringName] = []
var examined_object_ids: Array[StringName] = []
var interview_records: Array[InterviewRecord] = []
var investigation_closed: bool = false
var submitted_dossier: DossierSubmission = DossierSubmission.new()

func _init(case_def: CaseDefinition) -> void:
    case_definition = case_def

# Registra uma evidência no caderno. Retorna false se já estava registrada.
func register_evidence(evidence_id: StringName) -> bool:
    if collected_evidence_ids.has(evidence_id):
        return false
    # Valida que a evidência pertence ao caso carregado.
    if case_definition.get_evidence(evidence_id) == null:
        push_warning("CaseSession: evidência %s não pertence ao caso %s" % [evidence_id, case_definition.case_id])
        return false
    collected_evidence_ids.append(evidence_id)
    return true

func has_evidence(evidence_id: StringName) -> bool:
    return collected_evidence_ids.has(evidence_id)

func mark_examined(object_id: StringName) -> void:
    if not examined_object_ids.has(object_id):
        examined_object_ids.append(object_id)

func has_examined(object_id: StringName) -> bool:
    return examined_object_ids.has(object_id)

func add_interview_record(record: InterviewRecord) -> void:
    interview_records.append(record)

func get_interview_record(record_id: StringName) -> InterviewRecord:
    for record in interview_records:
        if record.record_id == record_id:
            return record
    return null

func get_records_for_suspect(suspect_id: StringName) -> Array[InterviewRecord]:
    var result: Array[InterviewRecord] = []
    for record in interview_records:
        if record.suspect_id == suspect_id:
            result.append(record)
    return result

func close_investigation() -> void:
    investigation_closed = true

func reset() -> void:
    collected_evidence_ids.clear()
    examined_object_ids.clear()
    interview_records.clear()
    investigation_closed = false
    submitted_dossier.clear()
