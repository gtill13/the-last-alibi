extends RefCounted
class_name CaseEvaluator

# Resultado do julgamento.
# verdict: "CONVICTED", "ACQUITTED", "INCONCLUSIVE"
# is_correct_outcome: bool — a acusação corresponde ao culpado verdadeiro?
# supporting_fact_ids: fatos sustentados pelo dossiê
# weakness_fact_ids: fraquezas identificadas
# short_summary: resumo narrativo curto
# report_seções: Array de dicionários com title e text

func evaluate(case_def: CaseDefinition, submission: DossierSubmission) -> Dictionary:
    var result = {
        "accused_suspect_id": submission.accused_suspect_id,
        "truth_suspect_id": case_def.truth_suspect_id,
        "verdict": "INCONCLUSIVE",
        "is_correct_outcome": false,
        "supporting_fact_ids": [],
        "weakness_fact_ids": [],
        "short_summary": "",
        "report_sections": []
    }

    # Validar que o suspeito acusado existe no caso.
    var suspect = case_def.get_suspect(submission.accused_suspect_id)
    if suspect == null:
        result["verdict"] = "INCONCLUSIVE"
        result["short_summary"] = "O dossiê não apontou um suspeito válido. O caso foi arquivado por falta de acusação formal."
        return result

    # Dossiê vazio nunca condena.
    if submission.submitted_evidence_ids.is_empty() and submission.submitted_record_ids.is_empty():
        result["verdict"] = "ACQUITTED"
        result["is_correct_outcome"] = (submission.accused_suspect_id != case_def.truth_suspect_id)
        result["short_summary"] = "Sem evidências ou depoimentos anexados, o tribunal absolveu por falta de provas."
        result["report_sections"] = [
            {"title": "Decisão", "text": "Absolvição — o dossiê foi submetido sem qualquer evidência ou gravação."}
        ]
        return result

    # Converter itens anexados em fatos sustentados.
    var supported_facts: Array[StringName] = []
    var contradicted_facts: Array[StringName] = []

    for evidence_id in submission.submitted_evidence_ids:
        var evidence = case_def.get_evidence(evidence_id)
        if evidence == null:
            continue
        # Só considera evidências com confiabilidade mínima.
        if evidence.reliability < 0.3:
            continue
        for tag in evidence.relevance_tags:
            if not supported_facts.has(tag):
                supported_facts.append(tag)
        for contradicted in evidence.contradicts_suspect_ids:
            var fact = "contradicao_%s" % [contradicted]
            if not contradicted_facts.has(fact):
                contradicted_facts.append(fact)

    for record_id in submission.submitted_record_ids:
        var record = _find_record(case_def, record_id)
        if record == null:
            continue
        for fact in record.revealed_fact_ids:
            if not supported_facts.has(fact):
                supported_facts.append(fact)

    result["supporting_fact_ids"] = supported_facts

    # Avaliar decisão com base em fatores.
    var is_culprit = (submission.accused_suspect_id == case_def.truth_suspect_id)

    # Evidências que apoiam diretamente o acusado.
    var direct_support: float = 0.0
    for evidence_id in submission.submitted_evidence_ids:
        var evidence = case_def.get_evidence(evidence_id)
        if evidence == null:
            continue
        if evidence.supports_suspect_ids.has(submission.accused_suspect_id):
            direct_support += evidence.reliability

    # Evidências que contradizem a acusação.
    var contradiction_penalty: float = 0.0
    for evidence_id in submission.submitted_evidence_ids:
        var evidence = case_def.get_evidence(evidence_id)
        if evidence == null:
            continue
        if evidence.contradicts_suspect_ids.has(submission.accused_suspect_id):
            contradiction_penalty += evidence.reliability

    var score = direct_support - contradiction_penalty
    var has_strong_proof = direct_support >= 0.8

    # Regras de decisão (determinísticas).
    if is_culprit and has_strong_proof and contradiction_penalty < 0.5:
        result["verdict"] = "CONVICTED"
        result["is_correct_outcome"] = true
        result["short_summary"] = "Condenação correta: o culpado foi identificado com provas sólidas e confiáveis."
    elif is_culprit and not has_strong_proof:
        result["verdict"] = "ACQUITTED"
        result["is_correct_outcome"] = false
        result["short_summary"] = "Absolvição do culpado: o suspeito certo foi acusado, mas o dossiê é insuficiente para condenar."
    elif not is_culprit and has_strong_proof and contradiction_penalty < 0.3:
        result["verdict"] = "CONVICTED"
        result["is_correct_outcome"] = false
        result["short_summary"] = "Condenação injusta: um inocente foi acusado com um dossiê aparentemente forte, mas enganoso."
    else:
        result["verdict"] = "ACQUITTED"
        result["is_correct_outcome"] = (not is_culprit)
        result["short_summary"] = "Absolvição: o dossiê não sustentou uma condenação firme."

    result["report_sections"] = _build_report_sections(result, case_def, submission, supported_facts, contradicted_facts)
    return result

func _find_record(case_def: CaseDefinition, record_id: StringName) -> InterviewRecord:
    # Busca em todos os suspeitos e tópicos. No MVP, os records são passados pela sessão;
    # aqui faz uma busca simplificada por ID nos dados do caso.
    for suspect in case_def.suspects:
        for topic in suspect.interview_topics:
            if topic.recording_id == record_id:
                var record = InterviewRecord.new()
                record.record_id = record_id
                record.suspect_id = suspect.suspect_id
                record.revealed_fact_ids = topic.revealed_fact_ids
                return record
    return null

func _build_report_sections(result: Dictionary, case_def: CaseDefinition, submission: DossierSubmission, supported: Array[StringName], contradicted: Array[StringName]) -> Array[Dictionary]:
    var sections = []
    var accused = case_def.get_suspect(submission.accused_suspect_id)
    var accused_name = accused.display_name if accused != null else "desconhecido"

    sections.append({
        "title": "Acusado",
        "text": "O dossiê acusou %s." % [accused_name]
    })

    if supported.is_empty():
        sections.append({
            "title": "Fatos sustentados",
            "text": "Nenhum fato foi suficientemente sustentado pelas provas anexadas."
        })
    else:
        sections.append({
            "title": "Fatos sustentados",
            "text": "%d fato(s) sustentado(s) pelas provas apresentadas." % [supported.size()]
        })

    if contradicted.size() > 0:
        sections.append({
            "title": "Contradições",
            "text": "Foram identificadas contradições que enfraquecem a acusação."
        })

    sections.append({
        "title": "Resultado",
        "text": result["short_summary"]
    })

    return sections
