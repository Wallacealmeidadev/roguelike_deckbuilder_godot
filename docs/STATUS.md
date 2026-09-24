# Estado do projeto

Direcao atual: a elite sera o terceiro combate e concedera uma reliquia e uma carta rara. A run expandida intercalara cinco combates e quatro eventos antes do chefe. As Docas serao tratadas como distrito misto de trabalho portuario, infraestrutura industrial e moradia.

Atualização: 24/09/2026 — elite, cartas raras, relíquias e run de três combates implementados; fluxo visual das duas recompensas corrigido após validação do usuário; validação visual final pendente; balanceamento adiado.

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
- `res://seletor_inimigos.gd` sorteia um inimigo ainda não enfrentado nos dois combates comuns; o terceiro combate usa o elite fixo e não entra no histórico comum.
- `res://inimigo_combate.gd` interpreta os ciclos dirigidos por dados, e a interface mostra dinamicamente nome, Vida, Barreira, intenção e estados do inimigo ativo.
- Run de três combates implementada: dois combates comuns com recompensa ou skip, elite fixo no terceiro combate e recompensa dupla obrigatória.
- Primeiro componente genérico criado em `res://combatente.gd`: Vida atual e máxima, Barreira, Exposto, Enfraquecido, cálculo de dano por golpe, recebimento de golpes e reinicialização.
- `res://jogador_combate.gd` concentra o estado do jogador, Energia, Combo e ativação por turno de Juntas de Retorno.
- `res://encontro_combate.gd` concentra inimigo ativo, baralho temporário, turno, condição de encerramento e execução da fase inimiga.
- Oferta comum sorteia três cartas distintas entre as seis cartas comuns disponíveis; a jogadora pode adicionar uma ao baralho ou pular. A oferta do elite sorteia duas relíquias e três cartas raras em etapas separadas, sem skip.
- A recompensa do elite alterna visualmente entre uma única etapa de relíquias e uma única etapa de cartas raras; os controles da etapa anterior são escondidos antes da próxima aparecer.
- Apresentação do combate reorganizada: intenção e estados do inimigo têm áreas próprias, a última ação fica visível, Energia mostra o limite e `SEM ENERGIA`, e a mão mostra seu limite e `MÃO CHEIA`.
- Layout da tela refinado: o bloco de pilhas tem espaço para as duas linhas, `VEGA` fica separado abaixo dele e os indicadores de Energia, Barreira, Combo, Relíquia e Vida ficam alinhados em uma coluna legível.

## Atividade atual

Core vertical v0.1 encerrado. A consolidação técnica inclui `Combatente`, `JogadorCombate`, `EncontroCombate`, `BaralhoCombate`, `InimigoCombate` e `ResolucaoCartas`. O catálogo de quatro inimigos comuns, o elite, as cartas raras e as relíquias foram implementados. `main.gd` delega estado do jogador, recursos temporários, inimigo ativo, baralho do combate, turno e fase inimiga; continua responsável por sinais da cena, cartas visuais, interface, recompensas e fluxo da run. A verificação automatizada da run de três combates passou. Após o relato visual do usuário, o fluxo da recompensa do elite foi corrigido para não manter os menus das duas etapas visíveis ao mesmo tempo; falta a confirmação visual final no editor.

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
- Validação visual do elite, da recompensa dupla e dos efeitos das novas relíquias ainda não foi relatada pelo usuário.
- Relato do usuário: após vencer o elite, a tela mostrava simultaneamente títulos/opções de relíquia e carta rara; o problema foi reproduzido no teste de ciclo e corrigido separando a visibilidade das duas etapas.
- Teste de regressão após a correção: 19 cenas em `tests/*.tscn` e a importação do editor headless terminaram com código 0.

## Próximo passo vigente

Validar visualmente o elite e a recompensa dupla no editor. Depois: desenhar e implementar os encontros não-combate das Docas antes de preparar o primeiro chefe e o mapa.

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

Implementação ainda não iniciada. O próximo passo é criar o plano técnico do catálogo, seletor, roteiro e painel de eventos, mantendo os eventos separados das regras de combate.

## Correção da troca entre recompensas do elite — 24/09/2026

Relato do usuário acompanhado de screenshot: após escolher a relíquia, o título e os botões de relíquia continuavam visíveis junto das cartas raras. O título de cartas raras também podia aparecer na primeira etapa, fazendo os menus parecerem sobrepostos e invadirem visualmente a mão.

Correção feita: `main.gd` agora controla separadamente o título e o container de cada etapa. A primeira etapa mostra somente relíquias; a segunda esconde completamente relíquias e mostra somente cartas raras; ao concluir, todo o painel é ocultado. `main.tscn` também inicia o título de cartas raras oculto.

Teste RED→GREEN: `tests/test_ciclo_run.tscn` primeiro falhou nos estados de visibilidade esperados e passou após a correção. A regressão dos 19 testes e a importação headless do editor terminaram com código 0.

Pendente: executar novamente a run no editor e confirmar visualmente as duas etapas sem sobreposição.
