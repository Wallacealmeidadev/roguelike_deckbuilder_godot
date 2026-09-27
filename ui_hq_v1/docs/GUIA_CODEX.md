# Aplicação do kit visual na Godot

## Objetivo

Aplicar a primeira UI do jogo preservando cartas, combate, mapa, eventos, recompensas, descansos e transições existentes. Primeiro leia o `AGENTS.md`, os scripts e a árvore atuais do repositório. Este documento é uma especificação de interface; não é autorização para reescrever sistemas que já funcionam.

O jogo usa uma linguagem de HQ cyberpunk contemporânea: tinta preta, bordas brancas, campos escuros, ciano de interação e cores semânticas. Não vincular a moldura às Docas, à Lastro ou à Vega. Esses nomes são conteúdo substituível.

## Arquivos e montagem

Copiar `ui_hq_v1` para `res://ui_hq_v1/`, mantendo sua estrutura. Se outro destino for necessário, atualizar explicitamente as referências `res://` dos recursos. Não mover apenas os `.tres`.

Aplicar `tema_base.tres` ao `Control` raiz da interface. Trata-se de uma base para botões primários, painéis, labels e barras; variações locais continuam necessárias. Em painéis claros, usar texto escuro. Botões secundários precisam de painel escuro e texto claro.

| Elemento | Recursos | Montagem sugerida |
| --- | --- | --- |
| Botão | `estilos/botao_*.tres` | `Button`, texto nativo, estado acionado pela interface |
| Ícone | `componentes/icones/*.tres` | `TextureRect`, manter proporção |
| Vida | `vida_moldura`, `vida_preenchimento` | `TextureProgressBar` ou barra nativa com preenchimento proporcional e label separado |
| Energia | `energia_caixa`, ícone `energia` | Painel, ícone e label atual/máximo separados |
| Estados | Ícones `barreira`, `exposto`, `enfraquecido`, `forca` | `HBoxContainer` ao lado da barreira; número separado; tooltip no foco |
| Combo | Ícone `combo` e label | Grupo separado por pequeno espaço dos estados comuns |
| Intenção | `faixa_turno` ou `painel_escuro`, ícone de ação | Nome, valor e quantidade vindos do inimigo real |
| Carta | Moldura + ilustração + labels | Componente compartilhado; custo, nome e regra continuam dinâmicos |
| Pilhas | `compra`, `descarte`, `mao` | Ícone e contador; inspeção conforme regras atuais |
| Mapa | `no_mapa` + ícone do tipo + `foco_cantos` | Nós clicáveis e conexões desenhadas a partir do modelo atual |
| Tooltip | `tooltip` ou painel claro | `RichTextLabel`/`Label` separado, largura limitada |
| Resultado | Título nativo, painéis e botões | Histórico e resumo recolhidos por padrão |

Os recursos AtlasTexture já contêm `region` e `filter_clip`. Eles usam partes dos PNGs compartilhados. Para cada peça, consulte `manifesto.json`.

Documentação da engine consultada:
- https://docs.godotengine.org/en/stable/classes/class_atlastexture.html
- https://docs.godotengine.org/en/stable/classes/class_styleboxtexture.html

## Fontes e cor

- Títulos curtos, nomes de cartas e botões: `Bangers-Regular.ttf`.
- Regras, descrições, números de histórico e textos de evento: `BarlowSemiCondensed-Regular.ttf`; negrito disponível em arquivo separado.
- Fundo `#101619`; painel `#1B252D`; branco `#F5F7FA`.
- Energia/foco `#00CEE6`; vida/ameaça `#FF4F4F`; barreira/defesa `#FFCA36`; elite `#DF3BAE`.
- Cor nunca é o único indicador: manter símbolo, valor, estado de foco ou texto acessível.

Os exemplos ilustrados podem mostrar a barreira em ciano; na implementação desta versão padronizar com o ícone âmbar entregue. O arquivo de arte é a referência concreta para esse elemento.

Na resolução de referência 1920×1080, usar texto de regra por volta de 24–28 px e títulos de carta por volta de 28–34 px. Conferir a legibilidade também na resolução real do projeto. Não reduzir a mão inteira até tornar as regras ilegíveis: utilizar foco, elevação da carta e organização adequada ao limite real de mão.

## Carta em camadas

1. Ilustração com recorte proporcional na janela.
2. Moldura por cima. A janela central da moldura tem transparência real.
3. Custo, título e regras como controles de texto.
4. Foco como estado visual, sem consumir a carta ou alterar seus dados.

Para a moldura de ataque, regiões aproximadas dentro do tamanho exibido: título em 22–94% da largura e 4–15% da altura; arte em 7–94% da largura e 16–72% da altura; regra em 9–91% da largura e 75–94% da altura. Ajustar com base na cena de carta atual, sem distorcer a arte.

Não esticar cantos de foco de maneira desproporcional. Preferir nove fatias ou quatro cantos de tamanho constante quando o painel mudar muito de formato. O tema base é um ponto de partida; conferir o tamanho mínimo do botão antes de aplicar a todos os controles.

## Fluxos e descoberta

### Menu

`Nova run`, `Configurações`, `Sair do jogo`. Não adicionar `Continuar` sem um sistema real de salvamento. `Rogue Cyberpunk` é o título de trabalho usado no estudo, não um novo nome definitivo aprovado.

### Combate

- Vega e Drone permanecem `ColorRect`/quadrados provisórios; usar um slot substituível para arte futura.
- Vida abaixo do respectivo combatente; intenção próxima ao inimigo.
- Barreira e demais estados ficam juntos, em ícones com contadores.
- Custo e efeito essencial da carta são legíveis. Hover/foco explica palavras-chave e demais detalhes.
- O botão de fim do turno usa as condições atuais. Nenhuma derrota por falta de cartas.
- Toda informação vem do estado real. Os números desenhados nas referências são exemplos.

### Recompensa e baralho

- A vitória normal vai diretamente à escolha de recompensa, sem criar uma nova confirmação intermediária.
- Preservar escolher uma carta ou pular, conforme a regra já implementada.
- Detalhes adicionais aparecem no foco; baralho abre uma consulta própria.
- A consulta não revela automaticamente a ordem de compra e não permite jogar cartas.
- No elite, adaptar as abas e os slots às escolhas que o código já oferece; não mudar quantidade de recompensas ou exclusividade por causa da referência gráfica.

### Evento e descanso

- Usar os textos e consequências do catálogo atual. As frases desta arte são exemplos.
- Mostrar efeitos essenciais antes de uma escolha irrevogável quando as regras existentes os revelam. Descoberta não significa esconder custos conhecidos.
- No descanso, curar ou aprimorar. O botão continuar respeita a resolução atual; não permitir repetir uma ação.
- A comparação do aprimoramento deve ler os dados atuais. O `6 → 9` da referência é ilustrativo.

### Mapa

- Preservar o modelo implementado. O exemplo reproduz o primeiro combate, elite no terceiro ponto, caminhos que se reencontram e ponto final reservado ao chefe.
- Só os destinos conectados e disponíveis são interativos. Não liberar saltos por estilizar o nó.
- O tema aceita qualquer distrito; `Docas` é apenas o título do conteúdo do exemplo.

### Derrota e conclusão

- Derrota somente quando a Vida se esgota.
- Acesso visível a jogar novamente, voltar ao menu e sair.
- Destaque inicial para o golpe fatal; histórico e resumo abrem sob demanda.
- A rajada usa o ícone de projéteis, não o punho da Vega.
- Exemplo de histórico: 6 de Vida → 3 após o primeiro golpe; 3 → 0 após o segundo; último golpe em vermelho e com texto `FATAL`.
- Conclusão da run não inventa final narrativo. Preservar as condições existentes.
- Caso voltar ao menu ou sair descarte uma run em andamento, avisar antes de confirmar. Não prometer salvamento inexistente.

## Ordem de integração

1. Tema, fontes e botões em uma cena de teste isolada do projeto.
2. Carta compartilhada, vida, energia, estados, intenção e pilhas.
3. Resultados, recompensa e inspeção do baralho.
4. Menu, pausa e configurações com as funções realmente disponíveis.
5. Mapa, eventos, descanso e aprimoramento.

Ao final, testar foco com teclado e mouse, seleção de cartas, alvos inválidos, consumo de energia, fim de turno, derrota, vitória, recompensa, retorno ao mapa e reinício. Conferir UI em 1280×720 e 1920×1080, sem mudar a resolução do jogo silenciosamente.

