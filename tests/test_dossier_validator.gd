extends RefCounted
class_name TestDossierValidator

func run_tests() -> void:
    var passed = 0
    var failed = 0

    var case_def = CaseDefinition.new()
    case_def.case_id = &"test_case"

    var suspeito_valido = SuspectDefinition.new()
    suspeito_valido.suspect_id = &"suspect_a"
    suspeito_valido.display_name = "Suspeito A"
    case_def.suspects = [suspeito_valido]

    var evid = EvidenceDefinition.new()
    evid.evidence_id = &"evid_1"
    case_def.evidence_catalog = [evid]

    var validator = DossierValidator.new()

    # Teste 5a: rejeita suspeito inexistente.
    var sub1 = DossierSubmission.new()
    sub1.accused_suspect_id = &"suspect_inexistente"
    var r1 = validator.validate(sub1, case_def)
    if not r1:
        passed += 1
        print("TEST PASS: validador rejeita suspeito inexistente")
    else:
        failed += 1
        print("TEST FAIL: validador aceitou suspeito inexistente")

    # Teste 5b: rejeita evidência duplicada.
    var sub2 = DossierSubmission.new()
    sub2.accused_suspect_id = &"suspect_a"
    sub2.submitted_evidence_ids = [&"evid_1", &"evid_1"]
    var r2 = validator.validate(sub2, case_def)
    if not r2:
        passed += 1
        print("TEST PASS: validador rejeita evidência duplicada")
    else:
        failed += 1
        print("TEST FAIL: validador aceitou duplicata")

    # Teste 5c: aceita submissão válida (sem provas obrigatórias).
    var sub3 = DossierSubmission.new()
    sub3.accused_suspect_id = &"suspect_a"
    var r3 = validator.validate(sub3, case_def)
    if r3:
        passed += 1
        print("TEST PASS: validador aceita submissão válida")
    else:
        failed += 1
        print("TEST FAIL: validador rejeitou submissão válida")

    print("TestDossierValidator: %d passed, %d failed" % [passed, failed])
