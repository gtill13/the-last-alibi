extends Resource
class_name ClueLink

# Liga um fato narrativo a uma evidência ou gravação que o sustenta ou contradiz.
@export var fact_id: StringName = &""
@export var supporting_evidence_ids: Array[StringName] = []
@export var supporting_record_ids: Array[StringName] = []
@export var contradicting_evidence_ids: Array[StringName] = []
@export var contradicting_record_ids: Array[StringName] = []
