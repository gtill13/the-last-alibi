extends Resource
class_name InterviewTopicDefinition

@export var topic_id: StringName = &""
@export var question_text: String = ""
@export_multiline var answer_text: String = ""
@export var recording_id: StringName = &""
@export var required_evidence_id: StringName = &""
@export var revealed_fact_ids: Array[StringName] = []
@export var follow_up_topic_ids: Array[StringName] = []
