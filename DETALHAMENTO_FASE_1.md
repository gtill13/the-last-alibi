# DETALHAMENTO_FASE_1.md — Movimento lateral, câmera e interação por proximidade

> **Projeto:** The Last Alibi  
> **Marco:** M1 — Movimento + interação  
> **Engine-alvo:** Godot 4.x com GDScript 2.0  
> **Versão de referência do projeto:** Godot 4.7.2, caso essa seja a versão fixada no repositório  
> **Objetivo:** validar a exploração e a interação usando placeholders, sem arte ou áudio finais  
> **Status:** revisado para implementação

---

## 0. Resumo da revisão

O detalhamento original tem um bom recorte de escopo, mas havia pontos ambíguos que poderiam gerar código inconsistente ou retrabalho:

1. **Detecção de proximidade contraditória:** a decisão recomendava calcular distâncias, mas os objetos eram descritos como áreas `Area2D` e não estava claro como o scanner receberia/registraria candidatos. Nesta revisão, `Area2D` é usado para descobrir candidatos; a escolha do alvo é feita separadamente por distância e ID, nunca pela ordem dos sinais.
2. **Sinais redundantes:** o objeto base emitia um sinal e cada classe concreta deveria escutá-lo para emitir outro. Isso adiciona etapas sem benefício para o MVP. Nesta revisão, o `InteractionScanner` emite um único sinal tipado com o alvo selecionado; o `InvestigationController` decide a ação.
3. **Sinal com ID somente:** enviar apenas `interactable_id` obriga o controlador a procurar o nó novamente e torna IDs duplicados mais perigosos. O sinal passa a transportar a referência tipada `Interactable`.
4. **Input acoplado a uma tecla física:** o evento usa a ação `interact` do `InputMap`, para permitir remapeamento e expansão futura para controle. `InputEvent.is_action_pressed("interact")` já ignora repetição de tecla por padrão.
5. **Câmera:** `Camera2D` não possui um método genérico chamado `follow`; a forma mais simples para este marco é torná-la filha do jogador. Em Godot 4, use `enabled`/`make_current()`, não `current = true`.
6. **Placeholder no mundo:** recomenda-se `Polygon2D` ou `Sprite2D` para representar o jogador e os objetos do mundo. `ColorRect` é um `Control` pensado para UI e pode produzir resultados confusos quando usado como visual de mundo.
7. **Objetos liberados:** não confiar apenas em `area_exited` ou em `unregister_interactable()` manual. O scanner limpa referências inválidas antes de escolher/interagir; isso protege contra `queue_free()` e mudanças na árvore.

**Decisão de escopo:** esta fase valida caminhada horizontal em uma cena lateral simples, sem salto, gravidade ou plataformas. Também não implementa ainda exame de evidências, diálogo real, gravações, caderno, salvamento ou julgamento. A interação deve produzir apenas feedback de depuração demonstrável.

---

## 1. Objetivo e definição de pronto

Ao final desta fase, deve existir uma cena de teste que permita:

- controlar o investigador para a esquerda e para a direita;
- manter o personagem dentro da área física do cenário, sem atravessar o piso ou paredes sólidas;
- seguir o personagem com a câmera numa área maior que a viewport;
- detectar objetos e suspeitos que estejam ao alcance;
- selecionar sempre o alvo mais próximo; em empate exato de distância, usar `interactable_id` em ordem lexicográfica;
- apresentar um prompt contextual, por exemplo `[E] Examinar — Vidro quebrado` ou `[E] Entrevistar — Mara`;
- solicitar exatamente uma interação por pressionamento, sem repetição causada por key echo;
- encaminhar o alvo para o controlador central, que mostra um resultado temporário de depuração;
- remover o prompt e limpar o alvo quando não houver candidato válido.

### Fora de escopo nesta fase

- sistema de evidências persistentes;
- conteúdo completo de entrevistas ou gravações;
- árvore de diálogo;
- resolução de crimes e julgamentos;
- inventário/caderno;
- menu principal e fluxo completo de cenas;
- suporte final a controle, acessibilidade ou remapeamento de teclas — apenas não bloquear essa evolução;
- arte, animação, música ou efeitos sonoros finais.

---

## 2. Decisões técnicas fixadas

| Área | Decisão para M1 | Motivo |
|---|---|---|
| Movimento | `CharacterBody2D`, caminhada horizontal | Controle explícito e colisão previsível sem física de plataforma desnecessária |
| Física | `move_and_slide()` em `_physics_process()` | Movimento independente da taxa de renderização e integrado ao sistema de colisões |
| Input | `InputMap`: `move_left`, `move_right`, `interact` | Não codificar a tecla E diretamente nos scripts |
| Descoberta de candidatos | `InteractionScanner` como `Area2D`; alvos como `Interactable` (`Area2D`) | Usa sinais de sobreposição para manter uma lista pequena de candidatos |
| Escolha do alvo | menor distância quadrada entre origem do scanner e `global_position` do alvo; ID como desempate | A ordem de chegada de sinais não determina o alvo |
| Alcance | `CircleShape2D` do scanner com raio inicial de 90 px; alvo validado também por distância ao pivô | Evita que uma área de interação grande selecione um alvo cujo pivô está fora do alcance |
| Entrada de interação | `InvestigatorController` recebe evento não tratado e chama o scanner | UI/modal futuro pode consumir input antes da interação no mundo |
| Evento de interação | um único sinal `interaction_requested(target: Interactable)` emitido pelo scanner | O controlador recebe diretamente o nó e seus dados tipados |
| Prompt | `Control` dentro de um `CanvasLayer` | Mantém a interface fixa na tela enquanto a câmera se move |
| Câmera | `Camera2D` filha de `Investigator` | Acompanha o jogador sem script de perseguição |
| Debug | ID do alvo visível durante M1 ou exibido no Output | Ajuda a verificar seleção e desempate |
| Autoloads | nenhum novo Autoload nesta fase | Evita estado global antes de existir necessidade real |

### Regra do alcance

O raio do `CircleShape2D` do nó `InteractionScanner/CollisionShape2D` é a fonte de verdade para o alcance. Ao selecionar o alvo, compare `global_position.distance_squared_to(target.global_position)` com o quadrado desse raio. Não mantenha outro `interaction_range` exportado em paralelo, pois os dois valores podem divergir.

Os centros/pivôs das cenas interativas devem ser colocados em posições representativas do local que o jogador deve alcançar. Se um objeto precisar de um ponto de interação diferente de seu centro visual, adicione depois um nó `InteractionAnchor`; não crie esse sistema adicional agora sem necessidade do protótipo.

---

## 3. Estrutura de pastas e arquivos

Criar apenas as pastas necessárias para esta fase, sem pré-criar sistemas que ainda não serão usados:

```text
res://
├── project.godot
├── scenes/
│   └── investigation/
│       ├── investigation_level.tscn
│       ├── player/
│       │   └── investigator.tscn
│       └── interactables/
│           ├── inspectable_object.tscn
│           ├── suspect_npc.tscn
│           └── exit_point.tscn
├── scripts/
│   ├── player/
│   │   ├── investigator_controller.gd
│   │   └── interaction_scanner.gd
│   ├── interactables/
│   │   ├── interactable.gd
│   │   ├── inspectable_object.gd
│   │   ├── suspect_npc.gd
│   │   └── exit_point.gd
│   ├── investigation/
│   │   └── investigation_controller.gd
│   └── ui/
│       └── interaction_prompt.gd
└── docs/
    └── M1_TESTS.md
```

Não criar ainda `EvidenceService`, `InterviewService`, `GameState`, `SaveManager`, `AudioManager` ou `SceneManager`. Se algum sistema não for usado no M1, não precisa existir apenas por antecipação.

---

## 4. Arquitetura de cenas e nós

### 4.1 `investigation_level.tscn`

```text
InvestigationLevel (Node2D)
├── World (Node2D)
│   ├── Floor (StaticBody2D)
│   │   └── CollisionShape2D
│   ├── LeftBoundary (StaticBody2D)
│   │   └── CollisionShape2D
│   ├── RightBoundary (StaticBody2D)
│   │   └── CollisionShape2D
│   └── OptionalBlockers (Node2D)
├── Interactables (Node2D)
│   ├── BrokenGlass (InspectableObject / Area2D)
│   ├── Mara (SuspectNPC / Area2D)
│   └── Exit (ExitPoint / Area2D)
├── Investigator (CharacterBody2D)
│   ├── CollisionShape2D
│   ├── PlaceholderVisual (Polygon2D)
│   ├── InteractionScanner (Area2D)
│   │   └── CollisionShape2D (CircleShape2D)
│   └── Camera2D
├── UI (CanvasLayer)
│   └── HUD (Control)
│       ├── InteractionPrompt (Control)
│       │   └── PromptLabel (Label)
│       └── DebugMessage (Label)
└── InvestigationController (Node)
```

`Camera2D` fica como filha de `Investigator`; assim a transformação do jogador também desloca a câmera. Não criar um script de follow para esse caso simples. Ative a câmera por `enabled = true` (valor padrão) e, se necessário, chame `make_current()` em `_ready()`. Configure limites da câmera com os limites do cenário; não copie `current = true` de exemplos antigos da Godot 3.

A UI fica sob `CanvasLayer`, fora da transformação espacial do jogador. O `InteractionPrompt` deve receber texto e visibilidade — não controlar movimento, seleção do alvo ou regra de investigação.

### 4.2 `investigator.tscn`

- Raiz: `CharacterBody2D`, script `investigator_controller.gd`.
- `CollisionShape2D`: `RectangleShape2D` ou `CapsuleShape2D`, aproximadamente 16–20 px de largura e 28–36 px de altura; ajustar por teste.
- `PlaceholderVisual`: `Polygon2D` com cor sólida, por exemplo azul.
- `InteractionScanner`: `Area2D` filha, com `CircleShape2D` de raio inicial 90 px.
- `Camera2D`: filha direta, habilitada; smoothing é opcional e só deve ser ligado depois de validar o acompanhamento básico.

O visual é apenas indicativo; a forma do visual não precisa ser idêntica à forma de colisão, mas devem ter dimensões visualmente próximas.

### 4.3 Cena base `Interactable`

`Interactable` será uma classe base com raiz `Area2D`. Ela representa a zona detectável de um alvo e expõe metadados. Como uma `Area2D` não é uma barreira física, objetos que precisem bloquear a movimentação deverão ter um `StaticBody2D` separado no cenário ou como filho apropriado da cena. Não depender da zona de interação para bloquear o jogador.

Campos recomendados:

```gdscript
class_name Interactable
extends Area2D

@export var interactable_id: StringName
@export var interaction_label: String = "Interagir"
@export var display_name: String = "Objeto"
@export var is_interactable: bool = true

func can_interact() -> bool:
    return (
        is_interactable
        and is_inside_tree()
        and not is_queued_for_deletion()
    )
```

Regras:

- `interactable_id` é obrigatório e único dentro da fase, por exemplo `&"evidence_broken_glass"` ou `&"suspect_mara"`.
- `interaction_label` é a ação exibida, por exemplo `Examinar`, `Entrevistar` ou `Sair`.
- `display_name` é o nome legível no prompt.
- `is_interactable` permite desativar um alvo sem removê-lo da árvore.
- Não emitir sinais redundantes em cada subclasse nesta fase.
- A cena deve ter um `CollisionShape2D` filho para a zona de interação.
- Configurar `monitorable = true` nos alvos.
- Adicionar cada raiz `Interactable` ao grupo `interactables` pelo editor; o controlador usa esse grupo para validar IDs duplicados.

### 4.4 Classes concretas

`InspectableObject` herda de `Interactable` e acrescenta apenas dados do objeto:

```gdscript
class_name InspectableObject
extends Interactable

@export var evidence_id: StringName
@export_multiline var description_found: String
```

`SuspectNPC` herda de `Interactable` e acrescenta os dados mínimos da pessoa:

```gdscript
class_name SuspectNPC
extends Interactable

@export var suspect_id: StringName
```

`ExitPoint` herda de `Interactable` e não precisa de dados adicionais neste marco.

Essas classes não abrem UI, não acessam Autoloads e não implementam a lógica de exame/entrevista. Elas são identificadores tipados para que o controlador reconheça a ação. Conteúdo real pertence às fases futuras.

---

## 5. Camadas e máscaras de colisão

Definir nomes na aba **Project Settings → Layer Names → 2D Physics**. Uma configuração inicial possível:

| Camada | Nome | Usada por |
|---|---|---|
| 1 | `World` | Piso, paredes e bloqueadores físicos |
| 2 | `Player` | Corpo físico do investigador |
| 3 | `Interactable` | Áreas dos objetos, suspeitos e saída |

Configuração:

- `Investigator` (`CharacterBody2D`): `collision_layer = Player`; `collision_mask = World`.
- Corpos físicos do cenário: `collision_layer = World`.
- `InteractionScanner` (`Area2D`): `collision_layer = 0`; `collision_mask` inclui `Interactable`; `monitoring = true`.
- Cada alvo `Interactable` (`Area2D`): `collision_layer` inclui `Interactable`; `monitorable = true`.
- Os alvos não precisam monitorar outros alvos; deixe `monitoring = false` neles se não houver outra necessidade.

Verificar no editor que as máscaras correspondem à tabela: nomes de camada ajudam a entender, mas a lógica depende dos bits configurados. Se as áreas nunca se detectarem, conferir primeiro `monitoring`, `monitorable`, máscaras e se ambas têm `CollisionShape2D` habilitado.

---

## 6. InputMap

Criar em **Project Settings → Input Map**:

| Ação | Teclas iniciais |
|---|---|
| `move_left` | `A`, seta esquerda |
| `move_right` | `D`, seta direita |
| `interact` | `E` |

Os scripts devem usar os nomes das ações, não verificar diretamente `KEY_E`, `KEY_A` ou `KEY_D`. Para movimento contínuo, usar `Input.get_axis("move_left", "move_right")`. Para interação de um único pressionamento, processar o evento de ação; não chamar a interação em `_process()`.

---

## 7. Implementação passo a passo

### M1.1 — Configurar o projeto e a cena de teste

1. Confirmar a versão de Godot usada pelo projeto e abrir o projeto sem erros.
2. Criar a estrutura de pastas.
3. Criar `investigation_level.tscn`.
4. Criar um piso e limites laterais com `StaticBody2D` + `CollisionShape2D`.
5. Criar o InputMap para as três ações.
6. Definir `investigation_level.tscn` como cena principal temporária.

**Pronto quando:** o projeto inicia na cena de teste e o piso/limites estão visíveis, mesmo como retângulos simples.

### M1.2 — Implementar o movimento

Exemplo inicial de `investigator_controller.gd`:

```gdscript
class_name InvestigatorController
extends CharacterBody2D

@export_range(50.0, 500.0, 10.0) var move_speed: float = 220.0

@onready var interaction_scanner: InteractionScanner = $InteractionScanner

func _physics_process(_delta: float) -> void:
    var direction := Input.get_axis("move_left", "move_right")
    velocity.x = direction * move_speed
    # Este marco é caminhada horizontal, não um plataforma.
    velocity.y = 0.0
    move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        interaction_scanner.request_interaction_with_active_target()
        get_viewport().set_input_as_handled()
```

Notas:

- `move_and_slide()` é chamado em `_physics_process()`.
- Não multiplicar `velocity` por `delta` antes de `move_and_slide()`; o método já considera o passo de física.
- Não mover o `CharacterBody2D` alterando diretamente `position` em cada frame.
- Se um painel/modal futuro precisar capturar E, o input não tratado permite que interfaces tenham prioridade antes da interação no mundo.
- Se houver um bug de colisão vertical, confirmar que `velocity.y` não está sendo alterado por outro script.

### M1.3 — Construir o scanner de interação

`InteractionScanner` herda de `Area2D`, tem uma zona circular e mantém uma lista de alvos próximos.

Responsabilidades exclusivas:

1. receber `area_entered` e `area_exited`;
2. registrar somente áreas cujo tipo seja `Interactable`;
3. limpar referências inválidas/na fila de exclusão;
4. selecionar o melhor alvo;
5. emitir `active_target_changed(target)` quando o alvo ativo muda;
6. ao receber solicitação de interação, revalidar o alvo e emitir `interaction_requested(target)` uma única vez.

Assinaturas principais:

```gdscript
class_name InteractionScanner
extends Area2D

signal active_target_changed(target: Interactable)
signal interaction_requested(target: Interactable)

var _nearby_targets: Array[Interactable] = []
var _active_target: Interactable
```

Ligue `area_entered` a `_on_area_entered(area: Area2D)` e `area_exited` a `_on_area_exited(area: Area2D)` em `_ready()` ou pelo editor. Escolha apenas um método de conexão para não conectar o mesmo sinal duas vezes.

Lógica esperada para seleção:

```gdscript
func _refresh_active_target() -> void:
    _prune_invalid_targets()

    var best_target: Interactable = null
    var best_distance_squared := INF
    var max_range_squared := _get_circle_radius_squared()

    for target in _nearby_targets:
        if not is_instance_valid(target) or not target.can_interact():
            continue

        var distance_squared := global_position.distance_squared_to(
            target.global_position
        )

        if distance_squared > max_range_squared:
            continue

        var is_closer := distance_squared < best_distance_squared
        var is_exact_distance_tie_with_lower_id := (
            distance_squared == best_distance_squared
            and best_target != null
            and String(target.interactable_id) < String(best_target.interactable_id)
        )

        if best_target == null or is_closer or is_exact_distance_tie_with_lower_id:
            best_target = target
            best_distance_squared = distance_squared

    if best_target != _active_target:
        _active_target = best_target
        active_target_changed.emit(_active_target)
```

**Notas de implementação:** não copie o exemplo isoladamente sem implementar `_get_circle_radius_squared()` e `_prune_invalid_targets()`. `_get_circle_radius_squared()` deve ler o raio do `CircleShape2D` filho, a fonte de verdade do alcance. `_prune_invalid_targets()` deve remover referências cujo objeto não é mais válido ou está em `queue_free()`. O desempate usa igualdade exata de distância para que uma comparação aproximada não introduza um resultado dependente da ordem de visita dos candidatos.

Também implementar:

- `_on_area_entered(area: Area2D)`: converter com `area as Interactable`; adicionar se o cast for válido e o alvo ainda não estiver na lista; atualizar a seleção.
- `_on_area_exited(area: Area2D)`: remover o alvo correspondente e atualizar a seleção.
- `_physics_process(_delta)`: chamar `_refresh_active_target()` para atualizar o alvo mais próximo enquanto o jogador se movimenta entre candidatos que já estão sobrepostos.
- `_prune_invalid_targets()`: iterar de trás para frente e remover itens inválidos ou `is_queued_for_deletion()` antes de chamar métodos neles.

Implementação do pedido de interação:

```gdscript
func request_interaction_with_active_target() -> void:
    _refresh_active_target()

    if not is_instance_valid(_active_target):
        return
    if not _active_target.can_interact():
        return

    interaction_requested.emit(_active_target)
```

Este método é chamado uma vez por evento de ação, não continuamente por frame.

### M1.4 — Validar os IDs dos alvos

Na cena de teste, usar IDs exclusivos, por exemplo:

- `evidence_broken_glass`
- `suspect_mara`
- `exit_apartment`

No `_ready()` do `InvestigationController`, recolher os objetos do grupo `interactables` e validar:

- todo nó do grupo é um `Interactable`;
- todo alvo tem ID preenchido;
- não existem IDs duplicados.

Se houver duplicidade, emitir `push_error()` com o ID e o caminho dos nós conflitantes. Não depender apenas de uma convenção escrita em documentação; falhas de configuração devem ser fáceis de localizar.

### M1.5 — Ligar o prompt contextual

`InteractionPrompt` fica dentro de `UI/CanvasLayer/HUD`.

API mínima do script:

```gdscript
class_name InteractionPrompt
extends Control

@onready var prompt_label: Label = $PromptLabel

func show_for_target(target: Interactable) -> void:
    if not is_instance_valid(target):
        hide_prompt()
        return

    prompt_label.text = "[E] %s — %s" % [
        target.interaction_label,
        target.display_name
    ]
    visible = true

func hide_prompt() -> void:
    visible = false
    prompt_label.text = ""
```

O controlador da cena conecta `InteractionScanner.active_target_changed` a um handler que chama `show_for_target(target)` ou `hide_prompt()` caso `target == null`.

O prompt deve ficar oculto ao iniciar, ao sair do alcance, quando o alvo é desativado ou liberado e quando nenhum candidato elegível resta. Não posicionar o prompt alterando a posição global do `Label` do mundo; para o MVP, use uma posição fixa na HUD. Posicionar o prompt sobre o personagem pode ser uma melhoria posterior.

### M1.6 — Roteamento de interação e feedback de depuração

`InvestigationController` conecta uma única vez o sinal `InteractionScanner.interaction_requested` e faz o roteamento por tipo:

```gdscript
func _on_interaction_requested(target: Interactable) -> void:
    if not is_instance_valid(target) or not target.can_interact():
        return

    if target is InspectableObject:
        _show_debug_message(
            "Examinar: %s (%s)" % [target.display_name, target.interactable_id]
        )
    elif target is SuspectNPC:
        _show_debug_message(
            "Entrevistar: %s (%s)" % [target.display_name, target.interactable_id]
        )
    elif target is ExitPoint:
        _show_debug_message("Solicitação de saída: %s" % target.display_name)
    else:
        _show_debug_message("Interação: %s" % target.display_name)
```

`_show_debug_message()` apenas atualiza `UI/HUD/DebugMessage` e/ou imprime no Output. A ação não deve abrir ainda o painel real de exame/entrevista nem encerrar a fase. O roteamento por tipo é aceitável no MVP; quando houver muitas ações, substituir por um contrato/padrão de interação mais extensível, sem antecipar essa abstração agora.

### M1.7 — Criar os três alvos de teste

**Vidro quebrado — `InspectableObject`**
- Cor laranja.
- `interactable_id = &"evidence_broken_glass"`.
- `interaction_label = "Examinar"`.
- `display_name = "Vidro quebrado"`.
- Preencher um `evidence_id` fictício só para confirmar que a subclasse aceita dados.

**Suspeita — `SuspectNPC`**
- Cor vermelha.
- `interactable_id = &"suspect_mara"`.
- `interaction_label = "Entrevistar"`.
- `display_name = "Mara"`.
- `suspect_id = &"mara"`.

**Saída — `ExitPoint`**
- Cor verde.
- `interactable_id = &"exit_apartment"`.
- `interaction_label = "Sair"`.
- `display_name = "Apartamento"`.

Os três devem ser posicionados em distâncias diferentes. Colocar dois alvos próximos um do outro permite testar a seleção e o desempate.

### M1.8 — Câmera e limites

1. Manter `Camera2D` como filha direta do investigador.
2. Usar `enabled = true`; chamar `make_current()` em `_ready()` apenas se houver mais de uma câmera ou se a câmera não estiver ativa.
3. Configurar `limit_left`, `limit_right`, `limit_top` e `limit_bottom` de acordo com a área jogável.
4. Testar com a fase mais larga que a viewport para que o acompanhamento seja realmente exercitado.
5. Ativar suavização apenas após o acompanhamento sem suavização estar correto.

**Armadilha:** limites incorretos podem fazer a câmera parecer travada ou causar recortes. Não usar script de follow manual em paralelo com a câmera filha.

### M1.9 — Validar descarte e desativação de alvos

Antes de selecionar ou interagir, o scanner deve limpar candidatos que não sejam mais válidos ou estejam na fila de exclusão. Ao sair da área, o evento `area_exited` também deve remover o alvo da lista.

Testar estes casos:

- o alvo mais próximo é liberado com `queue_free()`;
- o alvo mais próximo é desativado com `is_interactable = false`;
- o jogador sai do alcance;
- o alvo ativo desaparece enquanto o prompt está visível;
- o alvo é reativado dentro da área.

Resultado esperado: o prompt muda para o próximo alvo elegível ou desaparece; nenhuma referência inválida aparece no Output e nenhuma interação é emitida para um alvo inválido.

---

## 8. Colisão e interação através de paredes

A seleção por proximidade, sozinha, permite que o jogador interaja com um alvo atrás de uma parede se ambos estiverem dentro do raio. Para manter o escopo M1 pequeno:

- **M1 inicial:** o cenário de teste deve ser aberto e não deve colocar alvos atrás de paredes sólidas ou obstáculos opacos;
- **bloqueadores físicos:** usar `StaticBody2D` na geometria que bloqueia a caminhada;
- **se o primeiro teste de jogabilidade já exigir interação bloqueada por linha de visão:** adicionar um `RayCast2D` ou consulta de espaço de física do scanner até o ponto de interação, filtrando apenas colisões de `World`. Não implementar isso preventivamente sem um caso real de teste.

A limitação deve ficar registrada no `docs/M1_TESTS.md`, para que a equipe não confunda comportamento ainda não implementado com bug acidental.

---

## 9. Critérios de aceite

A fase só está concluída quando todos os itens abaixo passarem em execução manual:

- [ ] O projeto inicia `investigation_level.tscn` sem erros de parse ou referências quebradas.
- [ ] O jogador move-se à esquerda e à direita usando as ações do InputMap.
- [ ] A velocidade é consistente e o movimento usa `_physics_process()` + `move_and_slide()`.
- [ ] O jogador não atravessa o piso, limites ou bloqueadores físicos configurados.
- [ ] A câmera acompanha o investigador em uma fase maior que a viewport e respeita os limites.
- [ ] Nenhum prompt aparece quando não há alvo válido.
- [ ] O prompt correto aparece ao entrar no alcance e desaparece ao sair.
- [ ] O alvo ativo é sempre o mais próximo; a ordem de `area_entered` não afeta a seleção.
- [ ] Dois alvos com distância igual escolhem o ID lexicograficamente menor.
- [ ] A ação de interação, uma vez pressionada, gera exatamente um resultado de depuração.
- [ ] Segurar E não repete a interação por key echo.
- [ ] A ação funciona quando acionada pelo InputMap e não exige verificar `KEY_E` no script.
- [ ] Um alvo desativado ou removido deixa de ser selecionável.
- [ ] Não há erro de instância inválida ao liberar um alvo com `queue_free()`.
- [ ] `InteractionPrompt` e `DebugMessage` permanecem fixos na tela enquanto a câmera se move.
- [ ] O Output não contém erros ou warnings novos introduzidos pela fase.

---

## 10. Plano de testes manual

Registrar o resultado de cada teste em `docs/M1_TESTS.md` (Passou/Falhou + observação curta).

| ID | Teste | Resultado esperado |
|---|---|---|
| T01 | Iniciar a cena | Cena inicia sem erro de script ou recurso |
| T02 | Pressionar A/D e setas | Movimento nas duas direções |
| T03 | Segurar uma direção por 5 segundos | Velocidade consistente, sem atravessar piso/limites |
| T04 | Entrar no alcance de um alvo | Prompt correto aparece |
| T05 | Sair do alcance | Prompt desaparece |
| T06 | Aproximar-se de dois alvos | O mais próximo é selecionado |
| T07 | Posicionar dois alvos com a mesma distância | O ID menor lexicograficamente vence |
| T08 | Pressionar E uma vez | Um único resultado de depuração |
| T09 | Segurar E por 2 segundos | Nenhuma repetição por key echo |
| T10 | Desativar o alvo ativo | Ele deixa de aparecer como opção |
| T11 | Executar `queue_free()` no alvo ativo | Sem referência inválida; prompt atualiza |
| T12 | Percorrer o cenário de ponta a ponta | Câmera acompanha e respeita os limites |
| T13 | Interagir ao alternar rapidamente entre alvos | O resultado corresponde ao alvo mostrado no prompt |
| T14 | Reiniciar a cena várias vezes | Sem conexões duplicadas de sinais nem erros crescentes |

---

## 11. Armadilhas técnicas a evitar

| Armadilha | Prevenção |
|---|---|
| Selecionar alvo de acordo com a ordem dos sinais de área | Usar os sinais apenas para atualizar candidatos; escolher por distância e ID |
| Manter duas fontes para o alcance | Ler o raio do `CircleShape2D` do scanner |
| Fazer `_process()` procurar todos os nós da cena continuamente | Manter lista só dos candidatos sobrepostos e recalcular apenas entre eles |
| Usar string ID como única informação do sinal | Enviar uma referência tipada `Interactable` ao controlador |
| Reemitir sinais equivalentes em cada subclasse | Um sinal de solicitação no scanner é suficiente para o MVP |
| Conectar sinais duas vezes | Conectar uma única vez, no `_ready()` ou no editor, nunca pelos dois métodos simultaneamente |
| Usar `KEY_E` no script | Criar e ler a ação `interact` do InputMap |
| Fazer o movimento depender de FPS | Mover em `_physics_process()` via `move_and_slide()` |
| Multiplicar `velocity` por `delta` antes de `move_and_slide()` | Definir velocidade em unidades por segundo; não multiplicar por `delta` |
| Usar `ColorRect` para personagem no mundo | Usar `Polygon2D` ou `Sprite2D` para o placeholder do mundo |
| Configurar câmera usando `current = true` ou API de Godot 3 | Usar `enabled` e, quando necessário, `make_current()` |
| Supor que `Area2D` bloqueia o jogador | Criar um corpo físico separado (`StaticBody2D`) para objetos que bloqueiam caminhada |
| Interagir através de paredes sem perceber | Documentar a limitação inicial ou adicionar teste de linha de visão quando o layout exigir |
| Criar Autoloads antes de haver estado global real | Manter M1 local à cena até o MVP demonstrar necessidade |

---

## 12. Arquivos esperados ao terminar

```text
scenes/investigation/investigation_level.tscn
scenes/investigation/player/investigator.tscn
scenes/investigation/interactables/inspectable_object.tscn
scenes/investigation/interactables/suspect_npc.tscn
scenes/investigation/interactables/exit_point.tscn

scripts/player/investigator_controller.gd
scripts/player/interaction_scanner.gd
scripts/interactables/interactable.gd
scripts/interactables/inspectable_object.gd
scripts/interactables/suspect_npc.gd
scripts/interactables/exit_point.gd
scripts/investigation/investigation_controller.gd
scripts/ui/interaction_prompt.gd

docs/M1_TESTS.md
```

Ajustar nomes/caminhos se o projeto existente já tiver uma convenção estabelecida; não duplicar scripts só para reproduzir esta árvore.

---

## 13. Orientação para o OpenCode / agente de código

Copiar este texto como tarefa de implementação:

> Implemente somente o M1 — movimento lateral, câmera e interação por proximidade, conforme este documento. Antes de alterar arquivos, inspecione a estrutura atual do repositório e preserve convenções já existentes. Não implemente evidências reais, entrevistas, caderno, diálogo, julgamento, salvamento, áudio ou arte final nesta tarefa.
>
> Trabalhe incrementalmente nesta ordem: (1) InputMap e cena-base; (2) jogador e colisões; (3) Camera2D; (4) classe Interactable e cenas placeholder; (5) InteractionScanner; (6) prompt contextual; (7) roteamento de depuração; (8) validação de IDs e descarte seguro; (9) execução e testes manuais.
>
> Use Godot 4 / GDScript 2.0. Use ações do InputMap, sinais com referências tipadas, `CharacterBody2D` para o jogador e `Area2D` para detecção de proximidade. A escolha de alvo deve ser independente da ordem dos sinais: menor distância ao pivô do alvo, desempate por `interactable_id`. Não mantenha dois valores diferentes para o alcance. Não implemente um script manual de follow da câmera.
>
> Depois de cada etapa, execute a cena ou a validação disponível e corrija erros antes de continuar. Não declare um teste como aprovado se ele não foi executado. Ao final, atualize `docs/M1_TESTS.md` com Passou/Falhou e descreva qualquer limitação conhecida. Não altere arquivos fora do escopo sem explicar o motivo.

---

## 14. Próximo marco

Avançar para o M2 — **exame de objetos e coleta de evidências** — somente depois de todos os critérios de aceite do M1 estarem concluídos. O M2 deve introduzir `EvidenceDefinition`, painel de exame, caderno e serviço de evidências; não antecipar esses sistemas nesta fase.

---

## 15. Referências técnicas

Consultar a documentação correspondente à versão de Godot fixada no projeto:

- `CharacterBody2D` e movimentação: https://docs.godotengine.org/en/4.7/classes/class_characterbody2d.html
- `Area2D` e sinais de sobreposição: https://docs.godotengine.org/en/4.7/classes/class_area2d.html
- `InputEvent.is_action_pressed()`: https://docs.godotengine.org/en/4.7/classes/class_inputevent.html
- `Camera2D`: https://docs.godotengine.org/en/4.7/classes/class_camera2d.html
- Grupos de nós: https://docs.godotengine.org/en/4.7/tutorials/scripting/groups.html
- `Node.queue_free()` e ciclo de vida: https://docs.godotengine.org/en/4.7/classes/class_node.html
