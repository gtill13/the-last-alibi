# Auditoria — Arte procedural (Fase 0)

**Data:** 27/10/2026  
**Commit auditado:** `9836a6c`  
**Engine:** Godot `4.7.2.stable.official.ed1daf0bf`  
**Ambiente:** Linux, Godot X11 tools, renderer Vulkan/Forward+ na execução gráfica  
**Escopo:** auditoria somente. Nenhum script, cena ou configuração funcional foi alterado nesta fase.

## 1. Objetivo da auditoria

Conhecer o estado real do projeto antes de implementar a direção de arte procedural descrita em
`PLANO_ARTE_PROCEDURAL_PS1_THE_LAST_ALIBI.md`, identificar o que deve ser preservado e separar
problemas reais de suposições.

## 2. Estado atual do projeto

### 2.1 Aplicação e configuração

- Cena principal: `res://scenes/app/main.tscn`.
- Autoloads: `GameState` (`scripts/autoload/game_state.gd`) e `SceneRouter`
  (`scripts/autoload/scene_router.gd`).
- Resolução base: **1280 × 720**.
- Janela inicial: **1280 × 720** (`window_width_override` e `window_height_override`).
- Stretch mode: **`canvas_items`**.
- Filtro de textura global: **não configurado**; portanto, o padrão da engine é linear.
- Renderer mobile declarado: `gl_compatibility`.
- Não há tema, fonte externa ou escala de UI centralizada.
- O nível de investigação usa um mundo de **2400 × 720**, câmera com limites nesse retângulo,
  jogador em `(180, 560)`, cápsula de `18 × 32` e scanner circular de raio `90`.
- A HUD e os modais usam coordenadas fixas pensadas para 1280 × 720.

### 2.2 Arte procedural existente

- `scripts/procedural/procedural_art_definition.gd`
  - `definition_id`, `logical_size`, `pivot`, `commands`.
  - `commands` é `Array[Dictionary]`.
  - Setores emitem `changed`; `touch()` força atualização.
- `scripts/procedural/procedural_art_renderer.gd`
  - `Node2D` com `_draw()`.
  - Comandos suportados: `rect`, `line`, `circle`, `polygon`.
  - Desenha na ordem da lista e aplica `pivot`.
  - Só pede redesenho quando a definição muda ou o nó entra na árvore.
  - Avisos de configuração para definição ausente/vazia.
- `scripts/procedural/procedural_prefab_cache.gd`
  - Pool opcional de `PackedScene`, com limite por família.
  - Hooks `on_procedural_cache_acquired` e `on_procedural_cache_released`.
  - Não está registrado como Autoload; é opcional.
- Definições atuais: sala, mesa clara, mesa escura, planta, quadro e detetive.
- Prefabs atuais: cinco cenas em `scenes/props/`.
- Demo atual: `scenes/procedural/procedural_art_demo.tscn`, em 1280 × 720.
- Gerador: `tools/generate_procedural_art.gd`.
- Documentação existente: `docs/ARTE_PROCEDURAL.md`.

### 2.3 Integração com o jogo

- O nível de investigação **não usa** as definições procedurais. Ele ainda usa `Polygon2D`
  como placeholder para fundo, piso, jogador, objetos e suspeito.
- A demo procedural é independente e não substitui o nível.
- A separação entre arte, colisão e regras de investigação já está correta.
- O cache de prefabs não é usado pelo nível; os props atuais são fixos.

### 2.4 Testes e documentação

- Suíte: **58 testes em 12 suítes**.
- Cobertura procedural: definição, renderer, cache e cena-demo.
- A suíte headless valida estrutura e dados, **não valida aparência, escala ou legibilidade**.
- Evidência manual do M1: `tests/manual/screenshots/fase1/`.
- Evidência visual da demo procedural: `tests/manual/screenshots/procedural-art/`.
- O plano novo (`PLANO_ARTE_PROCEDURAL_PS1_THE_LAST_ALIBI.md`) está **não rastreado** no Git.
- O PNG avulso `docs/a_cinematic_moody_pixel_2d_flat_shaded_comic_no.png*` continua não rastreado
  e não é referenciado pelo jogo.

## 3. Validações executadas

| Verificação | Comando | Resultado |
|---|---|---|
| Versão da engine | `godot --version` | `4.7.2.stable.official.ed1daf0bf` |
| Importação/editor headless | `godot --headless --path . --editor --quit` | exit `0`; nenhum `ERROR`/`WARNING`/parse error |
| Suíte completa | `./tests/run_tests.sh` | exit `0`; **58 passaram, 0 falharam** |
| Demo procedural headless | `godot --headless --path . res://scenes/procedural/procedural_art_demo.tscn --quit-after 2` | exit `0`; sem erros/warnings |
| Nível de investigação headless | `godot --headless --path . res://scenes/investigation/investigation_level.tscn --quit-after 2` | exit `0`; sem erros/warnings |
| Dependências de imagem na arte | busca por `Sprite2D`, `TextureRect`, `.png`, `.jpg`, `.svg`, `texture` | nenhum asset de imagem usado como arte do mundo |
| Propriedade `TextureRect.color` | consulta a `ClassDB.class_get_property_list("TextureRect")` | **`TextureRect` não possui `color`** |
| Layout do menu | inspeção da captura existente `f1_01_menu.png` | menu aparece no canto superior esquerdo, não centralizado |

O único warning da suíte é o preexistente e esperado:

```text
WARNING: CaseSession: evidência evid_inexistente não pertence ao caso test_case
```

## 4. Problemas encontrados

### P0 — Resolução e escala ainda não são as do plano

O projeto está em 1280 × 720 com `canvas_items`. O plano pede uma imagem lógica de **320 × 180**,
ampliação inteira e filtro nearest. Trocar `project.godot` diretamente agora quebraria:

- o mundo de 2400 × 720;
- as posições e colisões do nível;
- as coordenadas fixas da HUD e dos modais;
- as definições de arte atuais, autoradas em unidades de 1280 × 720.

**Decisão de auditoria:** a Fase 1 deve validar 320 × 180 dentro de um `SubViewport` de laboratório,
sem alterar a configuração global do jogo. A migração do projeto inteiro só deve ocorrer depois de
uma comparação visual aprovada.

### P1 — O renderer atual é menor que o alvo do plano

Hoje existem apenas `rect`, `line`, `circle` e `polygon`. O plano prevê, em fases posteriores:

- `polyline`;
- `pattern_rect`;
- `shadow_polygon`;
- `outline_polygon`;
- perfil de estilo/paleta;
- animação por definições;
- definição de sala;
- validador centralizado;
- seeds determinísticas.

Nada disso deve ser implementado de uma vez. A Fase 1 precisa apenas de perfil de estilo, paleta,
viewport e uma amostra visual. Os comandos novos entram nas fases 2 e 3, quando uma peça real pedir.

### P1 — A UI está usando propriedades de Godot 3

Foram encontradas propriedades inválidas em várias cenas:

- `anchor_preset` e `layout_preset` em vez de `anchors_preset`/`layout_mode`;
- `custom_constants/separation` e `custom_constants/min_size` em vez de
  `theme_override_constants/...` ou `custom_minimum_size`;
- `color` em `TextureRect`, que não existe. O nó correto para um painel colorido é `ColorRect`
  (ou usar `self_modulate` em um `TextureRect` com textura).

Consequências observadas:

- o menu principal não está centralizado (captura `f1_01_menu.png`);
- os painéis de diálogo, caderno, dossiê e relatório tendem a ficar sem fundo visível;
- o fade overlay pode não cobrir a tela inteira por causa dos presets inválidos.

Isso é um defeito preexistente de UI, separado do renderer procedural. Recomendo corrigi-lo em uma
tarefa própria, antes de reutilizar esses painéis no Art Lab ou no corredor.

### P2 — A arte procedural ainda é uma demo, não uma direção final

- As definições atuais são “flat vector noir” em 1280 × 720.
- Não há textura, dithering, ruído, quantização, sombra suave ou animação.
- O detetive é estático.
- A demo não tem colisão, scanner ou integração com evidências.
- O resultado é bom como prova de sistema, mas ainda não é o “PS1 2D” descrito no plano.

### P2 — Falta validação visual automatizada

A suíte headless passou, mas não mede:

- legibilidade em 320 × 180;
- nitidez após ampliação;
- contraste do detetive contra o fundo;
- dithering sem cintilação;
- escala fracionária;
- UI sem filtro retrô.

A Fase 1 precisa de capturas em 1280 × 720 e 1920 × 1080 e de critérios de aceite visuais
explícitos.

### P3 — O cache não é necessário para o primeiro corredor

O `ProceduralPrefabCache` funciona e está testado, mas o corredor inicial é estático. Usar pool para
paredes, balcão e porta adicionaria complexidade sem ganho. A recomendação do plano de medir antes de
otimizar está correta; o cache deve ficar disponível, mas não obrigatório.

## 5. O que deve ser preservado

- Os três scripts procedurais e o formato atual de `ProceduralArtDefinition`.
- As seis definições `.tres` e os cinco prefabs existentes.
- A demo procedural e seus testes, como referência do sistema.
- O nível de investigação, colisões, scanner, evidências e regras de caso.
- A suíte de 58 testes.
- A separação entre arte, gameplay e UI.
- A documentação `docs/ARTE_PROCEDURAL.md` e `docs/M1_TESTS.md`.

Não mover os três scripts existentes para `scripts/procedural/data/` ou `rendering/` nesta fase:
os caminhos aparecem em `ext_resource` dos `.tres` e nos testes. Novos arquivos podem usar subpastas,
mas os existentes devem permanecer onde estão até uma migração planejada.

## 6. Proposta para a Fase 1

### 6.1 Arquivos previstos

Criar, sem alterar o `project.godot` global:

- `scripts/procedural/procedural_style_profile.gd` — recurso de estilo com paleta, passo lógico,
  contorno, sombra, luz, dithering, ruído, quantização, seed e flags.
- `art/procedural/palettes/palette_noir_hotel.tres` — paleta inicial do plano.
- `art/procedural/profiles/ps1_noir_profile.tres` — perfil que referencia a paleta.
- `scripts/procedural/procedural_art_lab.gd` — monta a amostra do laboratório.
- `scenes/art_lab/procedural_art_lab.tscn` — cena executável.
- `docs/PROCEDURAL_ART_STYLE_GUIDE.md` — guia curto de paleta, escala, composição e uso.
- Testes novos para o perfil, a paleta e a configuração do laboratório.

### 6.2 Como validar 320 × 180 sem quebrar o jogo

O laboratório deve usar:

```text
ProceduralArtLab (Node2D/Control)
└── GameViewportContainer (SubViewportContainer, 1280×720, stretch)
    └── GameViewport (SubViewport, 320×180)
        └── ArtSample (Node2D com ProceduralArtRenderer)
```

- `SubViewport.size = Vector2i(320, 180)`.
- `SubViewportContainer.stretch = true`.
- `stretch_shrink = 4` para 1280 × 720; 6 para 1920 × 1080.
- Filtro nearest no container/viewport.
- HUD do laboratório em `CanvasLayer` separada, fora do SubViewport, para testar a regra de que
  dithering e pixelização não devem borrar texto.
- Uma prévia 1× ao lado ou em um canto, para comparar “escala de edição” com “tamanho de jogo”.

### 6.3 Conteúdo visual mínimo do laboratório

- amostras da paleta com nome e código;
- parede de fundo com dois ou três valores;
- piso com linha de perspectiva e rodapé;
- silhueta do detetive em 320 × 180;
- um objeto pequeno (mesa ou envelope) para testar leitura;
- texto de UI fora do viewport pixelado.

### 6.4 Critérios de aceite da Fase 1

| Critério | Como validar |
|---|---|
| Paleta editável sem tocar no renderer | trocar uma cor no `.tres` e ver a mudança no lab |
| 320 × 180 lógico | `SubViewport.size` e captura em 1280 × 720 |
| Ampliação inteira | 4× em 1280 × 720 e 6× em 1920 × 1080 |
| Filtro nearest | pixels sem borrão nas capturas |
| Silhueta legível | detetive reconhecível no tamanho real |
| UI nítida | texto do lab fora do SubViewport |
| Sem dependência de imagens | busca por assets e inspeção da cena |
| Testes | suíte completa continua passando; novos testes do perfil/lab passam |

## 7. Riscos e decisões pendentes

1. **Migrar ou não o jogo inteiro para 320 × 180 agora?**
   Recomendação: não. Validar primeiro no laboratório. A migração mexe em mundo, câmera, UI,
   colisões e todas as definições de arte.
2. **Corrigir a UI quebrada junto com a Fase 1?**
   Recomendação: tratar como tarefa separada e pequena. O Art Lab pode usar `ColorRect` e
   `Label` corretos sem depender dos modais antigos.
3. **Paleta como `Dictionary` ou recurso separado?**
   Recomendação: `ProceduralStyleProfile` com um `Dictionary` de cores nomeadas e um recurso de
   paleta separado apenas se a paleta crescer. Para a Fase 1, um perfil já resolve.
4. **Usar shader de dithering já na Fase 1?**
   Não. O plano coloca dithering na Fase 6. A Fase 1 deve provar escala, paleta e silhueta sem
   efeitos.
5. **Commitar o plano novo e esta auditoria?**
   O plano está não rastreado. Recomendo commitar os dois juntos depois da aprovação da Fase 0,
   mantendo o PNG avulso fora do commit.

## 8. Conclusão

O projeto tem uma base saudável: a suíte passa, a importação está limpa, o renderer é genérico e a
separação entre arte e gameplay está correta. O que falta não é “mais código de desenho”; é uma
camada de direção visual: paleta centralizada, resolução lógica baixa, escala inteira, silhueta
legível e critérios visuais explícitos.

A Fase 1 deve ser um laboratório isolado em 320 × 180. O jogo principal continua em 1280 × 720 até
que o laboratório prove que a nova escala e a paleta funcionam. A UI quebrada é um problema real,
mas separado; corrigi-la agora evita que o laboratório herde os mesmos erros.
