# Plano de implementacao: fluxo inicial de Vega

**Objetivo:** abrir no menu, selecionar Vega explicitamente e so entao iniciar a run existente, sem alterar as regras do mapa ou combate.

**Stack:** Godot 4.7.2, GDScript tipado, cenas `.tscn`, tema nativo `.tres`.

**Especificacao:** `docs/superpowers/specs/2026-10-19-fluxo-inicial-vega-design.md`.

## Cuidados antes de editar

- Preservar as alteracoes preexistentes do worktree, especialmente `main.gd`, `main.tscn`, arte e documentos.
- Fazer RED -> GREEN em cada bloco, executando as cenas de teste na Godot 4.7.2 registrada.
- Nao modificar `main.tscn` nem os sistemas de gameplay: o controlador novo instancia a cena existente.
- Usar apenas a arte estatica aprovada de Vega e o cenario de Docas. `assets/ui/references/raw/` e referencia, nao asset de runtime.

## Tarefa 1 — menu e linguagem visual

**Arquivos:** `ui_entrada/menu_principal.gd`, `ui_entrada/menu_principal.tscn`, `ui_entrada/moldura_neon.gd`, `ui_entrada/botao_neon.gd`, `ui_entrada/tema_entrada.tres`, `tests/test_menu_principal.gd`, `tests/test_menu_principal.tscn`.

1. Criar teste que instancia o menu e verifica foco inicial, texto e sinais dos botoes; executar para observar falha.
2. Criar moldura responsiva e tema de botoes com estados normal, hover, pressed, focus e disabled.
3. Construir menu com containers, cenario de Docas e acoes `NOVA RUN`/`SAIR`; executar teste ate passar.

## Tarefa 2 — selecao de Vega

**Arquivos:** `ui_entrada/selecao_personagem.gd`, `ui_entrada/selecao_personagem.tscn`, `tests/test_selecao_personagem.gd`, `tests/test_selecao_personagem.tscn`.

1. Criar teste para Vega selecionada por padrao, arte proporcional, texto de Combo/Finalizacao, sinais de confirmar e voltar; executar RED.
2. Construir ficha de Vega sem opcoes ficticias; manter botoes e texto dentro da viewport em 1024x576; executar GREEN.

## Tarefa 3 — controlador e configuracao

**Arquivos:** `jogo.gd`, `jogo.tscn`, `project.godot`, `tests/test_jogo_fluxo.gd`, `tests/test_jogo_fluxo.tscn`.

1. Criar teste que cobre MENU -> SELECAO -> RUN, voltar, id invalido e ausencia de duplicacao; executar RED.
2. Criar controlador de estado e transicao curta; mudar apenas `run/main_scene` no projeto.
3. Executar teste focado e confirmar que a run mostra o mapa existente sem alteracao de gameplay.

## Tarefa 4 — verificacao e registro

**Arquivos:** `tests/capturar_fluxo_inicial.gd`, `docs/STATUS.md`, `docs/DECISIONS.md`.

1. Testar teclado/foco e limites de layout em 1024x576 e 1920x1080; ajustar problemas observados.
2. Executar a suite completa `tests/test_*.tscn`, a importacao headless e a cena principal na Godot 4.7.2.
3. Capturar menu e selecao nas duas resolucoes, inspecionar as imagens e registrar resultados concretos, pendencias e proximo passo pequeno em `STATUS.md`; registrar a direcao visual e o fluxo em `DECISIONS.md`.

## Revisao final

- O menu e a selecao sao operaveis por mouse e teclado.
- Confirmar Vega instancia uma run, e a run abre no mapa.
- Um id invalido ou clique repetido nao cria run extra.
- Nenhum asset `raw` com quadriculado aparece no runtime.
- A suite existente nao regride; visual fica sujeito a aprovacao do usuario.
