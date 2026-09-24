# Especificação: elite e recompensas da terceira batalha

Data: 24/09/2026  
Status: aprovado pelo usuário  
Escopo: terceiro combate da run, elite das Docas e recompensa dupla

## Contexto

O protótipo já possui quatro inimigos comuns dirigidos por dados, seleção sem repetição, cartas compartilhadas, estados básicos, relíquia inicial e recompensas comuns. A run atual termina depois de dois combates e `main.gd` ainda coordena a maior parte da transição visual e da run.

A próxima etapa deve aumentar a tensão sem criar um sistema paralelo. O elite precisa usar o mesmo `Combatente`, `InimigoCombate`, `EncontroCombate`, `ResolucaoCartas` e catálogo de intenções já validados. A dificuldade será apresentada por intenções claras e por uma sequência de ações, não por aleatoriedade escondida.

## Objetivos

- aumentar a run para três combates;
- manter os dois primeiros combates como encontros comuns sem repetição;
- criar um elite fixo para o terceiro combate;
- validar o mesmo sistema de cartas, estados e Energia contra o elite;
- conceder obrigatoriamente uma relíquia e uma carta rara após a vitória;
- manter a responsabilidade de regras fora de `main.gd` sempre que houver uma fronteira já existente ou necessária;
- preparar o fluxo para, depois, receber eventos, mapa e chefe.

## Decisões aprovadas

1. O elite será o terceiro combate da run, depois de dois combates comuns.
2. O elite será uma máquina ligada à infraestrutura das Docas, não um segundo inimigo nem o chefe final.
3. O elite usará somente ataque, defesa e preparação de bônus por golpe, que já existem em `InimigoCombate`.
4. As intenções serão determinísticas e o dano anunciado continuará incluindo os bônus preparados e Enfraquecido.
5. Os valores abaixo são provisórios para testar leitura, ritmo e dificuldade. Eles não são balanceamento final.
6. A vitória contra o elite abrirá duas escolhas obrigatórias, nesta ordem: uma relíquia entre duas opções e uma carta rara entre três opções.
7. A recompensa do elite não terá botão de pular. A run só será concluída depois das duas escolhas.
8. As recompensas comuns e o botão de pular entre os combates comuns permanecem como estão.

## Elite aprovado

### Unidade de Contenção Portuária

A Unidade de Contenção é uma máquina corporativa instalada para manter o vapor contaminado pressurizado e impedir o acesso ao centro de controle de infraestrutura. Ela representa a fiscalização automatizada que Vega precisa atravessar para chegar ao ponto de manutenção das Docas.

| Identificador | Nome | Vida | Identidade |
| --- | --- | ---: | --- |
| `unidade_contencao_portuaria` | Unidade de Contenção Portuária | 44 | Máquina resistente, alterna preparação, pressão e defesa |

### Ciclo de intenções

| Ordem | Intenção | Tipo | Efeito anunciado |
| ---: | --- | --- | --- |
| 1 | Pressurizar | preparação | `Preparar: +2 por golpe` |
| 2 | Rajada de contenção | ataque | `Atacar: 7 × 2` depois da preparação |
| 3 | Blindagem pesada | defesa | `Defender: 8` |
| 4 | Golpe de pistão | ataque | `Atacar: 8` |

O ciclo retorna à primeira intenção depois do Golpe de pistão. A intenção inicial do terceiro combate é Pressurizar. A Rajada de contenção tem danos-base `[5, 5]`; o valor anunciado passa a `[7, 7]` depois do bônus preparado. O bônus é consumido depois do ataque completo, como nos inimigos comuns.

O elite não terá cura, roubo de cartas, descarte forçado, múltiplos alvos, estados novos ou aleatoriedade durante a execução. O jogador terá uma janela anunciada de preparação antes da Rajada e poderá antecipar a Blindagem e o Golpe de pistão.

## Recompensa do elite

### Sequência

1. Ao vencer o terceiro combate, bloquear ações de combate e mostrar a tela de relíquias.
2. Sortear duas relíquias distintas que ainda não estejam na run.
3. A jogadora escolherá exatamente uma relíquia.
4. Esconder a oferta de relíquias e mostrar a tela de cartas raras.
5. Sortear três cartas raras distintas.
6. A jogadora escolherá exatamente uma carta rara.
7. Adicionar os dois identificadores escolhidos à run e mostrar `RUN CONCLUÍDA`.

A relíquia inicial `Juntas de Retorno` não poderá aparecer novamente como duplicata. O baralho permanente recebe somente a carta rara escolhida; a relíquia será registrada separadamente em `reliquias_run`.

### Catálogo inicial de cartas raras

Estas cartas usam efeitos que o resolvedor atual já suporta. O campo `raridade` distingue o pool sem criar uma regra de resolução paralela.

| Identificador | Nome | Tipo | Custo | Efeito provisório |
| --- | --- | --- | ---: | --- |
| `golpe_ariete` | Golpe de Aríete | ataque | 2 | Causa 12 de dano |
| `ruptura_pressao` | Ruptura de Pressão | ataque | 1 | Causa 4 de dano e aplica 2 de Exposto |
| `placa_reforcada` | Placa Reforçada | habilidade | 1 | Concede 8 de Barreira |

As três cartas serão apresentadas como raras. Ataques não-finalização continuam concedendo Combo segundo a regra de Vega; a carta de habilidade não concede Combo. Nenhuma delas será adicionada automaticamente ao baralho inicial.

### Catálogo inicial de relíquias

| Identificador | Nome | Regra provisória |
| --- | --- | --- |
| `reservatorio_auxiliar` | Reservatório Auxiliar | No início de cada turno de Vega, concede 2 de Barreira. |
| `mecanismo_recuo` | Mecanismo de Recuo | Uma vez por turno, depois de uma Finalização consumir pelo menos 1 Combo, concede 2 de Barreira. |

As relíquias serão dados identificáveis, não textos soltos em `main.gd`. `JogadorCombate` deverá receber as relíquias da run e expor os gatilhos necessários para o controlador aplicar seus efeitos sem depender da árvore da cena.

## Responsabilidades

### `dados_inimigos.gd`

- adicionar a configuração da Unidade de Contenção Portuária;
- preservar a validação dos quatro inimigos comuns;
- permitir distinguir, por identificador ou categoria, o elite dos inimigos comuns.

### `InimigoCombate`

- receber e executar a configuração do elite pela mesma interface dos comuns;
- preservar ciclo, preparação, Barreira, Exposto e Enfraquecido;
- não conter regras especiais hardcoded para a Unidade de Contenção.

### `dados_cartas.gd`

- adicionar `raridade: "rara"` às três novas cartas;
- manter `raridade: "comum"` ou equivalente explícito nas cartas atuais;
- oferecer consultas separadas para cartas comuns e raras;
- preservar a interface atual usada por `main.gd` e `ResolucaoCartas` durante a migração.

### Dados e estado de relíquias

Criar um catálogo próprio para as duas relíquias do elite. `JogadorCombate` deverá manter os identificadores de relíquias da run e controlar os estados temporários de ativação por turno ou por combate. Os métodos devem retornar efeitos ou mudanças de estado; não devem acessar `Label`, `Button` ou `main.tscn`.

### Oferta de recompensa

Reutilizar a ideia de oferta distinta para montar duas ofertas independentes: uma de relíquias e outra de cartas raras. A oferta deve copiar o pool, embaralhar a cópia e não modificar o catálogo original. Uma oferta inválida não deve concluir a run nem adicionar conteúdo parcial.

### `main.gd`

Deverá apenas coordenar:

- a escolha de inimigos comuns nos combates 1 e 2;
- a criação do elite fixo no combate 3;
- a transição entre combate comum, recompensa comum e próximo combate;
- a apresentação e os cliques das duas etapas da recompensa do elite;
- a atualização da interface a partir dos dados e estados dos componentes.

Ele não deverá decidir o ciclo da Unidade de Contenção, calcular o dano do elite ou conter a regra interna das novas relíquias.

### `main.tscn`

- manter a tela de recompensa comum atual;
- adicionar uma área de recompensa de relíquias com dois botões;
- adicionar uma área de recompensa de cartas raras com três botões;
- manter as áreas de recompensa do elite ocultas durante o combate;
- não exigir arte final nesta etapa.

## Fluxo da run

1. Iniciar a run com o baralho e a relíquia inicial atuais.
2. Combate 1: sortear e registrar um inimigo comum.
3. Vitória: mostrar três cartas comuns ou o botão de pular.
4. Combate 2: sortear outro inimigo comum sem repetir o primeiro.
5. Vitória: mostrar a recompensa comum ou o botão de pular.
6. Combate 3: instanciar a Unidade de Contenção Portuária.
7. Vitória: exigir uma escolha de relíquia e depois uma escolha de carta rara.
8. Concluir a run somente depois das duas escolhas.

Vida atual e relíquias escolhidas persistem. Energia, mão, compra, descarte, Combo, Barreira, turno, Vida do inimigo e intenção são reiniciados a cada combate conforme as regras atuais.

## Testes e critérios de aceitação

Antes da implementação, criar testes que falhem para:

1. catálogo válido da Unidade de Contenção, com Vida 44 e quatro intenções;
2. anúncio `7 × 2` depois de Pressurizar e consumo do bônus após a Rajada;
3. aplicação da Blindagem pesada e do Golpe de pistão;
4. manutenção do ciclo completo após voltar à primeira intenção;
5. run com três combates, dois comuns sem repetição e elite fixo no terceiro;
6. vitória do elite abrindo primeiro duas relíquias e depois três cartas raras;
7. opções distintas e pertencentes aos respectivos pools;
8. escolha de relíquia persistindo em `reliquias_run`;
9. escolha de carta rara aumentando o baralho em uma cópia;
10. impossibilidade de concluir a run antes das duas escolhas;
11. aplicação de Reservatório Auxiliar e Mecanismo de Recuo nos respectivos gatilhos;
12. regressão dos testes existentes e importação headless com Godot 4.7.2.

A validação manual deverá confirmar que o elite é difícil, mas legível e possível, e que a tela deixa claro que os dois prêmios foram recebidos.

## Fora de escopo

- balanceamento final do elite ou das cartas;
- chefe;
- mapa das Docas;
- eventos narrativos;
- múltiplos inimigos no mesmo encontro;
- arte final, animações e efeitos sonoros;
- sistema de salvamento;
- remoção completa das pontes legadas de `main.gd`.

Depois desta etapa, a próxima frente será desenhar e implementar os encontros não-combate das Docas antes de preparar o chefe e o mapa completo.
