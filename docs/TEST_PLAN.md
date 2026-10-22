# Plano de testes — TEST_PLAN.md

## Testes unitários prioritários

1. CaseSession.register_evidence() não aceita IDs duplicados.
2. CaseSession não aceita evidência que não pertence ao caso.
3. Registros de entrevistas ficam associados ao suspeito correto.
4. Tópicos bloqueados não aparecem até o requisito ser cumprido.
5. DossierValidator rejeita IDs inexistentes, duplicados ou pertencentes a outro caso.
6. Provas recolhidas, mas não anexadas, não afetam o julgamento.
7. Mesmo dossiê sempre produz o mesmo veredito (determinístico).
8. Culpado acusado com prova insuficiente não é condenado automaticamente.
9. Suspeito inocente pode ser acusado e o jogo mostra resultado coerente.
10. Reiniciar a sessão limpa descobertas, gravações e submissão anterior.

## Testes de fluxo manual

- Iniciar caso, ler briefing, entrar no cenário.
- Investigar sem registrar nada e sair.
- Registrar uma evidência, fechar/abrir caderno, confirmar persistência.
- Entrevistar pessoa, fechar painel, abrir gravação no caderno.
- Encontrar pista, desbloquear follow-up, ver gravação atualizada.
- Acusar cada um dos suspeitos.
- Enviar dossiê sem provas.
- Anexar uma prova relevante e deixar outra fora.
- Cancelar montagem e confirmar que escolhas não foram perdidas.
- Submeter; verificar fade e relatório.
- Reiniciar o caso e garantir que o estado não vazou.
- Redimensionar janela para 1280×720 e resolução menor.

## Checklist por marco

- [ ] Projeto abre na versão de Godot fixada (4.7.2).
- [ ] Não há erros de parser ou referências quebradas.
- [ ] A fase completa pode ser percorrida.
- [ ] O estado não depende de ordem de carregamento.
- [ ] Lógica de julgamento tem testes ou casos manuais documentados.
- [ ] Não foram introduzidos assets finais prematuramente.
- [ ] README/CHANGELOG atualizados se comandos ou estrutura mudaram.
