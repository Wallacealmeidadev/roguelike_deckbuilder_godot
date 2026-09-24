# Decisões e pendências

Atualizado em 24/09/2026. Base: decisões consolidadas na revisão 0.4 e relato atual do usuário.

**Autoridade:** histórico das escolhas e questões abertas. A descrição vigente de cada assunto vive no arquivo correspondente; este registro explica mudanças e evita regressões.

## Alterações que substituem decisões anteriores

- Vulto passa a se chamar **Luvto**.
- A mãe de Luvto morre salvando-o na invasão. A versão de suicídio foi descartada.
- Luvto sobrevive ao composto e à reconstrução, mas não é imortal.
- Vega é humana com braços protéticos, não uma robô integral.
- Cais é humana sem implantes, ex-mecânica industrial, pequena e limpa.
- Os três não se conhecem e não formam um grupo.
- Um distrito completo e um personagem substituem três personagens como primeira entrega.
- Vega é a primeira personagem; docas são seu distrito inicial. Na expansão, cada personagem terá seu distrito inicial e poderá acessar os demais.
- Runs alternativas estão confirmadas, com pequenos upgrades ou conhecimento persistente; não há ressurreição literal confirmada.
- As antigas mecânicas Carga/Eco e a personagem Nula não devem ser reintroduzidas por memória de versões anteriores.
- O balanceamento permanece adiado durante a construção do jogo. Os valores atuais são provisórios para testar regras, leitura e identidade; ajustes futuros devem partir de observação, sem tratar o protótipo como produto final.
- O primeiro inimigo é um drone de segurança das Docas. Seu ciclo de teste implementado é `Rajada → Blindagem → Rajada → Sobrecarga → Rajada → Marcar alvo → Rajada → repetir`; a implementação foi incremental, começando por Rajada e Blindagem.
- Rajada causa dois golpes de 3. Blindagem concede 6 de Barreira. Sobrecarga dará +2 por golpe ao próximo ataque completo e Marca dará +1 por golpe ao próximo ataque completo. Esses valores estão aprovados para teste, não como balanceamento final.
- Para este protótipo, o ciclo determinístico substitui a proposta inicial de sortear Blindagem, Sobrecarga ou Marca durante a preparação. Aleatoriedade poderá ser reavaliada depois dos testes do ciclo completo.
- O primeiro ciclo jogável da run tem dois combates contra inimigos comuns sorteados sem repetição. Entre eles, a oferta sorteia três cartas distintas a partir do pool atual de seis cartas; a jogadora escolhe uma ou pula a oferta.
- Entre esses dois combates, Vida e baralho da run persistem. Energia, mão, compra, descarte, Combo, Barreiras, turno e estado do inimigo são reiniciados.
- O core vertical v0.1 está concluído e validado. Isso confirma o ciclo fundamental do deckbuilder roguelike, não a implementação de todos os sistemas descritos no design.
- A consolidação técnica inicial e a identidade básica de Vega foram implementadas. A próxima fase é melhorar a leitura da tela e, depois, expandir inimigos e chefe; balanceamento fica para uma etapa posterior.
- A organização de `main.gd` será progressiva. O primeiro recorte extrai somente os dados das cartas e deve preservar o comportamento atual; não está aprovada uma grande reestruturação de uma vez.
- A reorganização para `main.gd` como orquestrador passa por `JogadorCombate` e `EncontroCombate` antes da expansão de inimigos. A etapa preserva regras e mantém pontes legadas somente durante a migração.
- A expansão seguirá: catálogo e escolha entre o Drone e três novos inimigos comuns → validação das cartas → elite → chefe → mapa das Docas.
- Juntas de Retorno ativa quando o Combo alcança 2 no turno do jogador, concede 3 de Barreira e só pode ativar uma vez por turno. Essa regra está implementada e aceita como o comportamento atual da relíquia inicial.
- O catálogo comum das Docas contém Drone de Segurança, Estivador Cibernético, Torreta de Contenção e Guarda Portuário. Os encontros sorteiam sem repetição na mesma run; as intenções permanecem determinísticas e dirigidas por dados.


## Decisões fechadas e pendências atuais

### Fechado nesta revisão

1. Vega é a primeira personagem jogável.
2. Docas são seu distrito inicial. Todos poderão acessar os distritos no jogo expandido; cada protagonista terá seu ponto inicial próprio.
3. Três desfechos: novo governo voltado ao bem-estar, assimilação corporativa (pior final), derrubada sem governo e com caos.
4. Runs alternativas, com pequenos upgrades ou conhecimento persistente.
5. Vega perdeu os braços ao salvar um colega que havia caído nas docas; ele depois a ajuda na adaptação dos braços.
6. Cais vive de pequenos trabalhos. A revolta contra o sistema e rumores sobre a queda do governo impulsionam as jornadas.
7. Nomes serão escolhidos com auxílio de propostas, sem transformar sugestões em cânone automaticamente.
8. Balanceamento final, catálogo definitivo e medição de duração continuam abertos. Ajustes do protótipo devem partir de comportamento observado, mudar uma variável por vez e permanecer identificados como hipóteses até serem aceitos.
9. O core vertical v0.1 foi validado pelo usuário: combate com cartas, intenção inimiga, progressão entre dois combates e conclusão de run formam uma base jogável.
10. A organização seguinte usa papéis genéricos: `Combatente` para Vida, Barreira e estados; `Jogador` para recursos e cartas; `Inimigo` para intenções; `main.gd` como orquestrador. A migração será incremental e não deve introduzir regras específicas de Vega ou Drone nas classes comuns.
11. A apresentação da tela deve ganhar organização e estados mais claros sem alterar as regras do combate. Depois dessa melhoria, a expansão priorizada será ampliar os inimigos, incluindo um chefe.

### Pendências relevantes

- Escolher nomes ainda abertos para lugares, facções e elementos narrativos a partir da [MUNDO_E_FINAIS.md](MUNDO_E_FINAIS.md) ou de novas opções. Luvto já está confirmado.
- Escrever aliados, ofertas corporativas e condições legíveis dos três finais.
- Conectar o clímax de um único distrito aos desfechos da cidade, sem ampliar automaticamente o escopo.
- Definir o que persiste entre runs e seus limites numa etapa posterior.
- Escolher o objetivo operacional inicial de Vega a partir dos rumores e de sua relação com as docas.
- Definir a especialidade do colega salvo, sem substituir sua relação já confirmada.

O estado implementado continua sendo o da [STATUS.md](STATUS.md). Nenhuma decisão narrativa nesta revisão equivale a código já feito.


## Registro de manutenção — 23/09/2026

- Documento monolítico v0.4 organizado neste conjunto de fontes, preservando as decisões e regras propostas.
- STATUS.md atualizado com o relato atual: carta selecionável, interação com alvo e Energia, botão de encerrar turno e Energia funcionando.
- Não houve inspeção nem alteração dos scripts locais, execução do jogo ou validação nova do combate nesta sessão.
- Este pacote passa a ser a base de continuidade ao ser adotado no projeto. O MD v0.4 deve ficar como histórico, sem manutenção paralela.

## Como registrar uma nova decisão

Copiar este formato quando houver mudança efetivamente aceita:

```text
Data:
Decisão:
Motivo:
Substitui:
Arquivo atualizado:
Impacto no escopo:
```

Sugestões não aprovadas ficam em pendências. Implementação concluída deve ser registrada em STATUS.md, com evidência.
