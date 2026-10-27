extends UnitTestCase

## Avaliador de julgamento determinístico (Fase 5).
## Verifica que o mesmo dossiê produz sempre o mesmo veredito,
## que dossiê vazio não condena e que acusar inocente não conta como correto.

func test_same_dossier_always_same_verdict() -> void:
	var case_def = CaseDefinition.new()
	case_def.case_id = &"test_case"
	case_def.truth_suspect_id = &"suspect_culpado"

	var evid_forte = EvidenceDefinition.new()
	evid_forte.evidence_id = &"evid_forte"
	evid_forte.title = "Evidência forte"
	evid_forte.description_found = "Prova direta"
	evid_forte.source_location = "Cena"
	evid_forte.category = "física"
	evid_forte.reliability = 0.9
	var relevance_tags: Array[StringName] = [&"fact_presente"]
	var supports: Array[StringName] = [&"suspect_culpado"]
	var contradicts: Array[StringName] = []
	var requirements: Array[StringName] = []
	var evidence_catalog: Array[EvidenceDefinition] = [evid_forte]
	evid_forte.relevance_tags = relevance_tags
	evid_forte.supports_suspect_ids = supports
	evid_forte.contradicts_suspect_ids = contradicts
	evid_forte.unlocks_after_inspection = false
	evid_forte.discovery_requirements = requirements
	case_def.evidence_catalog = evidence_catalog

	var submission = DossierSubmission.new()
	submission.accused_suspect_id = &"suspect_culpado"
	var submitted_evidence: Array[StringName] = [&"evid_forte"]
	var submitted_records: Array[StringName] = []
	submission.submitted_evidence_ids = submitted_evidence
	submission.submitted_record_ids = submitted_records

	var evaluator = CaseEvaluator.new()
	var s1 = evaluator.evaluate(case_def, submission)
	var s2 = evaluator.evaluate(case_def, submission)
	assert_eq(s1["verdict"], s2["verdict"], "veredito deve ser determinístico")
	assert_eq(s1["is_correct_outcome"], s2["is_correct_outcome"], "acurácia deve ser determinística")


func test_empty_dossier_never_convicts() -> void:
	var case_def = CaseDefinition.new()
	case_def.case_id = &"test_case"
	case_def.truth_suspect_id = &"suspect_culpado"

	var suspeito = SuspectDefinition.new()
	suspeito.suspect_id = &"suspect_culpado"
	suspeito.display_name = "Suspeito Culpado"
	var suspects: Array[SuspectDefinition] = [suspeito]
	case_def.suspects = suspects

	var submission_fraca = DossierSubmission.new()
	submission_fraca.accused_suspect_id = &"suspect_culpado"
	var empty_evidence: Array[StringName] = []
	var empty_records: Array[StringName] = []
	submission_fraca.submitted_evidence_ids = empty_evidence
	submission_fraca.submitted_record_ids = empty_records

	var evaluator = CaseEvaluator.new()
	var r_fraca = evaluator.evaluate(case_def, submission_fraca)
	assert_eq(r_fraca["verdict"], "ACQUITTED", "dossiê vazio não deve condenar")


func test_accusing_innocent_is_not_correct() -> void:
	var case_def = CaseDefinition.new()
	case_def.case_id = &"test_case"
	case_def.truth_suspect_id = &"suspect_culpado"

	var evid_forte = EvidenceDefinition.new()
	evid_forte.evidence_id = &"evid_forte"
	evid_forte.title = "Evidência forte"
	evid_forte.description_found = "Prova direta"
	evid_forte.source_location = "Cena"
	evid_forte.category = "física"
	evid_forte.reliability = 0.9
	var relevance_tags: Array[StringName] = [&"fact_presente"]
	var supports: Array[StringName] = [&"suspect_culpado"]
	var contradicts: Array[StringName] = []
	var requirements: Array[StringName] = []
	var evidence_catalog: Array[EvidenceDefinition] = [evid_forte]
	evid_forte.relevance_tags = relevance_tags
	evid_forte.supports_suspect_ids = supports
	evid_forte.contradicts_suspect_ids = contradicts
	evid_forte.unlocks_after_inspection = false
	evid_forte.discovery_requirements = requirements
	case_def.evidence_catalog = evidence_catalog

	var submission_inocente = DossierSubmission.new()
	submission_inocente.accused_suspect_id = &"suspect_inocente"
	var submitted_evidence: Array[StringName] = [&"evid_forte"]
	var submitted_records: Array[StringName] = []
	submission_inocente.submitted_evidence_ids = submitted_evidence
	submission_inocente.submitted_record_ids = submitted_records

	var evaluator = CaseEvaluator.new()
	var r_inocente = evaluator.evaluate(case_def, submission_inocente)
	assert_eq(r_inocente["is_correct_outcome"], false, "acusação de inocente não é correta")
