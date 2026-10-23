extends Node2D
class_name InvestigationController

@onready var scanner = $InteractionScanner
@onready var hud = $HUD
@onready var dialogue_panel = $ModalLayer/DialoguePanel
@onready var notebook_screen = $ModalLayer/NotebookScreen
@onready var dossier_builder = $ModalLayer/DossierBuilder
@onready var trial_report = $ModalLayer/TrialReport
@onready var confirmation_dialog = $ModalLayer/ConfirmationDialog

# Serviços e estado.
var case_session: CaseSession
var case_definition: CaseDefinition
var evidence_service: EvidenceService
var interview_service: InterviewService
var notebook_model: NotebookModel
var dossier_model: DossierModel
var dossier_validator: DossierValidator

var current_interactable_id: StringName = &""

func _ready() -> void:
	# Não inicializar serviços no editor (importação/registro de class_name).
	if OS.has_feature("editor"):
		return

	_connect_signal_once(scanner, "interaction_target_changed", _on_target_changed)
	_connect_signal_once(scanner, "interaction_target_lost", _on_target_lost)
	scanner.player_node = $Actors/Investigator

	# Decisão 4: one-shot por evento de pressionamento da tecla E.
	var investigator = $Actors/Investigator
	if investigator is InvestigatorController:
		_connect_signal_once(investigator, "interact_pressed", _on_interact_pressed)

	_connect_signal_once(confirmation_dialog, "confirmed", _on_confirm_exit)
	_connect_signal_once(confirmation_dialog, "canceled", _on_cancel_exit)

	_connect_signal_once(dossier_builder, "dossier_submitted", _on_dossier_submitted)
	_connect_signal_once(dossier_builder, "dossier_cancelled", _on_dossier_cancelled)
	_connect_signal_once(trial_report, "trial_closed", _on_trial_closed)

	_connect_interactables()
	_init_services()


func _connect_signal_once(src: Object, sig: StringName, callback: Callable) -> void:
	if src != null and not src.is_connected(sig, callback):
		src.connect(sig, callback)


func _connect_interactables() -> void:
	var interactables_node = $Interactables
	for child in interactables_node.get_children():
		if child is Interactable:
			scanner.register_interactable(child)
			# Desregistro automático quando o objeto sai de cena (Decisão 7).
			child.exit_tree.connect(func():
				scanner.unregister_interactable(child)
			)
			child.interaction_requested.connect(func(id: StringName):
				scanner.interact_with_current()
			)
		if child is InspectableObject:
			child.examine_requested.connect(_on_inspectable_examine_requested)
		if child is SuspectNPC:
			child.interview_requested.connect(func(sid: StringName, name: String):
				current_suspect_id = sid
				_on_suspect_interview_requested(sid, name)
			)
		if child is ExitPoint:
			child.exit_requested.connect(func():
				confirmation_dialog.dialog_text = "Encerrar a visita e montar o dossiê?"
				confirmation_dialog.show()
			)

func _init_services() -> void:
	case_definition = load("res://data/cases/bellweather_apartment/case_definition.tres")
	case_session = CaseSession.new(case_definition)

	evidence_service = EvidenceService.new()
	evidence_service.case_session = case_session

	interview_service = InterviewService.new()
	interview_service.case_session = case_session

	notebook_model = NotebookModel.new()
	notebook_model.case_session = case_session
	notebook_model.case_definition = case_definition

	dossier_model = DossierModel.new()
	dossier_validator = DossierValidator.new()

func _on_target_changed(target_id: StringName, interaction_label: String) -> void:
	# Decisão 5: texto dinâmico por tipo do interagível.
	current_interactable_id = target_id
	var prompt = _get_prompt()
	if prompt != null:
		prompt.show_prompt(target_id, interaction_label)

func _on_target_lost() -> void:
	current_interactable_id = &""
	var prompt = _get_prompt()
	if prompt != null:
		prompt.hide_prompt()

func _get_prompt() -> InteractionPrompt:
	var hud_canvas = $HUD
	if hud_canvas.has_node("InteractionPrompt"):
		return hud_canvas.get_node("InteractionPrompt")
	return null

func _on_interact_pressed() -> void:
	var target = scanner.get_current_target()
	if target == null:
		return
	target.request_interaction()

# Chamado pelos interagíveis via sinais.
func _on_inspectable_examine_requested(evidence_id: StringName, title: String, description: String) -> void:
	if case_session.has_examined(evidence_id):
		_show_message("Já examinada: %s" % [title])
		return
	case_session.mark_examined(evidence_id)
	_show_message("Examinado: %s\n%s" % [title, description])
	var already = case_session.has_evidence(evidence_id)
	if not already:
		evidence_service.register_evidence(evidence_id)
		_show_message("Registrada no caderno: %s" % [title])
	_refresh_notebook()

func _on_suspect_interview_requested(suspect_id: StringName, display_name: String) -> void:
	var suspect = case_definition.get_suspect(suspect_id)
	if suspect == null:
		return
	dialogue_panel.call_deferred("open_dialogue", suspect_id, display_name, suspect.interview_topics)

func _on_topic_selected(topic_id: StringName) -> void:
	var topic = _find_topic(topic_id)
	if topic == null:
		return
	var rules = InvestigationRules.new()
	if not rules.is_topic_available(topic, case_session.collected_evidence_ids):
		_show_message("Você precisa de mais contexto para pressionar essa pessoa.")
		return
	var transcript = [
		{"speaker": "detetive", "text": topic.question_text, "step": 0},
		{"speaker": topic_id, "text": topic.answer_text, "step": 0}
	]
	interview_service.record_interview(current_suspect_id, topic_id, transcript)
	_refresh_notebook()

var current_suspect_id: StringName = &""

func _find_topic(topic_id: StringName) -> InterviewTopicDefinition:
	for suspect in case_definition.suspects:
		for topic in suspect.interview_topics:
			if topic.topic_id == topic_id:
				return topic
	return null

func _on_confirm_exit() -> void:
	case_session.close_investigation()
	_open_dossier()

func _on_cancel_exit() -> void:
	pass

func _open_dossier() -> void:
	dossier_builder.call_deferred("bind", dossier_model, case_definition, case_session)
	dossier_builder.call_deferred("open_dossier")

func _refresh_notebook() -> void:
	notebook_screen.call_deferred("bind_model", notebook_model)

func _on_dossier_submitted(submission: DossierSubmission) -> void:
	var validator = DossierValidator.new()
	var valid = validator.validate(submission, case_definition)
	if not valid:
		_show_message("Dossiê inválido. Verifique as seleções.")
		dossier_builder.call_deferred("open_dossier")
		return

	case_session.submitted_dossier = submission

	var evaluator = CaseEvaluator.new()
	var result = evaluator.evaluate(case_definition, submission)

	dossier_builder.hide()
	trial_report.call_deferred("show_report", result)
	trial_report.show()

func _on_dossier_cancelled() -> void:
	_show_message("Montagem de dossiê cancelada.")

func _on_trial_closed() -> void:
	trial_report.hide()
	case_session.reset()
	get_tree().change_scene_to_file("res://scenes/app/main_menu.tscn")

func _show_message(text: String) -> void:
	print("[INVESTIGAÇÃO] %s" % [text])

func _on_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_N:
		_toggle_notebook()

func _toggle_notebook() -> void:
	if notebook_screen.visible:
		notebook_screen.hide()
	else:
		notebook_screen.call_deferred("bind_model", notebook_model)
		notebook_screen.show()