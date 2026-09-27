# Descanso e aprimoramento — especificação de apresentação e fluxo

## Objetivo

Adicionar ao mapa uma tela de descanso jogável, com recuperação de Vida ou aprimoramento de uma cópia de carta, preservando o fluxo existente, o baralho e as telas já estabilizadas.

## Estado observado

- `mapa_run.gd` já cria nós do tipo `descanso`.
- `main.gd::_ao_selecionar_no_mapa()` atualmente mostra somente uma mensagem provisória para descanso.
- Não existe fórmula, seleção, comparação ou mutação de aprimoramento implementada.
- `baralho_run` é `Array[String]`; `BaralhoCombate` copia esses identificadores para a compra.
- As cartas compartilham dados em `dados_cartas.gd` e usam `carta.tscn`/`botao_carta.gd`.

## Regras adotadas

- Recuperar aplica `+8` de Vida, limitado à Vida máxima.
- Vida cheia torna Recuperar indisponível e explica o motivo sem criar outra permissão.
- Toda cópia cujo identificador ainda não tenha sido aprimorado é elegível.
- Uma cópia só pode ser aprimorada uma vez.
- O aprimoramento provisório aumenta em `+3` o primeiro efeito numérico principal: `valor` quando presente; caso contrário, `barreira`. Efeitos secundários permanecem iguais. Essa regra é experimental e não representa balanceamento final.
- Selecionar carta abre comparação e não altera o baralho.
- Voltar retorna à seleção sem consumir a ação.
- Confirmar substitui somente a cópia escolhida e encerra o descanso.
- Um descanso aceita no máximo uma ação; cliques repetidos não curam, aprimoram ou avançam duas vezes.
- Continuar retorna ao mapa no mesmo nó atual.

## Composição

O overlay usa o fundo HQ existente e componentes do kit:

- Cabeçalho `RESPIRO`, Vida atual/máxima e quantidade de cartas derivados do estado real.
- Dois painéis grandes em `HBoxContainer`: `RECUPERAR` e `APRIMORAR`.
- Cada painel usa moldura HQ, símbolo separado, título Bangers e informação essencial em Barlow.
- A recuperação mostra o valor efetivo possível, ou a indisponibilidade quando a Vida já está cheia.
- O aprimoramento mostra a quantidade de cartas elegíveis, ou a indisponibilidade quando não há nenhuma.
- Resultado e `Continuar` permanecem no mesmo overlay; os painéis deixam de aceitar interação após a ação.

## Seleção e comparação

- A seleção usa instâncias de `carta.tscn` em um container centralizado com rolagem quando necessário.
- Cada entrada conserva o índice da cópia no `baralho_run` e apresenta um identificador de cópia para distinguir cartas iguais.
- A prévia usa a mesma arte, tipografia, tooltip e estados corrigidos das cartas de recompensa.
- A comparação mostra carta atual à esquerda, seta no centro e carta aprimorada à direita.
- `VOLTAR` retorna à seleção; `CONFIRMAR` só fica ativo com uma prévia válida.
- A comparação deriva ambos os lados dos dados reais e não escreve no baralho durante a prévia.

## Representação da cópia aprimorada

Para preservar a interface pública existente (`baralho_run: Array[String]`) e evitar reescrever o combate, o identificador persistido usa um sufixo interno (`id#aprimorado`). Helpers centralizados resolvem o identificador-base e os dados efetivos. `BaralhoCombate` continua transportando strings; a mão e a resolução usam os dados efetivos derivados do token.

## Integração

- O descanso será aberto somente ao selecionar um nó de descanso no mapa.
- `_avancar_roteiro()` e o retorno ao mapa não serão usados para conceder novamente a ação.
- A tela de combate, recompensas comum/elite, eventos e Brecha não terão mudança de regra.
- O estado transitório do descanso será limpo ao iniciar combate, abrir evento, reiniciar ou voltar ao mapa.

## Verificação

Testes devem cobrir: cura parcial e Vida cheia; ausência de elegíveis; cópias iguais e índice preservado; comparação sem mutação; voltar; confirmação única; persistência no combate seguinte; foco de teclado; e layout nas resoluções 1024×576, 1280×720 e 1920×1080. Capturas reais devem incluir tela inicial, seleção, comparação e resultado.
