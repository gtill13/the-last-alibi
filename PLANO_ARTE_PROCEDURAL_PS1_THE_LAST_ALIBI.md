# The Last Alibi — Plano de Desenvolvimento da Arte Procedural

**Destino:** IA local de desenvolvimento via OpenCode  
**Engine:** Godot 4.x  
**Linguagem:** GDScript  
**Tipo de jogo:** investigação narrativa 2D side-scroller para PC/Steam  
**Direção visual:** survival horror de baixo orçamento visual, inspirado nas limitações e na atmosfera de jogos de PlayStation 1, reinterpretado como arte 2D lateral original.  
**Regra central:** a arte final deve ser criada em tempo de execução por matemática, recursos de dados, desenho do CanvasItem e shaders escritos no projeto. Não importar sprites, ilustrações, fotografias ou texturas de imagem como arte do jogo.

---

## 0. Instruções obrigatórias para a IA de desenvolvimento

Leia este documento inteiro antes de modificar o projeto. Trabalhe em etapas pequenas e verificáveis. Não tente implementar todas as fases de uma vez.

### 0.1 Objetivo técnico

Construir um **sistema de arte procedural reutilizável**, não apenas uma cena desenhada à mão em um único script. Cada objeto visual deve poder ter uma definição própria, e um renderer genérico deve interpretar essa definição. O sistema deve permitir criar ambientes, props, personagens e pequenas animações com a mesma infraestrutura.

O resultado procurado é uma estética original que combine:

- paleta de cores reduzida e pouco saturada;
- formas angulosas e silhuetas simples;
- sombras duras e áreas grandes de escuridão;
- texturas e ruído criados matematicamente;
- resolução interna baixa e ampliação nítida;
- composição lateral com perspectiva falsa, profundidade por camadas e enquadramento de terror;
- animações econômicas, mas claras e legíveis.

A referência é a **linguagem visual geral** de survival horror do fim dos anos 1990, não uma reprodução de personagens, cenários, interfaces, logotipos ou assets de Resident Evil. Todo desenho, layout e personagem de The Last Alibi deve ser original.

### 0.2 Regras de execução

1. Antes de programar, inspecione o repositório, a versão da Godot, as cenas, os Autoloads e os três scripts procedurais existentes, se estiverem presentes:
   - `procedural_art_definition.gd`
   - `procedural_art_renderer.gd`
   - `procedural_prefab_cache.gd`
2. Não apague nem reescreva sistemas existentes sem explicar a razão, o risco e a migração necessária no relatório de implementação.
3. Preserve a compatibilidade com recursos `.tres` existentes sempre que possível. Se o formato dos comandos mudar, escreva uma migração ou um adaptador temporário.
4. Não use PNG, JPG, SVG, spritesheets, fotografias, fontes desenhadas externas ou assets baixados como arte do cenário ou dos personagens. A UI textual pode usar os recursos padrão da engine durante o protótipo; não introduza fontes externas sem aprovação.
5. É permitido criar texturas em memória usando `Image`, `ImageTexture`, `SubViewport` e shaders próprios, porque o conteúdo é gerado pelo código em execução. Não salvar a renderização final como uma imagem pré-fabricada para contornar o requisito procedural.
6. Não gere padrões aleatórios a cada frame. Variações decorativas devem ser determinísticas usando uma seed fixa por recurso/ambiente.
7. Não misture arte com lógica de investigação, colisão ou diálogo. O renderer desenha; o prefab organiza os nós; o sistema de gameplay decide o que pode ser examinado.
8. Não chame `queue_redraw()` continuamente se a arte não mudou. A solicitação de redesenho deve ocorrer quando uma definição, estado visual ou quadro de animação mudar.
9. Conclua apenas uma fase por vez. Após cada fase, execute a validação apropriada, registre os erros reais, corrija-os e só então avance.
10. Não declare que um teste passou se não foi executado. No relatório final, separe claramente testes executados, testes manuais pendentes e limitações do ambiente.

### 0.3 Definição geral de pronto

O projeto só estará validado quando a IA conseguir demonstrar, dentro da Godot:

- um corredor de hotel lateral visualmente coerente com a direção artística;
- um detetive desenhado proceduralmente, com pelo menos idle e caminhada;
- objetos de cenário criados com definições independentes;
- paleta, resolução baixa, sombras e textura procedural aplicadas sem depender de imagens externas;
- a mesma definição visual sendo reutilizada em mais de uma instância, sem compartilhar estado de animação indevidamente;
- critérios de aceitação aprovados e comandos de validação documentados.

---

## 1. Conceito de arte e limites do estilo

### 1.1 O que queremos dizer com “estética PS1 em 2D”

O jogo não será 3D e não precisa imitar tecnicamente a renderização de um PlayStation. A intenção é traduzir algumas características visuais da época para uma apresentação lateral 2D:

- **Baixa resolução:** detalhes pequenos se agrupam em blocos e a imagem é ampliada com filtro nearest.
- **Paleta controlada:** muitos tons escuros, cores envelhecidas, acentos de luz quentes e poucos destaques.
- **Geometria angular:** portas, mesas e móveis usam planos e polígonos, não contornos vetoriais excessivamente suaves.
- **Luz localizada:** luminárias e janelas criam ilhas de cor; áreas de sombra permanecem amplas.
- **Textura imperfeita:** padrões repetidos, dithering e ruído de baixa intensidade dão variação às superfícies.
- **Composição de terror:** espaços vazios, passagens estreitas, linhas de perspectiva e objetos parcialmente escondidos.
- **Animação econômica:** poses bem legíveis em vez de movimentos suaves e detalhados.

Não basta reduzir a resolução. Um cenário formado apenas por retângulos com cores aleatórias parecerá um desenho geométrico genérico. A qualidade deverá vir de composição, hierarquia de valores, silhuetas, perspectiva e consistência de paleta.

### 1.2 Direção visual sugerida

Comece com a recepção/corredor de um hotel antigo. Não construa o hotel inteiro. A primeira cena precisa mostrar apenas um espaço pequeno e controlado, que será utilizado para avaliar a qualidade do sistema.

**Paleta inicial de referência** — pode ser ajustada após a primeira captura:

| Função | Cor sugerida | Uso |
|---|---|---|
| Preto azulado | `#090D12` | áreas de sombra profunda e fundo |
| Azul carvão | `#151C24` | sombras de parede e planos escuros |
| Cinza gasto | `#303236` | paredes, concreto e pedra |
| Marrom envelhecido | `#49342D` | madeira, portas e balcão |
| Marrom médio | `#75513D` | bordas de madeira e luz refletida |
| Verde dessaturado | `#414A43` | papel de parede, plantas e detalhes |
| Vinho escuro | `#4A292D` | tapete, cortinas e pequenos detalhes |
| Âmbar | `#B98243` | luminárias, metal e luz quente |
| Marfim sujo | `#C5BDA6` | papéis, letreiros e reflexos fortes |
| Vermelho apagado | `#793C3B` | sinalização e acentos raros |

A lista acima é uma paleta inicial, não uma obrigação de usar todas as cores em todos os objetos. Cada material deve usar poucos tons relacionados. Evite usar branco puro ou preto absoluto em excesso.

### 1.3 Princípios de composição

- Separe visualmente fundo, arquitetura, chão, objetos, personagens e primeiro plano.
- Use linhas do chão, rodapés, molduras, corredores e balcões para guiar o olhar.
- O detetive deve continuar legível contra o fundo em escala de jogo, não apenas quando ampliado.
- Objetos investigáveis devem ter uma silhueta própria e um destaque sutil; não devem parecer todos itens coletáveis brilhantes.
- O maior contraste da cena deve conduzir o olhar sem revelar tudo de imediato.
- A perspectiva falsa deve ser coerente: ângulos, bordas do chão e linhas arquitetônicas não podem apontar para direções conflitantes sem intenção.

---

## 2. Arquitetura-alvo

### 2.1 Estrutura de pastas recomendada

Adapte a estrutura existente em vez de duplicar arquivos com nomes parecidos.

```text
res://
├── art/
│   └── procedural/
│       ├── palettes/
│       │   └── palette_noir_hotel.tres
│       ├── profiles/
│       │   ├── ps1_noir_profile.tres
│       │   └── ps1_noir_profile.gd
│       ├── definitions/
│       │   ├── characters/
│       │   │   ├── detective_idle.tres
│       │   │   ├── detective_walk_00.tres
│       │   │   └── detective_inspect.tres
│       │   ├── props/
│       │   │   ├── hotel_desk.tres
│       │   │   ├── wall_lamp.tres
│       │   │   ├── hotel_door.tres
│       │   │   └── evidence_envelope.tres
│       │   ├── environments/
│       │   │   └── hotel_corridor_backdrop.tres
│       │   └── patterns/
│       │       ├── wallpaper_pattern.tres
│       │       └── carpet_pattern.tres
│       └── room_definitions/
│           └── hotel_corridor.tres
├── scenes/
│   ├── art_lab/
│   │   └── procedural_art_lab.tscn
│   ├── characters/
│   │   └── detective_visual.tscn
│   ├── props/
│   │   ├── hotel_desk.tscn
│   │   ├── wall_lamp.tscn
│   │   └── hotel_door.tscn
│   └── environments/
│       └── hotel_corridor.tscn
├── scripts/
│   └── procedural/
│       ├── data/
│       │   ├── procedural_art_definition.gd
│       │   ├── procedural_style_profile.gd
│       │   ├── procedural_animation_definition.gd
│       │   └── procedural_room_definition.gd
│       ├── rendering/
│       │   ├── procedural_art_renderer.gd
│       │   ├── procedural_animation_player.gd
│       │   ├── procedural_texture_baker.gd
│       │   └── procedural_art_validator.gd
│       ├── generation/
│       │   ├── procedural_pattern_generator.gd
│       │   └── procedural_room_builder.gd
│       └── cache/
│           └── procedural_prefab_cache.gd
├── shaders/
│   └── procedural/
│       ├── ps1_palette_quantize.gdshader
│       ├── ordered_dither.gdshader
│       └── subtle_noise.gdshader
├── tests/
│   ├── procedural_art_test_runner.gd
│   └── fixtures/
└── docs/
    └── PROCEDURAL_ART_STYLE_GUIDE.md
```

Nem todos esses arquivos precisam ser criados no primeiro marco. A árvore indica a organização final desejada. Só introduza um sistema quando existir uma necessidade validada.

### 2.2 Responsabilidade de cada parte

**`ProceduralArtDefinition`**  
Recurso de dados que descreve formas e metadados de uma peça. Não deve saber como a peça é utilizada no jogo.

**`ProceduralStyleProfile`**  
Configuração visual compartilhada: paleta, tamanho de grade, parâmetros de dithering/ruído, níveis de contraste e opções de renderização. Evita colocar valores de estilo duplicados em cada definição.

**`ProceduralArtRenderer`**  
Nó visual genérico derivado de `Node2D`. Interpreta os comandos e desenha em `_draw()`. Não conhece inventário, evidências, personagens suspeitos ou diálogo.

**`ProceduralAnimationDefinition`**  
Lista ordenada de definições visuais, duração por quadro e regra de loop. Não controla movimento nem gameplay.

**`ProceduralAnimationPlayer`**  
Seleciona o quadro atual e manda o renderer usar a definição apropriada. Só solicita redesenho quando o quadro muda.

**`ProceduralRoomDefinition`**  
Descreve quais prefabs entram em uma sala, posições, ordem de desenho, variações determinísticas e referências aos estilos.

**`ProceduralRoomBuilder`**  
Monta uma sala a partir da definição. Não deve escolher os elementos de maneira aleatória em cada execução sem uma seed definida.

**`ProceduralTextureBaker`**  
Componente opcional e tardio. Converte arte procedural estática em uma textura criada em memória usando `SubViewport` ou `Image`/`ImageTexture`, apenas se medições indicarem benefício.

**`ProceduralPrefabCache`**  
Pool limitado de instâncias de cenas que são criadas/destruídas frequentemente. Não substitui o cache de recursos da Godot e não deve armazenar indiscriminadamente cada móvel ou parede.

**`ProceduralArtValidator`**  
Valida definições: comandos desconhecidos, dimensões inválidas, polígonos com poucos pontos, cores ausentes, coordenadas fora de limites esperados e recursos com identificadores duplicados.

### 2.3 Como a arte conecta com gameplay

Use uma cena de prefab que separe visual e comportamento. Exemplo:

```text
HotelEvidenceEnvelope (Area2D ou Node2D conforme a interação existente)
├── CollisionShape2D            # se necessário para interação/física
├── ProceduralArtRenderer       # só desenha
└── EvidenceInteraction        # só conecta o objeto às regras de investigação
```

A arte nunca deve decidir se uma pista foi coletada. O sistema de evidências mantém os IDs e os estados do caso. O sistema visual apenas pode receber um estado visual, por exemplo `is_examined`, para alterar contorno ou brilho.

---

## 3. Estratégia de renderização

### 3.1 Primeira opção: desenho direto de CanvasItem

A versão inicial deve continuar usando o método de desenho personalizado da Godot (`_draw()` e funções `draw_*`). A documentação de `CanvasItem` explica que `queue_redraw()` solicita um novo desenho, que ocorre quando o engine processa o desenho; portanto, não é necessário executar todo o desenho em `_process()` continuamente.

Comece suportando estes comandos:

- `rect`: retângulo preenchido ou contorno;
- `line`: linha com espessura controlada;
- `polygon`: polígono preenchido;
- `polyline`: linha poligonal;
- `circle`: círculo apenas quando fizer sentido visual;
- `ellipse`: elipse ou substituição por polígono se for necessário alinhar à grade;
- `pattern_rect`: região com padrão repetido calculado matematicamente;
- `shadow_polygon`: plano de sombra desenhado como polígono;
- `outline_polygon`: contorno de uma forma.

O renderer deve validar cada comando, emitir mensagens de erro compreensíveis e continuar processando os comandos válidos quando possível. Cada comando precisa ser desenhado na ordem da lista; comandos posteriores aparecem por cima dos anteriores.

**Não implemente todos os tipos de comando de uma vez.** Para o primeiro corredor, `rect`, `line`, `polygon` e `polyline` devem ser suficientes. Acrescente novos tipos conforme uma peça real precisar deles.

### 3.2 O que é arte vetorial e o que é pixel art

Desenhar polígonos por código não garante a aparência pixelada. Para obter o resultado proposto, combine:

1. coordenadas alinhadas à grade;
2. tamanho lógico baixo e consistente;
3. ampliação sem suavização;
4. áreas de cor chapadas, com detalhes agrupados em pixels;
5. dithering/ruído controlados;
6. contornos e silhuetas com espessuras coerentes.

Evite antialiasing em linhas de detalhe quando ele produzir bordas suaves incompatíveis com o alvo. Teste qualquer opção na resolução real de jogo.

### 3.3 Resolução interna inicial

Comece com **320 × 180** para a imagem de jogo (16:9). Isso permite escala inteira de 4x para 1280 × 720 e 6x para 1920 × 1080. Use este valor como baseline e não o trate como final até que a leitura dos detalhes seja validada.

Configuração de partida sugerida:

- tamanho base da janela/viewport: `320 × 180`;
- Stretch Mode: `viewport`;
- Stretch Aspect: `keep` durante a primeira validação; avalie `expand` posteriormente se precisar suportar mais proporções de tela;
- escala de estiramento inteira, se compatível com as opções da versão usada;
- filtro de textura padrão: nearest para conteúdo pixelado;
- testar em 1280 × 720 e 1920 × 1080.

Não altere configurações globais do projeto sem conferir as configurações atuais e registrar a mudança. Se o projeto já tiver outra estratégia de resolução, prepare uma comparação antes de substituir.

Se o projeto precisar de HUD com texto muito pequeno, confirme se a interface continua legível. Ela pode exigir uma camada/UI separada, sem aplicar o efeito de dithering do mundo inteiro.

### 3.4 Camadas visuais e profundidade falsa

Use camadas distintas para simular profundidade sem recorrer a 3D:

1. `FarBackground`: parede distante, janelas e silhuetas externas;
2. `Architecture`: paredes, molduras e portas;
3. `FloorPlane`: chão lateral, tapete e perspectiva sugerida;
4. `Furniture`: balcão, cadeiras, mesas;
5. `Characters`: detetive, NPCs;
6. `ForegroundOccluders`: bordas de portas, colunas e objetos que podem cobrir parte do personagem;
7. `WorldEffects`: luz decorativa, fumaça ou partículas discretas;
8. `HUD`: objetivo, prompt de interação e caderno, sem filtro retro global.

A ordem de desenho deve ser explícita, usando a ordem de nós, `z_index` e/ou `CanvasLayer` conforme o tipo de elemento. A câmera lateral não deve permitir que o detetive seja desenhado atrás do chão ou à frente de uma parede que deveria ocultá-lo.

Para criar perspectiva falsa, use polígonos com ângulos consistentes: por exemplo, rodapés e linhas do piso podem convergir para uma região fora do centro do quadro. Faça isso de forma moderada; o jogo continua side-scroller e as superfícies precisam funcionar com movimento horizontal.

---

## 4. Perfil de estilo PS1

### 4.1 Perfil de estilo como dado

Implemente um recurso de estilo reutilizável com campos equivalentes a:

- `profile_id`;
- `palette`;
- `logical_pixel_step`;
- `outline_color` e/ou regra para contorno;
- `shadow_color`;
- `highlight_color`;
- `dither_strength`;
- `noise_strength`;
- `color_quantization_levels`;
- `use_hard_shadows`;
- `use_procedural_texture`;
- `seed`;
- parâmetros opcionais de material (madeira, parede, metal, tecido, papel).

Use os recursos `.tres` para serializar definições no disco. A documentação oficial de `Resource` descreve recursos personalizados como contêineres de dados reutilizáveis que podem ser salvos em `.tres`/`.res` e carregados novamente pelo engine.

Não codifique os mesmos valores de paleta diretamente em cada prefab. Prefabs podem sobrescrever apenas o que for realmente especial.

### 4.2 Dithering

O dithering deve apoiar a percepção de tom intermediário, não cobrir toda a tela com pontos visíveis. Implemente primeiro um padrão ordenado de 2×2 ou 4×4. O shader deve ter uma intensidade configurável e receber os parâmetros pelo perfil de estilo.

Regras:

- intensidade pequena em áreas iluminadas;
- intensidade maior em gradientes de sombra ou neblina;
- não usar dithering sobre texto da interface, indicadores de interação ou detalhes que precisam ser lidos com precisão;
- manter o padrão estável na tela/mundo para evitar cintilação durante o movimento da câmera;
- testar a versão sem dithering e com dithering lado a lado.

Não aplique um efeito de ruído aleatório que mude de padrão a cada frame. Se houver animação de ruído, ela deve ser extremamente sutil, opcional e validada contra flicker.

### 4.3 Quantização de cores

Se a quantização for feita por shader, aplique-a ao mundo visual, não indiscriminadamente ao HUD. A redução de cores deve respeitar a paleta escolhida e evitar que todas as cores claras virem um único bloco branco.

Para o MVP, prefira usar uma paleta predefinida ao desenhar as formas. Considere o shader de quantização uma etapa posterior, porque aplicar quantização global sem controle pode destruir a legibilidade de papéis, pequenos objetos e personagens.

### 4.4 Ruído e texturas procedurais

Crie poucos geradores de padrão reutilizáveis, com seed fixa:

- **Papel de parede:** repetição geométrica desbotada, espaçada, com contraste muito baixo;
- **Carpete:** agrupamentos curtos e repetidos, com duas ou três cores próximas;
- **Madeira:** linhas de fibra quebradas e irregulares, sem textura fotográfica;
- **Metal:** pequenas faixas de luz e áreas oxidadas estilizadas;
- **Papel/documento:** cor base, linhas de texto abstratas e uma dobra/sombra.

Não faça o shader/padrão gerar detalhes que atrapalhem a leitura da forma. Um objeto deve continuar reconhecível mesmo com a textura desligada.

### 4.5 Luz e sombra

Comece com sombras desenhadas como polígonos, antes de desenvolver iluminação dinâmica complexa. Por exemplo, uma luminária pode ter um halo geométrico discreto e uma área de luz âmbar no piso, composta por polígonos de baixa opacidade.

A iluminação não precisa simular uma física realista. O objetivo é ter um foco visual controlado, sem iluminar uniformemente todo o cenário.

Shader de CanvasItem é uma ferramenta válida para efeitos 2D, mas use-o apenas quando o efeito exigir cálculo por pixel. Geometria simples é preferível para sombras estáticas claramente definidas.

---

## 5. Criação de personagens sem sprites

### 5.1 Método recomendado

O primeiro personagem será o detetive. Construa-o com formas e polígonos deliberados. Não tente gerar uma figura complexa a partir de dezenas de círculos aleatórios.

Divida a forma em grupos visuais (que podem ser comandos de uma única definição ou renderizadores separados se precisar animar partes):

- chapéu/cabelo;
- cabeça e rosto em sombra;
- pescoço;
- ombros e sobretudo;
- braços/mãos;
- pernas;
- sapatos;
- detalhes de contraste, como gravata, gola, cinto e um pequeno brilho.

O conjunto deverá produzir uma silhueta legível em 320×180. A identidade vem do chapéu, sobretudo, postura e contraste, e não de detalhes faciais minúsculos.

### 5.2 Pivot e colisão

O `pivot` visual deve ficar na base central dos pés para permitir que o desenho seja posicionado com facilidade no chão. O nó de gameplay e sua forma de colisão devem permanecer independentes do contorno visual.

Não faça a colisão acompanhar cada detalhe do casaco. A colisão deve ser simples, estável e testada separadamente.

### 5.3 Animação mínima do detetive

Crie primeiro estas poses:

1. `idle`: uma pose estática bem legível;
2. `walk`: quatro quadros iniciais para teste de caminhada;
3. `inspect`: corpo ligeiramente inclinado ou braço avançado;
4. `talk`: uma pose curta, sem necessidade de sincronização labial.

A animação pode ser uma lista de `ProceduralArtDefinition` por quadro. Um player simples troca a definição pelo intervalo de tempo e solicita redesenho quando o quadro muda. Não calcule geometria nova em cada frame se o desenho já estiver descrito no recurso.

Use um recurso separado para os quadros de animação. Não coloque decisões de gameplay no player visual: o controlador do jogador decide se está andando, parado ou examinando; o player apenas recebe o estado visual.

### 5.4 Reutilização de personagens

O NPC da recepção pode reutilizar parte da infraestrutura, mas deve ter sua definição e paleta. Não clone o detetive e altere apenas a cor se isso gerar silhuetas indistinguíveis.

Construa o primeiro NPC depois que o detetive for validado. A segunda silhueta deve provar que o sistema não é especializado em apenas um personagem.

---

## 6. Construção do primeiro cenário: corredor/recepção do hotel

### 6.1 Escopo exato da primeira cena

A primeira prova visual deve conter:

- parede de fundo com molduras ou papel de parede simples;
- chão com pelo menos duas faixas de perspectiva;
- uma porta principal;
- uma luminária de parede;
- uma mesa ou balcão de recepção;
- um objeto pequeno que possa futuramente ser uma pista;
- o detetive;
- um NPC estático de recepção, numa etapa posterior;
- uma etiqueta de localização e um prompt de interação temporário para validar legibilidade.

Não adicione vários quartos, chuva, fumaça animada, partículas, sombras dinâmicas e dezenas de props antes de validar a composição básica.

### 6.2 Construção em camadas

A cena deve ser montada a partir de recursos e prefabs individuais, com nomes descritivos. Exemplo:

```text
HotelCorridor (Node2D)
├── FarBackground (Node2D)
├── Architecture (Node2D)
├── FloorPlane (Node2D)
├── Furniture (Node2D)
├── Characters (Node2D)
├── ForegroundOccluders (Node2D)
├── WorldEffects (Node2D)
└── HUD (CanvasLayer)
```

As estruturas físicas existentes do projeto (por exemplo, `StaticBody2D`, `Area2D` ou `CollisionShape2D`) devem ser mantidas em nós próprios. O plano de arte não deve substituí-las por polígonos visuais.

### 6.3 Composição da cena

A sala deve ser desenhada em três passagens:

**Passagem A — massa e silhueta:** parede, piso, portas, balcão e personagem em poucas cores. Sem textura ou efeitos.

**Passagem B — luz e valores:** sombras, áreas de luz âmbar, planos escuros e separação de planos. Verifique se o personagem se destaca.

**Passagem C — detalhes:** molduras, frisos, papel de parede, padrão do tapete, pequenas manchas e ruído discreto.

Cada passagem deve ser validada antes de começar a próxima. Caso a imagem não funcione em silhueta, não tente consertar com mais textura.

### 6.4 Regra de legibilidade de evidências

O objeto que será uma possível evidência precisa ser identificável no cenário sem um contorno piscante permanente. Crie um estado visual opcional quando o jogador se aproxima, mas mantenha a aparência normal discreta.

O nome, ID, descrição e o estado de coleta pertencem ao sistema de evidências. A definição da arte só fornece a forma e, opcionalmente, variações visuais como `default`, `highlighted` e `examined`.

---

## 7. Texturas rasterizadas geradas por código (opcional)

A estratégia inicial será desenho direto de CanvasItem. Não comece com `SubViewport` para cada prefab: isso gera texturas e memória que talvez não sejam necessárias.

Só implemente o sistema `ProceduralTextureBaker` depois do primeiro cenário funcionar e depois de medir uma necessidade real. Casos adequados:

- cenário estático com muitas primitivas;
- plano de parede, carpete ou backdrop que nunca muda durante a cena;
- textura procedural que precisa ser repetida como uma textura 2D.

Fluxo possível:

1. criar uma cena/viewport de tamanho lógico conhecido;
2. desenhar a arte procedurally nele;
3. renderizar uma vez, usando o modo de atualização `Once` quando apropriado;
4. obter a textura do viewport;
5. manter referência enquanto necessária;
6. destruir ou liberar as texturas quando o nível descarregar.

Outra opção é montar uma `Image` em memória e convertê-la em `ImageTexture`. Não faça isso para cada quadro de animação ou para cada frame do jogo.

**Regra de decisão:** comparar o desenho direto com a textura gerada usando medições reais, tamanho de memória e qualidade visual. O baker não é automaticamente mais rápido e não é requisito do MVP.

---

## 8. Cache e gerenciamento de recursos

### 8.1 Diferenciar os caches

Não confunda estas três coisas:

1. **Cache de Resource:** a Godot já mantém recursos carregados em cache conforme seu sistema de carregamento. Não faça uma cópia manual de cada `.tres` sem uma razão.
2. **Cache de instâncias/pool de nós:** reutiliza `Node` que seria criado e destruído repetidamente. Útil para objetos transitórios e recorrentes.
3. **Cache de textura gerada:** mantém `ImageTexture` ou `ViewportTexture` criada por código. Útil apenas para elementos rasterizados e quando a reutilização vale o custo de memória.

### 8.2 O que pode entrar no pool

Possíveis candidatos: pequenas partículas, marcadores temporários de interação, objetos decorativos repetidos que entram/saem frequentemente, instâncias de props em cenas montadas dinamicamente.

Não faça pool de paredes, um balcão único, uma porta fixa ou um NPC único que já permanece na cena. A complexidade do ciclo de vida não compensa automaticamente.

### 8.3 Restrições de cache

- O pool deve ter limite configurável por tipo/família.
- A instância precisa ter estado de animação, seleção e timers resetado antes de ser reutilizada.
- A chave de pool deve distinguir prefabs que têm tipos/estados incompatíveis.
- A limpeza ao trocar de cenário deve liberar as instâncias que não serão reaproveitadas.
- Não mutar um `Resource` compartilhado para animar uma única instância. Se o recurso for compartilhado, mantenha o estado de animação no nó/animator ou duplique explicitamente o dado que precisa ser independente.
- A existência do cache precisa ser justificada por contagem de instâncias e/ou medição. Se não houver ganho mensurável no MVP, mantenha-o simples.

---

## 9. Fases de desenvolvimento e entregáveis

As fases abaixo são sequenciais. Cada uma precisa deixar o projeto em estado executável.

### Fase 0 — Auditoria do projeto

**Objetivo:** conhecer o projeto real antes de alterar arquivos.

**Tarefas:**
- localizar `project.godot` e confirmar versão instalada da Godot;
- identificar a cena principal, configurações de janela, escala, filtros, renderer e Autoloads;
- localizar e ler os scripts `ProceduralArtDefinition`, `ProceduralArtRenderer` e `ProceduralPrefabCache` existentes;
- verificar se há erros de parser ou warnings relevantes;
- registrar a estrutura de pastas atual;
- executar importação/headless check caso a Godot esteja disponível.

**Não fazer:** reescrever scripts, implementar shader ou redesenhar a cena nesta fase.

**Entregável:** relatório curto de auditoria, lista dos arquivos a preservar, problemas observados e plano adaptado ao estado real do projeto.

**Aceite:** a IA sabe exatamente quais arquivos existem e não introduziu mudanças funcionais.

### Fase 1 — Guia de estilo e viewport

**Objetivo:** fixar uma base visual antes de desenhar assets.

**Tarefas:**
- criar o recurso `ProceduralStyleProfile` e a paleta inicial;
- criar cena `procedural_art_lab.tscn` para comparar cores, contornos e escalas;
- ajustar/reservar a resolução lógica 320×180, a ampliação inteira e o filtro nearest;
- mostrar a mesma forma em escala de edição e em tamanho real de jogo;
- documentar como mudar a paleta sem tocar no renderer.

**Entregável:** Style Lab executável com paleta, escala, amostra de parede, piso e silhueta.

**Aceite:** pixels nítidos em 1280×720 e 1920×1080; sem distorção por escala fracionária na configuração alvo; elementos continuam legíveis.

### Fase 2 — Definições e validação de comandos

**Objetivo:** padronizar a descrição matemática da arte.

**Tarefas:**
- revisar o schema atual de `ProceduralArtDefinition`;
- manter os comandos existentes (`rect`, `line`, `circle`, `polygon`) compatíveis;
- documentar os campos obrigatórios/opcionais de cada comando;
- adicionar validação para tipos desconhecidos, coordenadas e dimensões inválidas;
- definir um sistema simples de seed e variações, sem aleatoriedade por frame;
- criar pelo menos três recursos `.tres` de exemplo.

**Entregável:** esquema documentado, recursos de exemplo e validador.

**Aceite:** uma definição inválida produz mensagem útil; uma definição válida é desenhada; alterar a definição atualiza a arte sem precisar editar o renderer.

### Fase 3 — Renderer base

**Objetivo:** assegurar o funcionamento de um renderer genérico e reutilizável.

**Tarefas:**
- implementar somente comandos essenciais que faltarem após a auditoria;
- usar `_draw()` como local de desenho;
- chamar `queue_redraw()` apenas quando dados ou quadro mudarem;
- desenhar a lista de comandos em ordem;
- respeitar `pivot` e tamanho lógico;
- manter o renderer independente de colisão e gameplay;
- fornecer avisos de configuração quando não houver definição.

**Entregável:** mesma cena de renderer desenhando balcão, porta, luminária e quadro a partir de recursos diferentes.

**Aceite:** nenhuma lógica individual de cada prefab foi copiada para o renderer; não há redesenho contínuo sem necessidade.

### Fase 4 — Protótipo do corredor em silhuetas

**Objetivo:** validar composição sem efeitos.

**Tarefas:**
- criar piso, parede, porta, balcão e luminária com polígonos e retângulos;
- manter a cena separada em camadas;
- adicionar o detetive como silhueta simples provisória;
- conferir ordem de desenho e oclusão;
- testar a composição no tamanho 320×180.

**Entregável:** `hotel_corridor.tscn` sem textura, sem partículas e sem efeitos de pós-processamento.

**Aceite:** a cena já comunica que é um corredor/recepção de hotel; o personagem, o chão, a porta e o balcão são distinguíveis. Se a cena não funcionar sem efeitos, refaça a composição antes de avançar.

### Fase 5 — Materiais e padrões procedurais

**Objetivo:** dar caráter de material às superfícies sem utilizar imagens importadas.

**Tarefas:**
- criar padrões determinísticos para madeira, papel de parede, carpete e papel;
- aplicar poucos detalhes por área, em ordem de desenho previsível;
- garantir que cada padrão tenha parâmetros de escala, densidade, opacidade e seed;
- comparar cada superfície com e sem padrão;
- evitar gerar comandos demais para detalhes que pouco acrescentam.

**Entregável:** materiais procedurais reutilizáveis aplicados ao corredor.

**Aceite:** os materiais são distinguíveis, mas não competem com o personagem ou com a evidência; a seed reproduz a mesma composição.

### Fase 6 — Dithering e shader de estilo

**Objetivo:** aproximar a imagem da estética de survival horror de baixa resolução.

**Tarefas:**
- criar um shader `canvas_item` para dithering ordenado, com parâmetro de intensidade;
- opcionalmente criar quantização de cores e ruído sutil, cada efeito isolável;
- aplicar efeito apenas à camada visual do mundo, não ao HUD;
- fornecer forma fácil de desativar cada efeito para comparação;
- testar movimento de câmera para detectar cintilação.

**Entregável:** shader(s) documentados e perfil com presets de comparação.

**Aceite:** o estilo fica mais consistente sem destruir detalhes; não há ruído aleatório piscando; texto de UI permanece nítido; o efeito é opcional.

### Fase 7 — Detetive procedural

**Objetivo:** criar um personagem original legível.

**Tarefas:**
- definir uma silhueta com chapéu/cabelo, rosto sombreado, sobretudo, braços, pernas e sapatos;
- manter pivô na base dos pés;
- criar as definições de idle e quatro quadros de caminhada;
- criar a estrutura `ProceduralAnimationDefinition` e o player visual apenas se o fluxo de quadros comprovar que é útil;
- criar pose de investigação e uma pose de diálogo se o primeiro conjunto estiver correto;
- manter o movimento e as colisões no sistema de personagem existente.

**Entregável:** cena `detective_visual.tscn` com idle/walk e parâmetros de paleta.

**Aceite:** é claramente o mesmo personagem em todos os quadros; ele não “pula” de posição devido a pivôs inconsistentes; animação estável na resolução interna; nenhuma imagem/spritesheet externa.

### Fase 8 — NPC e props de primeiro plano

**Objetivo:** provar que o sistema escala para outros elementos.

**Tarefas:**
- criar silhueta da recepcionista com perfil visual próprio;
- criar porta, luminária, balcão e pelo menos um envelope/documento;
- permitir estados visuais `default`, `highlighted` e `examined` quando necessário;
- integrar o destaque ao sistema de interação existente sem mover a lógica para o renderer.

**Entregável:** corredor com o detetive, NPC, móveis e objeto potencialmente examinável.

**Aceite:** todos os elementos usam o renderer/dados compartilhados, mas têm silhuetas e IDs independentes; trocar o estado de interação não altera a regra de evidência.

### Fase 9 — Composição e pequenas variações de sala

**Objetivo:** organizar os prefabs como uma sala de jogo, sem aleatoriedade caótica.

**Tarefas:**
- criar `ProceduralRoomDefinition` para as instâncias, posições, camada visual e seed;
- implementar `ProceduralRoomBuilder` somente se facilitar de fato a montagem;
- suportar variação pequena de alguns props (por exemplo, uma cadeira ligeiramente deslocada ou uma luminária apagada);
- garantir que cada seed reproduza sempre a mesma sala;
- verificar o alinhamento com colisões/zonas interativas existentes.

**Entregável:** uma sala criada a partir de recurso de definição e pelo menos uma variação fixa de teste.

**Aceite:** o layout é reproduzível e fácil de inspecionar; objetos interativos não aparecem fora do alcance ou dentro de paredes por causa de randomização.

### Fase 10 — Cache e rasterização opcional

**Objetivo:** otimizar apenas o que tiver uma necessidade comprovada.

**Tarefas:**
- medir tempo de construção/desenho e número de comandos na sala;
- verificar se cache de `PackedScene`/Resource existente já é suficiente;
- identificar instâncias realmente repetidas e transitórias para o pool;
- considerar `SubViewport` ou `ImageTexture` somente para superfícies estáticas caras;
- definir limite de memória e política de liberação ao descarregar sala;
- evitar rasterizar o personagem animado ou pistas cuja aparência muda continuamente.

**Entregável:** decisão documentada entre manter desenho direto ou introduzir bake/cache, com medições antes/depois.

**Aceite:** não há cache introduzido apenas por antecipação; se adotado, há estratégia de invalidação e limpeza testada.

### Fase 11 — Validação, documentação e integração

**Objetivo:** deixar o sistema seguro para uso nas próximas fases do jogo.

**Tarefas:**
- verificar todos os recursos de arte do corredor;
- executar verificação headless/import do projeto e teste manual na Godot;
- criar instruções para adicionar um novo prefab sem modificar o renderer;
- confirmar que a arte não altera IDs nem regras das evidências;
- registrar limitações conhecidas e próximos passos;
- preparar uma lista do que pode ser reutilizado em apartamentos, escritórios, quartos e cenas de crime.

**Entregável:** projeto validado, documentação de uso e relatório de testes.

**Aceite:** outro desenvolvedor consegue criar um prop básico seguindo a documentação sem editar a lógica do renderer.

---

## 10. Testes objetivos

### 10.1 Testes de dados e renderer

- [ ] Definição válida com `rect` é desenhada.
- [ ] Definição válida com `polygon` é desenhada.
- [ ] Comando desconhecido gera aviso útil e não interrompe a cena inteira.
- [ ] Dimensões inválidas são rejeitadas ou ignoradas de forma segura.
- [ ] Alterar a definição solicita novo desenho.
- [ ] Ordem dos comandos corresponde à ordem visual esperada.
- [ ] Pivot mantém os pés do detetive alinhados no mesmo ponto entre quadros.
- [ ] Duas instâncias do mesmo prefab podem usar posição/estado de animação independentes.
- [ ] Uma seed fixa produz o mesmo padrão em execuções repetidas.

### 10.2 Testes de aparência

- [ ] A cena é compreensível em 320×180 sem zoom do editor.
- [ ] O detetive se destaca do fundo.
- [ ] Porta, chão, balcão e evidência podem ser distinguidos.
- [ ] Dithering não prejudica o reconhecimento de formas.
- [ ] O shader não se aplica ao texto de interface sem intenção explícita.
- [ ] Não há tremulação óbvia dos padrões durante a movimentação da câmera.
- [ ] A mesma paleta é respeitada pelos objetos principais.
- [ ] A cena ainda funciona com os efeitos desligados.

### 10.3 Testes técnicos

- [ ] Projeto abre e importa recursos sem erros de parser.
- [ ] Não há dependências de arquivos de imagem para a arte do mundo.
- [ ] Nenhum renderer chama `queue_redraw()` indiscriminadamente em `_process()`.
- [ ] Pools têm limites e liberam instâncias excedentes.
- [ ] Recursos compartilhados não são alterados de forma que faça uma instância mudar a arte de outra.
- [ ] Ao trocar de cena, as instâncias temporárias e texturas geradas são liberadas conforme a política adotada.
- [ ] A sala de teste mantém a meta de 60 FPS no ambiente de referência, sem alegar desempenho universal com base apenas em uma execução.

O teste de 60 FPS deve ser reportado com ambiente, resolução, modo de execução e quantidade de objetos de teste. Se houver quedas, registrar medições em vez de otimizar sem evidência.

---

## 11. Armadilhas técnicas que devem ser evitadas

| Armadilha | Regra para evitar |
|---|---|
| Um script monolítico desenha o hotel inteiro | Cada prefab tem definição própria; cenário apenas compõe os objetos. |
| Geometria aleatória em cada frame | Usar recursos salvos e seeds determinísticas. |
| Muitos detalhes antes de validar silhuetas | Construir massa, luz e detalhes em passagens separadas. |
| Aplicar shader à tela inteira | Separar mundo visual e HUD em camadas diferentes. |
| Achar que low-res sozinho cria estilo PS1 | Trabalhar paleta, ângulos, sombras, padrões e composição. |
| Redesenhar constantemente | Usar `_draw()` e invalidar somente quando dados/quadros mudarem. |
| Transformar todo objeto em textura gerada | Começar com desenho direto; rasterizar apenas quando medição justificar. |
| Fazer pool de todos os nós | Pool apenas para elementos transitórios/repetidos; não confundir com cache de Resource. |
| Compartilhar estado mutável dentro do Resource | Definições são dados de arte; estado de animação e interação fica no nó/instância. |
| Colisão baseada no contorno artístico | Usar colisões simples e independentes. |
| Detalhes minúsculos ilegíveis | Avaliar sempre na resolução real, não apenas ampliado no editor. |
| Alterar arte do objeto ao coletar a evidência de forma irreversível | Expor estados visuais; a lógica de evidência permanece no serviço/controlador de gameplay. |
| Sobrescrever scripts antigos sem migração | Auditar, preservar formatos e testar compatibilidade antes de refatorar. |

---

## 12. Organização recomendada para a IA local

### 12.1 Como trabalhar em cada fase

Para cada fase, a IA deve seguir este ciclo:

1. Listar arquivos que pretende criar/modificar.
2. Explicar brevemente como a tarefa usa a arquitetura existente.
3. Implementar somente o escopo dessa fase.
4. Executar verificação de sintaxe/importação disponível.
5. Inspecionar logs e corrigir erros introduzidos.
6. Mostrar como abrir e validar a cena no editor.
7. Marcar critérios de aceite como `PASS`, `FAIL` ou `NOT RUN`.
8. Resumir arquivos alterados e deixar o projeto em estado funcional.

Evite refatorações oportunistas. Se surgir uma necessidade fora do escopo, registre-a como pendência e só altere o escopo quando for necessário para a fase atual funcionar.

### 12.2 Prompt inicial para OpenCode

Copie este texto para iniciar o trabalho da IA local:

> Você é um engenheiro sênior de Godot 4/GDScript especializado em renderização 2D procedural. Leia `PLANO_ARTE_PROCEDURAL_PS1_THE_LAST_ALIBI.md` integralmente e inspecione o estado atual do repositório antes de editar qualquer coisa. O objetivo é construir um sistema original de arte procedural para The Last Alibi, com atmosfera de survival horror de baixa resolução inspirada na era PS1, adaptada para side-scroller 2D. Não importe nem gere arquivos de imagem para usar como arte final. Use definições matemáticas serializadas, desenho CanvasItem e shaders próprios; texturas rasterizadas em memória são permitidas apenas quando justificadas e geradas pelo código. Preserve os scripts e recursos existentes, especialmente `ProceduralArtDefinition`, `ProceduralArtRenderer` e `ProceduralPrefabCache`, a menos que a auditoria demonstre que uma mudança é necessária. Trabalhe somente na Fase 0 e produza o relatório de auditoria, sem começar as fases seguintes. Não invente testes executados. Depois de concluir a Fase 0, pare e apresente arquivos encontrados, comandos de validação executados, problemas reais e a proposta de alteração da Fase 1.

### 12.3 Prompt padrão para cada fase seguinte

> Leia a fase correspondente de `PLANO_ARTE_PROCEDURAL_PS1_THE_LAST_ALIBI.md` e revise o relatório da fase anterior. Implemente apenas essa fase. Antes de editar, liste os arquivos que criará ou modificará e confira compatibilidade com os recursos `.tres` existentes. Após a implementação, execute as verificações que estiverem disponíveis, corrija os erros causados pelas mudanças e marque cada critério de aceite como `PASS`, `FAIL` ou `NOT RUN`, informando evidências. Não afirme que o projeto foi testado no editor se só executou uma verificação estática/headless. Deixe o projeto em estado funcional, documente o que mudou e pare antes da próxima fase.

---

## 13. Referências técnicas oficiais

Use a documentação correspondente à versão de Godot instalada. Se a documentação online estiver em uma versão diferente, confirme que propriedades e métodos existem na versão usada pelo projeto.

- [CanvasItem — desenho personalizado, `_draw()`, `queue_redraw()` e primitivas](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html)
- [Múltiplas resoluções e Stretch Mode — documentação Godot 4.x em português](https://docs.godotengine.org/pt-br/4.x/tutorials/rendering/multiple_resolutions.html)
- [Recursos personalizados e arquivos `.tres` — documentação Godot 4.x em português](https://docs.godotengine.org/pt-br/4.x/tutorials/scripting/resources.html)
- [SubViewport — renderização para textura](https://docs.godotengine.org/en/stable/classes/class_subviewport.html)
- [Image — construção e manipulação de imagens em memória](https://docs.godotengine.org/en/stable/classes/class_image.html)
- [Shaders de CanvasItem — documentação Godot 4.x em português](https://docs.godotengine.org/pt-br/4.x/tutorials/shaders/shader_reference/canvas_item_shader.html)

---

## 14. Resultado final esperado

No fim deste plano, a IA local deve entregar uma pequena **Procedural Art Lab** e um corredor de hotel demonstrativo. O sistema precisa permitir criar um novo objeto principalmente através de um recurso de definição, sem programar um desenho exclusivo para cada prefab.

O protótipo não precisa chegar à qualidade de arte final de um jogo comercial. Precisa provar quatro coisas:

1. a direção visual é consistente e adequada à atmosfera de The Last Alibi;
2. o desenho procedural é reutilizável e editável por dados;
3. o estilo é legível na resolução real do jogo;
4. a integração não mistura apresentação com investigação, colisão, entrevistas ou evidências.

**Prioridade máxima:** silhueta, composição, contraste e legibilidade. Textura, dithering, ruído, rasterização e cache só devem ser adicionados quando reforçarem esses quatro pontos.
