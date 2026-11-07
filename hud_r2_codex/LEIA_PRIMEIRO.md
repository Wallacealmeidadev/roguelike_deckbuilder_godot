# Repasse ao Codex — HUD de combate R2

Data: 28/09/2026. Direção aprovada por Wallace nesta conversa.

## Pedido de execução

Implemente a direção R2 no projeto Godot local. O usuário aprovou a ideia e os símbolos, aceitou adiar o acabamento e quer retomar melhorias visuais depois da integração. Leia as instruções do repositório e o STATUS.md local antes de editar. Identifique as cenas, componentes e sinais existentes; faça a implementação e sua validação, não apenas um plano. Preserve alterações locais do usuário.

Este pacote é um briefing com assets, não uma cópia do jogo. O projeto completo não esteve disponível nesta sessão. O código local e seus dados são a fonte de verdade para regras e valores.

## Referência aprovada

Figma R2: https://www.figma.com/design/zF2x3sUJp0jjh41ERsjTlu?node-id=14-6

- Repouso: node 14:7.
- Inspeção de intenção: node 14:76.
- Resposta ao dano: node 14:145.
- A revisão R1, node 4:3, foi superada pela R2.

O Figma contém estudos estáticos. Não há animação, tooltip funcional ou jogo implementado ali. O limite de chamadas do plano impediu a correção final da escala de alguns ícones; não reproduza os recortes e sobreposições resultantes. O Figma é referência de composição, não requisito de acesso para executar. Os SVGs deste pacote recuperam o mesmo código vetorial usado para construir os oito símbolos R2; não são uma nova interpretação nem uma exportação posterior do Figma.

## Decisões aprovadas

1. HP: manter a barra limpa. Remover a placa e os textos persistentes “VIDA” e “40/40”. Preenchimento proporcional ao HP real; valores exatos consultáveis por hover/foco. Uma única leitura de HP por combatente no espaço de combate.
2. Intenções: símbolo acima de cada inimigo e números táticos indispensáveis, por exemplo 3 × 2. Nome do movimento e regra no contexto de inspeção. Intenções sem dano também devem ter símbolo apropriado, sem inventar valores.
3. Buffs e debuffs: abaixo da barra do respectivo combatente, com ícone e quantidade/duração conforme a regra real. Ocultar efeitos inativos, não mostrar rótulos zerados. Recursos persistentes, como Combo, podem permanecer em zero para comunicar progresso.
4. Energia: símbolo próprio e contador, sem a palavra ENERGIA. Atualizar a partir do estado real. O custo das cartas e o contador devem ser semanticamente coerentes.
5. Compra e descarte: representações diferentes e contagem, sem títulos permanentes. Hover/foco explica; preservar a interação já existente para inspecionar as cartas.
6. Relíquias: ilustração própria em repouso, nome e efeito por inspeção. O símbolo reliquia.svg representa o estudo de Juntas de Retorno; não reutilizar a mesma figura para toda relíquia futura.
7. Mudança de turno: anúncio transitório. Evitar placa permanente “SEU TURNO” junto de outro contador ou log redundante. O botão “Encerrar turno” pode continuar com texto.
8. Preservar regras, custo, dano, turnos, seleção, foco, dimensões e comportamento da mão já aprovados. A montagem raster da mão no Figma não é uma nova especificação de espaçamento ou quantidade de cartas.

## Direção artística

Cyberpunk em HQ expressiva e exagerada. Atitude e rebeldia com estranheza e descoberta. Esta identidade vale para o mundo completo: não reduzir o jogo a Docas, clínicas, ferragens ou um único distrito.

Os oito símbolos anexos são a base visual aprovada. Preservar silhuetas e distinções; não substituir por emojis, ícones de biblioteca genéricos ou pelo mesmo raio para energia e ataque. Usar contorno de tinta comum e contrastes legíveis. Evitar placas inclinadas em tudo, brilho neon indiscriminado, circuitos decorativos e novas molduras que voltem a poluir a tela.

Valores da proposta: tinta #10161E, superfície #1D2933, linha #3D505A, papel #F5ECD9, secundário #A3B3BB, ciano #40E4DF, vermelho #F45C54, amarelo #ECCE6B. Bangers para destaques e Barlow Semi Condensed para leitura/valores, reaproveitando as fontes existentes. A paleta é referência desta revisão, não uma trava para futuros estudos.

## Assets e escala

- icones/energia.svg: célula de energia; contador deve ser texto vivo, sem recorte.
- icones/ataque.svg: disparos, para a intenção ofensiva representada.
- icones/barreira.svg: proteção.
- icones/combo.svg: elos encadeados.
- icones/compra.svg: pilha de compra.
- icones/descarte.svg: pilha de descarte.
- icones/reliquia.svg: estudo de articulação para Juntas de Retorno.
- icones/rota.svg: contexto de percurso.

SVGs com viewBox 0 0 48 48, sem fontes ou recursos externos. Importar como assets do projeto e preservar proporção. Não copiar o erro de redimensionar só o container e cortar o desenho. Verificar tamanho real pequeno, contraste e espaço de contadores; ajustar escala/padding primeiro. Não rasterizar o HUD inteiro nem usar capturas de cartas como interface final.

## Comportamento a implementar

- Hover e foco acessível devem revelar contexto equivalente. Não deixar dados táticos disponíveis apenas por cor.
- Tooltip próximo ao elemento, dentro da tela e sem encobrir mão, barra ou alvo necessário à decisão. Ao trocar de alvo, encerrar combate ou remover o efeito, limpar contexto obsoleto.
- Dano atualiza o HP lógico imediatamente. A apresentação pode mostrar um trecho recente de dano que desaparece brevemente e um número temporário. A animação não pode alterar regras, atrasar resolução lógica ou acumular valores incorretos com golpes múltiplos.
- Mostrar mudanças de energia, pilhas, Combo, Barreira e efeitos a partir dos sinais/dados existentes. Não fixar valores do mockup.
- Inspeção da vida exibe atual/máximo. Repouso continua sem números na barra, conforme decisão explícita do usuário.
- Não ampliar escopo para novos personagens, inimigos, balanceamento ou sistema de animação de personagens.

## Exemplo visual, não regra nova

O terceiro quadro ilustra Direto Hidráulico: 4 de dano, +2 Barreira, +1 Combo; energia de 4/4 para 3/4; inimigo de 30 para 26 HP; descarte de 0 para 1. Esses dados foram lidos da carta na captura. Conferir a definição atual no projeto e usar seus valores se houver diferença. A carta sai da mão na resolução real; não copiar literalmente a disposição de cinco recortes no Figma.

## Validação e entrega

Verificar no combate real: repouso, inspeção, dano, defesa, efeitos ativos/inativos, múltiplos acertos, recursos zerados e fim de combate. Preservar interação/foco com mão cheia 10/10 e os tamanhos aprovados. Conferir composição em 1024×576 e resolução grande suportada; registrar dimensões reais da janela, não chamar 1920×1061 de 1920×1080.

Executar os testes existentes relevantes e a importação headless com a versão local da Godot. Acrescentar testes apenas para riscos reais de comportamento modificados. Os 41 testes relatados anteriormente pelo Codex são histórico; não assumir que passaram nesta implementação. Salvar capturas de repouso, tooltip e dano/estado; inspecioná-las. Atualizar STATUS.md com mudanças, verificações, caminhos das evidências e acabamento pendente.

Ao terminar, informar o que foi implementado, quais verificações realmente rodaram e o que permanece para a próxima rodada artística. Não alegar validação interativa se só houve headless. Não bloquear a integração por pequenos refinamentos artísticos: a base R2 já foi aprovada.
