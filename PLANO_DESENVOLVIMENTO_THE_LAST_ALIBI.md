# THE LAST ALIBI
## Plano de desenvolvimento técnico e de validação — Godot 4 + GDScript

> **Tipo de documento:** plano de produção para protótipo jogável (graybox), orientado a implementação incremental por OpenCode + DeepSeek V4.1 Flash.  
> **Nome provisório:** **The Last Alibi**.  
> **Engine recomendada:** Godot **4.7.2 stable**; evitar builds beta/dev para o protótipo.  
> **Plataforma inicial:** PC (Windows/Linux durante o desenvolvimento; preparar exportação para Steam depois).  
> **Regra de produção:** validar a diversão e a clareza das mecânicas antes de investir em arte, animação ou som finais.

---

# 0. Visão do jogo

## 0.1 Pitch

**The Last Alibi** é um RPG de investigação 2D side-scroller. O jogador assume o papel de um investigador chamado para reexaminar cenas de crimes depois que a polícia já isolou o local, removeu o corpo e registrou a identidade das pessoas relacionadas ao caso. A polícia, porém, ainda não fez uma investigação profunda nem recolheu sistematicamente as evidências restantes.

O jogador explora cada cenário, examina objetos, recolhe evidências, entrevista pessoas e registra depoimentos. Quando julgar que investigou o suficiente, encerra a visita e monta um dossiê: seleciona o suspeito que está acusando, quais evidências sustentam a hipótese e quais gravações de entrevista pretende apresentar. Depois ocorre uma transição para um relatório do julgamento, que informa se houve condenação, absolvição, condenação equivocada ou outro resultado processual.

A grande promessa do jogo é: **o jogador pode acusar qualquer suspeito, mas não controla a verdade nem garante que o tribunal aceitará sua conclusão**. O jogo deve reagir ao que ele encontrou, ao que escolheu apresentar e à força lógica do dossiê.

## 0.2 Lista de nomes em inglês

1. **The Last Alibi** — nome provisório recomendado; memorável e ligado diretamente à investigação.
2. **Casefile: Hollow Street** — sugere um caso central ou uma série de casos.
3. **Beyond Reasonable Doubt** — enfatiza provas, lógica e tribunal.
4. **A Matter of Evidence** — tom mais sóbrio e investigativo.
5. **The Unquiet Witness** — funciona bem se testemunhas e contradições forem centrais.
6. **Cold Case Bureau** — bom para uma estrutura de muitos casos e uma organização recorrente.
7. **Shadows on Record** — dá destaque às gravações, depoimentos e informações escondidas.
8. **The Evidence Room** — comunica o lado de análise e montagem do dossiê.
9. **False Testimony** — tom mais sombrio, com foco em mentiras e consequências.
10. **Last Known Truth** — mais amplo e dramático.

Estes são nomes criativos provisórios, **não nomes legalmente verificados**. Antes de escolher o nome comercial, pesquisar Steam, marcas, domínios e lojas digitais para evitar conflito com jogos ou produtos existentes.

## 0.3 Pilares de design

1. **Observar é jogar:** a exploração de um cenário deve revelar informações que não aparecem no relatório inicial.
2. **Provas têm contexto:** recolher um objeto não basta; o jogador precisa interpretar por que ele importa e a que hipótese se conecta.
3. **Entrevistas são evidência:** ouvir alguém, escolher perguntas e registrar contradições devem afetar o dossiê.
4. **A acusação tem consequências:** o jogador pode errar, deixar o culpado escapar ou contribuir para a condenação de um inocente.
5. **O julgamento deve ser compreensível:** o resultado pode surpreender, mas não deve parecer aleatório. Depois da decisão, explicar os fatores principais sem revelar necessariamente todos os segredos do caso.
6. **Arte não pode mascarar problemas de design:** o protótipo deve funcionar com caixas, silhuetas, texto e cores de depuração.

## 0.4 O que o jogo não precisa ser no protótipo

- Não implementar combate, furtividade, armas, árvore de habilidades complexa ou mundo aberto.
- Não criar dezenas de casos antes de validar um caso completo.
- Não usar IA generativa dentro do jogo para criar diálogos ou determinar a culpa.
- Não tentar simular um sistema jurídico real de um país específico. O julgamento inicial será uma simulação narrativa determinística, feita para a lógica de jogo.
- Não criar animações finais, retratos ilustrados, trilha sonora ou efeitos de partículas.
- Não tornar o jogador obrigado a encontrar 100% dos itens antes de sair. Ele deve poder concluir a investigação quando acreditar que já tem material suficiente.

---

# 1. Escopo de validação: o primeiro caso

O alvo inicial é uma **vertical slice curta**, de aproximadamente 15–30 minutos para uma primeira tentativa, dependendo do tempo de leitura e exploração. O número é uma meta de teste, não uma promessa de duração final.

## 1.1 Conteúdo mínimo do caso

Criar um caso fictício chamado **The Bellweather Apartment** (nome interno de teste). A história completa fica em arquivos de dados, separada da lógica.

- 1 relatório policial inicial com resumo, horário aproximado, local e lista de pessoas conhecidas.
- 1 cenário side-scroller cinza de um apartamento, com entrada/corredor e 2 áreas conectadas.
- 3 suspeitos para entrevistar: uma pessoa culpada, uma pessoa inocente com algo a esconder e uma pessoa inocente com informação útil.
- 8–10 objetos que podem ser examinados; pelo menos 6 evidências coletáveis ou registráveis.
- 3–5 tópicos de entrevista por suspeito, com pelo menos 1 contradição detectável quando cruzada com uma evidência.
- 1 hipótese correta e pelo menos 1 caminho de investigação incompleto ou acusação errada.
- 1 tela de montagem de dossiê.
- 1 julgamento/resolução que apresente o resultado e explique os principais fatores.
- 1 fluxo para voltar ao menu e reiniciar o caso sem reiniciar o jogo inteiro.

### Conteúdo não obrigatório para o primeiro MVP

- Sistema de capítulos, campanha longa, reputação, dinheiro, missões secundárias, romances, inventário físico, vários finais narrativos, dublagem e conquistas.
- Sistema de diálogo com digitação livre. No MVP, perguntas e opções serão selecionadas em menus.
- Provas com simulação química, balística ou análise laboratorial. Cada prova pode ter uma descrição e uma interpretação roteirizada.

## 1.2 Loop principal

1. **Briefing:** ler o relatório policial e conhecer o cenário, as pessoas e os horários registrados.
2. **Exploração:** caminhar pelo cenário em 2D e se aproximar de objetos ou personagens.
3. **Exame:** interagir com objetos; ler descrição, observar detalhes e decidir se registra uma evidência.
4. **Entrevista:** conversar com suspeitos, escolher perguntas e guardar uma gravação/transcrição identificada.
5. **Caderno de investigação:** consultar as evidências e gravações encontradas, suas fontes e observações.
6. **Encerrar a visita:** interagir com o ponto de saída e confirmar que deseja sair. Não bloquear por evidências faltantes.
7. **Montar o dossiê:** escolher um suspeito para acusar, selecionar evidências e selecionar as gravações que sustentam a acusação. Permitir enviar um dossiê fraco.
8. **Julgamento:** fade out; exibir relatório narrativo com acusação, resultado, pontos aceitos/rejeitados e consequências.
9. **Revisão:** mostrar resumo para o jogador entender o que sustentou ou enfraqueceu sua hipótese, sem revelar todas as descobertas secretas necessariamente.
10. **Recomeçar/continuar:** no protótipo, voltar ao menu e iniciar outra tentativa. A progressão entre casos será decidida depois de validar o loop.

## 1.3 Regras importantes de design

- O jogador **pode sair a qualquer momento**, depois de uma confirmação. A possibilidade de sair com informação insuficiente faz parte da tensão.
- O jogador não deve precisar achar todos os objetos decorativos para terminar o caso.
- Examinar um objeto não significa automaticamente que ele é uma prova formal. Pode ser apenas uma observação; uma etapa ou detalhe adicional pode ser necessário para registrá-lo.
- Entrevistas devem guardar uma transcrição ou gravação selecionável no dossiê. O protótipo pode representar a gravação como um registro de texto com nome, data/hora e trechos importantes; áudio real é adiado.
- O resultado não deve depender da ordem em que os nós foram carregados, do FPS ou de aleatoriedade não visível.
- A solução verdadeira fica definida nos dados do caso e não muda com a decisão do jogador. O jogador pode descobrir ou não essa verdade.

---

# 2. Critérios gerais de sucesso do protótipo

O MVP estará validado quando pessoas que não participaram do desenvolvimento conseguirem:

- mover-se pelo cenário e perceber claramente como interagir;
- entender o relatório inicial sem explicação oral do desenvolvedor;
- inspecionar objetos e perceber a diferença entre decoração e evidência útil;
- entrevistar pessoas e reconhecer pelo menos uma contradição real;
- encontrar e consultar registros de evidências e gravações no caderno;
- encerrar a investigação sem obrigação de coletar tudo;
- montar e entregar um dossiê;
- entender por que houve condenação, absolvição ou resultado adverso;
- terminar uma primeira tentativa sem bugs bloqueadores.

### Métricas simples para playtest

Registrar manualmente ou em log local:

- tempo até a primeira interação;
- quantos jogadores descobrem o caderno sem instrução;
- quantas evidências relevantes são encontradas;
- quantos conseguem explicar, ao final, por que acusaram aquele suspeito;
- quantos acreditam que o julgamento foi justo e compreensível;
- momentos em que ficam sem saber o que fazer;
- erros de UI (não encontrar botão, seleção pouco clara, foco de teclado perdido).

**Critério qualitativo principal:** depois do julgamento, o jogador deve conseguir explicar a conexão entre pelo menos duas provas e a conclusão que tirou — mesmo que tenha errado a acusação.

---

# 3. Tecnologia, projeto e convenções

## 3.1 Versão da engine

Usar **Godot 4.7.2 stable** como referência inicial, confirmada no arquivo oficial de versões em 22/10/2026. A linha 4.8 está em beta nessa data; para reduzir mudanças durante o protótipo, não usar uma beta/dev como base. Se o ambiente de desenvolvimento já estiver padronizado em outra versão 4.x estável, fixar a versão no README e evitar atualizações no meio de uma fase.

Documentação oficial útil:
- Releases: https://godotengine.org/download/archive/
- Organização de cenas: https://docs.godotengine.org/pt-br/4.x/tutorials/best_practices/scene_organization.html
- Autoloads: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html
- Resources: https://docs.godotengine.org/en/stable/classes/class_resource.html
- Tipagem estática: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html

## 3.2 Configuração inicial

- Renderizador: compatível com o hardware-alvo; usar o padrão recomendado pela versão estável, sem personalização gráfica necessária nesta etapa.
- Orientação: paisagem 16:9 como base de PC, com layout que tolera redimensionamento.
- Resolução lógica inicial: 1280×720; validar também janelas menores.
- Escala de conteúdo/UI: usar containers e anchors; evitar posicionamento absoluto para toda a interface.
- Input Map: `move_left`, `move_right`, `interact`, `open_notebook`, `cancel`, `confirm`, `toggle_fullscreen`.
- Controle: teclado obrigatório no protótipo; suporte a controle pode ser incluído quando o fluxo principal estiver validado.
- Repositório Git desde o primeiro dia. Fazer commits pequenos por marco e manter o projeto sempre abrindo.

## 3.3 Convenções de código

- Usar GDScript tipado quando o tipo for conhecido: `var evidence_id: String = ""`.
- Usar `snake_case` em funções/variáveis e `PascalCase` em classes/cenas, seguindo o padrão da Godot.
- Cada script tem uma responsabilidade clara; extrair funções longas quando a lógica fica difícil de testar.
- Usar `class_name` apenas para conceitos que realmente serão tipos reutilizáveis.
- Usar `Resource` para conteúdo que precisa ser editável e reutilizado (definições de caso, suspeito, evidência, entrevista). Os dados de estado da tentativa devem ser separados desses recursos compartilhados.
- Usar `signal` para comunicar fatos ocorridos entre subsistemas; não usar um EventBus global por padrão para tudo.
- Não manter referências duradouras a nós de uma cena que será descarregada.
- Não colocar lógica de investigação, diálogos, julgamento e movimentação num único script `Game.gd`.
- Evitar `get_node("../../..")` repetido atravessando muitas camadas. Preferir composição, exports e signals.
- Adicionar comentários para decisões e regras não óbvias, não comentários que só repetem a linha de código.

---

# 4. Arquitetura de cenas, nós e pastas

## 4.1 Estrutura de diretórios sugerida

```text
res://
  project.godot
  README.md
  CHANGELOG.md
  docs/
    GAME_DESIGN.md
    CASE_FORMAT.md
    TEST_PLAN.md
  assets/
    placeholder/
      sprites/
      fonts/
    art/                  # arte final futura
    audio/                # som futuro
    fonts/                # fontes licenciadas
  data/
    cases/
      bellweather_apartment/
        case_definition.tres
        evidence/
        suspects/
        interviews/
    evidence/
    suspects/
    dialogue/
  scenes/
    app/
      main.tscn
      main_menu.tscn
      case_select.tscn
    investigation/
      investigation_level.tscn
      player/
        investigator.tscn
      interactables/
        inspectable_object.tscn
        suspect_npc.tscn
        exit_point.tscn
      environment/
        room_segment.tscn
    dialogue/
      dialogue_panel.tscn
      question_list.tscn
    notebook/
      notebook_screen.tscn
      evidence_detail.tscn
      interview_record_detail.tscn
    dossier/
      dossier_builder.tscn
      suspect_selector.tscn
      evidence_selector.tscn
      recording_selector.tscn
    results/
      trial_report.tscn
    ui/
      hud.tscn
      interaction_prompt.tscn
      confirmation_dialog.tscn
      fade_overlay.tscn
  scripts/
    autoload/
      game_state.gd
      scene_router.gd
      save_service.gd
    core/
      case_session.gd
      case_evaluator.gd
      investigation_rules.gd
    player/
      investigator_controller.gd
      interaction_scanner.gd
    interactables/
      interactable.gd
      inspectable_object.gd
      suspect_npc.gd
      exit_point.gd
    investigation/
      evidence_service.gd
      interview_service.gd
      notebook_model.gd
    dossier/
      dossier_model.gd
      dossier_validator.gd
    ui/
      dialogue_presenter.gd
      notebook_presenter.gd
      dossier_presenter.gd
      trial_report_presenter.gd
    resources/
      case_definition.gd
      suspect_definition.gd
      evidence_definition.gd
      interview_topic_definition.gd
      interview_record.gd
      clue_link.gd
    utilities/
      ids.gd
      debug_log.gd
  tests/
    test_case_evaluator.gd
    test_dossier_validator.gd
    test_evidence_service.gd
```

A estrutura é uma proposta inicial, não uma exigência de criar todos os diretórios de uma vez. Criar pastas e arquivos à medida que cada fase precisar deles.

## 4.2 Hierarquia da cena principal

`Main.tscn` deve manter o shell da aplicação e permitir trocar o conteúdo sem perder o estado global.

```text
Main (Node)
├── WorldHost (Node)             # a cena atual de jogo/menu fica aqui
├── UIHost (CanvasLayer)         # HUD/telas globais quando necessário
├── FadeOverlay (CanvasLayer)    # transições simples entre fases
└── DebugOverlay (CanvasLayer)   # apenas em build de desenvolvimento
```

Fluxo sugerido:

```text
Main Menu
  -> Case Briefing
    -> InvestigationLevel
      -> DossierBuilder
        -> TrialReport
          -> Main Menu / Retry Case
```

O jogo não precisa usar `change_scene_to_file()` para todas as transições. Uma cena `Main` persistente com `WorldHost` permite manter overlay de fade e serviços da aplicação. O `SceneRouter` será o responsável por trocar os filhos de `WorldHost`; não permitir que qualquer botão troque a cena sem passar pelo fluxo de transição.

## 4.3 Hierarquia da cena de investigação

```text
InvestigationLevel (Node2D)
├── Environment (Node2D)
│   ├── Background (Node2D)
│   ├── WalkableGeometry (Node2D)
│   ├── Props (Node2D)
│   └── DoorsAndTransitions (Node2D)
├── Actors (Node2D)
│   ├── Investigator (CharacterBody2D)
│   └── Suspects (Node2D)
├── Interactables (Node2D)
├── InvestigationController (Node)
├── Camera2D
├── HUD (CanvasLayer)
│   ├── InteractionPrompt
│   ├── CaseStatus
│   └── NotebookShortcut
└── ModalLayer (CanvasLayer)
    ├── DialoguePanel
    └── NotebookScreen
```

Para o primeiro cenário, manter a exploração simples: caminhar à esquerda e à direita por áreas conectadas; portas/zonas podem levar a segmentos separados. A perspectiva é side-scroller, mas o MVP não precisa de salto, combate ou plataforma precisa. **Não adicionar platforming só porque o jogo é 2D lateral**: qualquer movimento adicional deve melhorar a investigação.

## 4.4 Hierarquia dos nós interativos

`InspectableObject.tscn`:

```text
InspectableObject (Area2D)
├── CollisionShape2D
├── PlaceholderVisual (Polygon2D ou ColorRect adequado ao contexto)
└── Label/Marker opcional de depuração
```

`SuspectNPC.tscn`:

```text
SuspectNPC (Area2D ou CharacterBody2D, conforme precisar de movimento)
├── CollisionShape2D
├── PlaceholderVisual
└── NameLabel
```

Uma área detecta proximidade, mas a ação de interagir fica centralizada no controlador do jogador ou em um scanner. O objeto não deve abrir diretamente qualquer tela global sem uma interface clara de interação.

## 4.5 Autoloads essenciais e o que não deve virar global

### `GameState` — recomendado

Responsável somente pelo estado que precisa sobreviver a transições:
- ID do caso atual;
- fase global da aplicação (menu, briefing, investigação, dossiê, julgamento);
- resultado da última tentativa, se necessário para a tela seguinte;
- versão do formato de save ou flags de progresso simples.

**Não** armazenar referências a nós da cena, componentes visuais ou todos os dados mutáveis do caso aqui.

### `SceneRouter` — recomendado

- Carregar/trocar cenas de alto nível.
- Coordenar fade-out/fade-in e evitar cliques durante transição.
- Emitir sinais de transição concluída.
- Evitar que a UI tenha que saber como o `WorldHost` está organizado.

### `SaveService` — opcional no MVP, útil depois

- Salvar configurações e progresso persistente em `user://`.
- Versionar dados de save.
- Tratar arquivos ausentes/corrompidos sem impedir o jogo de abrir.
- Não salvar um recurso visual inteiro ou o estado de nós; salvar identificadores e dados serializáveis.

### `AudioManager` — adiar até validar o loop

Quando for necessário, controlar música e efeitos com volumes separados. Antes disso, deixar os pontos de integração preparados sem gastar tempo em mixagem ou composição.

### `EventBus` — não criar de início

Começar com signals locais e conexões feitas pelos nós pais. Um barramento global só deve aparecer se muitos subsistemas independentes precisarem reagir ao mesmo evento e as conexões locais ficarem realmente difíceis de manter.

### `CaseSession` — não é Autoload

É o modelo de uma única investigação, criado pelo controlador da cena/fluxo e entregue aos sistemas que precisam dele. Guarda evidências encontradas, entrevistas registradas, observações e estado de conclusão. Ao reiniciar o caso, criar uma nova sessão limpa.

---

# 5. Modelo de dados e separação entre conteúdo e lógica

A narrativa de um caso muda frequentemente; não deve exigir reescrever o código central. Usar recursos de dados (custom `Resource`) para definições e classes/modelos separados para o estado mutável da execução.

## 5.1 Tipos de dados sugeridos

### `CaseDefinition` (`Resource`)

Campos conceituais:
- `case_id: StringName`
- `title: String`
- `briefing: String`
- `scene_path: String`
- `suspects: Array[SuspectDefinition]`
- `evidence_catalog: Array[EvidenceDefinition]`
- `truth_suspect_id: StringName` (uso interno do avaliador, não deve ser exposto na UI ao jogador)
- `initial_police_report: String`
- configurações do caso para o cálculo do julgamento.

### `SuspectDefinition` (`Resource`)

- `suspect_id: StringName`
- `display_name: String`
- `short_bio: String`
- `known_relationship: String`
- `interview_topics: Array[InterviewTopicDefinition]`
- `is_true_culprit` não precisa estar disponível no recurso que a UI consome; preferir guardar a verdade no `CaseDefinition`/dados internos que o jogo não apresenta.

### `EvidenceDefinition` (`Resource`)

- `evidence_id: StringName`
- `title: String`
- `description_found: String`
- `source_location: String`
- `category: enum` (física, documental, digital, testemunhal, circunstancial)
- `reliability: float` entre 0 e 1
- `relevance_tags: Array[StringName]`
- `supports_suspect_ids: Array[StringName]`
- `contradicts_suspect_ids: Array[StringName]`
- `unlocks_after_inspection: bool`
- `discovery_requirements: Array[StringName]` para requisitos simples, se forem necessários.

Atributos como confiabilidade e relação com suspeitos são dados internos para prototipagem e podem ajudar o avaliador. Não mostrar ao jogador pontuações numéricas que ele não teria como conhecer. Mostrar explicações narrativas como “a origem não foi confirmada” ou “o horário contradiz o depoimento”.

### `InterviewTopicDefinition` (`Resource`)

- `topic_id: StringName`
- `question_text: String`
- `answer_text: String`
- `follow_up_options: Array[StringName]`
- `recording_id: StringName`
- tags de informação revelada e contradições associadas.

### `InterviewRecord` (estado da sessão)

- `record_id: StringName`
- `suspect_id: StringName`
- `topics_asked: Array[StringName]`
- `transcript_segments: Array[Dictionary]` ou um tipo de recurso serializável dedicado
- `recorded_at_case_step: int` (opcional)
- identificadores das contradições percebidas.

### `CaseSession` (estado mutável)

- referência ao `CaseDefinition` carregado;
- `collected_evidence_ids: Array[StringName]`;
- `examined_object_ids: Array[StringName]`;
- `interview_records: Array[InterviewRecord]`;
- `notes_by_id: Dictionary` para notas do jogador, se o protótipo realmente precisar;
- `investigation_closed: bool`;
- `submitted_dossier: DossierSubmission` (após submissão).

### `DossierSubmission`

- `accused_suspect_id: StringName`;
- `submitted_evidence_ids: Array[StringName]`;
- `submitted_record_ids: Array[StringName]`;
- `player_reasoning_note: String` opcional;
- `submission_time` não é necessário para o MVP, salvo como evento narrativo.

## 5.2 IDs estáveis, não nomes visuais

Usar IDs como `evidence_broken_glass`, `suspect_mara_voss` ou `record_mara_alibi`. Nunca usar o nome mostrado na tela como chave de lógica. Nomes e textos podem mudar por tradução; IDs não.

## 5.3 Descoberta, posse e apresentação são estados diferentes

Uma prova deve ter estados conceituais distintos:

1. **Não descoberta:** o jogador ainda não a encontrou.
2. **Examinada:** viu uma descrição ou observação, mas talvez ainda não a tenha registrado.
3. **Registrada no caderno:** consta entre as evidências coletadas.
4. **Apresentada no dossiê:** o jogador escolheu anexá-la à acusação.
5. **Considerada no julgamento:** o sistema avalia se ela é relevante/confiável para a hipótese e qual o peso dela.

Manter esta distinção evita o bug comum em que o jogo considera uma prova “usada” só porque ela foi recolhida, mesmo que o jogador não a tenha apresentado.

---

# 6. MVP: implementação passo a passo

## Fase 0 — Setup, contrato técnico e primeira execução

**Objetivo:** projeto limpo, versionado, executável e documentado.

### Tarefas

1. Criar projeto Godot 4.7.2 stable.
2. Configurar resolução lógica, stretch e Input Map.
3. Criar `Main.tscn` com `WorldHost`, `UIHost`, `FadeOverlay` e overlay de debug.
4. Criar `README.md` contendo versão Godot, controles e como executar.
5. Inicializar Git e adicionar `.gitignore` apropriado para Godot; não ignorar arquivos essenciais do projeto.
6. Criar um menu mínimo com botão “Start Case” e “Quit”.
7. Adicionar um painel de debug que possa ser ativado por uma tecla, mostrando fase atual e ID do caso.

### Critérios de aceite

- O projeto abre sem erros de parser.
- “Start Case” navega até uma cena de teste.
- O botão “Quit” funciona fora do editor e não quebra quando executado no editor.
- Uma segunda execução mantém o fluxo correto.
- Nenhuma arte ou áudio final é requerido.

### Armadilhas

- Começar criando muitas abstrações vazias.
- Atualizar a Godot a meio da fase sem necessidade.
- Misturar menu, nível e UI em uma única cena enorme.

---

## Fase 1 — Controle side-scroller e interação por proximidade

**Objetivo:** sentir o personagem andando e interagindo com objetos numa cena sem arte.

### Tarefas

1. Criar `Investigator.tscn` com `CharacterBody2D`, `CollisionShape2D`, visual temporário e script `investigator_controller.gd`.
2. Implementar movimento horizontal usando `Input.get_axis("move_left", "move_right")`.
3. Criar colisão simples com chão e obstáculos.
4. Criar `InspectableObject.tscn` e `SuspectNPC.tscn` com áreas de proximidade.
5. Criar uma estratégia consistente para saber qual interação está ativa: o candidato elegível mais próximo, com desempate determinístico.
6. Mostrar prompt, por exemplo `[E] Examine evidence` ou `[E] Interview Mara`.
7. Ao pressionar `interact`, chamar a interação do objeto ativo. O objeto em si emite um signal como `interaction_requested(interactable_id)` ou chama uma interface comum controlada pelo pai.
8. Criar câmera que acompanha o jogador e testar zonas conectadas.
9. Exibir um identificador de depuração sobre objetos interativos para testes.

### Recomendação de movimento

Usar movimento lateral sem salto na primeira versão, salvo se um teste indicar que saltar é realmente necessário para acessar pistas. A investigação precisa ser o desafio central; exigir precisão de plataforma pode distrair e frustrar.

### Exemplo inicial de controlador tipado

```gdscript
extends CharacterBody2D
class_name InvestigatorController

@export var move_speed: float = 220.0

func _physics_process(_delta: float) -> void:
    var direction: float = Input.get_axis("move_left", "move_right")
    velocity.x = direction * move_speed
    # O movimento vertical virá da gravidade/colisão se o level usar plataformas.
    move_and_slide()
```

Se o cenário é um plano lateral sem plataformas, usar uma área de colisão e limites simples. Se for usar gravidade e chão, configurar `velocity.y` pela gravidade e validar que o personagem sempre fica acessível; não misturar as duas soluções sem motivo.

### Critérios de aceite

- O jogador anda nos dois sentidos e não atravessa o piso.
- Prompt aparece e desaparece corretamente.
- Se dois objetos estiverem próximos, a interação selecionada é clara e previsível.
- Pressionar a tecla de interação uma única vez não dispara duas interações.
- Não há referência inválida quando um objeto sai de cena.

### Armadilhas

- Usar a ordem de sinais de `Area2D` como critério implícito para escolher o objeto.
- Deixar o jogador interagir com objetos através de paredes ou em alcance excessivo.
- Colocar UI de diálogo como filha de cada objeto e criar cópias independentes do mesmo painel.

---

## Fase 2 — Sistema de exame e caderno de evidências

**Objetivo:** transformar objetos do cenário em informação de investigação.

### Tarefas

1. Criar `EvidenceDefinition` como `Resource`.
2. Associar cada objeto examinável a um ID estável e a uma definição de dados.
3. Ao examinar, abrir um painel reutilizável com título, descrição e opções possíveis (por exemplo, “Registrar evidência”, “Continuar observando” e “Fechar”).
4. A opção de registrar adiciona o ID ao `CaseSession` via um serviço/modelo, não diretamente à UI.
5. Emitir signal `evidence_registered(evidence_id)` depois de uma alteração bem-sucedida.
6. Criar `NotebookScreen` acessível a qualquer momento durante a investigação.
7. Listar provas registradas e abrir detalhes com descrição, localização, categoria narrativa e anotações.
8. Permitir examinar novamente sem duplicar a evidência no caderno.
9. Adicionar pelo menos 6 provas de teste, com 2 úteis, 2 contextuais e 1 pista falsa/incompleta. Evitar pistas falsas arbitrárias: elas devem ter uma explicação posterior.

### Regras de UX

- Diferenciar claramente “inspecionar” de “registrar”.
- Se um objeto é apenas cenário, dizer algo sem interesse relevante ou simplesmente não permitir interação — não usar todos os props como botão disfarçado.
- Se a evidência já foi registrada, a UI informa “Already documented”/“Já registrada”, em português no protótipo.
- O caderno não deve desaparecer ou reiniciar quando o jogador fecha uma janela de diálogo.

### Critérios de aceite

- Uma evidência registrada permanece no caderno enquanto a sessão está ativa.
- Abrir e fechar o caderno não cria duplicatas nem perde dados.
- A mesma evidência não pode ser registrada duas vezes.
- Reiniciar o caso cria uma sessão nova sem provas da tentativa anterior.

### Armadilhas

- Guardar toda a investigação em labels e controles da UI.
- Misturar definição imutável da evidência com estado “coletada”.
- Usar nome de exibição como ID.

---

## Fase 3 — Entrevistas e gravações/transcrições

**Objetivo:** dar ao jogador pessoas para questionar e permitir que use depoimentos no dossiê.

### Tarefas

1. Criar `SuspectDefinition` e `InterviewTopicDefinition` como dados.
2. Criar um painel de entrevista reutilizável com nome, pergunta, resposta e lista de perguntas disponíveis.
3. Ao selecionar um tópico, mostrar a resposta definida no conteúdo do caso.
4. Guardar tópicos perguntados para não apresentar repetidamente a mesma opção como se fosse nova; permitir rever as respostas no caderno.
5. Criar um `InterviewRecord` por pessoa (ou por sessão de entrevista, se isso facilitar a narrativa).
6. Cada gravação deve ter ID, suspeito, tópicos cobertos e transcrição consultável.
7. Adicionar follow-ups que só aparecem depois de encontrar uma pista específica ou perguntar um tópico relevante.
8. Permitir ao jogador entrevistar novamente uma pessoa; manter a gravação existente e acrescentar a nova sessão se a lógica narrativa pedir.
9. Fazer pelo menos uma prova contrariar um depoimento e uma segunda fala esclarecer ou enfraquecer essa contradição.
10. Exibir no caderno a lista de gravações como itens selecionáveis para o dossiê.

### Escopo da conversa no MVP

Não implementar reconhecimento de texto livre nem árvore narrativa enorme. Um menu de perguntas com condições simples é mais previsível, testável e barato. A profundidade vem de cruzar informações, não de simular conversa aberta.

### Exemplo de dados de pergunta

```gdscript
extends Resource
class_name InterviewTopicDefinition

@export var topic_id: StringName
@export var question_text: String
@export_multiline var answer_text: String
@export var required_evidence_id: StringName = &""
@export var revealed_fact_ids: Array[StringName] = []
@export var follow_up_topic_ids: Array[StringName] = []
```

A regra que verifica `required_evidence_id` deve morar num serviço/modelo de entrevista, não no componente visual do botão.

### Critérios de aceite

- Pelo menos 3 personagens podem ser entrevistados.
- As respostas e as perguntas feitas aparecem no registro correto.
- Um follow-up bloqueado fica indisponível até cumprir o requisito.
- Sair da entrevista e voltar não apaga as respostas já registradas.
- A UI indica claramente de qual pessoa é cada gravação.

### Armadilhas

- Misturar toda a árvore de diálogo em um script com dezenas de `if`.
- Fazer o personagem entregar a solução apenas porque o jogador clicou em todas as opções.
- Tornar uma pista essencial impossível de encontrar por uma condição obscura não comunicada.

---

## Fase 4 — Estado de investigação, encerramento e montagem de dossiê

**Objetivo:** permitir que o jogador decida quando parar e transforme achados em acusação formal.

### Tarefas

1. Criar `ExitPoint.tscn`, com prompt para encerrar a visita.
2. Ao interagir, abrir confirmação: “Encerrar investigação e montar o dossiê?”
3. Não exigir um número mínimo de evidências; informar que sair cedo pode resultar em um caso fraco.
4. Congelar a exploração após confirmação e mandar o `SceneRouter` carregar a tela de dossiê.
5. Criar `DossierBuilder` com três seções:
   - **Acusado:** selecionar um dos suspeitos conhecidos.
   - **Evidências anexadas:** selecionar evidências registradas no caderno.
   - **Gravações anexadas:** selecionar entrevistas disponíveis.
6. Exibir contadores `x evidências`, `y gravações`, sem indicar quais escolhas garantem o resultado.
7. Permitir remover e recolocar itens antes de enviar.
8. Confirmar antes da submissão final. Depois de enviar, o dossiê fica imutável para aquela tentativa.
9. Criar `DossierSubmission` como objeto de dados, independente dos componentes UI.
10. Adicionar uma nota opcional do jogador como “Minha conclusão” se a implementação for simples; não fazer essa nota alterar o resultado no MVP.

### UX do dossiê

- Não pré-selecionar automaticamente todas as provas; a seleção deve ser uma decisão do jogador.
- Deixar claro que evidências descobertas e evidências anexadas são coisas diferentes.
- Não esconder gravações que o jogador fez; se uma gravação não for utilizável no julgamento por motivo de confiabilidade, ela ainda pode estar disponível para análise e o relatório posterior explica a limitação.
- Não bloquear uma acusação errada. O jogo precisa aceitar decisões ruins sem parecer quebrado.

### Critérios de aceite

- Jogador pode concluir com dossiê vazio ou fraco.
- Suspeito escolhido é registrado corretamente.
- O dossiê contém somente itens selecionados.
- Clicar duas vezes em enviar não inicia dois julgamentos.
- Cancelar antes da confirmação volta à edição sem perda de seleção.

### Armadilhas

- Fazer o julgador ler diretamente os nós da UI para descobrir o que foi selecionado.
- Bloquear envio quando falta a “prova certa”, eliminando a liberdade de acusar qualquer pessoa.
- Deixar evidências que foram recolhidas sem serem selecionadas contar como anexadas.

---

## Fase 5 — Julgamento determinístico e relatório final

**Objetivo:** entregar a principal consequência narrativa e validar se a investigação se transforma em decisão significativa.

### Princípio de arquitetura

Separar a avaliação das evidências da apresentação narrativa. Criar `CaseEvaluator` sem dependência de cena/UI. Ele recebe os dados do caso e um `DossierSubmission` e devolve um `TrialOutcome` (ou `Dictionary` tipado por uma classe de dados). O relatório de julgamento apenas apresenta esse resultado.

### Resultado conceitual

O sistema deve distinguir:
- **verdade narrativa:** qual suspeito realmente cometeu o crime;
- **acusação do jogador:** quem o jogador selecionou;
- **resultado do tribunal:** condenado, absolvido, caso inconclusivo ou outra decisão definida pelo caso;
- **qualidade da conclusão:** correta, errada ou sem evidência suficiente.

Isso permite resultados ricos:

1. **Condenação correta:** culpado verdadeiro, prova relevante e confiável suficiente.
2. **Absolvição do culpado:** culpado acusado, mas o dossiê é insuficiente ou mal montado.
3. **Acusação rejeitada:** suspeito inocente acusado com prova fraca ou contradições que o inocentam.
4. **Condenação injusta:** suspeito inocente acusado, e o dossiê parece forte, mas foi interpretado de modo enganoso. Usar com cuidado e sempre dar ao jogador informação posterior suficiente para entender o erro.
5. **Caso inconclusivo:** dossiê não sustenta uma decisão firme.

Nem todo caso precisa oferecer todos os resultados, mas o modelo deve representá-los sem hacks na UI.

### Regra inicial sugerida para o protótipo

Use uma avaliação baseada em fatores ponderados e relações pré-definidas. Exemplo inicial a calibrar durante testes:

- evidência confiável que liga diretamente o acusado ao evento: peso alto;
- evidência circunstancial relevante: peso médio;
- gravação coerente que confirma tempo/oportunidade: peso médio;
- contradição comprovada por uma evidência registrada e anexada: peso alto;
- evidência de origem fraca ou relato de ouvir dizer: peso reduzido;
- prova que contradiz a hipótese de acusação: penalidade ou sinal de dúvida;
- consistência temporal: bônus pequeno, se o caso tiver horários relevantes.

Evitar contar duas vezes a mesma informação. Se uma gravação apenas repete a evidência física, o avaliador deve reconhecer que ambas sustentam a mesma afirmação e reduzir a redundância. No MVP, pode-se agrupar pistas por `fact_id` e dar peso integral à melhor prova do grupo, com contribuição parcial para provas adicionais.

**Importante:** não criar um sistema jurídico genérico complexo nesta fase. Fazer regras transparentes e testáveis, que funcionem para um caso escrito manualmente. O avaliador é um motor de regras narrativas do jogo, não uma simulação real de justiça.

### Estrutura de saída do avaliador

Campos sugeridos:
- `accused_suspect_id`
- `verdict`: `CONVICTED`, `ACQUITTED`, `INCONCLUSIVE` ou outro enum documentado
- `is_correct_outcome: bool` ou uma enum de avaliação narrativa
- `supporting_fact_ids: Array[StringName]`
- `weakness_fact_ids: Array[StringName]`
- `short_summary: String`
- `report_sections: Array[ReportSection]`

Evitar expor no primeiro momento `truth_suspect_id` em texto de interface antes do julgamento. Depois da resolução, mostrar as explicações necessárias.

### Fluxo visual

1. Jogador envia o dossiê.
2. Fade out.
3. O sistema avalia dossiê e verdade narrativa.
4. Fade in na tela de julgamento.
5. Mostrar nome acusado, decisão do tribunal e texto jornalístico/judicial do caso.
6. Mostrar 2–4 fatores principais: o que sustentou a acusação, qual informação faltou e o que foi contradito.
7. Oferecer “Rever caderno” apenas se isso fizer sentido no desenho de fluxo; na primeira versão, melhor guardar a revisão para depois do resultado e oferecer “Jogar novamente”.

### Critérios de aceite

- O mesmo dossiê produz sempre o mesmo resultado.
- O avaliador pode ser testado sem abrir cenas.
- Provas não anexadas não influenciam a avaliação.
- Um dossiê vazio nunca resulta numa condenação correta por acidente.
- O relatório diferencia veredito judicial e acerto da investigação.
- O texto explica pelo menos uma razão concreta para o resultado.

### Armadilhas

- Fazer `randf()` determinar veredito.
- Usar somente uma variável escondida `score` sem explicação, gerando resultados que parecem arbitrários.
- Confundir “jogador selecionou o culpado verdadeiro” com “jogador provou a culpa no tribunal”.
- Fazer evidências com IDs parecidos compartilharem estado por engano.

---

## Fase 6 — Primeiro caso completo e revisão da experiência

**Objetivo:** colocar todos os sistemas no mesmo caso, sem conteúdo extra.

### Tarefas

1. Completar a planta cinza do apartamento e os pontos de interação.
2. Escrever briefing e conteúdo dos 3 suspeitos.
3. Configurar todas as evidências e diálogos em dados externos ao código de UI.
4. Desenhar uma cadeia dedutiva simples: uma observação encontrada no ambiente abre uma pergunta de entrevista; a resposta entra em conflito com um segundo fato; as duas peças juntas sustentam ou enfraquecem uma hipótese.
5. Criar pelo menos dois caminhos válidos de entendimento, quando possível, para não depender de um clique isolado.
6. Verificar se o culpado pode ser acusado sem o jogador ter encontrado a verdade — permitido, mas com resultado coerente.
7. Rodar teste com desenvolvedor, depois com 3–5 jogadores sem orientação. Registrar problemas, não explicar a solução durante o playtest.
8. Corrigir bloqueios e ambiguidades antes de adicionar qualquer sistema novo.

### Critérios de aceite

- É possível completar uma tentativa de começo a fim.
- Nenhuma pista obrigatória fica inacessível por problema de colisão ou prompt.
- É possível acusar cada um dos 3 suspeitos e obter uma resolução sem crash.
- O relatório do julgamento é coerente com as escolhas feitas.
- O estado de uma tentativa não vaza para a próxima.

---

# 7. Interface e experiência do jogador

## 7.1 Telas mínimas

1. **Main Menu:** Start Case, Settings (básico), Quit.
2. **Case Briefing:** relatório inicial, local, data/hora, lista de envolvidos e botão “Begin Investigation”.
3. **Investigation HUD:** prompt de interação, nome do cenário/área, acesso ao caderno e indicação discreta de que é possível sair.
4. **Inspection Panel:** descrição do objeto, ação de registrar e fechar.
5. **Interview Panel:** nome, pergunta, resposta, lista de tópicos e encerrar entrevista.
6. **Notebook:** abas Evidence, Interviews e Notes (Notes é opcional). Cada registro deve mostrar fonte, local/contexto e descrição.
7. **Exit Confirmation:** confirmação de encerramento, sem punição artificial por dizer não.
8. **Dossier Builder:** suspeito, provas, gravações e resumo da seleção.
9. **Trial Report:** resultado, explicação e botão para tentar novamente/voltar ao menu.
10. **Settings simples:** volume futuro, fullscreen, escala/resolução quando necessário. Não gastar muito tempo nisso antes do MVP.

## 7.2 Padrões de navegação

- Toda janela modal deve ter como fechar/cancelar e manter o estado anterior.
- Ao abrir UI, pausar o movimento do personagem (ou bloquear controles equivalentes); ao fechar, restaurar corretamente.
- `Esc` deve cancelar/fechar quando for seguro; não deve encerrar silenciosamente toda a investigação.
- Navegação por teclado deve funcionar com foco visual claro. Isso evita criar UI acessível apenas pelo mouse e ajuda futura compatibilidade com controle.
- Não depender exclusivamente de cor para diferenciar prova selecionada, estado novo ou contradição. Combinar cor com ícone/texto.
- Usar containers de UI (`VBoxContainer`, `HBoxContainer`, `MarginContainer`, `ScrollContainer`) em vez de posicionar dezenas de controles manualmente.

## 7.3 Feedback quando o jogador está perdido

Prototipar dicas não intrusivas:
- o relatório inicial apresenta uma lista de envolvidos e informações confirmadas;
- o caderno identifica quantos registros existem, sem dar percentagem falsa de conclusão;
- interações importantes têm prompts objetivos;
- se uma pergunta depende de uma evidência, indicar algo como “Você precisa de mais contexto para pressionar essa pessoa”; não exibir a resposta inteira;
- antes de encerrar, mostrar um lembrete neutro: “Você pode continuar investigando ou montar o dossiê com o que já encontrou.”

---

# 8. Serviços, estado e fluxo de dados

## 8.1 Responsabilidade por sistema

- `InvestigatorController`: movimento e input do jogador.
- `InteractionScanner`: descobre interações próximas e escolhe o alvo ativo.
- `InspectableObject`: apresenta interação de exame usando uma definição de dado.
- `InterviewService`: valida tópicos disponíveis e grava respostas/registros.
- `EvidenceService`: registra e consulta evidências da sessão.
- `NotebookModel`: consultas formatadas para a UI; não controla a interface.
- `CaseSession`: estado mutável da investigação atual.
- `DossierValidator`: valida IDs, duplicatas e pertença ao caso antes da submissão; não impede uma acusação fraca.
- `CaseEvaluator`: calcula resultado determinístico do julgamento.
- `SceneRouter`: transição entre cenas com fade.
- `GameState`: estado global mínimo que sobrevive às cenas.

## 8.2 Signals sugeridos

Signals devem anunciar algo que aconteceu; nomes no passado geralmente ajudam a manter o sentido:

```gdscript
signal interaction_target_changed(target_id: StringName)
signal evidence_registered(evidence_id: StringName)
signal interview_record_created(record_id: StringName)
signal investigation_closed
signal dossier_submitted
signal verdict_calculated(verdict_id: StringName)
signal scene_transition_started
signal scene_transition_finished
```

A lista é ilustrativa; não criar todos os sinais antes de precisar deles. Preferir conexões explícitas no nó pai. Quando uma cena é liberada, desconectar sinais automaticamente ao destruir os nós envolvidos; evitar manter `Callable` para um objeto já eliminado.

## 8.3 Pseudocódigo de sessão

```gdscript
extends RefCounted
class_name CaseSession

var case_definition: CaseDefinition
var collected_evidence_ids: Array[StringName] = []
var examined_object_ids: Array[StringName] = []
var interview_records: Array[InterviewRecord] = []
var investigation_closed: bool = false
var submitted_dossier: DossierSubmission

func register_evidence(evidence_id: StringName) -> bool:
    if collected_evidence_ids.has(evidence_id):
        return false
    collected_evidence_ids.append(evidence_id)
    return true

func has_evidence(evidence_id: StringName) -> bool:
    return collected_evidence_ids.has(evidence_id)
```

O exemplo serve para ilustrar as fronteiras, não deve ser colado sem criar as classes referenciadas. A validação precisa garantir que `evidence_id` realmente pertence ao caso carregado.

## 8.4 Persistência e reset

Para o MVP, a sessão ativa pode viver somente em memória. O botão de reiniciar cria uma sessão nova. O save persistente entra depois para configurações, histórico de casos e progresso.

Quando o salvamento for implementado:
- usar `user://`;
- armazenar IDs e valores simples, não referências de nó;
- incluir `save_version`;
- tratar arquivo ausente, inválido ou de versão desconhecida;
- salvar de forma atômica quando possível (arquivo temporário seguido de substituição);
- testar save/load depois de o formato do modelo estabilizar.

---

# 9. Organização do julgamento: modelo testável

## 9.1 Usar fatos/afirmações, não só uma soma cega

Cada peça de prova deve sustentar ou contradizer **afirmações narrativas**. Exemplos de `fact_id`:

- `fact_suspect_was_present`
- `fact_window_was_used`
- `fact_time_of_death_window`
- `fact_alibi_is_verified`
- `fact_weapon_belongs_to_suspect`

Uma evidência pode sustentar um ou mais fatos. Uma gravação pode sustentar o mesmo fato que uma prova física. O avaliador primeiro determina quais fatos são sustentados por material anexado e confiável; depois aplica as regras específicas do caso para cada suspeito. Isso é mais fácil de explicar e balancear do que somar todos os itens por igual.

## 9.2 Esqueleto do cálculo

1. Validar que suspeito, evidências e gravações existem no caso.
2. Considerar somente itens anexados no dossiê.
3. Converter itens anexados em fatos sustentados/contraditos considerando sua confiabilidade.
4. Agrupar evidências redundantes por fato para evitar duplicar peso.
5. Obter fatos pró-acusação, fatos contra a acusação e fatos críticos ausentes.
6. Avaliar as condições específicas de decisão do caso.
7. Criar resultado narrativo e lista de explicações.
8. Retornar estrutura pura sem manipular nós ou UI.

O avaliador deve ser determinístico: mesmos dados de caso + mesmo dossiê = mesmo resultado.

## 9.3 Justiça percebida

O jogo pode permitir um resultado injusto porque isso é parte do tema, mas precisa ser intencional. Para evitar que pareça arbitrário:

- todo resultado grave deve apontar quais provas o influenciaram;
- contradições importantes não podem ser invisíveis se forem usadas para punir o jogador;
- não apresentar a verdade que o jogo escondeu como se fosse óbvia desde o início;
- o relatório pode distinguir “o tribunal decidiu” de “a conclusão do investigador estava correta”;
- durante playtests, perguntar ao jogador se o resultado pareceu consequência de suas decisões ou sorte escondida.

---

# 10. Áudio, salvamento, configurações e conteúdo extra

## 10.1 Áudio (fase posterior)

Mesmo sem som final, reservar pontos de integração. Quando o loop estiver validado:
- música ambiente em investigação, música/ambiente diferenciado no julgamento;
- efeitos discretos de interação, coleta e transição;
- controle de volume master/música/efeitos;
- evitar sons repetidos ao reabrir o mesmo painel;
- não deixar o áudio ser a única forma de comunicar descoberta importante.

## 10.2 Salvamento (fase posterior)

Primeiro implementar salvar configurações e marcar casos concluídos. Saves de investigações no meio da cena só entram quando o projeto decidir se o jogador pode fechar o jogo antes de submeter o dossiê. Se sim, persistir IDs examinados, evidências coletadas, tópicos perguntados, registros de entrevista e posição/área do jogador. Não serializar a cena inteira.

## 10.3 Localização

Deixar textos em arquivos de dados sempre que prático, sem espalhar strings em scripts. O protótipo pode estar em português; os nomes do jogo e IDs técnicos ficam em inglês. Se houver localização para Steam, não concatenar frases de forma que não possam ser traduzidas e reservar espaço para textos maiores.

---

# 11. Polimento e otimização específicos da Godot 4

Em um cenário de investigação com poucos personagens e objetos, o maior risco não é o desempenho bruto: é criar dependências frágeis e estado inconsistente.

## 11.1 Boas práticas técnicas

- Preferir cenas pequenas e reutilizáveis com responsabilidades coesas.
- Instanciar recursos ou cenas conforme necessário; evitar carregar o catálogo inteiro de todos os casos se houver muitos casos no futuro.
- Não usar `_process()` para lógica que pode ser acionada por evento. Atualizar caderno, prompt e contadores quando o dado mudar.
- Usar `_physics_process()` para movimento e lógica ligada à física; não confiar em taxa de frames para regras narrativas.
- Configurar collision layers/masks de maneira explícita. Personagem, cenário sólido e áreas de interação não devem colidir por acidente.
- Evitar polling excessivo de cada objeto para descobrir se está no alcance do jogador; centralizar a detecção ou usar sinais de entrada/saída de áreas.
- Limpar conexões e referências a nós ao trocar de cena; a sessão não deve manter referências a UI eliminada.
- Evitar atualizações frequentes de textos completos e listas inteiras quando somente um item mudou.
- Manter a UI em `CanvasLayer` ou estrutura equivalente para que a câmera não mova os painéis.
- Usar placeholders simples antes de shaders e efeitos visuais.

## 11.2 Performance a observar

- O FPS permanece estável em uma cena com dezenas de objetos interativos e três NPCs simplificados.
- Não há travamento perceptível ao abrir o caderno ou montar o dossiê.
- Troca de cena não acumula instâncias duplicadas nem handlers de input.
- A UI não processa input de gameplay por baixo de um modal.

Não otimizar prematuramente com pooling ou sistemas complexos de gerenciamento de memória: para a vertical slice, simplicidade e previsibilidade são mais importantes.

## 11.3 Depuração

Criar ferramentas de desenvolvimento:
- overlay com nome da cena, fase de jogo, ID do caso e estado da sessão;
- modo de mostrar IDs de evidências e interações;
- log de perguntas e fatos revelados;
- botão de teste para reiniciar a investigação;
- comando de debug para adicionar uma evidência (não disponível na build normal);
- relatório do avaliador com fatos considerados e razões para o resultado.

Usar um relatório interno de avaliação para depurar, mas jamais mostrar IDs secretos ou solução do caso ao jogador antes do resultado final.

---

# 12. Plano de testes

## 12.1 Testes unitários prioritários

1. `CaseSession.register_evidence()` não aceita IDs duplicados.
2. `CaseSession` não aceita evidência que não pertence ao caso.
3. Registros de entrevistas ficam associados ao suspeito correto.
4. Tópicos bloqueados não aparecem até o requisito ser cumprido.
5. `DossierValidator` rejeita IDs inexistentes, duplicados ou pertencentes a outro caso.
6. Provas recolhidas, mas não anexadas, não afetam o julgamento.
7. Mesmo dossiê sempre produz o mesmo veredito.
8. Culpado acusado com prova insuficiente não é condenado automaticamente.
9. Suspeito inocente pode ser acusado e o jogo mostra resultado coerente.
10. Reiniciar a sessão limpa descobertas, gravações e submissão anterior.

## 12.2 Testes de fluxo manual

- Iniciar caso, ler briefing, entrar no cenário.
- Investigar sem registrar nada e sair.
- Registrar uma evidência, fechar/abrir o caderno e confirmar persistência.
- Entrevistar pessoa, fechar o painel, abrir gravação no caderno.
- Encontrar pista, desbloquear follow-up e ver a gravação atualizada.
- Acusar cada um dos suspeitos.
- Enviar dossiê sem provas.
- Anexar uma prova relevante e deixar outra fora.
- Cancelar montagem e confirmar que escolhas não foram perdidas.
- Submeter; verificar fade e relatório.
- Reiniciar o caso e garantir que o estado não vazou.
- Redimensionar a janela para 1280×720 e uma resolução menor.

## 12.3 Checklist para cada pull request/marco

- [ ] Projeto abre na versão de Godot fixada.
- [ ] Não há erros de parser ou referências quebradas.
- [ ] A fase completa ainda pode ser percorrida.
- [ ] O estado não depende de ordem de carregamento.
- [ ] A lógica de julgamento tem testes ou casos manuais documentados.
- [ ] Não foram introduzidos assets finais prematuramente.
- [ ] README/CHANGELOG atualizados se comandos ou estrutura mudaram.

---

# 13. Cronograma por marcos

A duração depende da experiência do desenvolvedor e do desempenho do agente; os marcos são mais importantes que datas fixas.

| Marco | Entrega | Definição de pronto |
|---|---|---|
| M0 | Projeto executável + Git | Menu e cena de teste abrem sem erro |
| M1 | Movimento + interação | Andar e interagir funciona com placeholders |
| M2 | Exame + evidências | Provas aparecem no caderno sem duplicatas |
| M3 | Entrevistas + gravações | 3 personagens e tópicos registráveis funcionam |
| M4 | Saída + montagem de dossiê | Jogador escolhe suspeito, evidências e gravações |
| M5 | Julgamento determinístico | Resultado explica a força/fraqueza do dossiê |
| M6 | Caso vertical slice completo | Um caso pode ser jogado do começo ao fim |
| M7 | Playtests e correções | Problemas de compreensão/bloqueadores resolvidos |
| M8 | Preparação técnica de conteúdo | Caso definido por dados, sem lógica hardcoded desnecessária |
| M9 | Arte e som exploratórios | Direção visual testada sem refazer sistemas centrais |
| M10 | Preparação Steam (posterior) | Exportações, opções, builds de teste e checklist de loja |

**Não avançar para M9 enquanto M6–M7 não demonstrarem que o loop é interessante e compreensível.**

---

# 14. Roteiro de tarefas para o OpenCode + DeepSeek V4.1 Flash

## 14.1 Modo de trabalho recomendado

O agente deve executar **uma tarefa pequena por vez**, abrir/validar o projeto quando houver ferramentas disponíveis, e resumir arquivos alterados, teste executado, resultado e próximos passos. Não pedir ao agente para construir o jogo inteiro a partir deste documento em uma única chamada.

Sempre incluir a instrução para ele ler este plano e `README.md` antes de editar. Se o ambiente do OpenCode tiver acesso à linha de comando, solicitar que valide o projeto com o executável da Godot instalado; **não afirmar que executou o jogo ou testes se não teve essa capacidade**.

## 14.2 Prompt inicial: auditar e preparar

```text
Leia PLANO_DESENVOLVIMENTO_THE_LAST_ALIBI.md por inteiro antes de implementar.
Você é o engenheiro principal de um protótipo investigativo 2D feito em Godot 4 + GDScript.
Não implemente todas as fases de uma vez.

Tarefa atual: executar apenas a Fase 0.
1. Inspecione o estado atual do repositório antes de criar/editar arquivos.
2. Informe brevemente o que já existe e o que falta.
3. Fixe a versão Godot esperada no README; não mude a versão sem uma razão concreta.
4. Crie a estrutura mínima necessária, Main, menu com Start Case/Quit, cena de teste e o overlay de debug básico.
5. Use GDScript tipado quando fizer sentido e evite abstrações vazias.
6. Se precisar criar Autoloads, implemente somente GameState e SceneRouter se realmente necessários para o marco.
7. Valide sintaxe/execução com as ferramentas disponíveis. Não declare testes que não executou.
8. Termine com: arquivos alterados, testes executados e resultados, limitações conhecidas e uma tarefa recomendada seguinte.
Não crie arte final, som final, campanha longa ou mecânicas fora da Fase 0.
```

## 14.3 Prompt para cada fase subsequente

```text
Leia PLANO_DESENVOLVIMENTO_THE_LAST_ALIBI.md e o README.md.
Implemente SOMENTE a Fase [N]: [NOME DA FASE], seguindo tarefas e critérios de aceite.
Antes de alterar qualquer coisa, inspecione os arquivos existentes e respeite os sistemas que já funcionam.

Restrições:
- Não reescreva sistemas estáveis sem necessidade demonstrada.
- Não implemente fases futuras por conveniência.
- Prefira mudanças pequenas e locais; não crie abstrações sem consumidor real.
- Separe dados do caso da lógica e da UI.
- Use IDs estáveis; não use nomes visuais como identificadores.
- Conecte sinais em pontos claros e mantenha dependências desacopladas.
- Atualize testes/checklists e documentação quando necessário.
- Execute as validações disponíveis e reporte honestamente qualquer validação que não conseguiu fazer.

Conclua com: resumo, arquivos alterados, testes executados com resultado, critérios de aceite atendidos/não atendidos, bugs conhecidos e próximo passo sugerido. Pare ao concluir esta fase.
```

## 14.4 Prompt de revisão/refatoração após um marco

```text
Faça uma revisão técnica do marco atual de The Last Alibi, sem adicionar funcionalidades novas.
Procure especialmente:
- erros de parser, referências nulas e sinais conectados mais de uma vez;
- dados de caso acoplados à UI;
- estados globais que deveriam pertencer a CaseSession;
- uso de nomes visuais em vez de IDs;
- evidências coletadas que influenciam julgamento sem serem anexadas;
- resultados não determinísticos;
- duplicação de lógica ou dependências de caminhos de nós frágeis;
- telas modais que não devolvem foco/controle ao jogo;
- requisitos de aceitação que ainda não estão cobertos por teste.
Corrija apenas problemas reais e de baixo risco. Não refaça o projeto inteiro por preferência estilística. Execute as validações disponíveis e liste qualquer problema que permanecer.
```

## 14.5 Regras de proteção contra alucinação do agente

- Se um script, cena, ferramenta ou API não existe no projeto, inspecionar antes de assumir.
- Não inventar resultado de execução. Separar “analisado estaticamente” de “executado/testado”.
- Não criar arquivos com muitos métodos vazios para parecer que a arquitetura está pronta.
- Quando precisar decidir entre várias opções, escolher a solução mais simples que mantém o próximo marco possível e registrar a decisão.
- Não trocar recursos `.tres` por JSON ou o contrário em larga escala sem uma necessidade concreta.
- Não apagar dados de caso ou testes durante refatoração.
- Não adicionar plugins externos à Godot sem justificar a necessidade e o custo.
- Se encontrar um defeito fora da fase atual, registrar e corrigir só se bloquear a fase atual ou causar corrupção de estado.

---

# 15. Riscos principais e mitigação

| Risco | Por que importa | Mitigação |
|---|---|---|
| O jogador não entende o que investigar | O jogo vira andar e clicar sem dedução | Briefing claro, prompts e relações dedutivas legíveis; playtest sem ajuda |
| Resultado parece aleatório | Destrói confiança no julgamento | Avaliador determinístico, fatores explicados e relatório de debug |
| Pistas essenciais são fáceis de perder | Jogador chega ao fim sem chance razoável | Mais de um caminho para fatos fundamentais quando possível; possibilidade de sair cedo permanece intencional |
| Diálogos ficam difíceis de editar | Conteúdo narrativo muda muito durante testes | Recursos/dados separados do código da UI |
| Arquitetura exagerada para uma demo | Desenvolvimento lento sem validar diversão | Implementar apenas a abstração que tem um consumidor real |
| Arte prematura esconde problemas | Mudanças de gameplay ficam caras | Graybox completo antes da arte final |
| Dossiê não distingue descoberta de apresentação | As decisões parecem sem consequência | Estados explícitos: examinado, registrado, anexado, avaliado |
| Condenação injusta irrita em vez de envolver | Perda de confiança no sistema | Fazer a injustiça ser compreensível, rara e narrativamente intencional |
| Escopo de narrativa explode | Muitos casos aumentam o custo de conteúdo | Validar um único caso com começo, meio e fim antes de expandir |

---

# 16. O que significa “validar que é divertido”

Não considerar o projeto validado só porque compila ou porque existe uma cena de investigação. A validação exige observar jogadores reais.

Perguntas pós-teste:

1. Você entendeu o que a polícia já sabia e o que ainda precisava descobrir?
2. Qual foi a primeira pista que mudou sua hipótese?
3. Você entendeu por que algumas provas tinham mais valor do que outras?
4. Você sabia que podia encerrar a investigação mesmo sem descobrir tudo?
5. O processo de montar o dossiê fez você reconsiderar sua acusação?
6. O julgamento pareceu consequência de suas escolhas?
7. Em que momento ficou entediado, confuso ou frustrado?
8. Você teria vontade de investigar outro caso com a mesma estrutura?

Sinais positivos:
- o jogador formula hipóteses em voz alta;
- volta ao caderno para comparar informações sem ser instruído;
- percebe uma contradição e busca uma entrevista de seguimento;
- hesita antes de anexar uma evidência ao dossiê;
- questiona o resultado, mas consegue relacioná-lo às provas que apresentou;
- pede para jogar outra vez ou investigar um caso novo.

Sinais negativos:
- clica em tudo sem ler;
- não entende por que uma conversa foi gravada;
- escolhe provas aleatoriamente;
- o julgamento parece um texto sem relação com a exploração;
- não consegue explicar de onde tirou sua conclusão.

---

# 17. Decisões em aberto para depois do MVP

Não decidir agora, a menos que o playtest exija:

- se a campanha tem casos independentes, uma conspiração maior ou ambos;
- se o jogador escolhe perguntas livremente ou se há um sistema de pressão/credibilidade;
- se cada caso tem um número fixo de suspeitos ou uma lista variável;
- se as consequências de uma acusação errada persistem entre casos;
- se o jogador pode comparar gravações lado a lado;
- se existem finais de campanha que dependem de erros anteriores;
- se há mecânicas de RPG explícitas (atributos, perícias, reputação) ou se a progressão vem principalmente de conhecimento do jogador;
- se o personagem pode interrogar formalmente em outro cenário, pedir mandados ou enviar provas para análise;
- qual será a direção visual, tipografia, retratos, animação e identidade sonora;
- quais opções específicas de acessibilidade e Steam serão obrigatórias para o lançamento.

Reavaliar essas decisões depois que a primeira vertical slice tiver sido testada, não antes.

---

# 18. Definição de pronto do protótipo

A versão de validação pode ser considerada pronta para playtest público pequeno quando:

- [ ] o caso pode ser iniciado, investigado, encerrado e julgado sem reiniciar a aplicação;
- [ ] movimento, interação, exame, entrevista, caderno e montagem do dossiê funcionam;
- [ ] existem 3 suspeitos, pelo menos 6 evidências registráveis e gravações selecionáveis;
- [ ] o jogador pode acusar qualquer suspeito;
- [ ] o resultado é determinístico e baseado apenas nos dados pertinentes ao dossiê submetido;
- [ ] a tela de julgamento explica as razões principais da decisão;
- [ ] as ações principais podem ser executadas pelo teclado;
- [ ] reiniciar não mantém estado da tentativa anterior;
- [ ] não há bugs conhecidos que bloqueiem a investigação;
- [ ] um mínimo de 3 pessoas externas testou a versão e suas observações foram registradas;
- [ ] existe uma decisão explícita de continuar, ajustar a mecânica ou abandonar o conceito com base nos resultados.

## Regra final de produção

**Primeiro provar a investigação; depois construir a apresentação.**

O primeiro objetivo não é criar uma cidade bonita ou escrever cinco casos. É fazer uma pessoa explorar um apartamento cinza, falar com três personagens, notar uma contradição, escolher as provas que considera relevantes, montar uma acusação e sentir que o julgamento foi consequência das decisões que tomou.

Quando esse ciclo funcionar de forma consistente e continuar interessante numa segunda tentativa, o projeto estará pronto para receber arte, som e mais conteúdo.
