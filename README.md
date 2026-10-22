# The Last Alibi

RPG de investigação 2D side-scroller — protótipo (graybox).
Engine: **Godot 4.7.2 stable** (GDScript).

> Este é um protótipo de vertical slice. O foco é validar o loop de investigação:
> explorar, examinar, entrevistar, montar dossiê e enfrentar o julgamento.
> Arte, áudio e campanha final são adiados.

## Como executar

1. Instale o **Godot 4.7.2 stable** (usado para este projeto).
2. Abra o Godot e escolha "Importar" ou "Abrir", apontando para esta pasta
   (`/home/till/Projects/the-last-alibi`).
3. Clique no botão de "Executar projeto" (▶) ou pressione `F5`.

## Controles (protótipo)

| Ação | Teclado |
|------|---------|
| Mover esquerda | `A` / seta esquerda |
| Mover direita | `D` / seta direita |
| Interagir / Examinar | `E` |
| Abrir caderno | `N` |
| Cancelar / Voltar | `Esc` |
| Confirmar | `Espaço` |
| Tela cheia | `F11` |

## Estrutura do projeto

```
res://
  project.godot
  README.md
  CHANGELOG.md
  docs/
    GAME_DESIGN.md
    CASE_FORMAT.md
    TEST_PLAN.md
  assets/placeholder/   # placeholders temporários
  data/cases/bellweather_apartment/  # dados do caso de teste
  scenes/               # cenas (.tscn)
  scripts/              # GDScript (.gd)
    autoload/           # GameState, SceneRouter
    core/               # CaseSession, CaseEvaluator, InvestigationRules
    player/             # InvestigatorController, InteractionScanner
    interactables/      # Interactable, InspectableObject, SuspectNPC, ExitPoint
    investigation/      # EvidenceService, InterviewService, NotebookModel
    dossier/            # DossierModel, DossierValidator
    ui/                 # apresentadores de UI
    resources/          # recursos de dados (CaseDefinition, etc.)
    utilities/          # IDs, debug
  tests/                # testes de unidade
```

## Fases de desenvolvimento (conforme PLANO_DESENVOLVIMENTO_THE_LAST_ALIBI.md)

- **M0**: Projeto executável + Git (menu + cena de teste)
- **M1**: Movimento + interação
- **M2**: Exame + evidências
- **M3**: Entrevistas + gravações
- **M4**: Saída + montagem de dossiê
- **M5**: Julgamento determinístico
- **M6**: Caso vertical slice completo

## Validação

O Godot não traz runner de testes GDScript nativo por padrão. Os testes em `tests/`
são scripts GDScript que podem ser executados no editor para validação manual da
lógica de julgamento e sessão.

## Licença

Projeto de protótipo interno. Sem arte final ou áudio incluído.
