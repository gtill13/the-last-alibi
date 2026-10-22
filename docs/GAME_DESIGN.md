# Design do jogo — The Last Alibi

## Pitch

The Last Alibi é um RPG de investigação 2D side-scroller. O jogador reexamina
cenas de crimes depois que a polícia já isolou o local, removeu o corpo e
registrou as pessoas envolvidas. A polícia não fez uma investigação profunda.

O jogador explora, examina objetos, recolhe evidências, entrevista pessoas e
monta um dossiê. Depois ocorre um julgamento que informa se houve condenação,
absolvição, condenação equivocada ou outro resultado.

**Promessa central:** o jogador pode acusar qualquer suspeito, mas não controla
a verdade nem garante que o tribunal aceitará a conclusão.

## Pilares de design

1. **Observar é jogar:** a exploração revela informações que não aparecem no relatório inicial.
2. **Provas têm contexto:** recolher um objeto não basta; é preciso interpretar por que importa.
3. **Entrevistas são evidência:** depoimentos, perguntas e contradições afetam o dossiê.
4. **A acusação tem consequências:** o jogador pode errar, deixar o culpado escapar ou condenar um inocente.
5. **O julgamento deve ser compreensível:** o resultado pode surpreender, mas não parecer aleatório.
6. **Arte não mascara problemas de design:** protótipo com caixas, silhuetas, texto e cores de depuração.

## O que o jogo NÃO precisa ser no protótipo

- Combate, furtividade, armas, árvore de habilidades ou mundo aberto.
- Dezenas de casos antes de validar um caso completo.
- IA generativa para diálogos ou culpa.
- Simulação jurídica real de um país específico.
- Animações finais, retratos ilustrados, trilha sonora ou partículas.
- Obrigatoriedade de encontrar 100% dos itens.

## Loop principal

Briefing → Exploração → Exame → Entrevista → Caderno → Encerrar visita → Montar dossiê → Julgamento → Revisão → Recomeçar/continuar.
