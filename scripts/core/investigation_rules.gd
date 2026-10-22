extends RefCounted
class_name InvestigationRules

# Regras centrais de investigação, separadas da UI e da cena.
# Mantém distinção entre examinado, registrado, anexado e avaliado.

# Verifica se um tópico de entrevista está disponível com base nas evidências coletadas.
func is_topic_available(topic: InterviewTopicDefinition, collected_evidence_ids: Array[StringName]) -> bool:
    if topic.required_evidence_id == &"":
        return true
    return collected_evidence_ids.has(topic.required_evidence_id)

# Retorna tópicos de follow-up desbloqueados com base nos fatos revelados.
func get_available_follow_ups(topic: InterviewTopicDefinition, revealed_fact_ids: Array[StringName]) -> Array[StringName]:
    var available: Array[StringName] = []
    for follow_id in topic.follow_up_topic_ids:
        available.append(follow_id)
    return available
