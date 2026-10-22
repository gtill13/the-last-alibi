extends RefCounted
class_name DossierValidator

signal validation_result(valid: bool, reason: String)

func validate(submission: DossierSubmission, case_def: CaseDefinition) -> bool:
    # Verifica se o suspeito acusado pertence ao caso.
    if submission.accused_suspect_id == &"":
        validation_result.emit(false, "Nenhum suspeito selecionado.")
        return false
    if case_def.get_suspect(submission.accused_suspect_id) == null:
        validation_result.emit(false, "Suspeito acusado não pertence a este caso.")
        return false

    # Verifica evidências anexadas.
    var seen_ids: Array[StringName] = []
    for evidence_id in submission.submitted_evidence_ids:
        if seen_ids.has(evidence_id):
            validation_result.emit(false, "Evidência duplicada no dossiê: %s" % [evidence_id])
            return false
        seen_ids.append(evidence_id)
        if case_def.get_evidence(evidence_id) == null:
            validation_result.emit(false, "Evidência inexistente ou de outro caso: %s" % [evidence_id])
            return false

    # Verifica gravações anexadas (duplicatas).
    seen_ids.clear()
    for record_id in submission.submitted_record_ids:
        if seen_ids.has(record_id):
            validation_result.emit(false, "Gravação duplicada no dossiê: %s" % [record_id])
            return false
        seen_ids.append(record_id)

    validation_result.emit(true, "Dossiê válido.")
    return true
