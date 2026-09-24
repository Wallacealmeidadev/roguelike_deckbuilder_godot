# Especificação: orquestração de combate

Data: 23/09/2026  
Status: aprovado pelo usuário  
Escopo: primeira etapa da reorganização arquitetural antes da expansão de inimigos

## Contexto

O protótipo já possui componentes separados para estado comum de combatentes, compra e descarte, resolução de cartas, intenções do inimigo e ofertas de recompensa. Entretanto, `main.gd` ainda concentra estado de Vega, estado do inimigo, ciclo do combate, run, recompensas, entrada da interface e atualização visual.

Essa mistura não impede o protótipo de funcionar, mas torna cada novo inimigo mais arriscado de adicionar. A próxima expansão precisa permitir trocar o inimigo atual sem duplicar regras no script da cena.

## Objetivo

Fazer uma extração incremental de duas responsabilidades concretas:

- `JogadorCombate`: estado e recursos temporários da personagem durante um combate.
- `EncontroCombate`: composição e ciclo do combate atual, incluindo o inimigo ativo, o baralho temporário e o turno.

Depois dessa etapa, `main.gd` continuará sendo o controlador da cena, mas deixará de ser a fonte principal desses estados. Ele deverá receber comandos da interface, encaminhá-los aos componentes e projetar os resultados nos nós visuais.

## Não objetivos

Esta etapa não irá:

- criar os três novos inimigos;
- criar elite, chefe ou mapa;
- alterar Vida, Energia, Combo, cartas, intenções, recompensas ou valores de teste;
- transformar imediatamente cada inimigo em uma subclasse própria;
- remover toda propriedade legada de `main.gd` em uma única mudança;
- introduzir sinais, autoloads ou um gerenciador global de estado.

## Responsabilidades propostas

### `Combatente`

Continua responsável somente por Vida, Barreira, Exposto, Enfraquecido e cálculo/recebimento de golpes.

### `JogadorCombate`

Será um `RefCounted` que contém um `Combatente` e os recursos específicos do lado do jogador:

- Energia atual e limite por turno;
- Combo atual e limite;
- estado de ativação por turno de Juntas de Retorno;
- reinicialização do combate preservando a Vida atual entre encontros;
- início e encerramento do turno;
- ganho de Combo e verificação da ativação de Juntas de Retorno.

Ele não conhecerá `Button`, `Label`, `main.tscn`, cartas visuais ou recompensas.

Interface mínima prevista:

```gdscript
class_name JogadorCombate
extends RefCounted

var estado: Combatente
var energia: int
var energia_maxima: int
var combo: int
var combo_maximo: int
var juntas_retorno_ativada_no_turno: bool

func iniciar_combate(vida_preservada: int) -> void
func iniciar_turno() -> void
func encerrar_turno() -> void
func ganhar_combo(barreira_reliquia: int, limiar_reliquia: int) -> bool
```

`ganhar_combo()` atualiza o Combo, respeita o máximo e retorna se Juntas de Retorno foi ativada. A quantidade de Barreira e o limiar permanecem parâmetros explícitos; o componente não depende de um catálogo global de relíquias.

### `InimigoCombate`

Continua responsável pelo comportamento do inimigo ativo: estado comum, intenção anunciada, preparação de bônus e execução da ação. Nesta etapa, ele ainda representa o Drone atual; a generalização de seus dados será uma etapa posterior.

### `BaralhoCombate`

Continua responsável exclusivamente pelas pilhas temporárias do combate. O baralho permanente da run permanece fora dele.

### `EncontroCombate`

Será um `RefCounted` que compõe o combate atual:

- referência ao `InimigoCombate` ativo;
- referência ao `BaralhoCombate` temporário;
- turno atual;
- preparação do encontro a partir do baralho permanente;
- encerramento e avanço do turno;
- consulta de vitória/derrota com base no jogador e no inimigo.

Ele não conhecerá nós da cena, recompensas ou textos de interface.

Interface mínima prevista:

```gdscript
class_name EncontroCombate
extends RefCounted

var inimigo: InimigoCombate
var baralho: BaralhoCombate
var turno: int

func iniciar(inimigo_novo: InimigoCombate, baralho_run: Array[String]) -> void
func combate_terminou(jogador: JogadorCombate) -> bool
func executar_fase_inimiga(jogador: JogadorCombate) -> Dictionary
func avancar_turno() -> void
```

`EncontroCombate.iniciar()` não recebe Vida do jogador: a preservação da Vida pertence a `JogadorCombate.iniciar_combate()`. `executar_fase_inimiga()` pode aplicar os golpes no estado do jogador e retornar a ação executada, sem conhecer Labels, Buttons ou callbacks da cena.

As assinaturas podem ser ajustadas durante a implementação se os testes mostrarem uma fronteira mais simples. O requisito é que os componentes não dependam da árvore de nós nem de callbacks específicos da tela para manter seu estado.

## Papel de `main.gd` após a extração

`main.gd` permanecerá responsável por:

- obter nós com `@onready` e conectar sinais;
- interpretar cliques em carta, alvo, fim de turno e recompensa;
- pedir a `ResolucaoCartas` que resolva uma carta;
- pedir ao encontro que avance suas fases;
- descartar a representação visual das cartas;
- atualizar Labels e Buttons a partir dos componentes;
- controlar o fluxo de run e a transição para recompensas.

`main.gd` deixará de ser responsável por armazenar diretamente a regra interna de Energia, Combo, reinicialização do jogador, turno e composição do encontro. Durante a migração, propriedades de compatibilidade poderão delegar aos novos componentes para preservar os testes existentes; elas serão removidas quando não houver mais consumidores.

## Fluxo preservado

O fluxo atual deverá permanecer observacionalmente equivalente:

1. iniciar combate preserva a Vida do jogador e reinicia estados temporários;
2. preparar o baralho temporário e comprar seis cartas;
3. iniciar turno com Energia 4 e Barreira do jogador zerada;
4. jogar cartas pela mesma `ResolucaoCartas`;
5. encerrar o turno, descartar a mão e executar a intenção anunciada do Drone;
6. avançar o turno ou mostrar derrota;
7. vencer, oferecer recompensa ou concluir a run como antes.

Nenhuma seleção de inimigo será exposta na interface nesta etapa. O componente receberá o inimigo atual por parâmetro para preparar a próxima etapa sem antecipar conteúdo.

## Testes e critérios de aceitação

Antes da extração, adicionar testes que falhem sem os componentes:

- `JogadorCombate` inicia com Energia 4, Combo 0 e mantém a Vida preservada ao reiniciar o combate;
- iniciar turno zera Barreira, restaura Energia e reinicia a ativação por turno da relíquia;
- encerrar turno zera Energia e Combo;
- ganhar Combo respeita o máximo e informa o limiar necessário para Juntas de Retorno;
- `EncontroCombate` prepara uma cópia do baralho permanente, reinicia o inimigo e começa no turno 1;
- o encontro identifica vitória e derrota sem depender de `main.tscn`;
- executar a fase inimiga aplica cada golpe ao jogador, interrompe ao chegar a Vida zero e retorna a ação executada;
- executar a cena principal continua produzindo a mesma interface e o mesmo ciclo de run.

Depois da integração, devem passar:

- os testes atuais dos 12 arquivos em `tests/*.tscn`;
- novos testes de `JogadorCombate` e `EncontroCombate`;
- importação headless do projeto com Godot 4.7.2.

A validação manual continuará necessária para confirmar a apresentação no editor.

## Próxima etapa após esta especificação

Com a extração aprovada e verde, será criada uma especificação separada para o catálogo de inimigos e a escolha do encontro. Ela deverá definir os três inimigos, suas Vidas e intenções antes da implementação. Elite, chefe e mapa permanecerão etapas posteriores, nessa ordem.
