extends UnitTestCase

## Validador de dossiê (Fase 4).
## Verifica rejeição de suspeito inexistente, evidência duplicada
## e aceitação de submissão válida (sem provas obrigatórias).

func test_rejects_unknown_suspect() -> void:
	var case_def = CaseDefinition.new()
	case_def.case_id = &"test_case"

	var suspeito_valido = SuspectDefinition.new()
	suspeito_valido.suspect_id = &"suspect_a"
	suspeito_valido.display_name = "Suspeito A"
	var suspects: Array[SuspectDefinition] = [suspeito_valido]
	case_def.suspects = suspects

	var evid = EvidenceDefinition.new()
	evid.evidence_id = &"evid_1"
	var evidence_catalog: Array[EvidenceDefinition] = [evid]
	case_def.evidence_catalog = evidence_catalog

	var validator = DossierValidator.new()
	var sub1 = DossierSubmission.new()
	sub1.accused_suspect_id = &"suspect_inexistente"
	assert_false(validator.validate(sub1, case_def), "validador deve rejeitar suspeito inexistente")


func test_rejects_duplicate_evidence() -> void:
	var case_def = CaseDefinition.new()
	case_def.case_id = &"test_case"

	var suspeito_valido = SuspectDefinition.new()
	suspeito_valido.suspect_id = &"suspect_a"
	suspeito_valido.display_name = "Suspeito A"
	var suspects: Array[SuspectDefinition] = [suspeito_valido]
	case_def.suspects = suspects

	var evid = EvidenceDefinition.new()
	evid.evidence_id = &"evid_1"
	var evidence_catalog: Array[EvidenceDefinition] = [evid]
	case_def.evidence_catalog = evidence_catalog

	var validator = DossierValidator.new()
	var sub2 = DossierSubmission.new()
	sub2.accused_suspect_id = &"suspect_a"
	var duplicate_evidence: Array[StringName] = [&"evid_1", &"evid_1"]
	sub2.submitted_evidence_ids = duplicate_evidence
	assert_false(validator.validate(sub2, case_def), "validador deve rejeitar evidência duplicada")


func test_accepts_valid_submission() -> void:
	var case_def = CaseDefinition.new()
	case_def.case_id = &"test_case"

	var suspeito_valido = SuspectDefinition.new()
	suspeito_valido.suspect_id = &"suspect_a"
	suspeito_valido.display_name = "Suspeito A"
	var suspects: Array[SuspectDefinition] = [suspeito_valido]
	case_def.suspects = suspects

	var validator = DossierValidator.new()
	var sub3 = DossierSubmission.new()
	sub3.accused_suspect_id = &"suspect_a"
	assert_true(validator.validate(sub3, case_def), "validador deve aceitar submissão válida")
