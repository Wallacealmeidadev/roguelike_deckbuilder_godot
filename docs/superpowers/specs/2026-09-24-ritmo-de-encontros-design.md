# Especificação: ritmo intercalado de combates e eventos

Data: 24/09/2026  
Status: aprovado em conversa; implementação ainda não iniciada  
Escopo: catálogo de encontros das Docas e ritmo da run antes do chefe

## Contexto

O protótipo atual tem três combates: dois encontros comuns sem repetição e uma Unidade de Contenção Portuária como elite no terceiro combate. Depois do elite, a jogadora escolhe uma relíquia e uma carta rara.

A próxima expansão não deve colocar vários combates seguidos e depois concentrar todos os eventos em um bloco de pouco controle. Combates e eventos devem alternar para manter decisões e ação distribuídas pela run.

## Decisões aprovadas

1. O projeto terá um catálogo de dez encontros possíveis, misturando combates, elite e eventos narrativos.
2. A run não exibirá automaticamente os dez encontros do catálogo. O catálogo é uma fonte de variedade; o roteiro da run define quais posições aparecem.
3. Antes do chefe, o ritmo será:

   `Combate comum → Evento → Combate comum → Evento → Elite → Evento → Combate comum → Evento → Combate comum`

4. Isso produz cinco combates antes do chefe, contando o elite, e quatro eventos intercalados.
5. O chefe será adicionado depois como uma etapa especial final. Ele não será sorteado entre os encontros comuns.
6. Um evento pode iniciar um combate especial como consequência de uma escolha. Esse combate não cria uma etapa extra do roteiro; ele resolve a consequência do evento e depois devolve o controle à run.
7. Eventos não concedem automaticamente a recompensa comum de carta. Cada evento define suas próprias consequências.

## Catálogo inicial

O catálogo inicial terá dez entradas:

### Combates e elite

- `drone_seguranca`: Drone de Segurança.
- `estivador_cibernetico`: Estivador Cibernético.
- `torreta_contencao`: Torreta de Contenção.
- `guarda_portuario`: Guarda Portuário.
- `unidade_contencao_portuaria`: elite atual, mantido como encontro especial do terceiro combate.

Essas entradas reutilizam `InimigoCombate`, `DadosInimigos`, `EncontroCombate` e o resolvedor de cartas já existentes.

### Eventos narrativos

- `valvula_vapor_contaminado`: desligar a válvula alerta uma máquina ou abominação e pode forçar um combate especial. A situação se conecta ao objetivo de atravessar a infraestrutura contaminada das Docas.
- `carga_abandonada`: uma carga claramente abandonada pode ser vasculhada e gerar recompensa sem retirar algo de uma pessoa identificável.
- `operario_ferido`: ajudar exige sacrificar 10 de Vida; recusar pode levar a uma consequência narrativa ruim.
- `ladrao_de_cartas`: a jogadora pode entregar uma carta ou enfrentar o ladrão. O evento pode remover uma carta do baralho como consequência real.
- `fiscalizacao_corporativa`: uma inspeção das operações portuárias oferece escolhas de cooperação, evasão ou confronto, com consequências diferentes.

Os valores exatos, recompensas e textos de cada evento continuam provisórios até a especificação de implementação. As ideias acima são a direção narrativa aprovada para o primeiro catálogo.

## Ritmo e seleção

O roteiro da run será separado do catálogo:

- o roteiro conhece a ordem das categorias (`combate`, `evento`, `elite`, `chefe`);
- um seletor escolhe o identificador dentro da categoria permitida;
- combates comuns continuam sem repetição dentro da run;
- eventos escolhidos para a run não devem se repetir, salvo uma decisão posterior que permita repetição;
- a Unidade de Contenção permanece fixa na posição de elite;
- o chefe fica bloqueado para a etapa final e não participa do sorteio comum.

O roteiro não deve depender de textos ou nomes exibidos na interface para decidir a próxima etapa. Cada posição deve ter um identificador e um tipo explícitos.

## Fluxo de um evento

1. O roteiro seleciona uma entrada de evento.
2. A interface mostra título, contexto e opções disponíveis.
3. A jogadora escolhe uma opção.
4. A resolução aplica uma consequência explícita: recurso, Vida, carta, recompensa, combate especial ou encerramento do evento.
5. Se houver combate especial, o estado do evento fica registrado para que a run retorne ao próximo ponto depois da vitória ou derrota.
6. O roteiro avança para a próxima etapa somente depois que a consequência terminou.

Um evento não deve alterar silenciosamente o baralho ou a Vida. A interface deve anunciar a consequência antes ou no momento em que ela for aplicada.

## Fronteiras técnicas

### `dados_encontros.gd`

Catálogo dos dez encontros, com pelo menos:

- identificador;
- nome exibido;
- tipo (`combate`, `evento` ou `elite`);
- descrição curta;
- referência ao inimigo, quando for combate;
- referência ao resolvedor de evento, quando for evento.

### Seletor e roteiro da run

Um componente de seleção deve controlar identificadores já usados. Outro componente deve controlar a sequência de categorias da run. A separação evita que um catálogo de conteúdo também seja responsável por decidir o ritmo.

O roteiro deve expor a etapa atual, o identificador escolhido e a próxima transição. `main.gd` apenas apresenta a etapa, encaminha cliques e pede o avanço ao componente.

### Resolução de eventos

As consequências narrativas devem ficar fora dos `Label` e `Button`. O componente de resolução deve receber a escolha e devolver um resultado estruturado, por exemplo:

- texto de resultado;
- Vida perdida ou recuperada;
- cartas adicionadas ou removidas;
- recompensa obtida;
- identificador de combate especial, se houver;
- sinal de que o evento terminou.

O primeiro incremento pode implementar poucos eventos completos, mas a fronteira deve permitir adicionar os dez sem transformar `main.gd` em um catálogo de regras.

### `main.gd`

Continua como orquestrador da cena. Deve:

- iniciar a etapa informada pelo roteiro;
- mostrar o painel de combate ou evento;
- enviar a escolha ao resolvedor apropriado;
- aplicar a transição retornada;
- preservar Vida, baralho e relíquias da run.

Não deve decidir por texto qual evento está ativo nem conter todos os efeitos narrativos em uma cadeia de `if` baseada em identificadores.

## Interface inicial

A primeira interface de eventos pode reutilizar a cena principal com um painel oculto durante combates:

- título do evento;
- texto de contexto;
- dois ou três botões de escolha;
- texto de consequência;
- botão para continuar quando a consequência terminar.

O painel de evento deve ficar oculto durante combate, recompensa comum, recompensa do elite e resultado final. O painel de combate deve ficar oculto durante a escolha do evento para não sugerir que a jogadora ainda pode usar cartas.

## Testes de aceitação

Antes da implementação, criar testes que falhem para:

1. catálogo com dez identificadores válidos e tipos reconhecidos;
2. roteiro alternando quatro eventos e cinco combates antes do chefe;
3. elite permanecendo na terceira posição de combate;
4. seleção de combates comuns sem repetição;
5. seleção de eventos sem repetição;
6. evento não concedendo recompensa comum automaticamente;
7. escolha de evento devolvendo uma consequência estruturada;
8. evento podendo solicitar combate especial e retornar ao roteiro depois dele;
9. Vida, baralho e relíquias persistindo entre etapas;
10. chefe não sendo sorteado antes da etapa final.

A validação manual deverá confirmar que a run não passa por um bloco longo de combates nem por um bloco longo de eventos, e que cada escolha informa sua consequência.

## Fora de escopo

- implementação do chefe;
- mapa visual das Docas;
- caminhos ramificados no mapa;
- arte final, animações e áudio;
- balanceamento definitivo das consequências;
- todos os dez eventos completos no primeiro incremento;
- sistema de salvamento.

Depois desta especificação, o próximo documento será um plano de implementação incremental, começando pelo catálogo e pelo roteiro antes de integrar os eventos narrativos à interface.
