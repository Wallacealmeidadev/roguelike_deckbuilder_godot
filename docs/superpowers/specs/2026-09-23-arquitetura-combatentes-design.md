# Arquitetura genérica de combate

Data: 23/09/2026

## Objetivo

Organizar progressivamente o `main.gd` para que o projeto possa receber novos personagens, inimigos, cartas, estados e encontros sem copiar regras específicas de Vega ou do Drone.

A mudança deve preservar o comportamento atual do protótipo: combate de dois encontros, seis opções de recompensa, cartas, Energia, Barreira, Combo, estados e ciclo determinístico de intenções.

## Estado observado

- `main.gd` tem aproximadamente 572 linhas e concentra interface, run, compra, descarte, cartas, dano, estados e intenções.
- `dados_cartas.gd` já separa os dados das cartas do código de resolução.
- O protótipo atual tem um jogador, um inimigo e uma cena principal, mas as regras comuns já aparecem misturadas com nomes de Drone e Vega.
- A Godot usada para verificação é 4.7.2, compatível com o projeto declarado como Godot 4.7 e `GL Compatibility`.
- A suíte atual possui testes de catálogo, estados, relíquia, intenções e ciclo de run.

## Princípios

1. Regras comuns usam papéis do combate, como `Combatente`, `Jogador` e `Inimigo`, nunca nomes de personagens.
2. O estado de uma entidade deve ter uma única fonte de verdade; adaptadores temporários podem preservar chamadas antigas durante a migração, mas não devem duplicar valores.
3. Modelos de regra não dependem de nós visuais da cena. A interface continua em `main.gd` até existir uma necessidade clara de outro controlador visual.
4. Cada extração deve manter a suíte existente verde e adicionar testes para a nova fronteira.
5. Vega, Luvto, Cais, Drone e outros inimigos fornecem configuração e mecânicas próprias; não são a classe base de uma regra comum.

## Componentes propostos

### `combatente.gd`

Modelo genérico de qualquer participante do combate, inicialmente como `RefCounted`.

Responsabilidades:

- Vida atual e Vida máxima;
- Barreira;
- Exposto e Enfraquecido;
- aplicação e consumo de cargas por golpe;
- cálculo do dano de um ataque realizado;
- recebimento de um golpe e desconto da Barreira;
- reinicialização do estado de combate.

Não conhece cartas, Energia, Combo, intenções, botões ou Labels.

### `jogador_combate.gd`

Camada de papel do jogador, criada quando a primeira extração de recursos for necessária.

Responsabilidades previstas:

- Energia do turno;
- referência ao `BaralhoCombate`;
- mão lógica e cartas selecionadas;
- recursos compartilhados do jogador.

Combo e Juntas de Retorno continuam sendo mecânicas de personagem durante a primeira migração. Não serão colocados em `Combatente` apenas para facilitar a extração.

### `inimigo_combate.gd`

Camada de papel do inimigo, criada junto da extração das intenções.

Responsabilidades previstas:

- intenção atual;
- execução do padrão de ações;
- valores anunciados;
- estado específico de preparação de um inimigo.

O código não deve se chamar `drone.gd`. O Drone será uma configuração ou padrão de inimigo aplicado a essa camada.

### `padrao_inimigo.gd`

Componente posterior para representar sequências como Rajada, Blindagem, Sobrecarga e Marca sem prender a lógica a um único inimigo.

Este arquivo não será criado no primeiro recorte se a extração de `InimigoCombate` ainda não exigir uma abstração própria.

### `baralho_combate.gd`

Modelo genérico das pilhas temporárias de um combate:

- preparar a pilha de compra a partir do baralho da run;
- comprar identificadores;
- descartar identificadores;
- reembaralhar o descarte quando necessário;
- informar os tamanhos das pilhas.

A criação e remoção dos botões visuais da mão permanece em `main.gd` inicialmente.

### `main.gd`

Depois das extrações, será o orquestrador da cena:

- conecta sinais da interface;
- inicia combate e run;
- pede ações aos componentes de regra;
- cria e remove representações visuais;
- atualiza Labels e botões;
- mostra recompensas e resultados.

Ele não deve continuar sendo a fonte primária de Vida, Barreira, estados, pilhas ou ciclo interno do inimigo.

## Ordem de migração

### Etapa 1 — `Combatente`

Extrair Vida, Barreira, Exposto, Enfraquecido e cálculo de golpes para `combatente.gd`. Migrar primeiro os caminhos de dano já testados, preservando adaptadores temporários para que os testes e a interface possam ser atualizados sem uma troca brusca.

Adicionar teste unitário para:

- Vida e Barreira;
- Exposto e Enfraquecido por golpe;
- dano mínimo zero;
- consumo contra Barreira;
- reinicialização entre combates.

### Etapa 2 — `BaralhoCombate`

Extrair compra, descarte e reembaralhamento. A mão visual continuará em `main.gd`; somente os identificadores e as pilhas sairão do controlador.

### Etapa 3 — `InimigoCombate`

Extrair o estado e o ciclo de intenções do inimigo. O primeiro teste continuará verificando o padrão atual, mas os nomes usados pela regra serão genéricos.

### Etapa 4 — resolução de cartas

Somente depois das três fronteiras anteriores estarem estáveis, extrair a resolução das cartas para um componente que receba fonte, alvo e dados da carta. Combo e Juntas serão mantidos como regras do jogador/personagem, não como efeitos universais de qualquer combatente.

## Compatibilidade e migração

- Não alterar valores de dano, custos, quantidade de cartas, ciclo de intenções ou regras de recompensa durante a organização.
- Usar propriedades de compatibilidade ou métodos delegadores somente quando necessário para migrar testes e interface gradualmente.
- Remover cada adaptador assim que nenhum consumidor depender dele.
- Não manter dois estados independentes para Vida, Barreira ou cargas. O adaptador deve encaminhar para o objeto genérico.

## Critérios de aceitação

- A suíte atual continua passando após cada etapa.
- A importação headless do projeto termina com código 0.
- O usuário consegue executar a mesma run e observar os mesmos valores.
- Um novo combatente pode ser criado sem copiar a lógica de Vida, Barreira, Exposto ou Enfraquecido.
- A primeira etapa não cria novos nós visuais nem muda o layout da cena.
- `STATUS.md` registra cada etapa com a distinção entre código implementado, teste automatizado e validação manual.

## Fora do escopo desta arquitetura inicial

- múltiplos inimigos em cena;
- mapa, eventos ou chefe;
- Resources para cada carta ou inimigo;
- sistema completo de modificadores e prioridades;
- multiplayer, backend ou persistência externa;
- refatoração visual da interface.
