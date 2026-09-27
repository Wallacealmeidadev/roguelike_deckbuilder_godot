# Estado do projeto

## Limpeza do workspace — 27/09/2026

O workspace foi reorganizado para manter na raiz somente os arquivos do jogo, os testes e a configuração/documentação necessária. Capturas e artefatos de validação foram movidos para `docs/evidencias/`, com `.gdignore` para não participarem da importação do jogo. Os previews determinísticos que não eram carregados pelo runtime nem pelos testes foram removidos. O auxiliar compartilhado `preview_fluxo.gd` foi movido para `tests/preview_fluxo.gd`, e os dois testes que o utilizam foram atualizados.

`node_modules`, os arquivos npm e o cache local `.godot` foram retirados da raiz por movimento reversível para a pasta de Downloads; não são dependências do jogo e podem ser regenerados. `ui_hq_v1`, cenas, scripts, dados, testes e documentação foram preservados. A suíte foi executada após a reorganização, com `TESTES=40 FALHAS=0`; `test_apresentacao_combate.tscn` também passou isoladamente. A importação da Godot 4.7.2 foi necessária para reconstruir temporariamente o cache de classes/importações antes da suíte; o cache foi retirado novamente ao final.

## Dimensionamento efetivo das cartas da mão de combate — 27/09/2026

Reproduzida a divergência na sequência real de resolução `1024x576 -> 1920x1080 -> 1024x576`. Antes da correção, `botao_carta.gd::configurar_escala()` atualizava apenas `custom_minimum_size`: a carta retornava a 1024 com `size=(225,360)` e mínimo `(120,192)`, enquanto uma carta criada diretamente em 1024 também conservava o tamanho efetivo da cena. A mão, que posiciona os filhos pelo `size`, calculava a geometria com esse valor stale.

Corrigido em `botao_carta.gd`: quando `permitir_reducao` identifica o caminho da mão de combate, `size` recebe explicitamente `custom_minimum_size`; recompensa e descanso continuam usando somente o dimensionamento aprovado pelos containers. `_atualizar_transformacao(false)` agora cancela o Tween vigente antes de aplicar a escala imediata, evitando que a animação antiga sobrescreva o resultado. A ordem de desenho não foi alterada: o foco continua elevando a carta pelo `z_index` existente.

`SelecaoLabel` não é mais exibido no combate: a seleção persistente continua sendo mostrada pela camada `Foco`, e o rótulo externo que ficava fora da raiz não aparece na mão. A identidade visual no descanso foi preservada.

Medições reais após a correção: carta inicial em 1024 `120x192`, em 1920 `225x360`, retorno a 1024 `120x192`, e carta criada diretamente em 1024 `120x192`. Durante o redimensionamento com foco, a carta permaneceu em `225x360` com escala `1.08`; a captura após a estabilização manteve a mesma geometria.

Capturas GL Compatibility em pasta nova: [mao_dimensionamento_2026-09-27](evidencias/mao_dimensionamento_2026-09-27/), incluindo início e retorno em 1024, 1920, entrada, foco durante redimensionamento e foco estabilizado. As imagens foram inspecionadas; a execução headless foi usada apenas para medidas/testes porque o renderer dummy não expõe textura de viewport.

Verificação executada: `tests/test_layout_combate.tscn` passou; a suíte completa terminou com `TESTES=40 FALHAS=0`; importação do editor headless terminou com código 0 e `git diff --check` passou. O warning `Scan thread aborted` ocorreu no encerramento da importação, sem código de falha.

## Investigação e correção das divergências da mão de combate — 27/09/2026

A reprodução foi feita com Godot 4.7.2 GL Compatibility no fluxo de `main.tscn` e no preview `preview_combate_estados.tscn`. A causa da borda inferior apertada era estrutural: `mao_combate.gd` posicionava a carta pelo tamanho lógico e pela margem fixa, mas não reservava a extensão dos cantos após rotação. Em 1024×576, a carta normal de seis cartas tinha limite transformado inferior com margem de aproximadamente 12,16 px; depois do cálculo estrutural, a margem passou para aproximadamente 14,64 px. O foco da mesma carta ficou com margem aproximada de 14,58 px. A mão de dez cartas não usa rotação e manteve sua sobreposição controlada.

A causa da Proteção ampliada em `combate_hud_estados_defesa_1024x576.png` era do preview, não do combate: `preview_combate_estados.gd` mantinha `button_pressed = true` da captura de carta selecionada antes de salvar os estados. O preview agora limpa seleção, foco, escala e camada de seleção antes das capturas de estados e aguarda a maior animação de entrada. A causa dos fragmentos aparentes foi separada: a ordem efetiva de desenho já colocava a carta focada em `z_index=20` e seus filhos entre 20 e 23, acima dos vizinhos em 0 a 3; os títulos laterais restantes pertencem às cartas sobrepostas atrás, não cobrem o conteúdo da carta focada.

Alterados `mao_combate.gd`, `botao_carta.gd`, `preview_combate_estados.gd` e `tests/test_layout_combate.gd`. O layout calcula a extensão inferior transformada usando a inclinação e o mesmo fator de foco de combate (`1.08`), sem reduzir as cartas nem criar offsets por resolução. O teste passou a verificar os cantos transformados na viewport, a ordem efetiva de desenho e a estabilidade após as animações.

Capturas reais regeneradas e inspecionadas: início em 1024×576, 1280×720 e 1920×1080; estados neutros em 1024×576 e 1920×1080; mão cheia e foco nas posições 0, 5 e 9 em 10 cartas, foco 0, foco 5 e foco 9; mão de seis cartas com foco 0, foco 3 e foco 5. As imagens foram capturadas após a estabilização das animações.

Verificação executada: `tests/test_layout_combate.tscn` passou; a suíte completa terminou com `TESTES=40 FALHAS=0`; a importação do editor headless terminou com código 0 e `git diff --check` passou. A inspeção visual confirma cartas inteiras, foco elevado sem cobrir Energia ou `Encerrar turno`, estados legíveis e ausência da seleção herdada na captura de defesa. A automação continua usando foco de teclado; movimento físico do cursor não foi usado como evidência.

## Ajuste final de geometria e leitura do HUD de combate - 27/09/2026

Reproduzidas no fluxo real as duas causas restantes: a mao de seis cartas usava passos completos mesmo quando a faixa disponivel terminava junto de `EncerrarTurno`; a mao de dez ja usava sobreposicao. O foco das cartas de combate escalava apenas 1,025 e a primeira carta encostava no painel de Energia. A faixa de estados reservava espaco para o titulo redundante `ESTADOS`, comprimindo icones e valores.

Corrigidos `mao_combate.gd`, `botao_carta.gd`, `main.tscn`, `main.gd`, `preview_combate_estados.gd` e `tests/test_layout_combate.gd`. A mao agora calcula um passo limitado pela largura util para qualquer quantidade, usa margem inferior que inclui a rotacao e termina antes do botao de turno. O foco/hover de combate usa escala 1,08, elevacao e pivot inferior; a selecao persistente continua separada. Recompensa e descanso preservam o fator anterior para nao alterar seus tooltips. Energia foi deslocada para uma faixa propria acima da mao. A faixa de estados ficou mais alta, sem o titulo redundante, com icones e valores alinhados; pilhas continuam separadas.

Capturas reais GL Compatibility geradas depois das animacoes: inicio 1024, inicio 1280, inicio 1920, mao cheia 10/10, foco primeira, foco central, foco ultima, estados 1024 e estados 1920. A inspeção confirma a mão curta contida, a mão cheia sobreposta dentro da faixa, foco ampliado sem invadir Energia/Encerrar turno e estados legíveis nas duas resoluções.

Verificação: o teste RED cobriu colisao da mao curta, faixa de estados comprimida, titulo redundante, foco 1,025 e foco sobre Energia. Depois, `test_layout_combate.tscn`, `test_composicao_combate.tscn`, `test_interacao_hud_combate.tscn` e `test_apresentacao_recompensas.tscn` passaram; a suíte completa terminou com `TESTES=40 FALHAS=0`, a importação headless do editor terminou com código 0 e `git diff --check` passou. As capturas automatizadas usam foco de teclado e aguardam a animação; não foram tratadas como prova de movimento físico do cursor.

## Acabamento e contencao do HUD de combate - 27/09/2026

Reproduzidos os problemas do HUD real e do preview. A causa de `BARALHO 12` escapar do painel era o `RunStatusLabel` com tres linhas em altura fixa. A causa da area de reliquia colidir com Barreira/Combo era a ausencia de um painel proprio. Em 1024, os estados do inimigo e as pilhas ocupavam faixas vizinhas sem separacao vertical; o painel vazio tambem exibia `SEM ESTADOS`. A mao cheia ainda era preparada diretamente no preview e, por isso, mostrava `Mao 6/10` apesar de conter dez cartas. O `HBoxContainer` expandia a faixa pela soma das larguras minimas e empurrava as ultimas cartas para fora da viewport. O foco de teclado nao entrava no mesmo destaque visual do hover em combate.

Corrigidos `main.tscn`, `main.gd`, `mao_combate.gd`, `botao_carta.gd`, `preview_combate_estados.gd` e as regressões de HUD. O status superior agora tem altura estrutural para tres linhas; `RelíquiaPainel` ocupa uma faixa separada; os estados ficam abaixo da Vida inimiga e sao ocultados quando vazios; compra/descarte ficam abaixo dessa faixa; Energia continua mostrando `atual/maxima`, inclusive `0/4`, com `SEM ENERGIA` como complemento. A mao passou a ser uma faixa `Control` com layout manual: ate seis cartas mantem a curva, e acima disso as cartas conservam tamanho visual e sobreposicao controlada dentro da viewport. Hover/foco traz a carta para frente sem ativar selecao; selecao de combate continua sendo o estado persistente.

Capturas reais GL Compatibility geradas e inspecionadas por `preview_combate_estados.tscn`: inicio 1024, inicio 1280, inicio 1920, mao cheia pelo baralho real, foco primeira carta, foco carta central, foco ultima carta, defesa e estados e energia zerada. A mao cheia mostra `10/10` e `Compra 2`; as capturas de foco mostram a carta ativa ampliada e legivel sem deslocar vizinhas nem invadir `Encerrar turno`.

Verificacao executada com Godot 4.7.2 GL Compatibility: RED inicial registrado para painel de reliquia, estados vazios, mao de dez cartas pequena e foco sem elevacao; depois, as 40 cenas em `tests/*.tscn` passaram, incluindo `test_composicao_combate.tscn` e `test_layout_combate.tscn` em viewport reduzido. A importacao headless do editor e `git diff --check` passaram. A interacao por sinais, clique e foco permanece coberta pelos testes existentes; uma sessao adicional com cursor fisico em cada resolucao continua sendo validacao manual separada da captura automatizada.

Pendencias preservadas: representacoes de Vega/inimigos continuam quadrados provisiorios; sprites definitivos, chefe e balanceamento seguem fora do escopo.

## HUD de combate com kit HQ — 27/09/2026

Aplicada a apresentação do combate a partir de `02_combate.png`, preservando regras, seleção de alvo, cartas, custos, dano, Combo, intenções, recompensas, eventos, descanso e progressão do mapa. `main.tscn` e `main.gd` reorganizam o HUD em jogador à esquerda, inimigo à direita, turno no topo, recursos acima da mão e `Encerrar turno` separado no canto inferior. Vida usa barras proporcionais; Barreira, Exposto e Enfraquecido usam ícones e valores reais. A intenção agora separa nome em Bangers e valor/multiplicidade em Barlow, ambos derivados de `InimigoCombate.texto_intencao()`; o rótulo legado permanece oculto para não duplicar a apresentação.

`botao_carta.gd` mantém a escala aprovada das recompensas e do descanso, mas aceita redução somente quando chamada pelo modo mão de combate. Para dez cartas, `mao_combate.gd` abandona o leque e a animação de entrada quando necessário, mantendo todas as cartas dentro da faixa e sem cobrir Energia ou `Encerrar turno`. A moldura-base e a camada ciano transparente de foco foram preservadas nos alvos e no botão de turno; nenhum fade foi reintroduzido no nó-raiz das cartas.

Capturas reais GL Compatibility geradas por `preview_combate_estados.tscn` e inspecionadas: início 1024, início 1280, início 1920, foco no alvo, carta selecionada, defesa e estados, sem Energia e mão com dez cartas. A captura inicial de 1024 mostra a mão completa e o botão de turno fora da área das cartas; a captura de 1920 mostra a defesa `+6` e os estados `6`, `2` e `1` com ícones.

Verificação executada com Godot 4.7.2 GL Compatibility: 40 cenas em `tests/*.tscn`, incluindo `test_composicao_combate.tscn`, `test_layout_combate.tscn`, `test_apresentacao_combate.tscn` e a interação do HUD, passaram em modo headless; a importação headless do editor terminou com código 0; `git diff --check` passou. As capturas reais foram inspecionadas separadamente da suíte headless.

Pendências preservadas: Vega e os inimigos continuam representações quadradas provisórias; sprites definitivos, chefe e novas mecânicas permanecem fora do escopo. As capturas automatizadas validam foco e sinais de interação; não substituem uma sessão manual com cursor físico em todas as resoluções.

## Acabamento visual do mapa e do pré-chefe — 27/09/2026

A apresentação dos nós foi unificada em `main.gd`: todos os estados usam a mesma moldura HQ de `botao_normal.tres`; hover, foco e pressão preservam essa base e ativam somente a camada `Interacao` transparente com destaque ciano. Os estados de progressão continuam diferenciados por modulação, ícone, marcador e conexões. A moldura arredondada anterior não é mais aplicada ao hover/foco dos nós.

Os rótulos de etapa foram retirados dos nós individuais e passaram para `MapaRotulosPontos`, uma camada única abaixo do grafo que exibe P1 a P7 uma vez por coluna. O painel de detalhes e as conexões permanecem separados dessa linha. `Reiniciar` recebeu a faixa HQ, fonte Bangers, altura mínima de 72 px, margens internas de 28/16 px e foco ciano transparente; a ação `Jogar novamente` e a tela provisória de pré-chefe permanecem as mesmas.

Capturas reais GL Compatibility inspecionadas: [normal 1024](evidencias/mapa_initial_1024x576.png), [hover 1024](evidencias/mapa_hover_1024x576.png), [foco 1024](evidencias/mapa_focus_1024x576.png), [bifurcação 1280](evidencias/mapa_branch_1280x720.png), [pré-chefe 1024](evidencias/mapa_preboss_1024x576.png) e [foco 1920](evidencias/mapa_focus_1920x1061.png). A captura solicitada como 1920×1080 resulta em área útil 1920×1061 neste ambiente. A prévia de hover emite o sinal real `mouse_entered` do botão sem usar `warp_mouse`; a interação física pelo cursor continua distinta dessa captura determinística.

Verificação executada com Godot 4.7.2 Compatibility: `test_apresentacao_mapa.tscn`, `test_navegacao_mapa.tscn` e `test_fluxo_mapa_principal.tscn` passaram em 1024×576; as 40 cenas de `tests/*.tscn`, a importação headless do editor e `git diff --check` terminaram com código 0. Progressão, conexões, encontros, recompensas e bloqueio de Lastro não foram alterados. A arte específica de Lastro continua pendente; a tela segue provisória.

## Apresentação visual do mapa ramificado — 27/09/2026

Aplicada a apresentação do mapa integrado como fluxo principal em `main.tscn`, `main.gd` e `mapa_conexoes.gd`, usando `11_mapa.png` como referência de composição. O cabeçalho agora usa a faixa HQ com `DOCAS`, `MAPA DAS DOCAS`, Vida e tamanho do baralho. O grafo mostra todos os nós reais do modelo, em sete colunas, com ramificações acima/abaixo, ícones de combate, evento, elite, descanso e chefe, linhas derivadas de `mapa_run.conexoes` e estados visuais de atual, disponível, concluído, futuro e reservado.

Os nomes longos ficam na área de detalhes ao receber foco ou hover; os ícones e marcadores permanecem dentro dos nós e não interceptam o mouse. A informação de variante foi removida da interface. O painel de detalhes foi estruturado com um único conteúdo interno e margem explícita para impedir que a tipografia Bangers toque a tinta superior da moldura. A progressão, os encontros, recompensas, descansos, bloqueios e pré-chefe não foram alterados.

Verificação executada com Godot 4.7.2 Compatibility: `test_apresentacao_mapa.tscn`, `test_navegacao_mapa.tscn` e `test_fluxo_mapa_principal.tscn` passaram após a correção do painel. As 40 cenas de `tests/*.tscn`, a importação headless do editor e `git diff --check` terminaram com código 0. O teste visual confirma também as duas variantes, a presença das conexões reais, a árvore única do painel de detalhes e os filtros de mouse dos ícones. A cena legada `test_apresentacao_recompensas.tscn` ainda emite aviso de recursos em uso no teardown, apesar de concluir suas asserções e retornar código 0; isso não é causado pelo mapa.

Capturas reais geradas pelo fluxo de preview com viewport 1152×648: [mapa inicial 1024](evidencias/mapa_initial_1024x576.png), [bifurcação 1280](evidencias/mapa_branch_1280x720.png), [retorno após descanso 1024](evidencias/mapa_rest_1024x576.png), [foco 1920](evidencias/mapa_focus_1920x1061.png) e [pré-chefe 1280](evidencias/mapa_preboss_1280x720.png). A janela solicitada como 1920×1080 foi capturada com área útil 1920×1061 neste ambiente. A validação de mouse físico continua separada da navegação acionada por sinais e do foco de teclado; a automação anterior com `warp_mouse` não é tratada como evidência de hover físico.

Pendências preservadas: `Lastro` ainda não possui combate; a arte dos nós e do quadro de detalhes é composta com recursos existentes/provisórios do kit, sem ilustrações específicas adicionais.

## Mapa ramificado como fluxo principal da run — 27/09/2026

A run normal agora começa em `main.gd::_iniciar_nova_run()` com o mapa gerado uma única vez. O primeiro ponto disponível é o combate P1; depois de cada consequência concluída, o mapa retorna mostrando somente os destinos conectados ainda não resolvidos. O estado distingue nó atual, nó em andamento e nós concluídos, bloqueando seleção inválida, reentrada e sinais repetidos.

Integrado no fluxo jogável: combate comum com recompensa ou pulo, eventos diretos, eventos que iniciam combate especial, elite com relíquia e carta rara em sequência, descansos nas duas variantes e reencontro antes do ponto final. Vida, baralho, cópias aprimoradas e relíquias permanecem na mesma instância da run. Os contadores de combate mostram o ponto real percorrido, sem depender do tamanho do roteiro linear.

`roteiro_run.gd` e seus chamadores legados foram preservados para testes e previews isolados, mas não conduzem mais a run iniciada por `main.tscn`. `mapa_run.gd` continua definindo as variantes e conexões. O botão de retorno legado do mapa fica oculto na tela principal, pois não existe uma saída válida que abandone um nó obrigatório sem resolver suas consequências.

Ao alcançar `Lastro`, a tentativa mostra `RUN PRE-CHEFE` e não libera o chefe, não marca o ponto como concluído e não afirma vitória. Derrota encerra a tentativa e não libera destinos.

Verificação executada com Godot 4.7.2 Compatibility: 39 cenas em `tests/*.tscn`, incluindo `test_fluxo_mapa_principal.tscn`, passaram em modo headless; a importação do editor headless e `git diff --check` também passaram. Capturas reais do fluxo foram geradas pela cena principal em 1024×576, 1280×720 e 1920×1061: [mapa inicial 1024](evidencias/mapa_initial_1024x576.png), [bifurcação 1280](evidencias/mapa_branch_1280x720.png), [retorno após descanso 1024](evidencias/mapa_rest_1024x576.png) e [retorno após descanso 1920](evidencias/mapa_rest_1920x1061.png). A janela de 1920×1080 produziu área útil de 1920×1061 no preview do Windows.

Pendências: o combate de `Lastro` ainda não foi implementado; a arte específica do mapa continua sendo a composição provisória de nós, tipografia e estados do kit. A validação de mouse físico permanece separada das capturas determinísticas de fluxo.

## Acabamento visual do descanso e inspeção do mapa — 26/09/2026

Na comparação do aprimoramento, `botao_carta.gd` agora mantém a descrição normal em texto escuro e usa uma camada `RichTextLabel` somente para marcar a linha cujo valor mudou. Em `GOLPE`, apenas `9 de dano.` recebe o marcador; `Ganha 1 Combo.` permanece normal. O marcador usa fundo discreto e texto escuro sobre branco, sem ciano claro.

`descanso_overlay.gd` dimensiona a lista de cartas para ocupar a área disponível e centraliza o grupo quando o conteúdo cabe. Quando o mínimo combinado excede a área, o container mantém largura de conteúdo e a rolagem horizontal. A seleção continua preservando identificação de cópias e foco. `descanso_overlay.tscn` separa a instrução da faixa do cabeçalho e aumentou a área mínima das descrições de `RECUPERAR` e `APRIMORAR` para 72 px, sem reduzir fontes.

Capturas GL Compatibility inspecionadas: [início 1024](evidencias/descanso_inicio_1024x576.png), [seleção 1024](evidencias/descanso_selecao_1024x576.png), [comparação 1024](evidencias/descanso_comparacao_1024x576.png), [início 1280](evidencias/descanso_inicio_1280x720.png), [comparação 1280](evidencias/descanso_comparacao_1280x720.png) e [rolagem 1280](evidencias/descanso_rolagem_1280x720.png). A comparação confirma o destaque localizado; a rolagem confirma que o grupo maior excede a área sem perder as cópias.

Verificação executada com Godot 4.7.2 Compatibility: 38 cenas de `tests/*.tscn`, `test_apresentacao_descanso.tscn` em 1024×576 e 1280×720, importação headless do editor e `git diff --check` terminaram com código 0.

Inspeção da integração do mapa, sem alteração de progressão: `main.gd::_ready()` inicia `roteiro_run` e chama `_iniciar_etapa_atual()`, que consome apenas `RoteiroRun.ETAPAS_PRE_CHEFE` (`combate_comum`, `evento`, `elite`) e inicia a primeira luta. Após recompensas/eventos, `_avancar_roteiro()` chama `roteiro_run.avancar()`; quando o roteiro termina, `_mostrar_pre_chefe()` exibe `MapaAbrir`. O mapa só é criado em `_abrir_mapa()`, que chama `mapa_run.gerar()` e fixa o nó inicial.

Os nós de descanso já existem em `mapa_run.gd`: `descanso_estrutura` na variante 0, ponto 5, e `descanso_inicial` na variante 1, ponto 2. Eles só são alcançados depois de `RUN PRE-CHEFE` → `Abrir mapa` → seleção de destinos conectados em `_ao_selecionar_no_mapa()`, que chama `_mostrar_descanso()`. O fluxo do descanso retorna ao mesmo mapa e não é concedido novamente.

Para usar o mapa ramificado desde o início, seria necessário substituir a inicialização linear em `_ready()` por uma inicialização única do mapa, fazer o primeiro destino partir do nó P1 e impedir que `_avancar_roteiro()` volte a consumir `roteiro_run`. Também seria necessário revisar a numeração de combates, a entrada das recompensas em `_resolver_vitoria()`, o retorno de eventos/descanso e a conclusão no nó `chefe`, preservando `mapa_no_atual`, os flags de espera e as guardas contra resolução duplicada. Essa integração não foi feita nesta entrega.

## Acabamento do descanso e resultado de aprimoramento — 26/09/2026

Corrigidos somente os três pontos visuais solicitados em `descanso_overlay.tscn`, `descanso_overlay.gd` e `main.gd`. O título `RESPIRO` agora é filho da própria `FaixaTitulo` (`PanelContainer`), usando a área interna real da moldura e alinhamento vertical centralizado para os glifos Bangers. A seleção de carta não reutiliza mais o `Subtitulo` global, evitando a duplicação de instruções abaixo do cabeçalho.

O resultado de aprimoramento agora deriva o nome e a mudança dos dados antes/depois: por exemplo, `GOLPE APRIMORADO` e `Dano: 6 → 9`. O estado de contagem de baralho fica oculto quando não há resumo a mostrar. A descrição é genérica para efeitos numéricos diferentes de dano, preservando a regra atual de aprimoramento sem assumir que toda carta altera dano.

Capturas reais GL Compatibility foram regeneradas e inspecionadas em 1024×576 e 1280×720: [início 1024](evidencias/descanso_inicio_1024x576.png), [seleção 1024](evidencias/descanso_selecao_1024x576.png), [comparação 1024](evidencias/descanso_comparacao_1024x576.png), [resultado 1024](evidencias/descanso_resultado_aprimorar_1024x576.png), [início 1280](evidencias/descanso_inicio_1280x720.png) e [resultado 1280](evidencias/descanso_resultado_aprimorar_1280x720.png). A comparação 1280 também foi gerada em `artifacts/descanso_comparacao_1280x720.png`.

Verificação executada com Godot 4.7.2 Compatibility: 38 cenas em `tests/*.tscn`, `test_apresentacao_descanso.tscn` em 1024×576 e 1280×720, além de `git diff --check`, terminaram com código 0. As regressões novas conferem a árvore do título, a ausência do subtítulo duplicado e o resultado dinâmico do aprimoramento, incluindo confirmação única e preservação da cópia escolhida.

Limitação de fluxo confirmada: o descanso está implementado e jogável ao selecionar um nó `descanso` no mapa. A rota linear atual só exibe `Abrir mapa` em `RUN PRE-CHEFE`; portanto o descanso não é oferecido como etapa adicional dentro da sequência linear de combates/eventos. Essa integração mudaria a progressão e não foi alterada nesta rodada, que ficou restrita ao acabamento pedido.

## Implementacao de descanso e aprimoramento — 26/09/2026

Implementado o descanso jogavel a partir dos nos `descanso` do mapa. `descanso_run.gd` concentra a cura de +8 limitada a Vida maxima, a elegibilidade de copias ainda nao aprimoradas e a transformacao provisoria de +3 no primeiro efeito numerico principal. O token interno `id#aprimorado` preserva a copia escolhida no `baralho_run`; `main.gd` resolve seus dados efetivos na mao, na consulta do baralho e ao jogar a carta.

Criados `descanso_overlay.tscn/.gd` e `preview_descanso.gd`, com os estados iniciais, selecao, comparacao antes/depois, resultado e retorno ao mapa. A selecao reutiliza `carta.tscn` em modo de descanso, mostra a ocorrencia de copias iguais, preserva tooltip/foco sem `SELECIONADA` de combate e nao muta o baralho antes de `CONFIRMAR`. A cura e a melhoria sao protegidas contra clique repetido; Vida cheia e ausencia de cartas elegiveis ficam indisponiveis.

Verificacao executada com Godot 4.7.2 Compatibility: `tests/test_descanso_run.tscn`, `tests/test_persistencia_aprimoramento.tscn`, `tests/test_ciclo_descanso.tscn` e `tests/test_apresentacao_descanso.tscn` passaram. A apresentacao passou em 1024x576, 1280x720 e 1920x1080; as 38 cenas de `tests/*.tscn`, a importacao do editor headless e `git diff --check` terminaram com codigo 0. O fluxo real foi capturado e inspecionado em [inicio 1024x576](evidencias/descanso_inicio_1024x576.png), [selecao 1280x720](evidencias/descanso_selecao_1280x720.png), [comparacao 1920](evidencias/descanso_comparacao_1920x1061.png) e [resultado 1280x720](evidencias/descanso_resultado_1280x720.png); existem capturas equivalentes nas quatro etapas para as tres resolucoes.

A referencia `06_descanso.png` e `13_aprimoramento.png` foi usada para hierarquia, dois paineis, selecao e comparacao. Como o kit nao fornece ilustracoes especificas de banco/descanso, os paineis usam os simbolos existentes de Vida e Forca como substitutos consistentes; a arte dedicada do descanso continua pendente. A captura rotulada como 1920x1080 possui area util 1920x1061 no Windows por causa da janela do preview; essa diferenca de decoracao foi registrada, sem alterar a resolucao do jogo.

## Acabamento da experiencia de descanso — 26/09/2026

Aplicado o acabamento visual no `descanso_overlay.tscn/.gd`: a faixa HQ e os icones reais de Vida/baralho permanecem dinamicos; os paineis de RECUPERAR e APRIMORAR ganharam simbolos maiores, informacao essencial em area clara e contraste legivel. A selecao preserva copias iguais fora da moldura da carta, usa rolagem horizontal para baralhos maiores e continua sem o estado `SELECIONADA` do combate. Tooltips continuam reservados a palavras-chave reais, sem repetir `COPIA`.

A comparacao agora identifica `ATUAL` e `MELHORADA`, usa a seta grafica do kit e destaca o efeito alterado na propria carta. O resultado foi reduzido a simbolo, titulo, efeito e estado resumido; `Escolha uma acao` desaparece depois da resolucao. Os botoes `VOLTAR`, `CONFIRMAR` e `CONTINUAR` usam a moldura normal tambem no foco, com `Interacao` ciano transparente separado; isso removeu a caixa escura maior sem alterar foco, clique ou bloqueio contra confirmacao duplicada.

`botao_carta.gd` separa o modo de descanso do modo de selecao de combate; `main.gd` passa tooltip derivado do catalogo e dados reais da cura/vida/baralho; `preview_descanso.gd` e as cenas `preview_descanso_resultado_aprimorar.tscn` e `preview_descanso_rolagem.tscn` cobrem os dois resultados, duplicatas e rolagem. Testes de apresentacao verificam a arvore, a seta, os overlays de foco, a moldura preservada e o resultado; o ciclo verifica cura unica, copia sem mutacao previa, retorno e confirmacao unica.

Verificacao executada com Godot 4.7.2 Compatibility: 38 cenas de `tests/*.tscn` passaram em 1280x720; `test_descanso_run`, `test_persistencia_aprimoramento`, `test_ciclo_descanso` e `test_apresentacao_descanso` passaram novamente, incluindo as novas assercoes. A importacao do editor headless e `git diff --check` terminaram com codigo 0. Capturas reais GL Compatibility foram geradas e inspecionadas em 1024x576, 1280x720 e 1920x1061: inicio, selecao, comparacao, resultado de cura, resultado de melhoria e rolagem estao em `artifacts/descanso_*.png`. As capturas maiores registram 1920x1061 porque a area util da janela Windows nao e 1920x1080.

Pendencias explicitas: os simbolos atuais de Vida e Forca sao substitutos consistentes, pois o kit nao fornece arte propria de banco/descanso; a arte dedicada permanece pendente. O hover fisico do mouse nao foi usado como evidencia automatizada nesta rodada; o foco de teclado, a camada transparente, a estabilidade geometrica e os cliques do fluxo foram verificados pelo renderer/testes, enquanto a limitacao anterior de `warp_mouse` permanece registrada.

## Validação manual relatada da opção de evento — 26/09/2026

O usuário confirmou que a opção de evento está funcional: hover, clique, navegação e transições foram validados manualmente no fluxo jogável. Essa confirmação é um relato manual do usuário, não uma execução automatizada adicional feita nesta sessão.

As verificações automatizadas permanecem as registradas abaixo: layout e regressões passaram conforme os testes relatados. A limitação do preview automatizado também permanece explícita: `warp_mouse` não ativa `is_hovered()` de forma determinística, portanto não é usado como evidência de hover físico.

## Ajuste final do espaçamento vertical da opção de evento — 26/09/2026

Após comparar as capturas, o conjunto com título e detalhe recebeu altura mínima de 100 px. A área interna agora usa 19 px de margem superior/inferior; o título Bangers reserva 34 px para acentos, o detalhe 22 px e o espaçamento entre linhas é 4 px. O mínimo combinado do `VBoxContainer` passou a 60 px. A opção sem detalhe continua no mesmo `VBoxContainer` centralizado.

`EventoOpcoes` usa `anchor_top=0.515`, `anchor_bottom=0.995` e separação de 5 px; o espaço resultante acomoda três opções de 100 px sem reduzir a fonte ou cortar glifos. A moldura-base, a camada ciano, a área clicável, a tela de resultado e a Brecha não foram alteradas.

Capturas reais GL Compatibility inspecionadas: [normal 1024×576](evidencias/evento_valvula_normal_1024x576.png), [foco 1024×576](evidencias/evento_valvula_foco_1024x576.png), [normal 1920×1080](evidencias/evento_valvula_normal_1920x1080.png) e [foco 1920×1080](evidencias/evento_valvula_foco_1920x1080.png). A inspeção confirmou espaço visível entre `DESLIGAR A VÁLVULA`, `Combate` e a tinta branca.

Verificação executada com Godot 4.7.2 Compatibility: a regressão completa de 34 cenas passou em 1280×720; `test_layout_evento_opcao.tscn` passou em 1024×576, 1280×720 e 1920×1080; importação do editor headless e `git diff --check` passaram. O hover físico continua com a limitação já registrada: o preview automatizado não ativa `is_hovered()` de forma determinística, portanto não foi declarado validado por captura.

## Ajuste de altura e área segura da opção de evento — 26/09/2026

Reproduzido o evento `valvula_vapor_contaminado`. As medidas reais em GL Compatibility mostraram que a opção de 88 px oferecia 52 px de área interna, enquanto o `VBoxContainer` de ação + detalhe exigia 50 px antes da folga visual da moldura. A opção passou para altura mínima de 92 px, com insets verticais de 20 px; `EventoOpcoes` passou a ocupar `0.52..0.98` para acomodar três opções sem invadir o painel narrativo.

`Interacao` deixou de cobrir o Button inteiro e usa offsets de 14 px em cada lado, alinhando o destaque ciano ao quadro visível da textura. O Button continua sendo a área clicável e a geometria não muda no foco. A ação isolada de `Contornar a tubulação` ficou centralizada no `VBoxContainer`; `Desligar a válvula` e `Combate` ficaram com espaço visual até as bordas.

Capturas reais limpas foram geradas para `valvula_vapor_contaminado` em normal e foco nas resoluções 1024×576, 1280×720 e 1920×1080, nos arquivos `artifacts/evento_valvula_{normal|foco}_{resolução}.png`. A inspeção visual de 1024×576 confirmou a melhora. O preview automatizado de hover ainda não registra `is_hovered()` no alvo após warp; essa validação específica continua pendente e não foi substituída por foco.

Verificação executada com Godot 4.7.2 Compatibility: `test_layout_evento_opcao.tscn`, `test_apresentacao_eventos.tscn` e `test_regressoes_ui_evento_brecha.tscn` passaram em 1024×576, 1280×720 e 1920×1080; 34 cenas passaram em 1280×720; importação do editor headless terminou com código 0; `git diff --check` passou. Brecha, resultado de evento e regras permaneceram verdes.

## Correção estrutural da opção de evento — 26/09/2026

Implementada a correção baseada no diagnóstico: `evento_opcao.tscn` agora mantém o `Button` como raiz e usa `Conteudo` (`MarginContainer`) → `Linha` (`HBoxContainer`) → `Textos` (`VBoxContainer`), com espaços próprios para `TipoIcone` e `Seta`. Os Labels deixaram de usar âncoras/offsets individuais; a área segura usa insets maiores que os antigos para respeitar a tinta real da moldura do atlas. A ação fica centralizada quando `Detalhe` está oculto; com duas linhas, ambas permanecem na mesma coluna.

`evento_opcao.gd` foi atualizado para os novos caminhos. A moldura-base continua a mesma em normal, hover, foco, pressed e hover_pressed; `Interacao` continua sendo somente a camada ciano transparente e não intercepta o mouse. `EventoOpcoes` recebeu apenas espaço vertical adicional para acomodar a altura mínima de 88 px nas três opções.

Foi acrescentada `tests/test_layout_evento_opcao.tscn`, que verifica a árvore interna, a contenção da área segura, título/detalhe/seta dentro dela e estabilidade de tamanho no foco. `tests/test_apresentacao_eventos.gd` e `tests/test_regressoes_ui_evento_brecha.gd` foram ajustados aos novos caminhos, preservando a regressão da Brecha.

`git diff --check` passou. A execução Godot 4.7.2, as capturas reais nas três resoluções e a inspeção visual ainda estão pendentes nesta máquina: o executável não foi encontrado em `C:\Users\Wallace\Downloads\Godot\_v4.7.2-stable\_win64.exe`. A correção não deve ser considerada visualmente concluída até essa execução.

## Coleta diagnóstica da opção de evento — 26/09/2026

O problema visual relatado continua pendente: em 1024×576, o título e o detalhe de `Confrontar a fiscalização` podem tocar a tinta da moldura, e `Combate` aparece junto da borda inferior. Foi feita somente uma coleta, sem nova alteração visual de produção. O relatório [DIAGNOSTICO_EVENTO_OPCAO_2026-09-26.md](DIAGNOSTICO_EVENTO_OPCAO_2026-09-26.md) registra a cena e o script completos, a cadeia StyleBox/AtlasTexture, a camada `Interacao`, o código externo de layout, retângulos globais e a lacuna dos testes.

As capturas diagnósticas mostram que normal, hover, foco, pressed e hover_pressed usam a mesma moldura-base; o foco acrescenta apenas a camada ciano. A causa provável é a diferença entre a tinta visível da região do atlas e os `Label`s filhos diretos, que não recebem automaticamente as margens de conteúdo do `StyleBoxTexture`. O teste geométrico atual verifica apenas contenção no retângulo lógico do botão, não colisão com os pixels da moldura. A captura de hover da mesma opção não foi considerada evidência: o warp do preview não ativou o alvo de forma determinística, e isso está registrado sem fabricar uma captura.

## Correção da moldura e geometria das opções de evento — 26/09/2026

Investigada a divergência entre `evento_opcao.tscn` nos estados normal e focado. O controle e os Labels tinham a mesma geometria, mas `normal` usava `painel_escuro.tres` como `StyleBoxTexture`, com margens de conteúdo `24/16/24/16`, enquanto `hover` e `focus` substituíam essa moldura por `opcao_evento_interacao.tres` como caixa inteira. Essa caixa começava no retângulo externo do controle e não preservava a tinta interna da moldura HQ; por isso o texto parecia caber no foco, mas invadia a área útil da moldura normal.

Corrigido sem deslocar somente o foco: `evento_opcao.tscn` mantém `painel_escuro.tres` em normal, hover, focus, pressed e hover_pressed. `opcao_evento_interacao.tres` agora é uma camada transparente, filha `Interacao`, com apenas borda ciano e `mouse_filter` decorativo; `evento_opcao.gd` alterna sua visibilidade para hover/foco. A área e a posição dos Labels permanecem iguais em todos os estados. Em 1024×576, o controle medido ficou em aproximadamente `506.9×79.8`, com `Acao` em `27.1` px, `Detalhe` em `25.5` px e a camada ciano usando exatamente o retângulo do controle. O título longo e `Combate` ficaram dentro da margem útil.

Criado o preview `preview_evento_hover.tscn`; as capturas reais GL Compatibility do mesmo evento e da mesma opção foram inspecionadas: [normal 1024](evidencias/evento_opcao_normal_1024x576.png), [hover 1024](evidencias/evento_opcao_hover_1024x576.png) e [foco de teclado 1024](evidencias/evento_opcao_foco_1024x576.png). A comparação com `ui_hq_v1/referencias/telas/05_evento.png` preserva a moldura HQ, a coluna de texto e a seta; o foco não cria uma caixa externa.

`tests/test_apresentacao_eventos.tscn` e `tests/test_regressoes_ui_evento_brecha.tscn` passaram em 1024×576, 1280×720 e 1920×1080. A suíte completa de 33 cenas passou em 1280×720, a importação do editor headless terminou com código 0 e `git diff --check` passou. A correção da Brecha foi preservada.

## Regressões de Brecha e opções de evento — 26/09/2026

Investigação reproduzida pelo fluxo de jogo: após escolher Brecha na recompensa, avançar pelo evento `valvula_vapor_contaminado` e iniciar o combate, a carta era criada com o identificador `brecha`, custo 1 e `disabled = false`, mas aparecia escurecida durante a entrada. A causa foi `botao_carta.gd::animar_entrada()`, que aplicava `modulate.a = 0` no próprio botão e fazia um tween de 0,18 s; a captura ocorria enquanto a animação ainda estava entre 0,45 e 0,73 de alpha. `self_modulate`, material, arte, catálogo e recurso compartilhado não eram a origem. A entrada agora preserva `modulate = Color.WHITE` e anima somente a escala, mantendo indisponibilidade legítima sob controle de `disabled` e do tema.

Também foi comparada uma Brecha adquirida pelo fluxo com uma Brecha criada diretamente por `_criar_carta_na_mao()`: ambas usam o mesmo identificador, custo e apresentação. O teste reproduzido confirma a compra com 4 de Energia, o uso contra a Torreta de Contenção, dano de 4 e consumo para 3 de Energia.

Nas opções de evento, a origem da moldura sobreposta era local: `evento_opcao.tscn` substituía o `focus` transparente do tema e o estado `hover` por `ui_hq_v1/estilos/botao_foco.tres`, uma textura HQ completa. O componente agora usa `ui_hq_v1/estilos/opcao_evento_interacao.tres`, um único `StyleBoxFlat` de corpo escuro e borda ciano para hover/foco; `pressed` continua usando o estado próprio de pressão. Não há texto nativo duplicado no Button nem controles legados visíveis. Os Labels `Acao` e `Detalhe` usam áreas proporcionais internas, mantendo título, informação secundária, ícone e seta dentro da moldura quando a VBox comprime em 1024×576.

Criado `tests/test_regressoes_ui_evento_brecha.tscn`, que verifica estilos normal/hover/foco, margens das duas linhas, identidade da Brecha, disponibilidade, modulate, comparação com criação direta e resolução com gasto de Energia. `preview_fluxo.gd` recebeu os modos `brecha_mao` e `brecha_jogada`; as capturas reais GL Compatibility foram geradas e inspecionadas em [Brecha na mão](evidencias/brecha_mao_1280x720.png), [Brecha após uso](evidencias/brecha_jogada_1280x720.png), [evento normal 1024](evidencias/evento_normal_1024x576_final.png) e [evento foco 1024](evidencias/evento_foco_1024x576_final.png). A captura da mão mostra `4/4` de Energia e a carta clara; a captura após o uso mostra `3/4`, dano aplicado e descarte.

Verificação executada com Godot 4.7.2: as regressões de eventos, Brecha e recompensa comum passaram em 1024×576, 1280×720 e 1920×1080; a suíte completa de 33 cenas passou em 1280×720; importação do editor headless terminou com código 0; `git diff --check` passou. A arte do evento continua sendo o símbolo genérico `evento.tres`; não há arte específica por evento.

## Acabamento visual da tela de eventos — 26/09/2026

Comparada diretamente com `ui_hq_v1/referencias/telas/05_evento.png`, a tela de eventos recebeu uma rodada restrita de apresentação. O símbolo provisório agora usa `STRETCH_KEEP_ASPECT_CENTERED` em uma área interna menor do quadro, preservando proporção e margens nas resoluções testadas; a faixa do nome permanece independente. O cabeçalho recebeu uma faixa HQ clara para `ENCONTRO`, mantendo Vida e baralho derivados do estado real.

`evento_opcao.tscn` deixou de usar `StyleBoxFlat` local fino e passou a reutilizar os estilos HQ de painel escuro, foco, pressão e tipografia do kit. A ação e o detalhe ficam em uma coluna alinhada à esquerda; a seta é um elemento separado com `mouse_filter` decorativo, e o ícone de combate aparece somente nas opções que iniciam combate especial. A altura mínima e os offsets internos foram ajustados para manter textos e molduras dentro do componente, sem deslocar opções vizinhas.

`main.gd` agora resume uma opção de combate como `Combate` e remove frases genéricas de continuação; custos de Vida continuam visíveis quando existem. Regras, textos narrativos do catálogo, handlers, proteção contra clique duplicado, resultado e transições não foram alterados. `Continuar` permanece abaixo do resultado, dentro do overlay e com margens internas do kit.

Capturas reais GL Compatibility do mesmo evento `fiscalizacao_corporativa`, geradas pelo fluxo de preview que chama `_mostrar_evento()` e `_ao_escolher_evento()`: [inicial 1024](evidencias/evento_inicial_1024x576.png), [foco 1024](evidencias/evento_foco_1024x576.png), [resultado 1024](evidencias/evento_resultado_1024x576.png), [inicial 1280](evidencias/evento_inicial_1280x720.png), [foco 1280](evidencias/evento_foco_1280x720.png), [resultado 1280](evidencias/evento_resultado_1280x720.png), [inicial 1920](evidencias/evento_inicial_1920x1080.png), [foco 1920](evidencias/evento_foco_1920x1080.png) e [resultado 1920](evidencias/evento_resultado_1920x1080.png). A captura de 1920×1080 foi feita com tela cheia; a escala interna do projeto permanece proporcional.

Verificação executada com Godot 4.7.2 GL Compatibility: `tests/test_apresentacao_eventos.tscn` e `tests/test_ciclo_encontros.tscn` passaram em 1024×576, 1280×720 e 1920×1080; as 32 cenas de `tests/*.tscn` passaram em 1280×720; a importação do editor headless terminou com código 0; e `git diff --check` passou. A inspeção visual das capturas confirmou o símbolo contido, molduras HQ, textos auxiliares reduzidos e botão de continuação sem achatamento. Recompensas comum e elite permaneceram fora do escopo e verdes.

Pendente: o quadro ainda usa o símbolo genérico `evento.tres`; não existem ilustrações específicas dos cinco eventos no kit.

## Apresentação visual dos eventos — 26/09/2026

A tela de eventos foi reconstruída usando `ui_hq_v1/referencias/telas/05_evento.png` como referência de composição, sem copiar seus textos ou números. O fluxo atual de `DadosEventos`, `ResolucaoEventos` e os handlers de escolha/continuação foi preservado: opções continuam sendo determinadas pelo catálogo, custos existentes continuam aplicados, combate especial continua encaminhando para o encontro e o resultado só avança pelo botão `Continuar`.

`EventoOverlay` agora usa cabeçalho HQ com identidade `ENCONTRO`, Vida e tamanho real do baralho; quadro escuro à esquerda com ícone de evento e faixa do nome; painel narrativo claro à direita; e escolhas empilhadas com moldura HQ, títulos Bangers, resumo secundário em Barlow e foco ciano. O componente `evento_opcao.tscn` mantém o `Button` como raiz, deixa a opção inteira clicável e marca os rótulos como decoração que não intercepta o mouse. Opções ausentes são ocultadas sem deixar espaços visuais. O resultado reutiliza o painel narrativo e mantém `Continuar` separado.

O resultado não reapresenta a narrativa antiga por baixo da consequência. Escolhas diretas são desabilitadas e marcadas como resolvidas antes de mostrar o resultado; cliques tardios não reaplicam Vida nem avançam para `Continuar`. `_mostrar_evento()` também sincroniza `etapa_evento_atual` com o identificador exibido, mantendo chamadas de fluxo e previews determinísticos consistentes. Eventos ainda usam o símbolo genérico `evento.tres`; não há ilustrações específicas por evento no kit, pendência registrada para arte futura.

Capturas reais GL Compatibility do mesmo evento `fiscalizacao_corporativa`, em estado inicial, foco na segunda opção e resultado após escolher a primeira: [inicial 1024](evidencias/evento_inicial_1024x576.png), [foco 1024](evidencias/evento_foco_1024x576.png), [resultado 1024](evidencias/evento_resultado_1024x576.png), [inicial 1280](evidencias/evento_inicial_1280x720.png), [foco 1280](evidencias/evento_foco_1280x720.png), [resultado 1280](evidencias/evento_resultado_1280x720.png), [inicial 1920](evidencias/evento_inicial_1920x1080.png), [foco 1920](evidencias/evento_foco_1920x1080.png) e [resultado 1920](evidencias/evento_resultado_1920x1080.png). A resolução 1920×1080 foi capturada em tela cheia para manter o tamanho real do viewport.

Arquivos principais desta etapa: `main.tscn`, `main.gd`, `evento_opcao.tscn`, `evento_opcao.gd`, `preview_fluxo.gd`, `preview_evento_foco.tscn`, `preview_evento_resultado.tscn` e `tests/test_apresentacao_eventos.gd`. Verificação com Godot 4.7.2: apresentação e ciclo de encontros passaram em 1024×576, 1280×720 e 1920×1080; as 32 cenas de `tests/*.tscn`, a importação do editor headless e `git diff --check` terminaram com código 0. Recompensas comum e elite foram preservadas.

## Acabamento de composição da recompensa elite — 26/09/2026

Preservado o fluxo obrigatório `relíquia -> carta rara`, as quantidades, a consulta do baralho, o foco entre etapas e a aquisição existente. A moldura horizontal compartilhada agora fica oculta somente durante a recompensa elite; o fundo HQ permanece. Os grupos de duas relíquias e três cartas raras usam `alignment = 1` e compartilham o eixo central do título e de `Ver baralho`.

`recompensa_reliquia.tscn` passou a usar corpo escuro, moldura branca quadrada e detalhe magenta; `recompensa_reliquia.gd` mantém ciano apenas no foco/hover e não escala mais o painel, evitando alterar o espaço reservado às opções. A raridade das cartas raras foi movida para `RaridadePill`, um `PanelContainer` com fundo, moldura magenta e margens próprias na faixa entre arte e descrição. O custo, tipo, nome e efeitos reais continuam derivados do catálogo.

Criados os previews neutros `preview_recompensa_elite_neutro.tscn` e `preview_recompensa_elite_cartas_neutro.tscn`; eles somente liberam foco e afastam o cursor para produzir a captura sem destaque. Capturas reais GL Compatibility foram geradas e inspecionadas nas três resoluções, em estado neutro e com foco: [relíquias neutro 1024](evidencias/recompensa_elite_reliquias_neutro_1024x576.png), [relíquias foco 1024](evidencias/recompensa_elite_reliquias_foco_1024x576.png), [cartas neutro 1024](evidencias/recompensa_elite_cartas_neutro_1024x576.png), [cartas foco 1024](evidencias/recompensa_elite_cartas_foco_1024x576.png), [relíquias neutro 1280](evidencias/recompensa_elite_reliquias_neutro_1280x720.png), [relíquias foco 1280](evidencias/recompensa_elite_reliquias_foco_1280x720.png), [cartas neutro 1280](evidencias/recompensa_elite_cartas_neutro_1280x720.png), [cartas foco 1280](evidencias/recompensa_elite_cartas_foco_1280x720.png), [relíquias neutro 1920](evidencias/recompensa_elite_reliquias_neutro_1920x1080.png), [relíquias foco 1920](evidencias/recompensa_elite_reliquias_foco_1920x1080.png), [cartas neutro 1920](evidencias/recompensa_elite_cartas_neutro_1920x1080.png) e [cartas foco 1920](evidencias/recompensa_elite_cartas_foco_1920x1080.png). A captura de 1920×1080 foi feita em tela cheia para manter o viewport real nessa resolução.

Verificação executada com Godot 4.7.2: `test_apresentacao_recompensa_elite.tscn`, `test_recompensa_elite.tscn` e `test_ciclo_encontros.tscn` passaram em 1024×576, 1280×720 e 1920×1080; as 32 cenas de `tests/*.tscn`, a importação do editor headless e `git diff --check` terminaram com código 0. A inspeção visual confirmou ausência da moldura residual, centralização, estabilidade do espaço no foco e marcador `RARA` legível. O símbolo das relíquias continua sendo o ícone genérico provisório `reliquia.tres`.

## Acabamento visual e integracao da recompensa elite — 26/09/2026

A recompensa elite foi reconstruida usando os componentes corrigidos da recompensa comum, sem alterar a quantidade de opcoes, a ausencia de skip ou a sequencia obrigatoria reliquia -> carta rara. A tela agora mostra identidade magenta de elite, estados ciano de interacao e um indicador explicito `1/2` ou `2/2`.

As reliquias usam um componente proprio clicavel e acessivel por teclado, com painel HQ, icone generico, nome Bangers e efeito essencial em Barlow derivados de `DadosReliquias`. O icone especifico de cada reliquia ainda nao existe no kit; a entrega usa `reliquia.tres` como simbolo provisório e essa pendencia permanece registrada.

As cartas raras agora sao instancias de `carta.tscn`, com custo, tipo, nome, arte, raridade e efeitos reais do catalogo. O tooltip unico continua sendo o `PanelContainer` corrigido. A consulta do baralho funciona durante as duas etapas elite, bloqueia a etapa atual e restaura o foco anterior ao fechar. A escolha da reliquia transfere o foco para a primeira carta rara; cliques tardios nao atravessam a troca de etapa.

Criados `recompensa_reliquia.gd`, `recompensa_reliquia.tscn`, `tests/test_apresentacao_recompensa_elite.gd`, `tests/test_apresentacao_recompensa_elite.tscn` e `preview_recompensa_elite_cartas.tscn`. Capturas reais GL Compatibility foram geradas e inspecionadas em 1024x576, 1280x720 e 1920x1080: [reliquias 1024](evidencias/recompensa_elite_reliquias_1024x576.png), [reliquias 1280](evidencias/recompensa_elite_reliquias_1280x720.png), [cartas raras 1024](evidencias/recompensa_elite_cartas_1024x576.png), [cartas raras 1280](evidencias/recompensa_elite_cartas_1280x720.png) e [cartas raras 1920](evidencias/recompensa_elite_cartas_1920x1080.png). As capturas incluem foco/hover ativo e tooltip complementar; a validação de duas palavras-chave permanece coberta pelo Pulso na recompensa comum.

Verificacao executada com Godot 4.7.2: 32 cenas de teste passaram nas tres resolucoes, incluindo o ciclo intercalado, aquisicao dupla, foco entre etapas, consulta do baralho e clique duplo; a importacao do editor headless terminou com codigo 0 e `git diff --check` passou. A recompensa comum foi preservada.

## Tooltip de recompensa com dimensionamento pelo layout — 26/09/2026

Substituido o dimensionamento manual do tooltip de recompensa por `PanelContainer` com `Label`, uma unica definicao de margens no `StyleBox` e largura definida antes da quebra de texto. A altura agora vem do layout final; a ponta decorativa foi separada do corpo em `Polygon2D` e `Line2D`, sem participar da area de conteudo.

O posicionamento tenta larguras decrescentes e candidatos acima, abaixo e nas laterais, validando viewport e areas protegidas antes de aplicar a posicao. Quando a carta muda de escala durante o hover, `_process()` reposiciona o balão. O preview sincroniza `oferta_recompensa.opcoes` com as cartas deterministicas, preservando a recompensa concedida pelo clique.

Brecha e Pulso Debilitante foram conferidos nas tres posicoes da oferta em mouse e teclado, em 1024x576 e 1280x720. As capturas reais `artifacts/recompensa_brecha_panelcontainer_1024x576.png`, `artifacts/recompensa_brecha_panelcontainer_1280x720.png`, `artifacts/recompensa_pulso_panelcontainer_1024x576.png` e `artifacts/recompensa_pulso_panelcontainer_1280x720.png` foram inspecionadas; texto, margens e ponta permanecem dentro do painel e da viewport.

Verificacao: `tests/test_apresentacao_recompensas.tscn` passou, as 31 cenas em `tests/*.tscn` passaram, a importacao do editor headless terminou com codigo 0 e `git diff --check` passou. Nenhuma regra de combate, selecao ou recompensa foi alterada.

## Correção do dimensionamento e posicionamento dos tooltips de recompensa — 26/09/2026

Investigada a divergência observada nas capturas de Brecha e Pulso Debilitante. O balão compartilhado agora mede a altura a partir do texto já quebrado, da quantidade de linhas, da altura tipográfica e das margens; o texto fica no topo e acima da textura de fundo. A busca de posição ocorre somente depois do dimensionamento final, protege título, custo e descrição das cartas, título da recompensa e ações inferiores, e usa posições laterais ou sobre a arte quando o espaço acima não comporta todas as linhas. O comportamento de seleção do combate e a escolha da recompensa não foram alterados.

Criados previews determinísticos `preview_recompensa_brecha.tscn` e `preview_recompensa_pulso.tscn`, ambos passando por `_resolver_vitoria()` e usando os dados reais do catálogo. Capturas reais foram geradas e inspecionadas em 1280×720 e 1024×576: Brecha mostra sua explicação completa; Pulso Debilitante mostra as duas palavras-chave completas, sem cobrir título, custo ou descrição essencial das cartas e dentro da viewport.

Alterados `botao_carta.gd`, `preview_fluxo.gd` e `tests/test_apresentacao_recompensas.gd`. A regressão também confere que duas palavras-chave aumentam a altura do tooltip, que o texto permanece dentro do fundo e que o balão fica dentro da viewport. A suíte de 31 cenas em Godot 4.7.2, a importação do editor headless e `git diff --check` terminaram com código 0. Capturas verificadas: `artifacts/recompensa_brecha_tooltip_1280x720.png`, `artifacts/recompensa_brecha_tooltip_1024x576.png`, `artifacts/recompensa_pulso_tooltip_1280x720.png` e `artifacts/recompensa_pulso_tooltip_1024x576.png`.

## Correção do hover das cartas de recompensa — 25/09/2026

Reproduzido pelo fluxo real de vitória comum (`_resolver_vitoria()`): as cartas compartilhavam `toggle_mode` e a apresentação de seleção do combate, então uma interação podia deixar `button_pressed`, `Foco` e `SELECIONADA` visíveis na recompensa. O modo recompensa agora neutraliza a seleção visual, mantendo o `Button` clicável e preservando o sinal que escolhe a carta. Hover eleva somente a carta sob o mouse; foco de teclado eleva a carta focada quando não há hover. Ao trocar ou sair, escala, foco visual e tooltip são restaurados.

O componente mantém um único tooltip customizado ativo. O balão anterior fecha ao mover o ponteiro para outra carta; o tooltip da carta focada pode ser restaurado quando o mouse sai. O tamanho recebeu margem interna maior, quebra de linha e cálculo de posição que evita as cartas vizinhas e respeita o viewport. `tooltip_text` nativo permanece vazio, evitando duas explicações simultâneas.

Foram acrescentadas regressões para as três cartas: hover sem `SELECIONADA`, tooltip único, ausência de colisão com a vizinha, retorno ao estado normal, seleção visual do combate preservada fora do modo recompensa e clique de recompensa intacto. As prévias agora percorrem `_resolver_vitoria()` e incluem hover real por ponteiro, foco, pressão e saída do grupo. Capturas: [hover da carta](evidencias/hover_carta_real_1280x720.png), [foco de carta](evidencias/foco_carta_final_1280x720.png) e [após retirar o mouse](evidencias/saida_carta_real_1280x720.png).

Verificação executada com Godot 4.7.2 GL Compatibility: `git diff --check`, 31 cenas de teste e importação do editor terminaram com código 0. A captura real mostra a carta sob o cursor ampliada suavemente, sem `SELECIONADA`, e a captura após retirar o mouse retorna todas as cartas à apresentação normal. A tela de recompensa permanece a única tela alterada nesta correção.

## Correção dos estados de tooltip e Pular recompensa — 25/09/2026

Reproduzido pela cena principal e pelo caminho real `_resolver_vitoria()`: o tooltip customizado da carta podia permanecer visível quando outra carta recebia hover, permitindo dois balões simultâneos. `botao_carta.gd` agora mantém apenas um tooltip customizado ativo, fecha o anterior ao mover o ponteiro e restaura o tooltip da carta que conserva o foco quando o ponteiro sai. O `tooltip_text` nativo também é limpo no `_ready` e na atualização da carta, deixando uma única fonte de explicação.

A origem da moldura ciana desproporcional do `Pular recompensa` estava no tema: o estado `hover` usava a textura completa de foco, sobrepondo a moldura normal, enquanto `focus` acrescentava outra camada. O tema agora usa o estilo normal no hover e mantém o foco de teclado como uma marca `StyleBoxFlat` transparente, com borda e sombra reduzidas; `pressed` e `hover_pressed` continuam explícitos. O texto do botão permanece legível em foco e pressão, sem override local que substitua o tema corrigido.

O teste de apresentação recebeu apenas a regressão necessária: hover entre cartas deixa somente um tooltip, a carta vizinha não se move, `Pular` conserva o texto, hover não sobrepõe a moldura normal e foco continua transparente. As cenas de preview passaram a chamar `_resolver_vitoria()` e geraram capturas reais GL Compatibility de hover, foco e pressão do `Pular`, além da consulta do baralho em 1024×576: [hover](evidencias/hover_pular_real_1280x720.png), [foco](evidencias/foco_pular_real_1280x720.png), [pressão](evidencias/pressed_pular_real_1280x720.png) e [baralho](evidencias/baralho_real_1024x576.png).

Verificação executada com Godot 4.7.2: `git diff --check`, 31 cenas de teste e importação do editor terminaram com código 0. A inspeção visual real confirmou a navegação por foco, o estado destacado do `Pular`, o caminho de vitória comum e o modal preservado. Nenhuma outra tela foi redesenhada.

## Acabamento verificável da recompensa comum — 25/09/2026

A rodada de acabamento preservou as regras e corrigiu a composição final: as três cartas ficam em um `HBoxContainer` centralizado no eixo do título, com intervalos constantes; `Ver baralho` e `Pular recompensa` ocupam a mesma faixa inferior nas extremidades; e os botões receberam margens internas maiores. O script passou a instanciar as cartas no container compartilhado correto, alinhando a árvore da cena ao fluxo real.

O custo foi removido da descrição visível e permanece no selo. Os efeitos agora são derivados do catálogo e quebrados em linhas, incluindo Finalização, Exposto, Enfraquecido, Barreira e Combo. O tooltip mostra somente explicações complementares de palavras-chave. A consulta do baralho ganhou scrim escuro, bloqueia as ações da recompensa enquanto aberta, mantém `Fechar` dentro do modal e restaura o foco anterior ao fechar.

O posicionamento do tooltip foi corrigido em `botao_carta.gd` para permanecer dentro do viewport em resoluções menores sem cobrir o cabeçalho. A investigação do tema confirmou que o foco original era uma textura de botão completo sobreposta; o tema vigente usa contorno transparente com foco ciano e `hover_pressed` explícito. Hover e foco elevam a carta sem reposicionar as vizinhas.

Arquivos alterados nesta rodada: `main.gd`, `main.tscn`, `botao_carta.gd`, os testes de apresentação/ciclo/recompensa, `preview_fluxo.gd` e as cenas de pré-visualização. Capturas reais foram geradas com Godot 4.7.2 GL Compatibility em 1280×720, 1920×1080 e 1024×576; exemplos: [sem foco](evidencias/recompensa_sem_foco_1280x720.png), [foco](evidencias/recompensa_foco_1280x720.png) e [baralho na menor resolução](evidencias/recompensa_baralho_1024x576.png).

Verificação executada: `git diff --check`, 31 cenas de `tests/*.tscn` e importação do editor headless terminaram com código 0. O teste focado confirma custo não duplicado, tooltip complementar, foco transparente, hover sem reposicionamento, scrim, bloqueio/restauração da oferta e botão de fechamento dentro do modal. As demais telas continuam fora desta rodada.

## Reconstrucao verificavel da recompensa comum — 26/09/2026

Lido `docs/CORRECAO_UI_EXPERIENCIA.md` e comparada a referencia `ui_hq_v1/referencias/telas/03_recompensa.png` com a captura real do fluxo. A recompensa comum deixou de exibir tres botoes textuais: no inicio da tela, as tres opcoes sao instancias do componente compartilhado de carta, recebem dados reais do catalogo, exibem custo e efeito na propria carta e usam um unico balao complementar no hover ou foco de teclado. O painel gigante anterior foi retirado da composicao da recompensa.

Investigado o tema original: `Button/styles/focus` usava `botao_foco.tres`, uma textura de botao inteiro sobreposta ao estado base. O foco agora usa contorno `StyleBoxFlat` transparente, e `hover_pressed` foi definido explicitamente. O componente de carta deixou de recortar o balao fora dos seus limites, manteve os textos acima do foco e recebeu arte para Habilidades que antes apareciam vazias, incluindo Pulso Debilitante.

Alterados `main.tscn`, `main.gd`, `carta.tscn`, `botao_carta.gd`, `ui_hq_v1/tema_base.tres`, `tests/test_apresentacao_recompensas.gd` e `preview_fluxo.gd`. A carta de recompensa usa escala maior que a carta da mao, com ajuste pelo viewport; a regra de adicionar, pular e avancar a run permaneceu a mesma.

Verificacao executada com Godot 4.7.2 GL Compatibility: `tests/test_apresentacao_recompensas.tscn` cobre cartas compartilhadas, custo/efeito, arte, foco transparente, foco de teclado, hover, tooltip unico, ausencia de desaparecimento e viewport reduzido em 1024x576. A suite completa de 31 cenas terminou com `FALHAS=0`; a importacao do editor terminou com codigo 0; `git diff --check` passou.

Capturas reais geradas e inspecionadas em 1280x720, 1920x1080 e 1024x576. A comparacao confirmou a hierarquia da referencia: titulo no alto, tres cartas protagonistas centralizadas, foco ciano, informacao basica na carta e acoes secundarias separadas. A recompensa agora tambem oferece `VER BARALHO`; a consulta mostra somente a composicao do baralho, fecha sem avancar a oferta e nao expoe a ordem oculta de compra. A captura de 1920x1080 confirmou tooltip legivel para texto maior. Esta entrega estabiliza a recompensa comum e os componentes compartilhados; o redesenho das demais telas continua pendente.

## Integracao jogavel das telas de recompensa e evento — 25/09/2026

O fluxo jogavel recebeu a aplicacao dos componentes do kit que ainda estavam somente importados: selecao de carta nao cobre mais nome, custo ou descricao; a recompensa comum usa painel, botoes de carta e balao de efeito no hover; a recompensa de elite usa o mesmo componente para reliquias e cartas raras; o evento usa painel escuro, titulo Bangers e botoes com area suficiente para texto longo. A entrada de combate para recompensa/evento agora usa uma transicao curta de opacidade e escala.

Alterados `carta.tscn`, `main.tscn`, `main.gd`, `recompensa_opcao.gd`, `ui_hq_v1/estilos/tooltip.tres`, `tests/test_composicao_combate.gd`, `tests/test_apresentacao_eventos.gd` e criado `tests/test_apresentacao_recompensas.gd`. Os arquivos `preview_fluxo.gd`, `preview_recompensa.tscn`, `preview_recompensa_elite.tscn` e `preview_evento.tscn` permitem inspecionar as tres telas com dados reais da partida.

Verificacao executada com Godot 4.7.2 GL Compatibility: os testes focados de composicao, evento e recompensa passaram; a suite de 31 cenas em `tests/*.tscn` terminou com `FALHAS=0`; `git diff --check` passou. Capturas reais em 1280x720 de recompensa comum, recompensa elite e evento foram geradas e inspecionadas. A captura de recompensa mostrou o balao de descricao no hover sem fazer o item desaparecer; a captura de evento mostrou o painel e as tres opcoes estilizadas.

Regra de jogo, sinais de escolha, baralho, transicoes de roteiro e efeitos de eventos nao foram alterados. O teste headless do preview nao produz textura de viewport no renderer dummy; por isso, a evidencia visual foi obtida com janela real GL Compatibility.

## Passe tipográfico e de recursos do HUD de combate — 25/09/2026

Após a captura real da reconstrução, o usuário apontou que alguns textos ainda não pertenciam à tipografia do jogo, Energia continuava parecendo texto simples, os recursos inferiores tinham pouca identidade e Vida precisava de tratamento cyberpunk mais forte.

Alterados `main.tscn`, `main.gd` e `tests/test_composicao_combate.gd`: títulos de turno, combatentes e intenção usam Bangers; valores e informações usam Barlow; Energia mostra ícone e valor compacto; Compra e Descarte ganharam módulos próprios com ícone e moldura; Vida agora usa ícone integrado, valor sem o rótulo solto `Vida:` e preenchimento/moldura neon com sombra. Regras, sinais, alvos, cartas e transições não foram alterados.

Verificação executada com Godot 4.7.2 GL Compatibility: o teste RED confirmou as expectativas tipográficas e de Vida antes da implementação; depois, as 30 cenas em `tests/*.tscn` terminaram com código 0. `tests/test_layout_combate.tscn`, `tests/test_composicao_combate.tscn` e `tests/test_interacao_hud_combate.tscn` passaram. Capturas reais em 1280×720 e 1920×1080 foram geradas por `preview_combate.tscn` e inspecionadas; a composição ficou legível sem o botão invadir a mão, com os módulos de recursos acima das cartas.

Pendência visual: Vega e os inimigos ainda usam quadrados provisórios. A próxima melhoria pode substituir esses placeholders por arte dos combatentes, sem reabrir a composição estrutural.

## Correção verificável da composição do combate — 25/09/2026

As capturas enviadas pelo usuário mostraram que a primeira adaptação do kit ainda tinha texto duplicado, painéis sobrepostos e cartas esticadas. A inspeção posterior no renderer real confirmou mais dois problemas: títulos de Habilidade sem contraste e descrições de cartas invadindo a arte. O teste anterior com `--headless --resolution` não havia mudado o viewport para os tamanhos alegados; por isso, aquela aprovação de layout não era evidência suficiente.

Corrigidos em `main.gd`, `main.tscn`, `carta.tscn` e `botao_carta.gd`: os rótulos legados permanecem ocultos ao retornar ao combate; turno, intenção, estados, alvos, Vida, mão e botão de turno ocupam áreas distintas; cartas mantêm proporção e centralização mesmo quando restam duas na mão; a tipografia cresce com a resolução; títulos de cartas têm contraste e nomes longos usam tamanho menor; descrições foram compactadas preservando valores e efeitos derivados do catálogo. As barras de Vida usam preenchimento proporcional com contorno separado. Recompensa e evento ocultam também as caixas decorativas do HUD, sem redesenhar essas telas.

Verificação executada com Godot 4.7.2 GL Compatibility: capturas reais em 1280×720 e 1920×1080 foram inspecionadas; capturas de recompensa e evento em 1280×720 confirmaram ausência do HUD de combate. `tests/test_layout_combate.tscn` confere viewport real, colisões de áreas, proporção da mão, contraste e espaço de texto para as nove cartas. `tests/test_interacao_hud_combate.tscn` aciona sinais dos botões de alvo e fim de turno e confirma seleção, custo, dano, vitória e derrota. A suíte de 29 cenas e a importação headless do editor terminaram com código 0. A validação visual no editor do usuário ainda não foi relatada para esta correção. A tipografia dos botões de recompensa/evento continua apertada; seu redesenho fica fora desta etapa de combate.

## Ajuste estrutural da tela de combate — 25/09/2026

Após a inspeção dos screenshots enviados pelo usuário, a adaptação visual recebeu um primeiro ajuste estrutural. O turno passou a separar título e número em linhas próprias; o resumo de combate, a intenção, os estados do inimigo e os dados do alvo ganharam áreas visuais independentes dos nós legados usados pelo código. Capturas posteriores ainda revelaram falhas corrigidas na seção acima.

O HUD de combate agora é ocultado integralmente ao entrar em recompensa, evento, resultado ou `RUN PRE-CHEFE`. Isso remove Vida, Energia, Barreira, Combo, relíquias, compra, descarte, mão e `Encerrar turno` dessas telas. A mão foi ampliada para acomodar seis cartas na composição de 1280×720, e o tooltip redundante das cartas foi removido para não cobrir a seleção.

Arquivos alterados nesta correção: `main.tscn`, `main.gd`, `carta.tscn`, `botao_carta.gd`, `tests/test_apresentacao_combate.gd` e este arquivo. As regras, sinais, alvos, gasto de Energia, fim de turno, vitória, derrota e transições não foram modificados.

Verificação executada com Godot 4.7.2: `git diff --check`, importação do editor headless e 27 cenas de `tests/*.tscn` passaram. `tests/test_apresentacao_combate.tscn` passou em 1280×720 e 1920×1080; também verificou que a recompensa não conserva o HUD de combate. A inspeção visual final em uma janela real do editor ainda é necessária, especialmente para recompensa, evento e pré-chefe.

Próximo passo: abrir `main.tscn` no editor em 1280×720 e 1920×1080, conferir a composição limpa nos quatro estados e relatar qualquer sobreposição residual antes de mexer em mapa ou menu.

## Snapshot vigente — 24/09/2026

O fluxo intercalado foi implementado: cinco combates e quatro eventos antes do chefe, na ordem `combate comum -> evento -> combate comum -> evento -> elite -> evento -> combate comum -> evento -> combate comum`. O catalogo contem dez encontros possiveis; o roteiro usa nove posicoes antes do chefe.

Implementados nesta sessao: `dados_encontros.gd`, `seletor_encontros.gd`, `roteiro_run.gd`, `dados_eventos.gd`, `resolucao_eventos.gd`, o `EventoOverlay` em `main.tscn` e a integracao do fluxo em `main.gd`. O painel de evento bloqueia cartas e alvos, e recompensas/resultado nao ficam visiveis junto do combate.

O elite continua sendo a Unidade de Contencao Portuaria no terceiro combate da run linear atual e sua recompensa dupla agora leva ao evento seguinte. Eventos podem iniciar combate especial sem recompensa comum automatica; a vitoria retorna ao resultado do evento e a derrota encerra a run sem avancar o roteiro. O chefe ainda nao foi implementado; o mapa agora possui uma tela de navegacao isolada aberta a partir de `RUN PRE-CHEFE`.

Verificacao automatizada desta sessao: 25 cenas de teste passaram com Godot 4.7.2 em modo headless. A validacao visual da run intercalada foi confirmada pelo usuario no editor.

Direcao atual: no mapa, a elite sera o terceiro ponto e concedera uma reliquia e uma carta rara quando a run for integrada. A sequencia linear atual permanece preservada ate a validacao do mapa. As Docas serao tratadas como distrito misto de trabalho portuario, infraestrutura industrial e moradia. A integracao visual inicial abre o mapa somente na tela pre-chefe.

Atualização: 24/09/2026 — ritmo intercalado, catálogo de encontros, eventos estruturados, painel de eventos e combate especial implementados; validação visual da run confirmada pelo usuário; balanceamento adiado.

## Validação manual da run intercalada — 24/09/2026

Relato do usuário acompanhado de screenshot: a run foi executada no editor até a posição `Combate: 5/5` e chegou corretamente à tela `RUN PRE-CHEFE`.

O screenshot mostrou `Baralho: 16`, `Vida: 25`, `Energia: 3/4`, `Barreira: 2` e as relíquias `Juntas de Retorno` e `Reservatório Auxiliar` preservadas. A tela final também manteve visíveis a última ação e os recursos do jogador.

Validação visual confirmada: o fluxo terminou sem sobreposição entre combate, recompensas, eventos e resultado. A mensagem indica que a rota até o chefe foi concluída, sem afirmar que o chefe foi derrotado.

Esta confirmação é uma validação manual no editor, separada da regressão headless de 25 testes já registrada acima.

## Integração da primeira etapa do kit visual de combate — 25/09/2026

Aplicado o kit em `res://ui_hq_v1/` somente à interface de combate. `main.tscn` agora usa `tema_base.tres`, o fundo compartilhado e os componentes de faixa de turno, ícones de Energia/Barreira/Combo/compra/descarte/mão, barras de Vida e painéis separados para intenção e estados do inimigo. Vega e Drone continuam quadrados provisórios, com molduras locais ciano e vermelha.

`carta.tscn` foi convertido em um componente compartilhado em camadas, ainda com raiz `Button`: moldura de Ataque/Habilidade, ilustração disponível, selo de custo, nome, descrição e foco de seleção. `botao_carta.gd` mantém o toggle, o `ButtonGroup`, o texto derivado e o clique da carta; a apresentação visual é atualizada com o identificador e o tipo reais da carta.

`main.gd` passou a atualizar barras, contadores separados, turno, intenção, estados e texto visual de Energia a partir do estado atual. Os nós antigos usados pelo fluxo e pelos testes foram preservados; regras, sinais, alvos, gasto de Energia, fim de turno, vitória, derrota e transições não foram alterados.

Verificação executada com Godot 4.7.2: `git diff --check`, importação do editor headless e 27 cenas em `tests/*.tscn` terminaram com código 0. `tests/test_apresentacao_combate.tscn` passou com `--resolution 1280x720` e `--resolution 1920x1080`, verificando tema, recursos, camadas da carta e limites da mão/botão de turno. A captura de pixels headless não foi válida porque o renderer dummy não expôs uma textura de viewport; portanto a inspeção visual final em janela real ainda precisa ser feita no editor.

Arquivos alterados nesta etapa: `main.tscn`, `main.gd`, `carta.tscn`, `botao_carta.gd` e `tests/test_apresentacao_combate.gd`. O menu, mapa, eventos e telas de recompensa não foram redesenhados.

Próximo passo: validar no editor a abertura do mapa, o bloqueio dos destinos desconectados e o retorno apos combate/evento; depois conferir visualmente a variante com descanso em outra posicao.

## Auditoria inicial para mapa e chefe — 24/09/2026

Inspeção estática do repositório atual: a cena jogável é `main.tscn`, com `main.gd` como orquestrador da interface, combate, recompensas, eventos e roteiro. `roteiro_run.gd` contém uma sequência linear de nove etapas pré-chefe; `dados_encontros.gd` e `seletor_encontros.gd` catalogam e sorteiam encontros; `dados_eventos.gd` e `resolucao_eventos.gd` controlam eventos; `dados_inimigos.gd`, `inimigo_combate.gd` e `encontro_combate.gd` controlam intenções e execução do combate.

Não foram encontrados cena, script ou dados de mapa, nós conectados, caminhos ramificados, descansos, melhoria de carta, chefe ou arena final. O chefe também não existe no catálogo atual. Os pontos narrativos do briefing para Lastro, sala de controle, exoesqueleto e escolhas após a luta permanecem design, não comportamento implementado.

Conflito identificado antes de qualquer alteração: o código e `DECISOES.md` fixam a Unidade de Contenção como terceiro combate, na quinta posição do roteiro atual; o briefing mais recente define o elite como terceiro ponto do mapa. Essa diferença precisa ser confirmada antes de alterar o roteiro.

Verificação executada nesta auditoria: `git diff --check`, conferência dos arquivos e referências de cena, e leitura estática dos scripts envolvidos. A Godot 4.7.2 não estava disponível no PATH nem nas localizações usuais deste ambiente; nenhum teste headless novo foi executado. Os relatos anteriores de testes continuam sendo histórico, não verificação desta auditoria.

O usuário confirmou a regra mais recente: o elite deve ser o terceiro ponto do mapa, não necessariamente o terceiro combate. Nenhum código de jogo foi alterado durante esta auditoria. A implementação seguinte registra essa decisão em `DECISOES.md` e `GAME_DESIGN.md`.

## Modelo isolado do mapa das Docas — 24/09/2026

Criado `mapa_run.gd` como objeto de dados independente. O modelo gera sete pontos: combate inicial, bifurcação, elite no terceiro ponto, duas bifurcações intermediárias, reencontro no sexto ponto e chefe `Lastro` no sétimo. Foram incluídas duas variantes estruturais, com o descanso no segundo ou no quinto ponto.

Criados `tests/test_mapa_run.gd` e `tests/test_mapa_run.tscn`. O teste verifica pontos fixos, ramificações, reencontro, chegada de todos os caminhos ao chefe e variação da posição do descanso. O mapa ainda não está conectado a `main.gd`; combate, eventos e recompensas não foram alterados.

Verificação executada: `git diff --check` passou. A execução RED/GREEN da cena não foi possível porque o executável da Godot não está disponível neste ambiente; portanto a compilação e o teste headless do novo script ainda precisam ser executados no editor ou em um terminal com Godot 4.7.2.

Validação relatada pelo usuário: `tests/test_mapa_run.tscn` exibiu `OK: estrutura do mapa`. Como o teste percorre os pontos fixos, as ramificações, o reencontro, a chegada ao chefe e as duas variantes de descanso, esses comportamentos foram observados como aprovados no ambiente do usuário. Esta é uma validação externa relatada, não uma execução feita neste terminal.

Relato posterior do usuário acompanhado de saída do editor: a variante 0 foi impressa com P1 combate, ramificações em P2 e P4, elite em P3, descanso/evento em P5, reencontro-evento em P6 e `Lastro` em P7. A saída terminou com `OK: estrutura do mapa`. O editor exibiu também um aviso de UID inválido para o recurso de `tests/test_mapa_run.gd`, mas carregou o script pelo caminho textual; não houve falha do teste.

Próximo passo: inspecionar visualmente as duas variantes ou gerar uma representação no editor antes de integrar o mapa à run.

## Navegacao visual isolada do mapa — 24/09/2026

Iniciada a integracao gradual do mapa em `main.gd` e `main.tscn`. A tela `RUN PRE-CHEFE` agora oferece `Abrir mapa`; o painel mostra os sete pontos e cria um botao para cada no da variante escolhida.

O mapa mantem um ponto atual e habilita somente os destinos conectados por `mapa_run.destinos_de`. Nos fora da rota ficam bloqueados. Ao selecionar um no, a integracao encaminha para o sistema existente: combate comum ou elite usa `_iniciar_combate_por_id`, evento usa `EventoOverlay` e descanso volta ao mapa com uma mensagem provisoria, sem alterar Vida ou baralho. O chefe `Lastro` aparece no mapa, mas continua reservado porque seu combate ainda nao existe.

O fluxo linear anterior continua sendo iniciado normalmente; o mapa pode ser aberto depois da tela pre-chefe para validar a navegacao sem alterar a luta, os eventos ou as recompensas existentes. Recompensas e continuacao de eventos iniciados pelo mapa retornam ao mapa atual.

Criado `tests/test_navegacao_mapa.gd` com `tests/test_navegacao_mapa.tscn`. O teste verifica a abertura do painel, o inicio em P1, dois destinos habilitados, bloqueio de nos desconectados e movimentacao somente apos selecionar um destino valido. A Godot nao esta disponivel no PATH deste terminal, portanto a execucao RED/GREEN ainda precisa ser feita no editor pelo usuario.

A variante permanece deterministica em `mapa_variante = 0` nesta etapa. O modelo ja aceita a variante 1 e o teste estrutural anterior confirmou a mudanca da posicao do descanso; ainda falta validar essa variante visualmente na tela integrada.

## Refino visual da tela do mapa — 24/09/2026

Relato do usuario acompanhado de screenshot: a primeira tela integrada do mapa deixava indicadores de combate, ultima acao e recursos visiveis por baixo do mapa. Os botoes tambem estavam concentrados no canto esquerdo, com pouca diferenciacao entre ponto atual, destino e no bloqueado.

Alteracao feita em `main.tscn` e `main.gd`: o mapa agora usa um fundo opaco em tela cheia, oculta os indicadores do combate enquanto esta aberto, centraliza as linhas dos sete pontos, aumenta a area clicavel dos nos, permite quebra de texto nos nomes e aplica estados visuais distintos para atual, destino disponivel e caminho bloqueado. A legenda explica esses estados dentro da propria tela.

O teste `tests/test_navegacao_mapa.gd` agora tambem verifica que o fundo aparece e que `PilhasLabel` e `AcaoLabel` ficam ocultos durante a navegacao. `git diff --check` passou. A Godot 4.7.2 nao esta disponivel no terminal, entao a compilacao, o teste headless e a aparencia final continuam pendentes de execucao no editor.

## Implementacao mais recente — 24/09/2026

Implementados os componentes de conteudo e fluxo desta sessao:

- `dados_encontros.gd`: dez entradas, com quatro combates comuns, um elite e cinco eventos narrativos.
- `seletor_encontros.gd`: sorteio de eventos sem repeticao, registro validado e reinicio.
- `roteiro_run.gd`: nove posicoes fixas antes do chefe, mantendo a Unidade de Contencao como terceiro combate.
- `dados_eventos.gd` e `resolucao_eventos.gd`: opcoes e consequencias estruturadas fora da cena e sem mutacao direta do jogador pelo resolvedor.
- `main.tscn`: `EventoOverlay` com titulo, contexto, ate tres opcoes, resultado e continuar.
- `main.gd`: transicoes de combate, evento, recompensa, elite, pre-chefe e combate especial.

O fluxo preserva Vida e baralho entre etapas. Recompensas comuns avancam para evento; skip tambem avanca sem alterar o baralho; a recompensa dupla do elite avanca para o evento seguinte. Ao terminar as nove posicoes, a interface mostra `RUN PRE-CHEFE` e nao afirma que o chefe foi derrotado.

Consequencias provisoriamente implementadas: ajudar o operario custa 10 de Vida; desligar a valvula inicia uma Torreta de Contencao; enfrentar o ladrao ou confrontar a fiscalizacao inicia um Guarda Portuario. As ideias de recompensa da carga e remocao real de carta pelo ladrao continuam sem efeito de jogo nesta etapa, para nao inventar regras ainda nao aprovadas.

Testes RED -> GREEN e regressao: foram adicionados `test_catalogo_encontros.tscn`, `test_seletor_encontros.tscn`, `test_roteiro_run.tscn`, `test_resolucao_eventos.tscn`, `test_apresentacao_eventos.tscn` e `test_ciclo_encontros.tscn`; a suite completa de 25 testes terminou com codigo 0. A importacao headless do editor tambem foi executada durante a implementacao.

Validação manual confirmada pelo usuário: a run chegou a `RUN PRE-CHEFE` no editor, com a tela organizada e sem sobreposição visual entre as etapas.

Próximo passo: definir os efeitos finais dos eventos, então preparar o primeiro chefe e o mapa das Docas. Balanceamento definitivo continua adiado.

## Confirmado

- Primeira entrega: Vega como personagem jogável e Docas como distrito inicial.
- Expansão planejada: Luvto e Cais, cada um com seu distrito inicial.
- Vega é humana com braços protéticos e usa Combo/Finalização.
- Tipos de carta: Ataque, Habilidade e Aprimoramento.
- Desenvolvimento acompanhado, gradual e com GDScript tipado.
- O projeto declara Godot 4.7 e `GL Compatibility`; screenshot do usuário mostrou o editor 4.7.2 stable.
- Foco inicial em PC, com intenção futura de celular.
- Marco v0.1: o ciclo fundamental de deckbuilder roguelike foi validado, sem significar que todos os sistemas do design estejam implementados.

## Estado implementado

- Cena principal em `res://main.tscn`, executada no editor segundo relato do usuário.
- Carta reutilizável em `res://carta.tscn`, com nome, custo, descrição e seleção.
- Dados de Golpe, Proteção, Direto Hidráulico, Quebra-chassi, Brecha, Pulso Debilitante e três cartas raras estão em `res://dados_cartas.gd`; `main.gd` continua usando a mesma interface de `CARTAS`.
- Compra de 6 cartas, mão, descarte e reembaralhamento.
- Baralho da run iniciado com 12 cartas: 4 Golpes, 4 Proteções, 2 Diretos Hidráulicos e 2 Quebra-chassis; recompensas comuns e a carta rara do elite podem aumentar o baralho durante a run.
- Energia, Vida, Barreira, fase inimiga, resultado e reinício do combate de teste.
- Combo de Vega até 5 e Quebra-chassi consumindo todo o Combo para causar `5 + 3 × Combo`.
- Relíquia inicial Juntas de Retorno: ao alcançar 2 Combo no turno, concede 3 de Barreira uma vez; voltar a 2 no mesmo turno não ativa novamente.
- Catálogo de relíquias em `res://dados_reliquias.gd`: Juntas de Retorno, Reservatório Auxiliar e Mecanismo de Recuo; a run começa com Juntas e o elite oferece duas opções restantes.
- Cartas raras: Golpe de Aríete, Ruptura de Pressão e Placa Reforçada; o elite oferece três opções distintas e a jogadora escolhe uma.
- Exposto e Enfraquecido funcionam como cargas contadas por golpe nos inimigos; Brecha e Pulso Debilitante estão disponíveis como recompensas, mas não entram no baralho inicial.
- Drone atual com 30 de Vida e ciclo visível `Rajada → Blindagem → Rajada → Sobrecarga → Rajada → Marca → Rajada`; Sobrecarga e Marca são consumidas na Rajada seguinte.
- Catálogo comum em `res://dados_inimigos.gd`: Drone de Segurança (30 de Vida), Estivador Cibernético (36), Torreta de Contenção (24) e Guarda Portuário (32), cada um com ciclo determinístico próprio de ataque, defesa e preparação.
- `res://seletor_inimigos.gd` sorteia inimigos comuns sem repetição entre as posições de combate; a terceira ocorrência de combate usa o elite fixo e não entra no histórico comum.
- `res://inimigo_combate.gd` interpreta os ciclos dirigidos por dados, e a interface mostra dinamicamente nome, Vida, Barreira, intenção e estados do inimigo ativo.
- Run intercalada implementada: cinco combates e quatro eventos antes do chefe, com recompensa comum entre combates e recompensa dupla obrigatória no elite.
- Primeiro componente genérico criado em `res://combatente.gd`: Vida atual e máxima, Barreira, Exposto, Enfraquecido, cálculo de dano por golpe, recebimento de golpes e reinicialização.
- `res://jogador_combate.gd` concentra o estado do jogador, Energia, Combo e ativação por turno de Juntas de Retorno.
- `res://encontro_combate.gd` concentra inimigo ativo, baralho temporário, turno, condição de encerramento e execução da fase inimiga.
- Oferta comum sorteia três cartas distintas entre as seis cartas comuns disponíveis; a jogadora pode adicionar uma ao baralho ou pular. A oferta do elite sorteia duas relíquias e três cartas raras em etapas separadas, sem skip.
- A recompensa do elite alterna visualmente entre uma única etapa de relíquias e uma única etapa de cartas raras; os controles da etapa anterior são escondidos antes da próxima aparecer.
- Apresentação do combate reorganizada: intenção e estados do inimigo têm áreas próprias, a última ação fica visível, Energia mostra o limite e `SEM ENERGIA`, e a mão mostra seu limite e `MÃO CHEIA`.
- Layout da tela refinado: o bloco de pilhas tem espaço para as duas linhas, `VEGA` fica separado abaixo dele e os indicadores de Energia, Barreira, Combo, Relíquia e Vida ficam alinhados em uma coluna legível.

## Atividade atual

Core vertical v0.1 encerrado. A consolidação técnica inclui `Combatente`, `JogadorCombate`, `EncontroCombate`, `BaralhoCombate`, `InimigoCombate` e `ResolucaoCartas`. O catálogo de quatro inimigos comuns, o elite, as cartas raras, as relíquias, o catálogo de encontros, o roteiro e os eventos foram implementados. `main.gd` delega estado do jogador, recursos temporários, inimigo ativo, baralho do combate, turno e fase inimiga; continua responsável por sinais da cena, cartas visuais, interface, recompensas e fluxo da run. A run intercalada e o combate especial passaram nos testes headless; falta a confirmação visual final no editor.

O plano `superpowers/plans/2026-09-23-primeira-cena.md` é histórico e não representa a atividade atual.

## Evidência disponível

- Relato do usuário: o ciclo básico funciona para jogar cartas, gastar Energia, defender, descartar, comprar e vencer.
- Relato do usuário: a apresentação das cartas ficou adequada.
- Relato do usuário: prints mostraram Combo 3/5 preservado após jogar Proteção.
- Inspeção dos arquivos confirmou as estruturas registradas nas seções cronológicas abaixo.
- Teste automatizado executado com Godot 4.7.2 em modo headless confirmou o ciclo Rajada/Blindagem; a experiência visual ainda deve ser conferida no editor.
- Teste automatizado da run confirmou Vida persistente, recompensa no baralho, reinicialização do estado temporário e conclusão após o segundo combate.
- Relato do usuário, com base nas telas: compra, seleção, uso, descarte, reembaralhamento, recursos, Combo/Finalização, intenções, vitória/derrota, persistência de Vida e conclusão da run funcionaram no editor.
- Teste automatizado do catálogo confirmou as seis cartas e seus valores; os testes de intenções e run permaneceram verdes após a extração, a inclusão de Direto e os estados.
- Teste automatizado de Juntas de Retorno confirmou ativação ao alcançar 2 Combo, concessão de 3 de Barreira, ausência de repetição no mesmo turno e nova ativação no turno seguinte.
- Regressão headless com Godot 4.7.2: catálogo, Juntas de Retorno, intenções do Drone e ciclo de run terminaram com código 0; a importação do projeto no editor headless também terminou com código 0.
- Teste automatizado de estados confirmou Exposto `2 → 1 → 0`, Enfraquecido reduzindo cada golpe da Rajada, consumo contra Barreira, aplicação por Brecha/Pulso e exibição dos estados no Drone.
- Relato do usuário: Brecha e Pulso Debilitante foram utilizados no editor e funcionaram bem.
- Relato do usuário: as ofertas aleatórias e o botão `Pular recompensa` funcionaram corretamente no editor.
- Regressão após a integração de `Combatente`: `test_combatente.tscn`, `test_catalogo_cartas.tscn`, `test_estados.tscn`, `test_juntas_retorno.tscn`, `test_intencoes_drone.tscn` e `test_ciclo_run.tscn` terminaram com código 0; a importação do editor headless também terminou com código 0.
- Screenshot do usuário identificou sobreposição visual entre `PilhasLabel` e o botão `VEGA`, além de desalinhamento dos indicadores do jogador; o ajuste foi feito em `main.tscn` sem alterar regras ou conteúdo do combate.
- Teste focado `tests/test_apresentacao_combate.tscn` passou após o ajuste e confirmou largura/altura do bloco de pilhas, separação vertical de `VEGA` e ausência de invasão dos indicadores de recurso.
- Regressão headless com Godot 4.7.2: os 12 testes em `tests/*.tscn` terminaram com código 0; a importação do projeto no editor headless também terminou com código 0.
- Regressão após `JogadorCombate` e `EncontroCombate`: os 14 testes em `tests/*.tscn` terminaram com código 0; a importação do projeto no editor headless também terminou com código 0.
- Testes do catálogo confirmaram os quatro inimigos, suas Vidas e ciclos; o seletor confirmou sorteio sem repetição, rejeição de duplicatas e esgotamento seguro.
- `tests/test_cartas_multiplos_inimigos.tscn` confirmou as seis cartas atuais contra os quatro inimigos configurados.
- Regressão após a integração do catálogo: os 17 testes em `tests/*.tscn` terminaram sem `SCRIPT ERROR`, `ERROR:` ou `FALHA:`; a importação do projeto no editor headless também terminou limpa.
- Relato do usuário: os quatro inimigos comuns foram enfrentados no editor; nomes, intenções e variação dos encontros ficaram mais dinâmicos.
- Teste do catálogo confirmou a Unidade de Contenção Portuária com 44 de Vida, quatro intenções e Rajada fortalecida para `7 × 2` depois de Pressurizar.
- Testes confirmaram nove cartas catalogadas, três raras e resolução de Golpe de Aríete, Ruptura de Pressão e Placa Reforçada pelo mesmo `ResolucaoCartas`.
- Testes confirmaram três relíquias catalogadas, rejeição de duplicatas e os gatilhos de Reservatório Auxiliar e Mecanismo de Recuo em `JogadorCombate`.
- Teste do ciclo de run confirmou dois inimigos comuns sem repetição, elite fixo no terceiro combate, duas opções de relíquia, três cartas raras e conclusão somente após os dois prêmios.
- Regressão headless com Godot 4.7.2: 19 cenas em `tests/*.tscn` terminaram com código 0; a importação do editor headless também terminou com código 0.
- Relato do usuário acompanhado de screenshot: a run intercalada chegou a `Combate: 5/5` e `RUN PRE-CHEFE`, com Vida, Energia, Barreira e as relíquias visíveis na tela.
- Relato do usuário: após vencer o elite, a tela mostrava simultaneamente títulos/opções de relíquia e carta rara; o problema foi reproduzido no teste de ciclo e corrigido separando a visibilidade das duas etapas.
- Teste de regressão após a correção: 19 cenas em `tests/*.tscn` e a importação do editor headless terminaram com código 0.

## Próximo passo vigente

Definir os efeitos finais dos eventos e preparar o primeiro chefe. Depois, iniciar o mapa das Docas.

## Como atualizar este arquivo

Substitua os itens não verificados por fatos específicos após observar o resultado. Informe versão, caminho, arquivos criados, comportamento visto, erros existentes e próximo passo. Preserve a distinção entre proposta e funcionamento observado.

## Nota sobre o histórico

O resumo inicial e a última seção cronológica descrevem o estado vigente. As seções cronológicas anteriores preservam decisões e marcos históricos; quando um item antigo divergir do resumo atual, ele deve ser lido como registro do estado daquela etapa, não como requisito ou pendência atual.

Último avanço: elite fixo no terceiro combate, recompensa obrigatória de relíquia e carta rara, com testes automatizados verdes.

Validado automaticamente:
- 19 cenas de teste headless com Godot 4.7.2.
- Importação do projeto em modo editor headless.

Validado manualmente:
- Os quatro inimigos comuns foram enfrentados no editor.

Pendente de validação manual:
- Unidade de Contenção, recompensa dupla e efeitos das novas relíquias.

Histórico manual anterior:
- Novo turno restaura a energia para 4.
- Contador de turnos avança.
- Encerrar turno após derrotar o drone é bloqueado.

Próximo passo:
- Executar novamente a run de três combates no editor e confirmar que apenas uma etapa da recompensa do elite aparece por vez.

## Atualização da preparação de `carta.tscn` — 23/09/2026

Estado observado no projeto: `carta.tscn` existia, mas sua raiz era um `Control` sem script, texto ou tamanho mínimo. `main.tscn` ainda mantém as duas cartas manuais dentro de `Mao`, como pedido para esta etapa.

Alteração feita: `carta.tscn` agora tem uma raiz `Button` chamada `Carta`, usa `botao_carta.gd`, define tamanho mínimo de 180 x 240 e começa com o texto `CARTA`. `main.tscn` e `main.gd` não foram alterados.

Verificação executada: inspeção estática dos arquivos e conferência da versão declarada no projeto (`Godot 4.7`, `GL Compatibility`). Não houve execução de F6 neste ambiente, portanto a resposta visual do botão ainda precisa ser confirmada no editor.

Próximo passo: abrir `carta.tscn` na Godot, executar com F6 e confirmar o texto `GOLPE` e a alternância entre selecionada e desmarcada ao clicar.

## Incidente e restauração de `main.tscn` — 23/09/2026

Relato do usuário: a Godot exibiu `Parse Error` em `res://main.tscn:5` e falhou ao carregar a cena.

Diagnóstico observado: `main.tscn` havia sido sobrescrito como uma cena que referenciava `res://main.tscn` como `PackedScene` e instanciava a si mesma. Isso criava uma dependência circular. A causa não estava em `carta.tscn`.

Restauração feita: `main.tscn` voltou à estrutura anterior com raiz `Main` (`Control`), `main.gd`, `Mao` (`HBoxContainer`), `BotaoCarta` e `BotaoProtecao`. A cena `carta.tscn` foi preservada.

Verificação executada: inspeção estrutural confirmou que `main.tscn` não instancia a si mesma e contém as referências e nós esperados. Ainda falta abrir a cena na Godot e executar F6 para confirmar o carregamento no editor.

## Implementação provisória de compra, mão e descarte — 23/09/2026

Alteração solicitada: testar o ciclo de combate com um baralho provisório de 5 Golpes e 5 Proteções, comprando 6 cartas por turno.

Arquivos alterados:

- `main.gd`: pilha de compra, pilha de descarte, criação de cartas por `carta.tscn`, metadata `id_carta`, descarte ao jogar e ao encerrar, ataque do drone e reembaralhamento quando a compra esvazia.
- `main.tscn`: remoção dos dois botões fixos de `Mao`, criação de `PilhasLabel` e separação 12; o `Mao` foi preservado.
- `carta.tscn`: tamanho mínimo alterado para 140 x 200; raiz `Button` e `botao_carta.gd` preservados.

Verificação executada: inspeção estrutural confirmou as referências, nós e constantes principais. A Godot 4.7 não está disponível no `PATH` deste terminal, portanto ainda não há execução de F6 nem validação manual do ciclo.

Próximo passo: executar `main.tscn` na Godot e conferir as contagens iniciais (`Compra: 4 | Descarte: 0 | Mão: 6`), depois jogar uma carta e encerrar o turno observando as contagens e a Energia.

## Apresentação das cartas — 23/09/2026

Relato do usuário: o ciclo básico de combate está funcionando, incluindo jogar cartas, gastar Energia, defender, descartar, comprar e vencer.

Alteração feita: `botao_carta.gd` agora mostra nome, custo em Energia, descrição do efeito e o marcador `SELECIONADA` sem esconder as demais informações. `main.gd` preenche esses campos a partir do dicionário `CARTAS`; Golpe mostra o dano e Proteção mostra a Barreira usando os valores atuais do dicionário.

Regras preservadas: compra, mão, descarte, reembaralhamento, Energia, dano, defesa, turnos e condição de vitória não foram alterados nesta etapa.

Verificação executada: inspeção estrutural confirmou os campos exportados, o preenchimento derivado de `CARTAS` e a permanência das funções de compra e descarte. A Godot não está disponível no `PATH` deste terminal; a aparência final ainda precisa ser conferida executando `main.tscn` no editor.

Próximo passo: validar visualmente as cartas e então iniciar a etapa de resultado e reinício do combate.

## Resultado e reinício do combate — 23/09/2026

Relato do usuário: a apresentação das cartas ficou adequada e o ciclo básico continua funcionando.

Alteração feita: `main.tscn` recebeu os filhos diretos `ResultadoLabel` e `Reiniciar`, posicionados no centro e abaixo dele, longe da mão. Ambos começam ocultos durante o combate.

`main.gd` agora mostra `VITÓRIA` quando o drone é derrotado, mostra `DERROTA` quando Vega fica sem Vida e conecta `Jogar novamente` a `reload_current_scene()`, reiniciando o combate de teste com um novo baralho embaralhado.

Regras preservadas: compra, mão, descarte, Energia, dano, Barreira, turnos e bloqueio dos controles continuam no fluxo anterior.

Verificação executada: inspeção estrutural confirmou os nós, referências, mensagens e chamadas nos dois caminhos de encerramento. A Godot não está disponível no `PATH` deste terminal; ainda falta validar visualmente vitória, derrota e reinício executando `main.tscn`.

Próximo passo: executar o combate até vencer e até perder, verificando a mensagem correspondente e o botão `Jogar novamente`.

## Contador de Combo da Vega — 23/09/2026

Alteração feita: `main.tscn` recebeu o `ComboLabel` como filho direto de `Main`, próximo ao indicador de Barreira. `main.gd` recebeu `COMBO_MAXIMO = 5`, o estado `combo` e a atualização `Combo: atual/máximo`.

Regra implementada: Golpe concede 1 Combo até 5; Proteção preserva o valor; encerrar o turno zera o Combo; derrotar o drone também zera o Combo antes da atualização final da interface. A descrição de Golpe agora informa que ele concede 1 Combo.

Regras preservadas: compra, mão, descarte, Energia, dano, Barreira, resultado e reinício continuam no fluxo anterior. Nenhuma carta consumidora de Combo foi adicionada.

Verificação executada: inspeção estrutural confirmou o nó, a constante, a variável, os pontos de incremento/reset e a descrição atualizada. A Godot não está disponível no `PATH` deste terminal; ainda falta executar o combate no editor para conferir `0/5`, `1/5`, manutenção com Proteção, `2/5` e reset para `0/5`.

Próximo passo: testar o contador em um combate novo antes de adicionar Quebra-chassi.

## Quebra-chassi e Finalização — 23/09/2026

Relato do usuário: os prints confirmaram Combo 3/5 preservado após jogar Proteção.

Alteração feita: `main.gd` agora cadastra Quebra-chassi como uma Finalização de custo 1, dano base 5 e bônus de 3 por ponto de Combo. O baralho provisório passou a ter 4 Golpes, 4 Proteções e 2 Quebra-chassis.

Regra implementada: ao jogar Quebra-chassi contra o inimigo, o dano é calculado como `5 + 3 × Combo`, todo o Combo é consumido e a carta não gera Combo. Golpe continua gerando 1 Combo; Proteção continua preservando o valor. O alvo e o custo são validados antes da resolução, então usar Quebra-chassi em Vega não deve gastar Energia nem consumir Combo.

Apresentação atualizada: a descrição da Finalização mostra que ela consome o Combo e exibe a fórmula do dano.

Verificação executada: inspeção estrutural confirmou cadastro, composição 4 + 4 + 2, fórmula, consumo, ausência de ganho de Combo e validações anteriores à resolução. A Godot não está disponível no `PATH` deste terminal; ainda falta validar no editor o caso Combo 1 produzindo 8 de dano e Combo 3 produzindo 14.

Próximo passo: testar Golpe → Quebra-chassi → Golpe e confirmar os valores 24 → 16 → 10 de Vida do drone, com Combo 1 → 0 → 1.

## Revisão de fontes e especificação — 23/09/2026

Problema confirmado: `GAME_DESIGN.md`, o topo de `STATUS.md` e a especificação de intenções ainda continham informações substituídas ou desatualizadas, incluindo o nome anterior de Luvto, Vega como robô e o antigo escopo de três personagens na primeira entrega.

Correções feitas:

- `GAME_DESIGN.md`: alinhado a Luvto, Vega humana com braços protéticos e primeira entrega focada em Vega/Docas; a precedência de `DECISOES.md`, `PERSONAGENS.md`, código e `STATUS.md` ficou explícita.
- `DECISOES.md`: esclarece que Luvto já está confirmado e que testes de balanceamento do protótipo podem começar, mantendo valores como hipóteses até aceitação.
- `STATUS.md`: resumo inicial consolidado com o estado implementado atual; o plano M0 permanece apenas como histórico.
- Especificação de intenções e recompensas: corrigida para três tipos de carta, Luvto e valores atuais observados do Drone. As hipóteses não aprovadas de 40 de Vida e ataques 6/10 foram removidas.

Nenhum script ou cena foi alterado naquela revisão. A direção posterior substituiu o ataque fixo pelo ciclo de intenções registrado abaixo.

## Rajada e Blindagem do Drone — 23/09/2026

Direção aprovada: intenção é a ação completa anunciada pelo inimigo, podendo representar ataque, defesa, buff ou debuff. O Drone de segurança das Docas terá o ciclo completo `Rajada → Blindagem → Rajada → Sobrecarga → Rajada → Marcar alvo → repetir`, implementado em partes.

Primeiro incremento implementado em `main.gd`: Rajada causa dois golpes separados de 3; Blindagem concede 6 de Barreira; as duas intenções alternam e são mostradas no botão do Drone. A Barreira anterior do Drone expira no início do turno dele, e ataques de Vega agora descontam primeiro essa Barreira.

Teste automatizado adicionado em `tests/test_intencoes_drone.gd`. Evidência headless com Godot 4.7.2: o teste falhou antes da implementação por ausência da execução, da Barreira inimiga e do texto da intenção; após a implementação, terminou com `OK: ciclo Rajada e Blindagem` e código 0. Foram confirmados Vega `40 → 34`, Blindagem 6, dano 6 totalmente absorvido sem reduzir a Vida 30 do Drone e nova Rajada levando Vega `34 → 28`. Jogar a carta Golpe nesse ponto, incluindo ganho de Combo, permanece na validação manual.

Validação manual posterior relatada no marco v0.1: a apresentação das intenções foi observada funcionando no editor. Sobrecarga e Marca ainda não fazem parte do estado implementado. O sorteio inicialmente considerado foi substituído, neste protótipo, pelo ciclo determinístico aprovado.

## Primeiro ciclo de run — 23/09/2026

Implementado o fluxo `combate 1 → recompensa → combate 2 → conclusão`. O baralho da run começa com 10 cartas e a escolha entre Golpe, Proteção ou Quebra-chassi adiciona uma cópia permanente para o segundo combate. A opção de pular recompensa permanece adiada.

A Vida atual de Vega atravessa a transição. Energia, mão, compra, descarte, Combo, Barreiras, turno, Vida do Drone e intenção do Drone são reiniciados. O segundo combate usa o baralho de 11 cartas e, após sua vitória, mostra `RUN CONCLUÍDA` e o botão de reinício.

Teste automatizado `tests/test_ciclo_run.gd`: primeiro falhou pela ausência dos nós e operações da recompensa; depois passou com Godot 4.7.2 em modo headless. Foram observados Vida 31 preservada, baralho `10 → 11`, Drone restaurado para 30, mão 6, compra 5, descarte vazio e conclusão após a segunda vitória. O teste anterior de Rajada/Blindagem também permaneceu verde.

Validação manual posterior relatada no marco v0.1: a recompensa e o ciclo completo foram observados funcionando no editor.

## Marco: core vertical v0.1 — 23/09/2026

Validação relatada pelo usuário com base nas telas do jogo:

- cartas são compradas, selecionadas, usadas e descartadas;
- compra, descarte e reembaralhamento funcionam;
- Energia, Vida e Barreira funcionam;
- Combo e Finalização da Vega produzem decisões relevantes;
- o Drone anuncia e executa intenções;
- vitória e derrota encerram corretamente o combate;
- a Vida persiste entre combates;
- a recompensa aumenta o baralho de 10 para 11 cartas;
- a run de dois combates chega à conclusão.

Conclusão aceita: a hipótese central foi validada e o protótipo já constitui um pequeno deckbuilder roguelike funcional. Este marco conclui o core vertical, não o projeto inteiro.

Continuam fora do estado implementado: catálogo de estados, relíquias, Aprimoramentos, múltiplos inimigos, mapa, eventos e chefe. Esses sistemas passam a ser expansão do core.

Ordem aprovada para a próxima fase:

1. consolidar tecnicamente o código, começando somente pela extração dos dados das cartas de `main.gd`;
2. implementar Direto Hidráulico;
3. implementar a relíquia inicial Juntas de Retorno;
4. implementar Exposto e Enfraquecido;
5. avançar depois para encontros diferentes, mapa das Docas e chefe.

Nenhum código ou cena foi alterado ao registrar este marco.

## Consolidação dos dados de cartas — 23/09/2026

Criado `dados_cartas.gd` como componente próprio de dados. `main.gd` mantém a constante local `CARTAS`, mas agora a recebe do catálogo; isso preserva as chamadas existentes enquanto remove o dicionário de regras do arquivo principal.

Nenhum valor anterior foi alterado. O catálogo agora contém também Direto Hidráulico, com custo 1, dano 4, alvo inimigo, geração de 2 de Barreira e ganho de 1 Combo.

Teste RED→GREEN: `tests/test_catalogo_cartas.gd` falhou antes da extração porque o recurso não existia e passou depois com `OK: catálogo de cartas preserva os dados do combate`. Em seguida, os testes de Rajada/Blindagem e da run de dois combates passaram novamente; a importação headless da Godot 4.7.2 também terminou com código 0.

Próximo incremento: implementar a relíquia inicial Juntas de Retorno, ativada ao alcançar pelo menos 2 Combo no turno.

## Direto Hidráulico — 23/09/2026

Implementado no catálogo, no baralho inicial da Vega e nas recompensas. O baralho passa a conter 12 cartas: 4 Golpes, 4 Proteções, 2 Diretos Hidráulicos e 2 Quebra-chassis. A área de recompensa passou a oferecer quatro opções fixas.

Ao jogar Direto contra o Drone, a carta causa 4 de dano, gera 2 de Barreira para Vega e concede 1 Combo. A descrição da carta é derivada dos mesmos dados usados na resolução.

Teste RED→GREEN: a suíte falhou antes da implementação pela ausência do identificador, do efeito e do botão de recompensa; após a implementação, catálogo, run e intenções terminaram com código 0. O teste do catálogo confirmou Vida do Drone `30 → 26`, Barreira `0 → 2` e Combo `0 → 1`. A recompensa confirmou o baralho `12 → 13`.

## Juntas de Retorno — 23/09/2026

Implementada a primeira relíquia da Vega em `main.gd`, com indicador permanente em `main.tscn`.

Regra implementada: quando um ataque não-finalização faz o Combo alcançar pelo menos 2 no turno, Juntas de Retorno concede 3 de Barreira. A relíquia ativa uma única vez por turno; consumir o Combo e alcançar 2 novamente no mesmo turno não concede outra Barreira. O estado de ativação é reiniciado no início de cada combate e no início de cada novo turno.

Teste RED→GREEN: `tests/test_juntas_retorno.gd` confirmou a primeira ativação, a ausência de repetição no mesmo turno e uma nova ativação no turno seguinte. A suíte também confirmou que Golpe continua gerando Combo e que a relíquia não altera o custo ou o efeito das cartas.

Verificação executada com Godot 4.7.2 em modo headless: teste do catálogo, teste de Juntas de Retorno, teste de intenções e teste do ciclo de run terminaram com código 0. A importação do projeto no editor headless também terminou com código 0.

Próximo passo: validar manualmente Brecha e Pulso Debilitante quando forem disponibilizados no fluxo de recompensas; depois decidir a entrada dessas cartas no baralho de teste e avançar para Sobrecarga e Marca do Drone.

## Exposto e Enfraquecido — 23/09/2026

Implementada a infraestrutura inicial de estados no `main.gd`. O Drone agora mantém cargas de Exposto e Enfraquecido, contadas por golpe e reiniciadas no início de cada combate.

Regra implementada: Exposto acrescenta 2 ao dano dos próximos golpes recebidos pelo Drone; Enfraquecido reduz em 2 o dano dos próximos golpes realizados pelo Drone, até zero. Cada carga é consumida mesmo quando a Barreira absorve o dano. A Rajada aplica o cálculo separadamente nos dois golpes.

Cartas adicionadas ao catálogo de teste em `dados_cartas.gd`:

- Brecha: Ataque de 4 de dano que aplica Exposto 2 se o Drone sobreviver.
- Pulso Debilitante: aplica Enfraquecido 2 ao Drone e concede 3 de Barreira a Vega.

Essas cartas não foram adicionadas ao baralho inicial, mas agora aparecem nas recompensas junto das quatro cartas anteriores. Isso preserva o baralho inicial enquanto permite validar os estados em jogo.

Apresentação: o botão do Drone mostra `Exposto: N` e `Enfraquecido: N` quando houver cargas ativas.

Teste RED→GREEN: `tests/test_estados.gd` confirmou catálogo, cálculo por golpe, consumo das cargas contra Barreira, aplicação de Brecha/Pulso, leitura na interface e reinicialização entre combates.

Verificação executada com Godot 4.7.2 em modo headless: catálogo, estados, Juntas de Retorno, intenções do Drone e ciclo de run terminaram com código 0. A importação do projeto no editor headless também terminou com código 0.

## Brecha, Pulso, Sobrecarga e Marca — 23/09/2026

Brecha e Pulso Debilitante foram adicionados à grade de recompensas em `main.tscn` e conectados ao fluxo de recompensa de `main.gd`. A grade passou a ter seis opções: Golpe, Proteção, Direto Hidráulico, Quebra-chassi, Brecha e Pulso Debilitante.

O Drone agora segue o ciclo determinístico `Rajada → Blindagem → Rajada → Sobrecarga → Rajada → Marca → Rajada`. Sobrecarga prepara +2 por golpe para a próxima Rajada; Marca prepara +1 por golpe para a próxima Rajada. O valor anunciado da Rajada já inclui esses modificadores e cada bônus é consumido depois do ataque completo.

O ciclo também respeita Enfraquecido: cada golpe passa pelos modificadores do Drone separadamente, e as cargas continuam sendo consumidas por golpe.

Teste RED→GREEN: `tests/test_intencoes_drone.gd` confirmou as quatro intenções novas/anteriores, os valores anunciados, o dano `5 × 2` de Sobrecarga, o dano `4 × 2` de Marca e o consumo dos bônus. `tests/test_ciclo_run.gd` confirmou que Brecha pode ser escolhida e adicionada ao baralho permanente.

Verificação executada com Godot 4.7.2 em modo headless: catálogo, estados, Juntas de Retorno, intenções completas e ciclo de run terminaram com código 0. A importação do projeto no editor headless também terminou com código 0. Validação manual posterior relatada pelo usuário confirmou o uso de Brecha e Pulso Debilitante no editor.

## Arquitetura genérica de combatentes — Task 1 e Task 2 — 23/09/2026

Criado `combatente.gd` como modelo `RefCounted` genérico para qualquer jogador ou inimigo. Ele concentra Vida atual e máxima, Barreira, Exposto, Enfraquecido, cálculo de dano por golpe, recebimento de golpes e reinicialização.

`main.gd` agora mantém `estado_jogador` e `estado_inimigo` como fontes únicas desse estado comum. As propriedades legadas `vida_jogador`, `vida_inimigo`, `barreira`, `barreira_inimigo`, `exposto_inimigo` e `enfraquecido_inimigo` continuam disponíveis, mas delegam aos objetos para preservar as interfaces existentes durante a migração.

A inicialização de um novo combate reinicia Barreira e estados temporários dos dois combatentes, preservando a Vida atual do jogador entre combates. Nenhuma regra de carta, intenção, recompensa ou layout foi alterada.

Teste RED→GREEN: a integração primeiro falhou porque `main.gd` não expunha os dois `Combatente`. Depois da implementação, `tests/test_estados.gd` confirmou os objetos e a sincronização entre o estado genérico e a interface legada. A regressão completa e a importação headless da Godot 4.7.2 terminaram com código 0.

Próximo passo: extrair a compra, o descarte e o reembaralhamento para `BaralhoCombate`, mantendo as pilhas temporárias do combate separadas do baralho permanente da run.

## Baralho de combate genérico — Task 3 — 23/09/2026

Criado `baralho_combate.gd` como componente `RefCounted` responsável somente pelas pilhas temporárias do combate. Ele copia o baralho permanente para a compra, compra identificadores, envia cartas ao descarte e reembaralha o descarte somente quando uma compra exige.

`main.gd` agora usa `baralho_combate` para preparar as pilhas, comprar identificadores e descartar cartas. As propriedades legadas `pilha_compra` e `pilha_descarte` continuam delegando ao componente para preservar a interface da tela e os testes existentes. O baralho permanente `baralho_run` continua separado e não é modificado pela compra.

Teste RED→GREEN: `tests/test_baralho_combate.tscn` primeiro falhou porque `BaralhoCombate` não existia. Depois da implementação, confirmou cópia do baralho, compra completa, reembaralhamento do descarte, descarte e retorno vazio quando ambas as pilhas acabam. `tests/test_ciclo_run.tscn` também terminou com código 0 após a integração.

Próximo passo: extrair o ciclo de intenções para um papel genérico `InimigoCombate`, mantendo a resolução de dano e a interface em `main.gd` durante a transição.

## Inimigo de combate genérico — Task 4 — 23/09/2026

Criado `inimigo_combate.gd` como extensão de `Combatente`. O componente concentra o ciclo determinístico de Rajada, Blindagem, Sobrecarga e Marca, os bônus preparados, o texto da intenção e a lista de danos de uma ação de ataque.

`main.gd` agora recebe a ação de `InimigoCombate.executar_intencao()` e aplica os golpes ao jogador, interrompendo a Rajada quando a Vida chega a zero. O texto visível também vem de `InimigoCombate.texto_intencao()`. Os nomes `intencao_drone`, `bonus_sobrecarga_inimigo` e `_executar_intencao_drone()` permanecem temporariamente como pontes de compatibilidade com o fluxo existente; eles não são a fonte do ciclo.

Teste RED→GREEN: `tests/test_inimigo_combate.tscn` primeiro falhou porque a classe não existia. Depois da implementação, confirmou o ciclo, os valores `3 × 2`, `5 × 2` e `4 × 2`, a preparação e o consumo dos bônus. A regressão dos oito testes e a importação headless da Godot 4.7.2 terminaram com código 0.

Próximo passo: criar a fronteira `ResolucaoCartas`, mantendo Combo e Juntas de Retorno explicitamente no contexto do jogador/personagem.

## Resolução de cartas — Task 5 — 23/09/2026

Criado `resolucao_cartas.gd` sem dependência de `Button`, `Label` ou cena. O componente valida identificador, alvo e Energia; resolve dano, Barreira, Exposto e Enfraquecido sobre `Combatente`; calcula o dano de Quebra-chassi; e retorna os dados do efeito, incluindo custo, dano, Barreira, Combo e estados aplicados.

`main.gd` usa essa fronteira para resolver as cartas e continua responsável pela carta visual, descarte, atualização da interface, Combo como recurso da personagem e ativação de Juntas de Retorno. Nenhuma regra, número, layout ou composição de baralho foi alterado nesta consolidação.

Teste RED→GREEN: `tests/test_resolucao_cartas.tscn` primeiro falhou porque `ResolucaoCartas` não existia. Depois confirmou Golpe, Direto Hidráulico, Brecha, Pulso Debilitante, Quebra-chassi e rejeição de alvo inválido sem criar nós visuais. A regressão final dos nove testes e a importação headless da Godot 4.7.2 terminaram com código 0.

Resultado da etapa: as cinco tarefas do plano de arquitetura foram executadas e verificadas. Isso não encerra a arquitetura completa do projeto: novas extrações só devem ser feitas quando uma responsabilidade concreta justificar a mudança.

## Ofertas de recompensa aleatórias — 23/09/2026

Criado `oferta_recompensa.gd` como objeto `RefCounted` com `opcoes: Array[String]`. A oferta copia e embaralha o pool atual de seis cartas, seleciona três identificadores distintos e não modifica o pool original.

`main.tscn` agora exibe três botões genéricos de recompensa e um botão `Pular`. `main.gd` preenche os três botões a cada vitória que oferece recompensa; escolher uma opção adiciona somente aquela carta ao `baralho_run`, enquanto pular inicia o combate seguinte sem alterar o baralho.

Teste RED→GREEN: `tests/test_oferta_recompensa.tscn` confirmou três opções distintas pertencentes ao pool e preservação do pool original. `tests/test_recompensa_pular.tscn` confirmou que o skip preserva o baralho e a Vida entre combates. A regressão completa dos onze testes e a importação headless da Godot 4.7.2 terminaram com código 0.

Validação manual no editor ainda pendente; o comportamento visual da oferta deve ser conferido pelo usuário.

## Organização inicial da apresentação do combate — 23/09/2026

Adicionados `IntencaoLabel`, `EstadosInimigoLabel`, `AcaoLabel` e `MaoStatusLabel` em `main.tscn`. O botão do inimigo continua sendo o alvo clicável, mas agora mostra somente Vida e Barreira; intenção e estados ficam separados.

`main.gd` registra ações válidas e bloqueadas, incluindo carta jogada, alvo inválido, `SEM ENERGIA`, encerramento de turno e ação executada pelo Drone. A Energia mostra `atual/máxima`, e a mão mostra `atual/limite` com `MÃO CHEIA` quando chega ao limite.

Teste RED→GREEN: `tests/test_apresentacao_combate.tscn` primeiro falhou pela ausência dos quatro elementos visuais. Depois confirmou intenção, estados, última ação, aviso de Energia e limite da mão. A regressão dos doze testes e a importação headless da Godot 4.7.2 terminaram com código 0.

Validação visual final no editor ainda deve ser feita pelo usuário. Próxima frente aprovada: expandir inimigos em geral e incluir um chefe.

## Ajuste de layout da tela — 23/09/2026

Relato do usuário: o screenshot da tela mostrou que o conteúdo do `PilhasLabel` ficava visualmente próximo demais do botão `VEGA`, enquanto os indicadores do jogador começavam desalinhados em relação ao botão.

Alteração feita em `main.tscn`: o bloco de pilhas foi ampliado para acomodar suas duas linhas; o botão `Jogador` foi movido para baixo e recebeu uma área própria; Energia, Barreira, Combo, Relíquia e Vida foram alinhados em uma coluna. Nenhuma regra de combate, carta, intenção, recompensa ou run foi alterada.

Verificação executada com Godot 4.7.2: o teste de apresentação primeiro falhou nas quatro verificações de layout e passou após a alteração. A regressão completa dos 12 testes em `tests/*.tscn` terminou com código 0, assim como a importação do projeto no editor headless.

Validação visual no editor ainda deve ser feita pelo usuário. Próxima frente aprovada: expandir os inimigos usando a fronteira genérica e preparar um chefe.

## Orquestração de jogador e encontro — 24/09/2026

Criados `jogador_combate.gd` e `encontro_combate.gd`. O primeiro concentra Vida/Barreira do jogador, Energia, Combo e ativação por turno de Juntas de Retorno. O segundo concentra inimigo ativo, baralho temporário, turno, condição de encerramento e resolução da fase inimiga.

`main.gd` passou a delegar esses estados e continua responsável por sinais, cartas visuais, atualização da interface, recompensas e fluxo da run. As propriedades legadas permanecem temporariamente como pontes para os testes e serão removidas quando não houver consumidores.

Teste RED→GREEN: `tests/test_jogador_combate.tscn` confirmou persistência limitada da Vida, Energia, Combo máximo, encerramento de turno e ativação única de Juntas. `tests/test_encontro_combate.tscn` confirmou cópia do baralho, reinício do inimigo, condição de encerramento, aplicação da Rajada e interrupção após golpe letal.

Verificação executada com Godot 4.7.2: os 14 testes headless e a importação do editor terminaram com código 0. A validação manual da cena principal permanece necessária.

Próximo passo: especificar o catálogo de três inimigos e a escolha do encontro antes de criar elite, chefe e mapa.

## Catálogo e sorteio de inimigos comuns — 24/09/2026

Criados `dados_inimigos.gd` e `seletor_inimigos.gd`. O catálogo contém Drone de Segurança (30 de Vida), Estivador Cibernético (36), Torreta de Contenção (24) e Guarda Portuário (32). Seus ciclos usam somente ataque, defesa e preparação; as intenções são determinísticas e não mudam depois de anunciadas.

`inimigo_combate.gd` passou a interpretar qualquer ciclo válido do catálogo. `main.gd` sorteia um inimigo ainda não enfrentado antes de iniciar cada combate, registra somente configurações válidas e apresenta nome, Vida, Barreira, intenção e estados a partir do inimigo ativo. Na run atual de dois combates, o segundo inimigo é sempre diferente do primeiro.

As seis cartas atuais foram exercitadas contra os quatro inimigos por `tests/test_cartas_multiplos_inimigos.tscn`. A regressão completa executou 17 cenas de teste com Godot 4.7.2 em modo headless, sem mensagens de erro, e a importação do editor headless também terminou limpa.

Validação manual pendente: executar `main.tscn` mais de uma vez e conferir visualmente os quatro nomes, os ciclos anunciados e executados e a ausência de repetição dentro de cada run. O próximo sistema a implementar depois dessa conferência é o encontro de elite.

## Validação manual do catálogo comum — 24/09/2026

Relato do usuário: os quatro inimigos comuns foram enfrentados no editor. A variedade dos padrões tornou os combates mais dinâmicos. O próximo recorte aprovado para definição é o encontro de elite.

## Elite e recompensas da terceira batalha — 24/09/2026

Implementada a Unidade de Contenção Portuária como elite fixo do terceiro combate. Ela possui 44 de Vida e o ciclo dirigido por dados `Pressurizar → Rajada de contenção → Blindagem pesada → Golpe de pistão`. A Rajada usa danos-base `5 × 2` e, depois de Pressurizar, anuncia e executa `7 × 2`; a Blindagem concede 8 e o Golpe de pistão causa 8.

A run passou de dois para três combates. Os dois primeiros continuam usando o seletor de inimigos comuns sem repetição; o terceiro instancia o elite diretamente e não registra seu identificador no histórico de comuns.

Criado `dados_reliquias.gd` com Juntas de Retorno, Reservatório Auxiliar e Mecanismo de Recuo. `JogadorCombate` agora mantém `reliquias_run`, rejeita duplicatas, aplica Reservatório no início do turno e Mecanismo após uma Finalização, preservando o comportamento da relíquia inicial.

O catálogo de cartas passou a ter nove cartas, com três raras: Golpe de Aríete, Ruptura de Pressão e Placa Reforçada. A recompensa do elite sorteia duas relíquias distintas e três cartas raras distintas. A jogadora escolhe uma relíquia e, em seguida, uma carta rara; não há skip nessa tela e a run só conclui após as duas escolhas.

Arquivos principais alterados: `main.gd`, `main.tscn`, `dados_inimigos.gd`, `dados_cartas.gd`, `dados_reliquias.gd`, `jogador_combate.gd` e os testes de catálogo, resolução, ciclo e apresentação. A nova área de recompensa fica oculta durante o combate e separa visualmente as duas etapas.

Verificação automatizada executada com Godot 4.7.2: 19 cenas em `tests/*.tscn` terminaram com código 0, incluindo a run completa, o catálogo do elite, o catálogo de relíquias, as cartas raras e a interface da recompensa. A importação do projeto em modo editor headless também terminou com código 0.

Validação visual ainda pendente: executar `main.tscn` no editor, vencer os dois combates comuns, conferir as intenções do elite, escolher as duas recompensas e verificar a exibição das relíquias equipadas. Os valores permanecem provisórios; balanceamento não foi realizado.

Próximo passo: validar manualmente este fluxo e, depois, desenhar os encontros não-combate das Docas com base na narrativa aprovada.

## Ritmo intercalado de combates e eventos — 24/09/2026

Direção aprovada pelo usuário: a run expandida terá cinco combates antes do chefe, contando o elite, e quatro eventos intercalados na sequência `combate comum → evento → combate comum → evento → elite → evento → combate comum → evento → combate comum`.

O catálogo inicial terá dez encontros possíveis: quatro combates comuns, o elite atual e cinco eventos narrativos. O catálogo fornece variedade; um roteiro separado define as posições da run. O chefe será uma etapa especial final e não participará do sorteio comum.

Naquele registro, a implementação ainda não havia iniciado. O plano técnico foi criado depois e o estado vigente está resumido no snapshot do topo deste arquivo.

## Correção da troca entre recompensas do elite — 24/09/2026

Relato do usuário acompanhado de screenshot: após escolher a relíquia, o título e os botões de relíquia continuavam visíveis junto das cartas raras. O título de cartas raras também podia aparecer na primeira etapa, fazendo os menus parecerem sobrepostos e invadirem visualmente a mão.

Correção feita: `main.gd` agora controla separadamente o título e o container de cada etapa. A primeira etapa mostra somente relíquias; a segunda esconde completamente relíquias e mostra somente cartas raras; ao concluir, todo o painel é ocultado. `main.tscn` também inicia o título de cartas raras oculto.

Teste RED→GREEN: `tests/test_ciclo_run.tscn` primeiro falhou nos estados de visibilidade esperados e passou após a correção. A regressão dos 19 testes e a importação headless do editor terminaram com código 0.

Pendente: executar novamente a run no editor e confirmar visualmente as duas etapas sem sobreposição.
