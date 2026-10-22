extends RefCounted
class_name TestEvidenceService

func run_tests() -> void:
    var passed = 0
    var failed = 0

    var case_def = CaseDefinition.new()
    case_def.case_id = &"test_case"

    var evid = EvidenceDefinition.new()
    evid.evidence_id = &"evid_1"
    case_def.evidence_catalog = [evid]

    var session = CaseSession.new(case_def)
    var service = EvidenceService.new()
    service.case_session = session

    # Teste 1: não aceita IDs duplicados.
    var r1 = service.register_evidence(&"evid_1")
    var r2 = service.register_evidence(&"evid_1")
    if r1 and not r2:
        passed += 1
        print("TEST PASS: não aceita evidência duplicada")
    else:
        failed += 1
        print("TEST FAIL: duplicata não rejeitada")

    # Teste 2: não aceita evidência que não pertence ao caso.
    var r3 = service.register_evidence(&"evid_inexistente")
    if not r3:
        passed += 1
        print("TEST PASS: rejeita evidência de outro caso")
    else:
        failed += 1
        print("TEST FAIL: aceitou evidência de outro caso")

    print("TestEvidenceService: %d passed, %d failed" % [passed, failed])
