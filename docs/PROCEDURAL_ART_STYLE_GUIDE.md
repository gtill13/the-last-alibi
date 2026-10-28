# The Last Alibi — Guia de estilo procedural PS1 (Fase 1)

> **Status:** Fase 1 validada em 28/10/2026
>
> **Escopo:** laboratório isolado de arte; o jogo principal continua em 1280×720
>
> **Regra central:** toda a arte é gerada por código. Não há sprites, ilustrações, fotos ou texturas importadas.

## 1. Princípios

1. **Procedural de verdade.** Formas, cores e composição vêm de `ProceduralArtDefinition`, `ProceduralArtRenderer` e recursos de estilo versionados.
2. **Resolução lógica baixa.** A imagem do jogo é composta em **320×180** e ampliada por um fator inteiro.
3. **Paleta controlada.** Cores são escolhidas por chave (`color_key`) em uma paleta compartilhada; comandos não devem espalhar hexadecimais soltos.
4. **Silhueta primeiro.** Um objeto precisa ser reconhecível no tamanho real, sem depender de detalhe fino.
5. **UI fora do viewport pixelado.** Texto e controles usam a resolução da janela e permanecem nítidos.
6. **Nada de escala fracionária.** O fator é sempre inteiro: 4× em 1280×720 e 6× em 1920×1080.

## 2. Resolução e escala

| Contexto | Resolução | Fator | Uso |
|---|---:|---:|---|
| Viewport lógico | 320×180 | 1× | composição, colisões visuais e leitura de silhueta |
| Janela padrão | 1280×720 | 4× | escala de jogo |
| Janela grande | 1920×1080 | 6× | escala de jogo em monitor 1080p |
| Prévia de edição | 320×180 | 1× | inspeção de pixel e composição |

O laboratório usa:

```text
ProceduralArtLab (Control)
├── GameViewport (SubViewport 320×180)
│   └── Scene (Node2D)
├── MainDisplay (TextureRect nearest)
└── UI (Control, fora do SubViewport)
```

`MainDisplay.texture_filter = TEXTURE_FILTER_NEAREST`, `expand_mode = EXPAND_IGNORE_SIZE` e
`stretch_mode = STRETCH_KEEP_ASPECT_CENTERED` no modo de jogo. A tecla **Tab** ou **P** alterna
para a prévia 1× (`STRETCH_KEEP_CENTERED`).

**Não altere** `project.godot` para 320×180 nesta fase. O mundo, a câmera, a HUD e as definições
antigas ainda estão autorados em 1280×720. A migração global é uma decisão posterior.

## 3. Paleta noir do hotel

Fonte: `art/procedural/palettes/palette_noir_hotel.tres`.

| Chave | Hex | Uso principal |
|---|---|---|
| `shadow_deep` | `#090D12` | contornos, sombras de contato, fundo do piso |
| `shadow_wall` | `#151C24` | parede em sombra, silhueta do sobretudo |
| `wall` | `#303236` | parede iluminada, painéis |
| `wood_dark` | `#49342D` | madeira escura, rodapé, porta |
| `wood_mid` | `#75513D` | topo de móveis, moldura, pele |
| `green_muted` | `#414A43` | variação fria, objetos de apoio |
| `wine` | `#4A292D` | tapete, cortina, volume quente |
| `amber` | `#B98243` | luz de lâmpada, metal, detalhe quente |
| `ivory` | `#C5BDA6` | papel, texto, brilho de contorno |
| `red_muted` | `#793C3B` | gravata, acento de sangue seco |

Regras:

- Use no máximo **dois ou três valores** para uma mesma superfície.
- Reserve `amber` e `ivory` para luz e foco. Se tudo brilha, nada brilha.
- Prefira `red_muted` a vermelho saturado.
- A paleta é um recurso externo ao perfil. Trocar uma cor no `.tres` deve atualizar o laboratório sem editar o renderer.

## 4. Perfil de estilo

Fonte: `art/procedural/profiles/ps1_noir_profile.tres`.

| Campo | Valor atual | Observação |
|---|---|---|
| `profile_id` | `ps1_noir` | identificador estável |
| `palette` | referência externa a `palette_noir_hotel.tres` | não embutir cópia |
| `logical_resolution` | `320×180` | resolução de composição |
| `logical_pixel_step` | `1` | um pixel lógico por passo |
| `outline_color` | `#090D12` (equivale a `shadow_deep`) | contorno escuro |
| `shadow_color` | `#090D12` (equivale a `shadow_deep`) | sombra dura |
| `highlight_color` | `#C5BDA6` (equivale a `ivory`) | brilho pontual |
| `dither_strength` | `0.0` | dithering fica para a Fase 6 |
| `noise_strength` | `0.0` | ruído fica para fase posterior |
| `color_quantization_levels` | `16` | margem para etapas futuras |
| `use_hard_shadows` | `true` | sombras geométricas |
| `use_procedural_texture` | `false` | textura fica para fase posterior |
| `seed` | `1337` | determinismo |

O renderer resolve `color_key` pela paleta do perfil. `alpha` multiplica o canal alfa e é limitado
entre 0 e 1. Comandos antigos com `color` continuam funcionando.

Exemplo de comando:

```gdscript
{
    "type": "rect",
    "position": Vector2(0, 96),
    "size": Vector2(320, 26),
    "color_key": "wood_dark",
    "alpha": 1.0,
}
```

## 5. Composição do Art Lab

A cena `scenes/art_lab/procedural_art_lab.tscn` monta uma recepção de hotel em 320×180:

- parede em dois valores, painéis verticais e rodapé de madeira;
- porta, quadro de avisos e relógio como âncoras de leitura;
- tapete em perspectiva e piso com linhas;
- silhueta do detetive à esquerda, em 32×64;
- mesa de recepção, luminária e envelope à direita;
- barra de paleta com dez amostras e códigos hexadecimais;
- rótulo de escala e dica de teclado fora do `SubViewport`.

O laboratório é uma **amostra de direção**, não uma sala final. Ele existe para provar quatro coisas:
paleta editável, viewport 320×180, ampliação inteira e leitura de silhueta.

## 6. Regras de autoria

1. Defina `definition_id`, `logical_size` e `pivot` antes dos comandos.
2. Use o pivô na base do objeto (pés do personagem, base do móvel) para encaixar no piso.
3. Desenhe do fundo para a frente; a ordem dos comandos é a ordem de pintura.
4. Prefira formas grandes e legíveis a muitos detalhes de um pixel.
5. Use `color_key`; `color` cru só é aceitável em protótipos ou testes.
6. Não importe imagens. Texturas em memória, `SubViewport` e shaders próprios são permitidos.
7. Valide a peça em 1× e em 4×/6×. Se só funciona ampliada, a silhueta está fraca.
8. Mantenha a UI fora do `SubViewport`.

## 7. Fluxo para adicionar uma peça

1. Adicione a definição em `tools/generate_art_lab.gd` (ou em um gerador próprio).
2. Rode o gerador:

```bash
export GODOT_BIN="/home/till/.local/share/Steam/steamapps/common/Godot Engine/godot.x11.opt.tools.64"
"$GODOT_BIN" --headless --path . -s res://tools/generate_art_lab.gd
```

3. Instancie um `ProceduralArtRenderer` na cena, atribua a definição e o perfil.
4. Adicione ou atualize o teste da cena.
5. Rode a suíte e capture a evidência visual.

## 8. Evidências visuais

| Arquivo | Resolução | O que valida |
|---|---:|---|
| `tests/manual/screenshots/art-lab/art_lab_1280x720_4x.png` | 1280×720 | escala 4×, UI nítida, paleta |
| `tests/manual/screenshots/art-lab/art_lab_1280x720_1x.png` | 1280×720 | prévia 1× centralizada |
| `tests/manual/screenshots/art-lab/art_lab_1920x1080_6x.png` | 1920×1080 | escala 6× em 1080p |
| `*_raw.png` | 320×180 | composição lógica sem ampliação |

Reproduza com:

```bash
./tests/manual/driver_art_lab.sh
```

Validação numérica executada em 28/10/2026: recortes das capturas 4×, 6× e 1× foram reduzidos
por nearest e comparados ao viewport cru de 320×180. O resultado foi **0 pixels de diferença** nos
três casos, confirmando escala inteira e filtro nearest.

## 9. Critérios de aceite da Fase 1

- [x] Paleta editável sem tocar no renderer
- [x] `SubViewport.size == 320×180`
- [x] Ampliação inteira: 4× em 1280×720 e 6× em 1920×1080
- [x] Filtro nearest sem borrão
- [x] Silhueta do detetive legível no tamanho real
- [x] UI fora do `SubViewport`, com texto nítido
- [x] Nenhum asset de imagem na cena do laboratório
- [x] Suíte completa passando, incluindo perfil, paleta, renderer e cena do lab

## 10. O que ainda não entra

- Dithering, ruído e quantização visual (Fase 6).
- Shaders de scanline, vinheta ou aberração cromática.
- Animação por definições e spritesheets procedurais.
- Migração global do jogo para 320×180.
- Correção dos painéis de UI que ainda usam propriedades de Godot 3.

Esses itens ficam para fases próprias, com validação separada. A Fase 1 prova a base: paleta,
resolução, escala e silhueta.
