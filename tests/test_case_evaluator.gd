extends RefCounted
class_name TestCaseEvaluator

func run_tests() -> void:
    var passed = 0
    var failed = 0

    # Teste 7: Mesmo dossiê produz sempre o mesmo veredito (determinístico).
    var case_def = CaseDefinition.new()
    case_def.case_id = &"test_case"
    case_def.truth_suspect_id = &"suspect_culpado"

    var submission = DossierSubmission.new()
    submission.accused_suspect_id = &"suspect_culpado"
    submission.submitted_evidence_ids = [&"evid_forte"]
    submission.submitted_record_ids = []

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

    var s1 = CaseEvaluator.evaluate(case_def, submission)
    var s2 = CaseEvaluator.evaluate(case_def, submission)
    if s1["verdict"] == s2["verdict"] and s1["is_correct_outcome"] == s2["is_correct_outcome"]:
        passed += 1
        print("TEST PASS: dossiê determinístico (%s)" % [s1["verdict"]])
    else:
        failed += 1
        print("TEST FAIL: dossiê não é determinístico")

    # Teste 8: Culpado com prova insuficiente não é condenado automaticamente.
    var submission_fraca = DossierSubmission.new()
    submission_fraca.accused_suspect_id = &"suspect_culpado"
    submission_fraca.submitted_evidence_ids = []
    submission_fraca.submitted_record_ids = []
    var r_fraca = CaseEvaluator.evaluate(case_def, submission_fraca)
    if r_fraca["verdict"] == "ACQUITTED":
        passed += 1
        print("TEST PASS: dossiê vazio não condena")
    else:
        failed += 1
        print("TEST FAIL: dossiê vazio deveria absolver, got %s" % [r_fraca["verdict"]])

    # Teste 9: Suspeito inocente pode ser acusado com resultado coerente.
    var submission_inocente = DossierSubmission.new()
    submission_inocente.accused_suspect_id = &"suspect_inocente"
    submission_inocente.submitted_evidence_ids = [&"evid_forte"]
    submission_inocente.submitted_record_ids = []
    var r_inocente = CaseEvaluator.evaluate(case_def, submission_inocente)
    if r_inocente["is_correct_outcome"] == false:
        passed += 1
        print("TEST PASS: acusação de inocente não é correta")
    else:
        failed += 1
        print("TEST FAIL: acusação de inocente marcada como correta")

    print("TestCaseEvaluator: %d passed, %d failed" % [passed, failed])
