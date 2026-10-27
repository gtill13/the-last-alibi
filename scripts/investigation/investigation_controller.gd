extends Node2D
class_name InvestigationController

@onready var investigator: InvestigatorController = $Actors/Investigator
@onready var scanner: InteractionScanner = $Actors/Investigator/InteractionScanner
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
	# Não inicializar serviços quando a cena está aberta apenas no editor.
	# (OS.has_feature("editor") também é true em builds de ferramentas, o que
	# impedia a inicialização ao rodar o jogo por linha de comando ou pelo F5.)
	if Engine.is_editor_hint():
		return

	_connect_signal_once(scanner, "active_target_changed", _on_active_target_changed)
	_connect_signal_once(scanner, "interaction_requested", _on_interaction_requested)

	# Decisão 4: one-shot por evento de pressionamento da tecla E.
	_connect_signal_once(investigator, "interact_pressed", _on_interact_pressed)

	_connect_signal_once(confirmation_dialog, "confirmed", _on_confirm_exit)
	_connect_signal_once(confirmation_dialog, "canceled", _on_cancel_exit)

	_connect_signal_once(dossier_builder, "dossier_submitted", _on_dossier_submitted)
	_connect_signal_once(dossier_builder, "dossier_cancelled", _on_dossier_cancelled)
	_connect_signal_once(trial_report, "trial_closed", _on_trial_closed)

	_validate_interactables()
	_init_services()


func _connect_signal_once(src: Object, sig: StringName, callback: Callable) -> void:
	if src != null and not src.is_connected(sig, callback):
		src.connect(sig, callback)


func _validate_interactables() -> void:
	var seen_ids: Dictionary = {}
	for node in get_tree().get_nodes_in_group("interactables"):
		if not node is Interactable:
			push_error("InvestigationController: nó no grupo 'interactables' não é Interactable: %s" % node.get_path())
			continue
		var target := node as Interactable
		if target.interactable_id == &"":
			push_error("InvestigationController: Interactable sem ID: %s" % target.get_path())
			continue
		if seen_ids.has(target.interactable_id):
			var other := seen_ids[target.interactable_id] as Interactable
			push_error(
				"InvestigationController: ID duplicado '%s' em %s e %s" % [
					target.interactable_id,
					other.get_path(),
					target.get_path(),
				]
			)
			continue
		seen_ids[target.interactable_id] = target

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

func _on_active_target_changed(target: Interactable) -> void:
	# Decisão 5: prompt contextual com ação e nome legível.
	current_interactable_id = target.interactable_id if is_instance_valid(target) else &""
	var prompt = _get_prompt()
	if prompt != null:
		if is_instance_valid(target) and target.can_interact():
			prompt.show_for_target(target)
		else:
			prompt.hide_prompt()

func _get_prompt() -> InteractionPrompt:
	var hud_canvas = $HUD
	if hud_canvas.has_node("InteractionPrompt"):
		return hud_canvas.get_node("InteractionPrompt")
	return null

func _on_interact_pressed() -> void:
	scanner.request_interaction_with_active_target()


func _on_interaction_requested(target: Interactable) -> void:
	if not is_instance_valid(target) or not target.can_interact():
		return

	if target is InspectableObject:
		var inspectable := target as InspectableObject
		_on_inspectable_examine_requested(
			inspectable.evidence_id,
			inspectable.object_title,
			inspectable.description_found
		)
	elif target is SuspectNPC:
		var suspect := target as SuspectNPC
		current_suspect_id = suspect.suspect_id
		_on_suspect_interview_requested(suspect.suspect_id, suspect.display_name)
	elif target is ExitPoint:
		var exit_point := target as ExitPoint
		confirmation_dialog.dialog_text = exit_point.confirm_text
		confirmation_dialog.show()
	else:
		_show_message("Interação: %s (%s)" % [target.display_name, target.interactable_id])

# Chamado pelos interagíveis via sinais.
func _on_inspectable_examine_requested(evidence_id: StringName, title: String, description: String) -> void:
	if case_session.has_examined(evidence_id):
		_show_message("Já examinada: %s" % [title])
		return
	case_session.mark_examined(evidence_id)
	var registered := false
	if not case_session.has_evidence(evidence_id):
		registered = evidence_service.register_evidence(evidence_id)
	var suffix := "\nRegistrada no caderno." if registered else ""
	_show_message("Examinado: %s\n%s%s" % [title, description, suffix])
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
	var debug_label := hud.get_node_or_null("DebugMessage") as Label
	if debug_label != null:
		debug_label.text = text

func _on_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_notebook"):
		_toggle_notebook()

func _toggle_notebook() -> void:
	if notebook_screen.visible:
		notebook_screen.hide()
	else:
		notebook_screen.call_deferred("bind_model", notebook_model)
		notebook_screen.show()