extends Resource
class_name InterviewRecord

@export var record_id: StringName = &""
@export var suspect_id: StringName = &""
@export var topics_asked: Array[StringName] = []
@export var transcript_segments: Array[Dictionary] = []
@export var revealed_fact_ids: Array[StringName] = []
@export var recorded_at_case_step: int = 0

func add_segment(speaker: String, text: String) -> void:
    var segment = {
        "speaker": speaker,
        "text": text,
        "step": recorded_at_case_step
    }
    transcript_segments.append(segment)
