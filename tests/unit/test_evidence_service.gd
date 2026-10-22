extends UnitTestCase

## Serviço de evidências (Fase 2).
## Verifica não aceitação de IDs duplicados e de evidência de outro caso.

func test_rejects_duplicate_evidence() -> void:
	var case_def = CaseDefinition.new()
	case_def.case_id = &"test_case"

	var evid = EvidenceDefinition.new()
	evid.evidence_id = &"evid_1"
	case_def.evidence_catalog = [evid]

	var session = CaseSession.new(case_def)
	var service = EvidenceService.new()
	service.case_session = session

	var r1 = service.register_evidence(&"evid_1")
	var r2 = service.register_evidence(&"evid_1")
	assert_true(r1, "primeiro registro deve ter sucesso")
	assert_false(r2, "duplicata deve ser rejeitada")


func test_rejects_evidence_not_in_case() -> void:
	var case_def = CaseDefinition.new()
	case_def.case_id = &"test_case"

	var session = CaseSession.new(case_def)
	var service = EvidenceService.new()
	service.case_session = session

	var r3 = service.register_evidence(&"evid_inexistente")
	assert_false(r3, "evidência de outro caso deve ser rejeitada")
