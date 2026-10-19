# Especificacao: fluxo inicial com menu e selecao de Vega

## Objetivo

Criar a porta de entrada do vertical slice: iniciar a aplicacao em um menu principal, seguir para uma selecao explicita de Vega e somente entao instanciar a run existente. O incremento deve estabelecer a nova linguagem visual neon indicada por `assets/ui/references/` sem reescrever o combate, o mapa ou o estado da run.

O resultado observavel e este fluxo:

`Menu principal -> Selecao de Vega -> Mapa da run existente`

O jogador tambem podera voltar da selecao ao menu e sair da aplicacao pelo menu. A run continuara usando as regras e o conteudo atuais.

## Estado observado

- O projeto usa Godot `4.7.2.stable.official.ed1daf0bf`, renderer `GL Compatibility` e foco atual em PC.
- `project.godot` abre `main.tscn` diretamente.
- `main.gd::_ready()` inicia uma nova run e abre o mapa sem uma etapa anterior de menu ou selecao.
- `main.tscn` e `main.gd` concentram a apresentacao da run, mas os modelos de combate, baralho, mapa e estado ja existem separados.
- A segunda passagem da suite de base terminou com `62/62` cenas retornando codigo 0; as 12 cenas de producao e preview carregaram individualmente.
- A Vega estatica de corpo inteiro e a apresentacao aprovada no runtime. O rig segmentado continua isolado e sem aprovacao visual para integracao.
- `assets/ui/references/` contem um conceito de HUD em `1280x720` e seis imagens `raw`.
- Todos os sete PNGs novos sao opacos. Nos arquivos `raw`, o quadriculado esta incorporado aos pixels e nao representa canal alfa.

## Regra de design

A imagem na raiz de `assets/ui/references/` e a referencia visual mais recente. Os arquivos em `raw/` orientam geometria, proporcao, acabamento e distribuicao de informacao; eles nao serao tratados como componentes prontos.

Este incremento reconstruira a linguagem visual com recursos nativos da Godot:

- fundos azul-marinho quase pretos;
- contornos escuros fortes;
- acentos ciano e magenta;
- paineis geometricos com cantos chanfrados;
- texto claro de alto contraste;
- estados interativos visiveis por cor, contorno e movimento curto.

Nenhum quadriculado sera exibido no jogo. Nenhuma limpeza automatica removera pixels claros dos PNGs. A extracao de elementos rasterizados fica condicionada a uma tarefa posterior com recorte e validacao visual proprios.

## Escopo deste incremento

### Incluido

- uma cena raiz leve para controlar o fluxo da aplicacao;
- menu principal com `NOVA RUN` e `SAIR`;
- tela de selecao com Vega como unica personagem disponivel;
- confirmacao explicita de Vega e retorno ao menu;
- instanciacao de `main.tscn` somente depois da confirmacao;
- foco inicial e navegacao por mouse e teclado;
- transicoes curtas entre menu, selecao e run;
- componentes visuais reutilizaveis suficientes para essas duas telas;
- testes funcionais, testes de layout e capturas deterministicas nas resolucoes alvo;
- atualizacao de `STATUS.md` e `DECISOES.md` com resultados reais.

### Fora do escopo

- implementar Lastro ou alterar o chefe provisorio;
- ampliar o catalogo de cartas, inimigos, efeitos ou reliquias;
- redesenhar todo o HUD de combate neste mesmo incremento;
- adicionar Luvto, Cais ou espacos bloqueados simulando personagens futuros;
- adicionar `Continuar`, salvamento, metaprogressao ou backend;
- duplicar as configuracoes internas da run no menu;
- integrar o rig segmentado da Vega;
- processar em lote os PNGs `raw`.

## Arquitetura

### Cena raiz da aplicacao

Uma nova `jogo.tscn`, controlada por `jogo.gd`, passara a ser a `run/main_scene` do projeto. Essa cena tera uma unica responsabilidade: coordenar qual tela de alto nivel esta ativa.

Estados permitidos:

1. `MENU`: mostra `menu_principal.tscn` e nao instancia gameplay.
2. `SELECAO`: mostra `selecao_personagem.tscn` e nao instancia gameplay.
3. `RUN`: remove as telas iniciais e instancia uma unica copia de `main.tscn`.

O controlador nao copiara Vida, deck, seed, reliquias ou qualquer outro dado de gameplay. Esses dados continuam pertencendo a `RunState`, `JogadorCombate` e aos sistemas existentes.

### Menu principal

`menu_principal.tscn` e `menu_principal.gd` cuidarao apenas da apresentacao e da intencao do jogador. A cena emitira:

- `nova_run_solicitada`;
- `sair_solicitado`.

O menu nao carregara `main.tscn` e nao criara estado de run. `NOVA RUN` recebera o foco inicial. `SAIR` emitira o pedido, e `jogo.gd` chamara `get_tree().quit()`.

### Selecao de personagem

`selecao_personagem.tscn` e `selecao_personagem.gd` exibirao uma unica ficha de Vega com nome, descricao curta, mecanica `Combo / Finalizacao` e a arte aprovada ja existente. A cena emitira:

- `personagem_confirmada(id_personagem: String)` com o valor `"vega"`;
- `voltar_solicitado`.

Vega aparecera selecionada por padrao, com estado visual explicito. O botao de confirmacao sera a acao principal. Nao havera fichas falsas ou botoes desabilitados para personagens ainda nao implementados.

### Entrada na run

Ao receber `"vega"`, `jogo.gd` fara estas operacoes uma unica vez:

1. bloquear novas transicoes;
2. encerrar a transicao visual da selecao;
3. ocultar ou liberar as telas iniciais;
4. instanciar `main.tscn` como filha da cena raiz;
5. transferir o foco para o primeiro controle valido criado pelo fluxo existente;
6. liberar o bloqueio depois que a nova cena estiver pronta.

`main.tscn` continuara iniciando a run de Vega por seu caminho atual. Nao sera criado um segundo metodo de inicializacao enquanto apenas Vega existir.

Como a cena corrente passara a ser `jogo.tscn`, o `reload_current_scene()` ja usado pelo resultado da run recarregara o fluxo inicial e retornara ao menu sem encerrar a aplicacao. Esse comportamento sera preservado neste incremento; uma API dedicada de reinicio so sera criada se um teste demonstrar necessidade real.

## Componentes visuais

Sera criado um componente de moldura neon responsiva para os paineis das duas telas. Ele desenhara a forma com `_draw()`, usando poligono escuro, contorno preto, linha ciano e pequenos acentos magenta. Ele nao tera estado de gameplay nem interceptara input.

Um recurso de tema compartilhado definira:

- fundo principal: `#070B18`;
- painel: `#0D1430`;
- ciano: `#19E5FF`;
- magenta: `#FF27C7`;
- violeta: `#8E45FF`;
- texto principal: `#F4F7FF`;
- texto secundario: `#9BA9C2`.

As fontes existentes serao reutilizadas:

- `Bangers-Regular.ttf` somente para o titulo do jogo;
- `BarlowSemiCondensed-Bold.ttf` para botoes, titulos de painel e numeros;
- `BarlowSemiCondensed-Regular.ttf` para descricoes.

O fundo usara a arte de Docas ja integrada, preservando proporcao com `STRETCH_KEEP_ASPECT_COVERED`, sob uma camada azul-marinho semitransparente. O conceito novo nao sera colocado como fundo da tela porque e uma prancha de componentes, nao um cenario.

Estados obrigatorios dos botoes:

- normal: painel escuro e contorno discreto;
- hover/foco: ciano mais claro e leve elevacao;
- pressionado: escala curta para `0.98` e acento magenta;
- desabilitado: contraste reduzido, quando aplicavel;
- selecionado: contorno ciano persistente e marcador magenta.

As transicoes usarao `Tween`, com duracao entre `0.16 s` e `0.24 s`, somente em opacidade e deslocamento curto. Nenhuma transicao atrasara a criacao da run por mais de `0.24 s`.

## Layout responsivo

O layout sera construido com anchors e Containers, sem coordenadas absolutas como fonte primaria de dimensionamento.

Em `1024x576`:

- todos os botoes permanecerao dentro da viewport;
- nenhum texto essencial sera truncado;
- alvos de interacao terao no minimo `44x44` pixels logicos;
- a ficha de Vega e os botoes de confirmacao/voltar nao se sobreporao.

Em `1920x1080`, os paineis crescerao ate limites maximos e permanecerao centralizados; a arte de Vega manterá a proporcao, sem estiramento horizontal ou vertical.

## Fluxo de dados e protecoes

- `jogo.gd` sera a unica unidade autorizada a trocar o estado de alto nivel.
- As cenas de menu e selecao comunicarao intencoes somente por sinais.
- Um bloqueio `em_transicao: bool` impedira duplo clique ou duas instancias simultaneas de `main.tscn`.
- Um identificador diferente de `"vega"` nao iniciara gameplay: a selecao permanecera visivel e sera emitido um aviso de diagnostico.
- Voltar durante a selecao retornara ao menu sem criar nem preservar uma run parcial.
- As telas iniciais nao armazenarao copias de Vida, Energia, Combo, cartas ou reliquias.

## Verificacao

O trabalho seguira RED -> GREEN com GDScript tipado.

Testes automatizados cobrirao:

1. `project.godot` aponta para `jogo.tscn`;
2. a aplicacao inicia em `MENU`, sem instancia de `main.tscn`;
3. `NOVA RUN` abre a selecao;
4. Vega aparece selecionada e a confirmacao emite `"vega"`;
5. confirmar cria exatamente uma instancia da run e abre o mapa existente;
6. confirmacoes repetidas nao duplicam a run;
7. `VOLTAR` retorna ao menu sem criar gameplay;
8. identificadores invalidos sao rejeitados;
9. menu e selecao permanecem dentro da viewport em `1024x576` e `1920x1080`;
10. foco inicial e vizinhanca de foco permitem operar o fluxo por teclado.

Depois dos testes focados:

- executar todas as cenas `tests/test_*.tscn`;
- executar importacao headless na Godot registrada;
- carregar a cena principal headless;
- gerar e inspecionar capturas reais do menu e da selecao em `1024x576` e `1920x1080`;
- executar manualmente `Menu -> Vega -> Mapa` no editor.

Capturas automatizadas comprovam composicao e dimensoes, mas nao substituem a avaliacao visual manual do usuario.

## Criterios de aceite

- O projeto abre no menu, nao no mapa.
- `NOVA RUN` leva a uma selecao funcional de Vega.
- A confirmacao de Vega inicia a run existente e mostra o mapa.
- `VOLTAR` e `SAIR` nao sao botoes decorativos.
- O fluxo funciona por mouse e teclado.
- Nao ha duplicacao de estado de gameplay na UI inicial.
- Nenhum PNG com quadriculado incorporado aparece no jogo.
- O visual usa a paleta e a geometria da nova referencia sem esticar imagens.
- O combate, as cartas e o mapa preservam o comportamento verificado na linha de base.
- Resultados de testes e limitacoes sao registrados em `STATUS.md`; a nova direcao visual e o controlador de fluxo sao registrados em `DECISOES.md`.

## Sequencia posterior

Depois deste incremento ser validado, o proximo subprojeto recomendado e substituir o chefe provisorio por Lastro e fechar a tela de conclusao da run. A propagacao completa do novo visual para o HUD de combate deve ser um subprojeto separado, guiado por capturas do fluxo inicial aprovado.
