extends Resource
class_name CaseDefinition

@export var case_id: StringName = &""
@export var title: String = ""
@export var briefing: String = ""
@export var scene_path: String = ""
@export var suspects: Array[SuspectDefinition] = []
@export var evidence_catalog: Array[EvidenceDefinition] = []
@export var truth_suspect_id: StringName = &""
@export var initial_police_report: String = ""

# Retorna a definição de suspeito pelo ID, ou null se não existir.
func get_suspect(suspect_id: StringName) -> SuspectDefinition:
    for suspect in suspects:
        if suspect.suspect_id == suspect_id:
            return suspect
    return null

# Retorna a definição de evidência pelo ID, ou null se não existir.
func get_evidence(evidence_id: StringName) -> EvidenceDefinition:
    for evidence in evidence_catalog:
        if evidence.evidence_id == evidence_id:
            return evidence
    return null
