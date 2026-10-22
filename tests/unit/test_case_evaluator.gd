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
	evid_forte.relevance_tags = [&"fact_presente"]
	evid_forte.supports_suspect_ids = [&"suspect_culpado"]
	evid_forte.contradicts_suspect_ids = []
	evid_forte.unlocks_after_inspection = false
	evid_forte.discovery_requirements = []
	case_def.evidence_catalog = [evid_forte]

	var submission = DossierSubmission.new()
	submission.accused_suspect_id = &"suspect_culpado"
	submission.submitted_evidence_ids = [&"evid_forte"]
	submission.submitted_record_ids = []

	var evaluator = CaseEvaluator.new()
	var s1 = evaluator.evaluate(case_def, submission)
	var s2 = evaluator.evaluate(case_def, submission)
	assert_eq(s1["verdict"], s2["verdict"], "veredito deve ser determinístico")
	assert_eq(s1["is_correct_outcome"], s2["is_correct_outcome"], "acurácia deve ser determinística")


func test_empty_dossier_never_convicts() -> void:
	var case_def = CaseDefinition.new()
	case_def.case_id = &"test_case"
	case_def.truth_suspect_id = &"suspect_culpado"

	var submission_fraca = DossierSubmission.new()
	submission_fraca.accused_suspect_id = &"suspect_culpado"
	submission_fraca.submitted_evidence_ids = []
	submission_fraca.submitted_record_ids = []

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
	evid_forte.relevance_tags = [&"fact_presente"]
	evid_forte.supports_suspect_ids = [&"suspect_culpado"]
	evid_forte.contradicts_suspect_ids = []
	evid_forte.unlocks_after_inspection = false
	evid_forte.discovery_requirements = []
	case_def.evidence_catalog = [evid_forte]

	var submission_inocente = DossierSubmission.new()
	submission_inocente.accused_suspect_id = &"suspect_inocente"
	submission_inocente.submitted_evidence_ids = [&"evid_forte"]
	submission_inocente.submitted_record_ids = []

	var evaluator = CaseEvaluator.new()
	var r_inocente = evaluator.evaluate(case_def, submission_inocente)
	assert_eq(r_inocente["is_correct_outcome"], false, "acusação de inocente não é correta")
