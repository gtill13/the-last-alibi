extends RefCounted
class_name InterviewService

signal interview_record_created(record_id: StringName)

var case_session: CaseSession

func record_interview(suspect_id: StringName, topic_id: StringName, transcript: Array[Dictionary]) -> InterviewRecord:
    if case_session == null:
        push_error("InterviewService: CaseSession não definido.")
        return null
    var record = InterviewRecord.new()
    record.record_id = "record_%s_%s" % [suspect_id, topic_id]
    record.suspect_id = suspect_id
    record.topics_asked = [topic_id]
    record.transcript_segments = transcript
    record.recorded_at_case_step = 0
    case_session.add_interview_record(record)
    interview_record_created.emit(record.record_id)
    return record

func get_record(record_id: StringName) -> InterviewRecord:
    if case_session == null:
        return null
    return case_session.get_interview_record(record_id)

func get_records_for_suspect(suspect_id: StringName) -> Array[InterviewRecord]:
    if case_session == null:
        return []
    return case_session.get_records_for_suspect(suspect_id)
