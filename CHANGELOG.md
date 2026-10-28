# Changelog — The Last Alibi

## 0.1.0 (não lançado)

- Projeto Godot 4.7.2 inicial baseado em PLANO_DESENVOLVIMENTO_THE_LAST_ALIBI.md
- Estrutura de pastas e autoloads (GameState, SceneRouter)
- Main.tscn com WorldHost, UIHost, FadeOverlay
- Menu principal com Start Case e Quit
- Cena de teste (investigação) com investigador, câmera e área de teste
- M1 concluído: movimento lateral, câmera com limites, scanner por proximidade, prompt contextual e três alvos de teste
- Testes automatizados do M1 (35 testes) e registro manual em `docs/M1_TESTS.md`
- Protótipo de arte 100% procedural: `ProceduralArtDefinition`, renderer genérico, cache de prefabs, 6 definições, 5 prefabs e cena-demo
- Testes da arte procedural (23 novos, 58 no total) e validação visual em `docs/ARTE_PROCEDURAL.md`
- Fase 1 da direção PS1: Art Lab isolado em 320×180, paleta noir compartilhada, perfil de estilo, escala nearest 4×/6× e prévia 1×
- Guia de estilo em `docs/PROCEDURAL_ART_STYLE_GUIDE.md`, capturas em `tests/manual/screenshots/art-lab/` e driver `tests/manual/driver_art_lab.sh`
- Testes da Fase 1 (26 novos, 84 no total): paleta, perfil, color-key/alpha no renderer e estrutura do Art Lab
