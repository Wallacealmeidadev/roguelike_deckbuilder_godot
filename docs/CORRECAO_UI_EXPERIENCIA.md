# Correção da UI — composição, interação e validação

## Objetivo e prioridade

Transformar a integração existente em uma experiência jogável de HQ cyberpunk. Manter as regras e sistemas atuais. Este documento corrige a orientação anterior de aplicar o kit a todas as telas em sequência: a primeira entrega agora é uma tela de recompensa bem resolvida, apoiada por componentes de botão, carta e tooltip confiáveis.

Ler as instruções do repositório e inspecionar o código real antes de editar. Os caminhos abaixo são do kit entregue; adaptar ao destino real caso tenha sido movido. Não usar documentos antigos para desfazer decisões recentes do jogo.

## Evidências e limites da análise

Esta revisão usou nove capturas do jogo, o tema, os estilos e os atlas do kit original. Não houve acesso às cenas ou scripts atuais do projeto. Problemas de execução específicos precisam ser reproduzidos localmente. Capturas não comprovam comportamento, animações ou a causa exata de recortes.

| Evidência | Problema observado | Objetivo da correção |
| --- | --- | --- |
| `image(20260926-014023).png` | Combate tem cartas ilustradas, mas acumula faixas, painéis e três mensagens sobre o turno. | Preservar cartas e melhorar hierarquia; evitar repetir a mesma informação. |
| `image(20260926-014038).png` | Recompensa mostra botões “Adicionar…” no lugar das cartas. | Permitir comparar visualmente custo e efeito antes de escolher. |
| `image(20260926-014046).png` | Texto fora do fundo claro, moldura interna reduzida e duas apresentações do mesmo detalhe. | Corrigir estados do componente e manter um único tooltip. |
| `image(20260926-014115).png` | Evento tem título sobre a borda, controles pequenos e grande painel vazio. | Compor o encontro em quadro visual, narrativa e escolhas. |
| `image(20260926-014200).png` | Ação “Continuar” aparece parcialmente encoberta/recortada. | Garantir que a ação principal permaneça inteira e acessível. |
| `image(20260926-014225).png` | Recompensa de relíquia repete o defeito de foco; tooltip claro tem texto quase branco. | Reutilizar componentes corrigidos e garantir contraste por variante. |
| `image(20260926-014236).png` | Cartas raras também são botões textuais com detalhes duplicados. | Usar a mesma apresentação de carta da recompensa comum. |
| `image(20260926-014340).png` | Conclusão tem ação parcialmente cortada e pouco tratamento de hierarquia. | Organizar resultado e navegação em área segura. |
| `image(20260926-014348).png` | Mapa é uma lista de caixas sem linhas de conexão visíveis; botão inferior cortado; “Variante: 0” exposta. | Representar caminhos com nós e conexões; retirar informação interna de depuração da apresentação normal. |

Não atribuir todos os defeitos ao código novo. O kit original também precisa de correções técnicas.

## 1. Corrigir a base antes de redesenhar telas

### Foco e estados de botão

No `ui_hq_v1/tema_base.tres` original, `Button/styles/hover` e `Button/styles/focus` usam `estilos/botao_foco.tres`. Esse estilo aponta para uma imagem que contém o botão completo: fundo branco, moldura e cantos cianos.

Na Godot, o estilo `focus` é desenhado sobre o estilo base. Um botão completo nesse slot pode encobrir o estado pressionado e criar molduras duplicadas. Verificar se o projeto ainda usa essa configuração.

Correção desejada:

- Fundo e moldura pertencem ao estado normal/hover/pressionado/desabilitado.
- Foco de teclado é uma camada transparente com contorno ou cantos. Nunca um segundo botão inteiro.
- Pode usar `componentes/hud/foco_cantos.tres` se o recorte e o tamanho se ajustarem, ou desenhar cantos simples com geometria nativa. Preservar centro transparente e espessura constante.
- Definir também o estado combinado `hover_pressed` e sua cor de texto. Não depender de fallback que produza outra identidade visual.
- Manter a posição do texto, área clicável e dimensões entre estados.
- Não eliminar o foco de teclado para esconder o problema.

### Margens e escala

No estilo de foco original, as margens de textura são 64 px nas laterais e 54 px em cima/baixo, enquanto as margens de conteúdo são 24/16 px. Há descompasso entre a área interna da arte e a área reservada ao texto. Isso é um risco confirmado do recurso; medir o efeito nos tamanhos reais do projeto.

Inspecionar regiões do atlas, nine-slice, margens internas, tamanho mínimo e escala efetiva. A tinta de cada moldura deve ficar fora da área de texto. Testar nomes longos como “CONTORNAR A TUBULAÇÃO”. Não resolver diminuindo toda a tipografia nem cortando rótulos essenciais.

Se uma textura não se adaptar ao tamanho necessário, usar outra composição com o mesmo vocabulário visual. A finalidade do kit é apoiar a tela; não é obrigatório aplicar a mesma imagem a todos os retângulos.

### Tooltips e camadas

- Uma fonte de tooltip por componente. Conferir se `tooltip_text` nativo está ativo junto de um balão customizado.
- Texto escuro em fundo claro; texto claro em fundo escuro. Labels customizados não podem herdar automaticamente a cor branca do tema geral.
- Quebra de linha, margem interna e tamanho ajustados ao conteúdo.
- Posicionar próximo ao elemento, dentro da área visível; inverter o lado quando necessário.
- Fechar ao mudar de tela, remover a carta ou perder o foco correspondente.
- Tooltips decorativos não interceptam a ação da carta.

Para o recorte de “Continuar”, “Abrir mapa” e “Voltar”, investigar separadamente: `clip_contents` dos ancestrais, retângulos dos Controls, mínimos dos Containers e painéis sobrepostos. A captura não permite escolher uma causa sem inspeção.

## 2. Primeira entrega: recompensa comum

Referência principal: `ui_hq_v1/referencias/telas/03_recompensa.png`. Abrir a imagem e compará-la com a tela em execução. A intenção dessa composição é tornar as três cartas protagonistas. Não copiar os números demonstrativos ou tentar reproduzir lettering inexistente nas fontes entregues.

### Experiência esperada

Ao vencer, o jogador reconhece a vitória, compara três cartas e decide qual entra no baralho. Custo e efeito principal estão na própria carta. Foco explica palavras-chave e mostra informação complementar. Pular e consultar o baralho são ações secundárias, sempre encontráveis.

### Composição

- Título curto “Vitória” e instrução “Escolha uma carta” no alto.
- Três cartas ilustradas no centro, com tamanho e alinhamento consistentes.
- Mesmo componente visual usado no combate, com modo de recompensa. Os dados, o custo e a descrição vêm do catálogo real.
- Uma área secundária para consultar o baralho e outra para pular. Não colocar as cartas dentro de um painel gigante só para ocupar a tela.
- Acento ciano identifica a opção em foco. As demais continuam legíveis.
- Detalhe de palavra-chave aparece em um único balão. A regra básica da carta não depende do balão.

Referência de proporção para 1920×1080: margem externa de aproximadamente 64 px; cabeçalho de 120–160 px; grupo de cartas centralizado, com cartas de cerca de 320–360 px de largura, preservando a proporção da moldura; intervalos de 40–56 px; ações secundárias na faixa inferior. São medidas iniciais para orientar a composição, não offsets absolutos a aplicar cegamente. Ajustar ao viewport real e conferir também em 1280×720.

Não herdar a escala pequena da mão para a recompensa. A carta precisa de modos de apresentação, preservando o mesmo conteúdo e linguagem visual. Usar Bangers em títulos curtos e Barlow Semi Condensed nas regras. Não reduzir uma descrição até ficar ilegível para manter uma medida sugerida.

### Interação

- Entrada: transição curta, sem confirmação intermediária de vitória.
- Hover/foco: elevação leve da apresentação da carta, em torno de 8–12 px por 120–160 ms, sem deslocar as vizinhas nem mudar a área de clique.
- Mouse, Tab/setas conforme navegação existente e Enter devem acessar a mesma informação e escolha.
- Escolha: chamar a resolução já existente uma única vez, dar retorno visual e seguir o fluxo atual. Bloquear acionamento repetido durante a transição.
- Pular: nenhuma carta adicionada; progressão ocorre uma única vez.
- Consultar baralho: abrir e fechar mantendo a oferta intacta, sem jogar cartas ou expor ordem oculta de compra.
- Respeitar opção de movimento reduzido, se já existir; não criar um novo sistema de configurações apenas para esta entrega.

### Aceite obrigatório

1. A oferta aparece como três cartas completas, não como três botões “Adicionar nome”.
2. Custo e efeito são legíveis sem tooltip.
3. Nenhum texto ou botão está cortado; nenhuma moldura atravessa texto.
4. Foco não produz um segundo fundo, altera contraste ou desloca o layout.
5. Apenas um tooltip é exibido; cabe na tela e lê-se com clareza.
6. Escolher, pular e consultar o baralho preservam as regras existentes.
7. O estado de menor resolução e o estado com texto mais longo continuam utilizáveis.
8. Comparação visual com a referência confirma hierarquia, escala das cartas e prioridade das ações.

## 3. Como verificar esta entrega

Criar uma forma de reprodução de desenvolvimento, fora do fluxo normal, para chegar à recompensa com oferta conhecida e dados reais. Evitar jogar a run inteira a cada ajuste. Não alterar o balanceamento de produção para gerar a cena.

Capturar a tela inicial, carta em foco com tooltip, seleção confirmada e resolução menor. Testar componentes compartilhados também no combate e em uma opção de evento para verificar regressões do tema.

Compilar sem erros ou carregar `.tres` não comprova qualidade visual. É necessário abrir e inspecionar as capturas. Se o ambiente não permite renderizar, declarar que a verificação visual está pendente e informar os poucos passos exatos que o usuário precisa executar. Não registrar “UI concluída” com base apenas em testes headless de carregamento.

Automatizar verificações que protegem comportamento: recompensa não duplicada e dados preservados ao inspecionar o baralho. Revisar composição visualmente. Não ampliar testes sem uma falha concreta a investigar.

## 4. Próximas telas, após estabilizar a primeira entrega

Este é o roteiro seguinte, não uma autorização para marcar todas as telas como concluídas no mesmo lote.

| Tela | Pergunta do jogador | Composição e resposta visual |
| --- | --- | --- |
| Combate | O que posso jogar e o que o inimigo fará? | Mão, energia e intenção com prioridade; vida sob cada combatente; estados em ícones ao lado da barreira. Uma indicação de turno suficiente. |
| Elite | Qual relíquia e qual carta ajudam meu baralho? | Peças visuais de relíquia e cartas completas; preservar etapas e quantidades reais de escolha. |
| Evento | O que aconteceu e o que posso fazer? | Quadro do encontro, narrativa curta em coluna legível e escolhas com consequência conhecida. Sem um painel vazio ocupando quase a tela inteira. |
| Descanso | Preciso de vida ou de uma carta melhor? | Duas ações distintas; vida recuperável real; comparação antes/depois no aprimoramento. |
| Mapa | Onde estou e que caminho posso tomar? | Nós com ícones e conexões visíveis; rota percorrida e opções disponíveis distintas; nome/detalhe no foco. Tirar “Variante: 0” da UI normal. |
| Derrota | O que me matou e o que faço agora? | Último quadro da luta com golpe fatal, histórico recolhido e ações claras de reinício/menu/saída. Sem cena de personagem apenas triste. |
| Conclusão provisória | O que concluí e como continuo a testar? | Resultado honesto do trecho disponível e navegação inteira. Não inventar vitória sobre o chefe adiado. |
| Menu e pausa | Como começo ou retomo? | Ação principal reconhecível; secundárias agrupadas; foco consistente. Confirmar abandono quando houver run ativa. |

Usar as referências correspondentes do kit. Manter o estilo independente de distrito/personagem. Vega e inimigos permanecem quadrados nesta fase. Não criar arte nova para encobrir problemas de composição.

## 5. Entrega esperada do Codex

Implementar a correção da base e a recompensa comum; verificar regressões dos componentes compartilhados. Apresentar capturas e um resumo curto do que mudou. Separar explicitamente os fatos verificados das hipóteses e do que ficou pendente.

Se as capturas ainda falharem nos critérios de aceite, continuar corrigindo esta entrega. Não propagar um componente quebrado pelo restante do jogo. A revisão desta primeira tela orientará as demais, seguindo o processo combinado: ideia, estudo, primeira versão e melhoria.

Fontes técnicas consultadas para esta revisão:

- https://docs.godotengine.org/en/stable/classes/class_button.html — composição do foco sobre o estilo base e estados do botão.
- https://docs.godotengine.org/en/stable/classes/class_styleboxtexture.html — margens da textura e escalonamento em nove partes.

Este arquivo é uma especificação de correção, não uma atualização já aplicada ao kit ou ao repositório do jogo.
