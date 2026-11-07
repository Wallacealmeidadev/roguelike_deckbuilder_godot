# Run das Docas — infraestrutura inicial

## Intenção e autoridade

O pedido anexado em 28/09/2026 substitui as regras anteriores de sete pontos, elite obrigatório e recompensa dupla obrigatória. Esta entrega constrói uma run navegável e reproduzível sem redesign, novos assets ou novo bestiário. O combate funcional e a apresentação R2/R3 permanecem. O template inicial tem 11 nós percorridos, três blocos e Boss. Elite/Desmanche é uma primeira bifurcação curta, não uma regra permanente para templates futuros.

## Modelo

`MapaRun` gera em duas passagens: primeiro os slots e suas conexões; depois escolhe IDs de conteúdo de catálogos existentes. Há uma rota de quatro combates comuns, três eventos, dois descansos, uma escolha Elite ou Desmanche, e um Boss. A geração recebe seed, usa RNG local e a mesma seed reproduz estrutura e conteúdo. O grafo é acíclico; só se entra em destinos conectados e ainda não concluídos. Eventos não se repetem na run e eventos consecutivos não compartilham família; uma família pode aparecer novamente após outro tipo ou outra família. O catálogo excede o conteúdo visível em uma tentativa.

`RunState` pertence à cena principal nesta fase, pois mapa, encontro e overlays já estão em `main.tscn`. Guarda seed, mapa, Vida atual/máxima, tokens do deck (inclusive `#aprimorado`), relíquias, flags, nó atual/em andamento e concluídos. Energia, Barreira, Combo e outras condições de encontro ficam em `JogadorCombate`/combate e reiniciam ao entrar no próximo encontro. A tela só apresenta dados; catálogos e resolução mantêm as regras.

## Fluxos

Nova run gera mapa uma vez. A seleção de nó marca-o em andamento; não o conclui. Combate usa inimigos já existentes e preserva Vida/deck entre encontros. Vitória abre oferta de três cartas comuns/incomuns, ou, para Elite, uma rara garantida e duas comuns/incomuns em ordem variável; pode-se escolher uma ou pular. Apenas depois disso o nó é concluído e o mapa volta. Relíquias não são prêmio de combate comum. O Boss usa combate existente claramente marcado como provisório; vencer encerra a run sem fingir que Lastro definitivo está pronto.

REST cura 8 de Vida, valor provisório, sem opção de upgrade. SCRAPYARD permite remover uma cópia ou recalibrar uma cópia com `DescansoRun.aplicar_melhoria`. Eventos são dados com id, título, família, texto, opções, condições, resultados e flags exigidas/concedidas; uma flag desbloqueia uma opção posterior. A UI desses fluxos é simples e reaproveita componentes existentes. Debug imprime seed, estrutura, conteúdo e transições importantes apenas em modo debug.

## Critérios verificáveis

Testes cobrem seed idêntica e diferente, contagens por rota, todos os caminhos ao Boss, elite opcional, unicidade e famílias de eventos consecutivos, visita apenas a conexões, Vida/deck/relíquias/flags/upgrades persistentes, recursos temporários resetados, recompensas por raridade, escolha/pular, REST, SCRAPYARD e evento condicionado. Cada etapa deve carregar na Godot 4.7.2 e preservar o combate anterior. As decisões antigas incompatíveis são atualizadas em `docs/GAME_DESIGN.md` e registradas em `docs/DECISOES.md`; resultados reais ficam em `docs/STATUS.md`.
