# Intenções inimigas e recompensas entre combates

Data: 23/09/2026

## Objetivo

Evoluir o combate de teste para que o jogador precise responder a ameaças visíveis e possa construir o baralho ao longo de uma run. A implementação deve preservar a leitura do combate atual e avançar em incrementos verificáveis.

## Estado observado

- `main.gd` controla dois combates sequenciais, com um Drone, Energia, Barreira, Combo, compra e descarte. O catálogo atual contém seis cartas; o baralho inicial usa Golpe, Proteção, Direto Hidráulico e Quebra-chassi, enquanto Brecha e Pulso Debilitante permanecem cartas de teste.
- `main.tscn` possui a interface do combate e a cena reutilizável `carta.tscn` é usada para criar a mão.
- `Jogar novamente` recarrega a cena e reinicia toda a run de dois combates.
- A Godot declarada no projeto é 4.7 com `GL Compatibility`.
- O executável não está no `PATH`, mas a instalação local da Godot 4.7.2 pode ser chamada diretamente para testes headless; a apresentação visual continua dependendo do editor.

## Autoridade e classificação das informações

- `DECISOES.md` registra substituições e mudanças aceitas.
- `PERSONAGENS.md` é a fonte vigente para nome, história, aparência e personalidade.
- `GAME_DESIGN.md` define direção e regras propostas, desde que não tenha sido substituído por uma decisão posterior.
- `STATUS.md`, o código atual e o comportamento observado determinam o que está implementado.
- Este documento distingue regras confirmadas, estado observado e hipóteses de teste. Uma hipótese não deve ser implementada como regra aprovada sem decisão explícita.

## Regras de design que permanecem vigentes

- Intenções inimigas são visíveis antes da decisão do jogador.
- O inimigo não troca silenciosamente a ação anunciada.
- A Vida do jogador persiste entre encontros; ela não é restaurada automaticamente.
- O baralho da run e as melhorias persistem entre combates.
- O design amplo prevê três ofertas ou pular; o protótipo atual mostra quatro recompensas fixas e ainda não oferece pular.
- A compra, o descarte, a Energia e o Combo continuam seguindo as regras já implementadas.

## Método de balanceamento

O Drone permanece com 30 de Vida. O ciclo completo aprovado para teste é `Rajada → Blindagem → Rajada → Sobrecarga → Rajada → Marcar alvo → repetir`. Rajada causa `3 × 2`; Blindagem concede 6; Sobrecarga acrescentará 2 por golpe ao próximo ataque completo; Marca acrescentará 1 por golpe ao próximo ataque completo contra Vega.

Esses números são valores experimentais aprovados para o protótipo, não balanceamento final. A implementação será incremental: primeiro Rajada e Blindagem, depois Sobrecarga e Marca. Assim, cada duração e consumo pode ser verificado antes de combinar todos os estados.

Depois da validação estrutural, novas intenções e inimigos serão tratados como hipóteses de teste. Para cada rodada manual, registrar turnos, Vida perdida, Proteções usadas, Combo consumido, dano das Finalizações e Vida restante do inimigo. Alterar uma variável de cada vez e registrar a hipótese em `STATUS.md`; uma mudança de direção aceita também deve ser resumida em `DECISOES.md`.

## Sequência de implementação

### 4A — Intenções no Drone

Implementar Rajada e Blindagem alternadas. A interface mostra `Rajada: 3 × 2` ou `Blindagem de emergência: +6` antes da decisão. Rajada resolve cada golpe separadamente contra a Barreira de Vega. Blindagem concede Barreira ao Drone durante o turno de cartas seguinte e expira no início do próximo turno do Drone.

### 4B — Sobrecarga e Marca

Implementação atual: Sobrecarga e Marca foram acrescentadas ao ciclo determinístico. Os indicadores permanecem visíveis e o valor anunciado da Rajada seguinte já inclui os modificadores. Cada bônus é consumido somente depois do ataque completo; Enfraquecido continua sendo consumido por golpe.

### 4C — Variação de inimigo

Somente depois de validar o ciclo completo do Drone, propor um segundo inimigo coerente com as Docas. Seus valores e sequência ainda não estão definidos.

### 5A — Estado da run

O baralho persistente da run é separado das pilhas temporárias do combate. Ao iniciar um encontro, o jogo copia o baralho da run para a pilha de compra e zera apenas o estado específico do combate. A Vida do jogador permanece com o valor do encontro anterior.

### 5B — Recompensa

Após a primeira vitória, os controles do combate ficam bloqueados e aparecem seis escolhas fixas: Golpe, Proteção, Direto Hidráulico, Quebra-chassi, Brecha e Pulso Debilitante. A escolha adiciona o identificador da carta ao baralho da run e inicia o segundo encontro sem restaurar a Vida. A opção de pular permanece no design amplo, mas está adiada neste primeiro protótipo.

Após a segunda vitória, a run é concluída. O botão `Jogar novamente` recarrega a cena e recomeça o ciclo completo.

## Critérios de aceitação

- O jogador vê a próxima intenção antes de encerrar o turno.
- A intenção resolvida corresponde ao que estava anunciado.
- A primeira intenção visível resolve dois golpes separados de 3.
- Blindagem concede 6 de Barreira, não causa dano e permanece durante o turno de cartas seguinte.
- Rajada e Blindagem produzem decisões diferentes e continuam totalmente anunciadas.
- Quando 4B for implementada, a Rajada mostrará os bônus de Sobrecarga e Marca antes de ser executada.
- A frequência de vitórias no primeiro turno é registrada antes de alterar Vida, dano ou composição do baralho.
- Após a primeira vitória, uma das três recompensas pode ser escolhida.
- A carta escolhida aparece no baralho do próximo combate.
- A Vida restante atravessa o encontro seguinte.
- O comportamento de reinício da futura run é definido e aprovado antes de substituir o recarregamento atual da cena.
- O combate atual continua jogável caso o fluxo de recompensa ainda não tenha sido iniciado.

## Fora do escopo desta etapa

- Relíquias, eventos narrativos, lojas e mapa de rotas.
- Remoção de cartas do baralho.
- Balanceamento final ou catálogo definitivo de inimigos e recompensas.
- Novas mecânicas de Luvto ou Cais.
