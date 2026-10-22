extends Resource
class_name EvidenceDefinition

@export var evidence_id: StringName = &""
@export var title: String = ""
@export var description_found: String = ""
@export var source_location: String = ""
@export var category: String = "circunstancial" # física, documental, digital, testemunhal, circunstancial
@export var reliability: float = 0.5
@export var relevance_tags: Array[StringName] = []
@export var supports_suspect_ids: Array[StringName] = []
@export var contradicts_suspect_ids: Array[StringName] = []
@export var unlocks_after_inspection: bool = false
@export var discovery_requirements: Array[StringName] = []
