# Primeira cena — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. O método já escolhido é acompanhamento do usuário: ele opera o editor, o assistente explica e revisa. Não executar a atividade inteira silenciosamente.

**Goal:** Criar e executar uma cena com um botão que representa Golpe, compreendendo nós, propriedades e cenas.

**Architecture:** Uma cena Main com raiz Control e um filho Button chamado CardButton. A atividade usa propriedades do editor e o comportamento visual nativo do botão; não contém scripts ou lógica de combate.

**Tech Stack:** Godot 4 padrão, PC; instruções para Windows. GDScript tipado será usado nas próximas atividades.

**Spec:** ../../GAME_DESIGN.md, seções de controles, tipos de carta e método de trabalho.

## Global Constraints

- PC como foco integral da primeira versão.
- Tipos de carta definidos pelo usuário: Ataque, Habilidade e Aprimoramento.
- O usuário quer aprender como o jogo é construído e compreender o código que será mantido.
- Não há código ou cena já implementados neste pacote.
- Não instalar plugins nem ferramentas de teste para esta atividade de interface.
- Registrar a versão efetivamente usada; a página de Windows consultada em 23/09/2026 oferecia a edição padrão 4.7.2.

## Review Focus

1. Pasta de projeto errada ou aninhada: identificar a raiz pelo arquivo project.godot.
2. Diferenças de versão/idioma: registrar a versão e buscar os nomes de propriedades sem inventar menus.
3. Botão pequeno ou invisível: definir tamanho mínimo e verificar a cena em execução.
4. Confundir executar cena e executar projeto: testar F6 e configurar a cena principal ao usar F5.
5. Mudanças não salvas: reabrir a cena e confirmar persistência.

## Task 1: Uma carta visual executável

**Files:**
- Criar pelo editor: project.godot e os arquivos auxiliares que a Godot gerar.
- Criar pelo editor: scenes/main.tscn.
- Atualizar após verificar: docs/STATUS.md.
- Preservar: README.md, AGENTS.md, .gitignore, docs/GAME_DESIGN.md e docs/DECISIONS.md.

**Interfaces:**
- Consumes: editor Godot aberto e diretório vazio escolhido pelo usuário.
- Produces: cena res://scenes/main.tscn com raiz Main (Control) e filho CardButton (Button).
- Não há funções GDScript nesta atividade.

### Preparar o ambiente

- [ ] Acessar https://godotengine.org/download/windows/ e baixar a edição padrão x86_64 para um PC Windows de 64 bits; a edição .NET é destinada a C#.
- [ ] Extrair o ZIP e abrir o executável da Godot. Ele não exige instalador.
- [ ] Registrar a versão mostrada. Se o computador não for Windows ou x86_64, usar o download correspondente antes de seguir.
- [ ] Clicar em Create/New Project no gerenciador. Nome: Rogue Cyberpunk.
- [ ] Selecionar uma pasta vazia, por exemplo C:\Dev\rogue-cyberpunk. Se a opção Create Folder estiver ativa, conferir o caminho final para não criar uma pasta duplicada.
- [ ] Escolher Compatibility e criar o projeto. A integração Git dentro do editor não é necessária.
- [ ] Com o projeto já criado, copiar os arquivos deste pacote para a pasta que contém project.godot. Não usar Import no ZIP: este pacote contém orientação, não um projeto Godot pronto.
- [ ] Conferir a raiz no painel FileSystem: project.godot pertence à pasta escolhida. No editor, res:// significa essa raiz.

### Montar a cena

- [ ] Na cena vazia, escolher User Interface. O nó raiz será Control. Renomear para Main.
- [ ] Selecionar Main, adicionar um nó filho do tipo Button e renomeá-lo para CardButton.
- [ ] Selecionar CardButton e editar a propriedade Text para GOLPE.
- [ ] No Inspector, localizar Custom Minimum Size (custom_minimum_size). Definir x = 180 e y = 240. O nome pode aparecer traduzido; use o filtro de propriedades se necessário.
- [ ] Manter o botão na posição inicial visível, no canto superior esquerdo. Centralização e composição visual serão estudadas depois.
- [ ] Salvar com Ctrl+S. Criar a pasta scenes no diálogo de salvamento e usar main.tscn.

### Verificar manualmente

- [ ] Pressionar F6 para executar a cena atual. Observar o botão GOLPE.
- [ ] Passar o mouse e clicar. Esperar somente a resposta visual nativa do botão; nenhum dano ou mensagem de console foi programado.
- [ ] Se ocorrer um erro, copiar a mensagem exata. Não mudar renderer, versão e árvore de nós simultaneamente tentando adivinhar a causa.
- [ ] Fechar a execução com F8. Pressionar F5 e, se solicitado, escolher scenes/main.tscn como cena principal. Confirmar que o projeto abre a mesma cena.
- [ ] Alterar o texto para GOLPE TESTE, salvar e executar novamente. Explicar por que uma propriedade do nó mudou o resultado visível. Depois restaurar GOLPE.
- [ ] Fechar e reabrir a cena salva. Confirmar texto, nome dos nós e tamanho mínimo.
- [ ] Enviar screenshot da árvore de nós e da cena executando, junto da versão. Atualizar STATUS somente com resultados observados.

### Registrar um ponto de retorno

- [ ] No terminal dentro da pasta que contém project.godot, verificar Git:
```powershell
git --version
```
Se Git não estiver disponível, registrar isso como pendência. O teste da cena continua válido; não declarar o commit concluído.

- [ ] Se Git estiver disponível, inicializar e conferir os arquivos:
```powershell
git init
git status --short
```

- [ ] Confirmar que .gitignore exclui .godot/. Depois preparar e revisar o que será registrado:
```powershell
git add .
git diff --cached --stat
```

- [ ] Com apenas os arquivos do projeto e de acompanhamento presentes, criar o commit:
```powershell
git commit -m "chore: cria primeira cena de aprendizado"
```
Se Git pedir identidade de autor, usar seu nome e email escolhidos; não inventar dados. Nenhum push ou publicação é necessário nesta atividade.

## Conclusão da atividade

O usuário deve conseguir apontar a raiz, o nó filho, a propriedade Text e o arquivo da cena, além de explicar a diferença entre F6 e F5. Uma cena executável não comprova regras de combate: essas regras ainda não foram implementadas.

## Fontes verificadas

- Download: https://godotengine.org/download/windows/
- Gerenciador: https://docs.godotengine.org/en/stable/tutorials/editor/project_manager.html
- Nós e cenas: https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html
- Propriedades de interface: https://docs.godotengine.org/en/stable/classes/class_control.html
