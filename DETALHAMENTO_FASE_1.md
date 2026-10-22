# DETALHAMENTO_FASE_1.md — Controle Side-Scroller e Interação por Proximidade

> **Projeto:** The Last Alibi  
> **Fase:** M1 — Movimento + interação  
> **Engine:** Godot 4.7.2 stable  
> **Definição de pronto:** andar e interagir funciona com placeholders

---

## 1. Decisões a serem tomadas (início do detalhamento)

Antes de implementar, as seguintes decisões de design/técnica precisam estar definidas. Elas impactam diretamente a Fase 1 e fases posteriores:

| Decisão | Opção A | Opção B | Recomendação | Motivo |
|---------|---------|---------|--------------|--------|
| **Detecção de proximidade** | Distância euclidiana simples no scanner | `Area2D` com sobreposição (signals `body_entered`/`body_exited`) | **Opção A** (distância) | Mais previsível e determinístico; evita problemas de ordem de sinais do `Area2D` (armadilha do plano) |
| **Escolha do alvo ativo** | Candidato mais próximo, desempate por ID lexicográfico | Candidato mais próximo, desempate por ordem de árvore/carregamento | **Mais próximo + desempate por ID** | Determinístico, independente de ordem de carregamento (plano, seção 4.4/6.1) |
| **Movimento** | Deslizamento lateral puro (sem gravidade/plataforma) | Movimento com gravidade e chão | **Deslizamento lateral puro** | MVP não precisa de plataforma; evitar precisão de plataforma que distraia (plano, seção 6.4) |
| **Interação duplicada** | Debounce com cooldown de ~0.2s | One-shot por pressionamento (`InputEventKey` pressionado, não `_process`) | **One-shot por evento de pressionamento** | Garante que pressionar uma única vez não dispara duas interações (critério de aceite) |
| **Prompt de interação** | Texto estático "[E] Interagir" | Texto dinâmico por tipo ("[E] Examinar", "[E] Entrevistar", "[E] Sair") | **Texto dinâmico por tipo** | Mais claro para o jogador; cada interagível expõe seu `interaction_label` |
| **Identificador de depuração** | Sempre visível sobre objetos interativos | Visível apenas com tecla de debug (overlay global) | **Sempre visível no MVP** | Ajuda testes iniciais; pode ser escondido depois por tecla (plano, seção 6.1 item 9) |
| **Objetos que saem de cena** | Scanner remove automaticamente da lista | Scanner ignora se nó foi `queue_free()` | **Scanner remove automaticamente** | Evita referência inválida quando objeto sai de cena (critério de aceite) |
| **Alcance de interação** | Raio fixo (ex: 90 px) | Raio configurável por tipo de objeto | **Raio fixo no scanner** | Simples para o MVP; configurável por tipo pode vir depois |

---

## 2. Visão geral da fase

**Objetivo:** Fazer o jogador sentir o personagem andando e interagindo com objetos numa cena sem arte.

A Fase 1 estabelece a base física de exploração do jogo: o investigador se move lateralmente, detecta objetos/NPCs próximos, exibe um prompt contextual e executa a interação quando o jogador pressiona a tecla. Tudo com placeholders (caixas coloridas) — sem arte final.

---

## 3. Por que cada ponto importa

### 3.1 Investigator.tscn (CharacterBody2D + script)
**Por que:** O personagem é a interface do jogador com o mundo. Sem movimento, não há exploração. Usar `CharacterBody2D` (não `RigidBody2D` ou `KinematicBody2D`) dá controle direto sobre posição/velocidade, ideal para investigação sem física complexa.  
**Risco se não fizer:** Sem personagem controlável, não há como testar interação nem avançar para as fases seguintes.

### 3.2 Movimento horizontal com `Input.get_axis`
**Por que:** `get_axis("move_left", "move_right")` combina teclas (A/D e setas) num único valor entre -1 e 1, simplificando input de teclado e futuro suporte a controle.  
**Risco se não fazer:** Input fragmentado por tecla dificulta adicionar suporte a controle depois e torna o controle menos responsivo.

### 3.3 Colisão simples com chão e obstáculos
**Por que:** Impede o personagem de atravessar cenários e estabelece limites de exploração. No MVP, é um plano lateral sem plataformas — colisão é retangular e simples.  
**Risco se não fazer:** Personagem sai da cena ou atravessa paredes, quebrando a imersão e os testes de interação.

### 3.4 InspectableObject.tscn e SuspectNPC.tscn com áreas de proximidade
**Por que:** São os dois tipos de interação do MVP: examinar objetos e entrevistar pessoas. Ambos herdam de `Interactable` (área de proximidade + signal `interaction_requested`).  
**Risco se não fazer:** Sem objetos interativos, o jogador não tem nada para investigar; sem NPCs, não há entrevistas (Fase 3).

### 3.5 Estratégia de alvo ativo (mais próximo, desempate determinístico)
**Por que:** Quando vários objetos estão próximos, o jogo precisa escolher qual interação exibir. Escolher o mais próximo é intuitivo; desempate por ID (não por ordem de carregamento) torna o comportamento previsível e testável.  
**Risco se não fazer:** Se usar ordem de `Area2D`/sinais, o alvo ativo depende da ordem em que os nós foram carregados — comportamento não determinístico (armadilha do plano).

### 3.6 Prompt de interação
**Por que:** O jogador precisa saber que pode interagir e com o quê. O prompt "[E] Examinar vidro" ou "[E] Entrevistar Mara" comunica isso claramente.  
**Risco se não fazer:** O jogador não sabe interagir, fica perdido e abandona o caso.

### 3.7 Interação via signal do objeto ativo
**Por que:** O objeto emite `interaction_requested(interactable_id)`; o scanner/controlador decide o que fazer com isso. Isso desacopla a UI da lógica do objeto — o objeto não abre telas globais diretamente.  
**Risco se não fazer:** Se cada objeto abrir sua própria UI, há cópias independentes do mesmo painel e acoplamento fraco (armadilha do plano).

### 3.8 Câmera que acompanha o jogador
**Por que:** Side-scroller, a câmera segue o investigador para que ele permaneça visível enquanto explora áreas conectadas.  
**Risco se não fazer:** O jogador sai da tela e não consegue explorar o cenário.

### 3.9 Identificador de depuração sobre objetos interativos
**Por que:** Durante desenvolvimento, ver o ID do objeto sobre ele confirma que o scanner está detectando o alvo correto.  
**Risco se não fazer:** Difícil depurar por que certo objeto está (ou não está) sendo selecionado como ativo.

---

## 4. Critérios de aceite (Fase 1)

- [ ] O jogador anda nos dois sentidos e não atravessa o piso.
- [ ] Prompt aparece e desaparece corretamente ao aproximar/afastar.
- [ ] Se dois objetos estiverem próximos, a interação selecionada é clara e previsível.
- [ ] Pressionar a tecla de interação uma única vez não dispara duas interações.
- [ ] Não há referência inválida quando um objeto sai de cena.
- [ ] Câmera acompanha o jogador sem recortes abruptos.

---

## 5. Arquitetura e fluxo de dados

```
Input (tecla E) → InteractionScanner.detecta alvo ativo
                                       ↓
                    InteractionPrompt exibe "[E] Ação"
                                       ↓
                    InvestigatorController.on_interact_pressed()
                                       ↓
                    Interactable.request_interaction()
                                       ↓
                    signal interaction_requested(interactable_id)
                                       ↓
                    InvestigationController trata por tipo:
                    - InspectableObject → examine_requested
                    - SuspectNPC → interview_requested
                    - ExitPoint → exit_requested
```

**Responsabilidades por nó:**
- `InvestigatorController`: movimento e input do jogador.
- `InteractionScanner`: descobre interações próximas e escolhe o alvo ativo.
- `Interactable` (classe base): área de proximidade, signal `interaction_requested`.
- `InspectableObject` / `SuspectNPC` / `ExitPoint`: tipos concretos de interação.
- `InteractionPrompt` (UI): exibe/esconde o texto contextual.
- `InvestigationController`: orquestra a cena e conecta sinais.

---

## 6. Implementação ponto a ponto (checklist)

### 6.1 Investigator.tscn
- [ ] Nó raiz: `CharacterBody2D` com script `investigator_controller.gd` (`class_name InvestigatorController`)
- [ ] `CollisionShape2D` com forma (círculo ou retângulo pequeno)
- [ ] `PlaceholderVisual` (`ColorRect` azul, 24×32)
- @export `move_speed: float = 220.0`
- @export `interaction_range: float = 90.0` (ou no scanner)
- `_physics_process(delta)`: lê `Input.get_axis("move_left", "move_right")`, define `velocity.x`, chama `move_and_slide()`

### 6.2 Interactable (base)
- [ ] Nó raiz: `Area2D` com script `interactable.gd` (`class_name Interactable`)
- [ ] `CollisionShape2D` (área de detecção de proximidade)
- @export `interactable_id: StringName`
- @export `interaction_label: String`
- @export `is_interactable: bool = true`
- signal `interaction_requested(interactable_id: StringName)`
- `request_interaction()` emite o signal se `is_interactable`

### 6.3 InspectableObject
- [ ] Herda de `Interactable`, script `inspectable_object.gd`
- [ ] `PlaceholderVisual` (cor diferente, ex: laranja)
- @export `evidence_id: StringName`, `object_title`, `description_found`, `examination_prompt`
- Conecta `interaction_requested` → emite `examine_requested(evidence_id, title, description)`

### 6.4 SuspectNPC
- [ ] Herda de `Interactable` (ou `CharacterBody2D` se precisar de movimento futuro), script `suspect_npc.gd`
- [ ] `PlaceholderVisual` (cor diferente, ex: vermelho)
- @export `suspect_id: StringName`, `display_name`
- Conecta `interaction_requested` → emite `interview_requested(suspect_id, display_name)`

### 6.5 ExitPoint
- [ ] Herda de `Interactable`, script `exit_point.gd`
- [ ] `PlaceholderVisual` (verde)
- signal `exit_requested`

### 6.6 InteractionScanner
- [ ] Nó `Node` (não `Node2D`) na cena de investigação
- @export `player_node: Node2D`, `interaction_range: float`
- `nearby_interactables: Array[Interactable]` (registrados via `register_interactable`)
- `_physics_process`: atualiza lista por distância, escolhe melhor alvo
- signal `interaction_target_changed(target_id)`, `interaction_target_lost`
- Desempate determinístico por `interactable_id`

### 6.7 HUD + InteractionPrompt
- [ ] `InteractionPrompt` (`Control`, invisível por padrão)
- [ ] `PromptLabel` (`Label`) com texto "[E] {interaction_label}"
- `show_prompt(target_id)` / `hide_prompt()`
- Posicionado próximo ao jogador ou fixo na tela

### 6.8 Câmera
- [ ] `Camera2D` como filha da cena de investigação, `current = true`
- Acompanha o investigador (via `follow` ou script simples)

### 6.9 Debug ID
- [ ] `Label` sobre cada interagível mostrando `interactable_id`
- [ ] Visível no MVP (esconder por tecla depois)

---

## 7. Armadilhas e como evitar

| Armadilha | Como evitar na Fase 1 |
|-----------|----------------------|
| Usar ordem de sinais de `Area2D` como critério implícito | Usar distância + desempate por ID no `InteractionScanner` |
| Interagir através de paredes ou em alcance excessivo | Raio fixo de proximidade; sem raycast contra paredes no MVP (adiar) |
| UI de diálogo como filha de cada objeto | UI centralizada no HUD/ModalLayer; objetos apenas emitem signals |
| Pressionar E uma vez dispara duas interações | One-shot por `InputEventKey.pressed`, não polling em `_process` |
| Referência inválida quando objeto sai de cena | `unregister_interactable` no `exit_tree()` do objeto; scanner limpa nulos |
| Misturar movimento com gravidade sem motivo | Deslizamento lateral puro no MVP; sem `velocity.y` gravidade |

---

## 8. Próximos passos após a Fase 1

1. Validar critérios de aceite com jogada manual.
2. Avançar para Fase 2 (Exame + evidências): criar `EvidenceDefinition`, painel de exame, `NotebookScreen`, `EvidenceService`.
3. Avançar para Fase 3 (Entrevistas): painel de entrevista, `InterviewService`, `InterviewRecord`.

---

## 9. Arquivos envolvidos (Fase 1)

```
scenes/investigation/player/investigator.tscn
scripts/player/investigator_controller.gd
scripts/player/interaction_scanner.gd
scripts/interactables/interactable.gd
scripts/interactables/inspectable_object.gd
scripts/interactables/suspect_npc.gd
scripts/interactables/exit_point.gd
scenes/investigation/interactables/*.tscn
scenes/ui/hud.tscn
scripts/ui/interaction_prompt.gd
scenes/investigation/investigation_level.tscn (câmera + scanner + HUD)
scripts/investigation/investigation_controller.gd
```

---

**Status:** Pronto para implementação. Nenhuma decisão bloqueia o início; todas as opções acima têm recomendação com justificativa.
