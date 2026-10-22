extends Control
class_name DialoguePanelUI

signal topic_selected(topic_id: StringName)
signal interview_closed

@onready var suspect_name_label: Label = $Panel/SuspectName
@onready var question_list: ItemList = $Panel/QuestionList
@onready var answer_label: Label = $Panel/AnswerText
@onready var close_button: Button = $Panel/CloseButton

var current_suspect_id: StringName = &""
var current_topics: Array[InterviewTopicDefinition] = []
var current_topic_by_id: Dictionary = {}

func open_dialogue(suspect_id: StringName, suspect_name: String, topics: Array[InterviewTopicDefinition]) -> void:
    current_suspect_id = suspect_id
    current_topics = topics
    current_topic_by_id.clear()
    suspect_name_label.text = suspect_name
    question_list.clear()
    answer_label.text = ""
    for topic in topics:
        question_list.add_item(topic.question_text)
        current_topic_by_id[topic.topic_id] = topic
    visible = true

func _on_question_list_item_selected(index: int) -> void:
    var topic_id = question_list.get_item_metadata(index)
    var topic = current_topic_by_id[topic_id]
    if topic == null:
        return
    answer_label.text = topic.answer_text
    topic_selected.emit(topic_id)

func _on_close_button_pressed() -> void:
    visible = false
    interview_closed.emit()

func _ready() -> void:
    visible = false
    question_list.item_selected.connect(_on_question_list_item_selected)
    close_button.pressed.connect(_on_close_button_pressed)
