extends RefCounted
class_name NotebookModel

var case_session: CaseSession
var case_definition: CaseDefinition

func get_collected_evidence_titles() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if case_session == null or case_definition == null:
        return result
    for evidence_id in case_session.collected_evidence_ids:
        var evidence = case_definition.get_evidence(evidence_id)
        if evidence != null:
            result.append({
                "id": evidence.evidence_id,
                "title": evidence.title,
                "description": evidence.description_found,
                "source": evidence.source_location,
                "category": evidence.category,
                "reliability": evidence.reliability
            })
    return result

func get_interview_summaries() -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    if case_session == null:
        return result
    for record in case_session.interview_records:
        result.append({
            "id": record.record_id,
            "suspect_id": record.suspect_id,
            "topics": record.topics_asked.duplicate(),
            "segment_count": record.transcript_segments.size()
        })
    return result

func is_evidence_registered(evidence_id: StringName) -> bool:
    if case_session == null:
        return false
    return case_session.has_evidence(evidence_id)
