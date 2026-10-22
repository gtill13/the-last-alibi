# Formato de dados do caso — CASE_FORMAT.md

Este documento descreve os recursos de dados (.tres/.gd) usados para definir um
caso de investigação, separados da lógica e da UI.

## CaseDefinition (Resource)

- case_id: StringName — ID estável do caso (ex: "bellweather_apartment")
- title: String — título de exibição
- briefing: String — relatório policial inicial
- scene_path: String — caminho da cena de investigação
- suspects: Array[SuspectDefinition]
- evidence_catalog: Array[EvidenceDefinition]
- truth_suspect_id: StringName — uso interno do avaliador (NÃO expor na UI)
- initial_police_report: String

## SuspectDefinition (Resource)

- suspect_id: StringName
- display_name: String
- short_bio: String
- known_relationship: String
- interview_topics: Array[InterviewTopicDefinition]

## EvidenceDefinition (Resource)

- evidence_id: StringName
- title: String
- description_found: String
- source_location: String
- category: enum (física, documental, digital, testemunhal, circunstancial)
- reliability: float (0-1)
- relevance_tags: Array[StringName]
- supports_suspect_ids: Array[StringName]
- contradicts_suspect_ids: Array[StringName]
- unlocks_after_inspection: bool
- discovery_requirements: Array[StringName]

## InterviewTopicDefinition (Resource)

- topic_id: StringName
- question_text: String
- answer_text: String
- follow_up_options: Array[StringName]
- recording_id: StringName
- required_evidence_id: StringName (opcional — bloqueia o tópico até ter a evidência)
- revealed_fact_ids: Array[StringName]
- follow_up_topic_ids: Array[StringName]

## Estados de uma prova (conceituais)

1. Não descoberta
2. Examinada (viu descrição, ainda não registrou)
3. Registrada no caderno (coletada)
4. Apresentada no dossiê (anexada à acusação)
5. Considerada no julgamento (avaliada pelo CaseEvaluator)

IDs estãoveis são usados como chaves de lógica; nomes de exibição nunca devem
ser usados como identificadores.
