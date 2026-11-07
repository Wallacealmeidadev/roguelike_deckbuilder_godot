# Roguelike cyberpunk — direção e regras v0.2

**Revisão em andamento — 23/09/2026.** Este documento reúne direção confirmada e mecânicas propostas para o combate. `DECISOES.md` e `PERSONAGENS.md` prevalecem em mudanças posteriores de cânone; código e `STATUS.md` registram o que está implementado. Valores e regras sem confirmação explícita continuam sendo hipóteses de teste. O título definitivo permanece fora deste recorte.

## 1. Direção confirmada

### Progressão implementada da run

Na implementação atual, a run jogável começa no mapa das Docas com 11 pontos percorridos, três blocos e um Boss provisório. Há uma bifurcação curta Elite/Desmanche no ponto 6, seguida de reconvergência. O mapa é a fonte de progressão da tentativa: um nó só é concluído após suas consequências e recompensa, e a derrota encerra a tentativa. O Boss usa provisoriamente o combate da Unidade de Contenção Portuária; Lastro definitivo permanece fora do escopo.

Na entrada da aplicação, o jogador passa por `Menu principal -> Seleção de Vega -> Mapa das Docas`. Vega é a única personagem disponível neste recorte; confirmar sua ficha inicia a run existente, enquanto voltar não cria estado de gameplay. Essa camada de entrada não muda as regras de progressão, combate ou baralho descritas abaixo.

- Deckbuilder roguelike em uma metrópole cyberpunk decadente, com rotas, encontros, alianças e diferentes finais ligados a um grande golpe.
- O prazer principal é construir uma mecânica e transformá-la através de cartas, aprimoramentos e relíquias. Cada personagem deve sustentar mais de uma build.
- A cidade e seus conflitos ocupam o centro da narrativa. A reconstrução do personagem faz parte do mundo, sem concentrar toda a experiência numa clínica.
- O corpo pode ser completamente modificado. A consciência e a identidade do personagem permanecem entre reconstruções.
- O tom comporta decadência, estranheza, horror, humor, afeto e vida cotidiana.
- Inimigos diversos, com origem e comportamento coerentes com cada ambiente: humanos, máquinas, fauna, organismos artificiais e outras formas de vida tecnológica.
- Intenções inimigas visíveis para permitir ataque, defesa e preparação consciente.
- Arte 2D, com os combatentes integrados ao cenário. Interações sutis de fundo reforçam as ações sem disputar atenção com cartas e intenções.
- Meta de runs de até dez minutos no conceito inicial.
- A primeira entrega concentra-se em Vega e nas Docas. A expansão prevê Luvto e Cais, cada personagem com seu distrito inicial e acesso posterior aos demais distritos.
- Tipos de carta definidos pelo usuário: Ataque, Habilidade e Aprimoramento.
- Valores numéricos próprios devem ser escolhidos pelo ritmo e pelas combinações desejadas. Todos os valores novos continuam experimentais.
- PC como foco integral da primeira versão. Celular faz parte da intenção futura.

## 2. Base comum proposta

| Elemento | Regra inicial |
| --- | --- |
| Combate | Um personagem contra um a três inimigos. Turnos, sem limite de tempo para decidir. |
| Vida inicial | 40 para os três personagens. A Vida restante persiste entre encontros. |
| Energia | 4 no início de cada turno do jogador. Energia excedente não passa ao turno seguinte. |
| Compra | Comprar 6 cartas no início do turno. Isso é uma quantidade de compra, não uma reposição da mão até seis. |
| Limite da mão | 10 cartas. Compras que ultrapassariam esse limite são interrompidas; as cartas continuam na pilha de compra. |
| Baralho inicial | 10 cartas: 3 Golpes, 3 Proteções e 4 cartas do personagem. |
| Mão ao encerrar | Cartas não usadas vão ao descarte, exceto as que tiverem Reter. |
| Compra vazia | Embaralhar o descarte para formar a nova pilha, apenas quando uma compra exigir isso. Se ambas as pilhas estiverem vazias, interromper a compra. |
| Barreira | Absorve dano antes da Vida. A Barreira restante desaparece no início do próximo turno de seu dono. |
| Derrota | Vida do jogador igual a zero encerra a run. |
| Vitória | Todos os inimigos derrotados, após concluir o efeito em resolução e suas consequências, desde que o jogador esteja vivo. |
| Aleatoriedade | Está na ordem de compra, composição dos encontros e ofertas de recompensa. Uma carta não depende de uma rolagem para acertar ou executar seu efeito. |

A proposta de teste passa a usar 4 Energias e 6 cartas compradas por turno: isso abre espaço para preparar, encadear e finalizar ações no mesmo turno. Vida, dano, defesa e custos permanecem hipóteses para medir junto da duração de cada combate. A troca de números precisa servir ao ritmo e às escolhas do jogo.

### Jogar uma carta no PC

1. Clicar na carta para selecioná-la.
2. A interface destaca os alvos válidos e mostra custo e consequências calculáveis.
3. Clicar no alvo confirma a jogada. Cartas sem alvo individual usam uma área explícita de confirmação no campo do jogador.
4. A carta só cobra recursos depois de validar custo e alvo. Cancelar a seleção não gasta nada.
5. Os efeitos resolvem na ordem escrita. Depois da resolução, a carta vai ao descarte, à área de Aprimoramentos ou à pilha de Esgotadas, conforme seu texto.

Arrastar cartas pode ser um atalho posterior. Inspecionar uma carta ou intenção deve funcionar por clique, mesmo que o PC também ofereça hover. Isso preserva a possibilidade de adaptação para toque.

### Tipos de carta

| Tipo | Função | Destino usual |
| --- | --- | --- |
| Ataque | Causa um ou mais golpes e pode ter efeitos adicionais. | Descarte após resolver. |
| Habilidade | Produz defesa, compra, recursos, estados ou outra ação utilitária. | Descarte após resolver. |
| Aprimoramento | Instala uma regra adicional que permanece naquele combate. | Área de Aprimoramentos; sai da circulação até o combate terminar. |

Uma carta de Aprimoramento volta ao baralho normal no combate seguinte. Seu efeito não atravessa encontros. Relíquias permanecem ativas durante a run e não precisam ser compradas ou jogadas como cartas.

## 3. Fluxo do combate e intenções

### Preparação

Restaurar o baralho da run, zerar Barreira, estados, recursos exclusivos e dispositivos; ativar as relíquias; embaralhar. A Vida não é restaurada automaticamente. Cada inimigo anuncia sua próxima ação antes da primeira decisão do jogador.

### Início do turno do jogador

1. Zerar contadores de “uma vez por turno” do jogador e remover sua Barreira restante.
2. Resolver sua Corrosão, se houver. Vida zero encerra a run imediatamente.
3. Definir Energia como 4.
4. Resolver efeitos de início de turno, na ordem em que suas fontes foram adquiridas ou instaladas.
5. Comprar 6 cartas, respeitando o limite da mão.

### Fase do jogador

Jogar cartas, inspecionar intenções e organizar as ações. É permitido encerrar com Energia ou cartas restantes. Novos Aprimoramentos só ativam um gatilho de início de turno a partir do próximo início; efeitos escritos como imediatos acontecem ao instalar.

### Encerramento e fase inimiga

1. Resolver dispositivos da esquerda para a direita, seguidos dos demais efeitos de fim do turno do jogador, na ordem de instalação das fontes.
2. Descartar cartas sem Reter e zerar a Energia não utilizada. Zerar o Combo restante de Vega após os efeitos de fim de turno. Esse descarte automático é diferente de descartar uma carta por um efeito: só ativa uma habilidade se seu texto incluir expressamente o descarte do encerramento.
3. Os inimigos agem da esquerda para a direita. Cada um remove sua Barreira anterior, resolve sua Corrosão e seus efeitos de início de turno, e então executa a intenção anunciada, se ainda estiver vivo.
4. Após a fase inimiga, anunciar as próximas intenções dos sobreviventes e iniciar o novo turno do jogador.

### Informação confiável

- Mostrar tipo da ação, alvo, dano por golpe, quantidade de golpes, Barreira e estados relevantes.
- Modificadores provocados pelo jogador atualizam imediatamente os números previstos.
- Se um comportamento reage a Vida, morte de aliados ou outro gatilho, essa regra deve ser inspecionável. Uma mudança de intenção precisa ser explicitada antes da próxima decisão do jogador.
- Inimigos não trocam silenciosamente a ação anunciada depois que o jogador encerra o turno. Alterações causadas por efeitos anunciados durante a fase inimiga continuam válidas.
- Distinguir dano anunciado de dano previsto à Vida depois da Barreira. Mostrar a ordem dos inimigos ajuda a entender quem consumirá a defesa primeiro.

### Drone de segurança das Docas — protótipo

Uma intenção descreve a ação completa que o inimigo executará, e não apenas o dano do próximo ataque. A interface deve distinguir ataque, defesa, preparação e marcação, mostrando seus valores e efeitos antes da decisão do jogador.

O ciclo de teste completo do Drone é `Rajada → Blindagem de emergência → Rajada → Sobrecarga → Rajada → Marcar alvo → repetir`. Rajada causa dois golpes de 3; Blindagem concede 6 de Barreira; Sobrecarga acrescenta 2 por golpe ao próximo ataque completo; Marca acrescenta 1 por golpe ao próximo ataque completo contra Vega. Buff e marca são consumidos somente depois de todo o ataque fortalecido.

A implementação é incremental. A primeira versão alterna Rajada e Blindagem. A Barreira do Drone segue a regra comum: permanece durante o turno de cartas do jogador e expira no início do turno seguinte do próprio Drone. Os valores são experimentais e devem ser avaliados em combate antes de novas alterações.

## 4. Vocabulário comum de efeitos

Os efeitos desta seção podem existir nos baralhos dos três personagens. As ofertas podem combinar cartas compartilhadas e cartas exclusivas.

| Nome | Efeito exato da v0.2 |
| --- | --- |
| Dano N | Remover N pontos de Barreira e, se ela acabar, remover o excedente da Vida. Dano nunca é negativo. |
| Barreira N | Acrescentar N à Barreira atual. Expira no início do próximo turno do dono. |
| Reparar N | Recuperar N de Vida, até a Vida máxima. Não revive alguém com Vida zero. |
| Comprar N | Comprar N cartas, com as regras de mão e reembaralhamento da base. |
| Energia N | Acrescentar N à Energia disponível neste turno. |
| Potência N | Acrescentar N ao dano de cada golpe de suas cartas ou ações do tipo Ataque, até o fim do combate. |
| Exposto N | Os próximos N golpes de Ataque recebidos causam 2 de dano adicional cada. Cada golpe consome uma carga, mesmo se a Barreira absorver tudo. |
| Enfraquecido N | Os próximos N golpes de Ataque realizados causam 2 de dano a menos cada, até o mínimo de zero. Cada golpe consome uma carga, mesmo se o dano chegar a zero. |
| Corrosão N | No início do turno do afetado, perder N de Vida ignorando Barreira; depois reduzir Corrosão em 1. |
| Reter | A carta permanece na mão durante o descarte automático do encerramento. |
| Esgotar | Após resolver, a carta sai da circulação até o fim do combate. |

Potência, Exposto, Enfraquecido e Corrosão acumulam por adição. Exposto e Enfraquecido contam **golpes, não turnos**; seus ícones precisam deixar isso explícito. Reter e Esgotar são palavras-chave, não contadores.

Para um golpe de Ataque, calcular: máximo entre zero e dano base + Potência + 2 se o alvo estiver Exposto − 2 se o atacante estiver Enfraquecido. Em seguida, consumir as cargas aplicáveis e descontar a Barreira. Recalcular cada golpe de um ataque múltiplo.

Dispositivos, Corrosão e dano de relíquias não são golpes de Ataque. Portanto, não usam Potência, Exposto ou Enfraquecido, salvo texto que declare expressamente outra interação. Corrosão ignora Barreira; os demais danos continuam sujeitos à Barreira.

### Cartas comuns de referência

| Carta | Tipo | Custo | Efeito |
| --- | --- | --- | --- |
| Golpe | Ataque | 1 | Causar 6 de dano a um inimigo. |
| Proteção | Habilidade | 1 | Ganhar 5 de Barreira. |
| Brecha | Ataque | 1 | Causar 4 de dano; depois aplicar Exposto 2 ao alvo sobrevivente. |
| Pulso debilitante | Habilidade | 1 | Aplicar Enfraquecido 2 a um inimigo; ganhar 3 de Barreira. |
| Reserva de emergência | Habilidade | 0 | Ganhar 1 de Energia. Esgotar. |
| Reforço estrutural | Aprimoramento | 1 | No início dos seus próximos turnos, ganhar 2 de Barreira. |

Golpe e Proteção são as seis cartas compartilhadas dos baralhos iniciais. As outras são exemplos de recompensas, não concessões automáticas ao iniciar a run. Reparar e Corrosão fazem parte do vocabulário, mas não precisam estar em todos os baralhos iniciais.

## 5. Personagens e mecânicas

Vega é a personagem da primeira entrega. Luvto e Cais permanecem planejados para a expansão. A proposta mantém Energia, compra, Vida inicial e fluxo de turno iguais para os três; cada personagem tem uma mecânica exclusiva, quatro cartas próprias no baralho inicial e uma relíquia inicial.

### Vega — Combo e Finalização

**Direção confirmada pelo usuário:** humana com o restante do corpo normal e braços protéticos que ficam extremamente musculosos em combate, focada em combos.

**Proposta visual:** corpo humano, cabelo curto e braços protéticos com articulações reforçadas, mecanismos de travamento e aumento muscular durante o combate. A energia da personagem aparece no peso dos movimentos, nos apoios e na sequência de impactos. A antiga proposta de artista e os recursos de Carga foram retirados.

**Combo:** contador sem teto mecânico no protótipo, exclusivo de Vega. Uma carta só concede Combo quando seus dados declaram `ganha_combo`; `Direto Hidráulico` concede 1, enquanto `Golpe` não altera o valor. Uma carta com vários golpes concede no máximo o ganho declarado pela própria carta. Habilidades e Aprimoramentos preservam a sequência. Combo zera no encerramento do turno do jogador, depois dos efeitos de fim de turno, e no fim do combate. A progressão sem teto é experimental; o balanceamento será revisto após observar a sinergia.

**Finalização:** palavra-chave de cartas de Ataque que consomem todo o Combo na confirmação para produzir o bônus escrito. Não geram Combo. A previsão usa o valor que será consumido, e o custo só é cobrado depois de validar o alvo. Podem funcionar com Combo zero, usando seu valor básico.

| Carta inicial exclusiva | Cópias | Tipo e custo | Efeito |
| --- | --- | --- | --- |
| Direto hidráulico | 2 | Ataque, 1 Energia | Causar 4 de dano; ganhar 2 de Barreira; conceder 1 Combo depois de resolver. |
| Quebra-chassi | 2 | Ataque, 1 Energia | Finalização. Causar 5 + 3 por ponto de Combo consumido de dano em um golpe. |

Golpe causa 6 de dano e não gera Combo. Cartas de Ataque jogadas por outros personagens não geram esse recurso; a declaração de ganho continua sendo específica da carta.

**Relíquia inicial — Juntas de retorno:** na primeira vez que atingir pelo menos 2 Combo em cada turno do jogador, ganhar 3 de Barreira. Consumir o Combo e chegar novamente a 2 no mesmo turno não reativa a relíquia.

**Aprimoramento de referência — Ritmo de combate:** custa 1 Energia. Sempre que ganhar efetivamente 1 Combo, ganhar 1 de Barreira. Como o protótipo não tem teto de Combo, cartas que declaram ganho continuam a gerar o recurso e seu efeito. Consumir Combo não é ganhá-lo.

**Builds a explorar:** muitas cartas de ataque e compra; preparo de uma finalização forte; conversão do Combo em defesa. Os braços fortes se expressam tanto em sequências quanto em golpes finais. A mecânica não exige uma sequência de cartas específicas para funcionar.

### Luvto — Ocultação e Emboscada

**Direção confirmada pelo usuário:** humano com metade do corpo em aço cirúrgico exposto e metade orgânica, focado em furtividade. Luvto substitui Nula e o nome de trabalho anterior.

**Proposta visual:** metade orgânica, metade em aço cirúrgico exposto e uma manta marrom muito rasgada. A silhueta é estreita e contida; o movimento furtivo contrasta com sua personalidade explosiva e inconsequente. Os detalhes completos permanecem em `PERSONAGENS.md`.

**Ocultação:** estado de 0 ou 1, conservado entre turnos até ser consumido ou até terminar o combate. Reaplicá-lo não acumula outra proteção. Possui duas formas de consumo:

- Ao confirmar uma carta de Ataque enquanto Oculto, consumir Ocultação e ativar Emboscada nessa carta.
- Ao receber o primeiro golpe inimigo de Ataque com dano positivo, consumir Ocultação para reduzir o dano desse golpe à metade, arredondando para baixo. Aplicar essa redução depois de Potência, Exposto e Enfraquecido, e antes de descontar a Barreira.

Habilidades e Aprimoramentos não revelam o personagem. Um ataque inimigo com vários golpes consome Ocultação apenas no primeiro golpe positivo; os seguintes causam dano normal. Golpes em área também podem consumir a proteção. Corrosão e outros danos que não são Ataques não recebem essa redução nem consomem Ocultação. Estar Oculto não altera silenciosamente a intenção escolhida pelo inimigo.

**Emboscada:** acrescentar 4 ao dano do primeiro golpe da carta que consumiu Ocultação, antes da Barreira do alvo e junto dos demais modificadores. Os outros golpes dessa carta não recebem o bônus. A Emboscada é um evento daquela carta, não um segundo recurso acumulável.

**Previsão:** mostrar o resultado ofensivo ao selecionar um Ataque e o resultado defensivo ao avaliar o encerramento do turno. Não há chance de falha da camuflagem ou rolagem de esquiva.

| Carta inicial exclusiva | Cópias | Tipo e custo | Efeito |
| --- | --- | --- | --- |
| Camuflar | 2 | Habilidade, 1 Energia | Ganhar Ocultação e 3 de Barreira. |
| Ponto cego | 2 | Ataque, 1 Energia | Causar 6 de dano em um golpe. Quando ativa Emboscada, esse golpe também ignora a Barreira do alvo. Sem outros modificadores, causa 10 diretamente à Vida nessa condição. |

O bônus padrão de Emboscada não ignora Barreira: essa propriedade pertence especificamente a Ponto cego. Golpe também pode ativar Emboscada, mas seu dano continua sujeito à Barreira.

**Relíquia inicial — Lente de caça:** na primeira Emboscada de cada turno do jogador, comprar 1 carta depois da resolução do Ataque, se o combate continuar.

**Aprimoramento de referência — Execução silenciosa:** custa 1 Energia. Acrescentar 3 ao bônus de Emboscada. Com uma cópia instalada, seu bônus passa de 4 para 7. Cada cópia adicional acrescenta outros 3.

**Builds a explorar:** uma abertura de grande dano; alternar camuflagem e ataques para produzir várias Emboscadas; guardar Ocultação para amortecer um ataque anunciado e preparar o turno seguinte. O jogador escolhe entre a proteção e o bônus ofensivo de cada aplicação.

### Cais — Sucata e dispositivos

**Direção confirmada pelo usuário:** Cais é uma mecânica engraçada e apegada às suas sucatas e máquinas.

**Identidade proposta:** mecânica de elevadores dos megablocos, que conhece os trajetos esquecidos da cidade. Dá apelidos às máquinas, conversa com elas enquanto trabalha e fica ofendida quando alguém chama uma peça recuperável de lixo. Seu humor vem desse afeto e da confiança em soluções improvisadas; ela continua competente e capaz de levar os conflitos da cidade a sério.

**Proposta visual:** macacão remendado, bolsos cheios de componentes, óculos de proteção e ferramentas de origens diferentes. Seus dispositivos têm marcas de reparos, adesivos e pequenos detalhes pessoais. Reações curtas às montagens e desmontagens reforçam a personalidade, sem falas obrigatórias repetidas a cada ação.

**Sucata:** recurso entre 0 e 6. É gerado e gasto por efeitos explícitos de cartas. Descartar cartas no fim do turno não gera Sucata. O recurso permanece entre turnos e zera no fim do combate; o excesso acima de 6 é perdido.

**Dispositivos:** Cais pode manter até dois. Eles não são inimigos ou aliados com Vida e não recebem ataques na v0.2. Seus efeitos disparam no fim do turno do jogador, inclusive no turno em que são montados. Desaparecem ao terminar o combate.

Se os dois espaços estiverem ocupados, montar outro exige escolher antes da confirmação qual será substituído. A substituição remove o dispositivo antigo, sem devolução automática de Sucata. Os espaços resolvem da esquerda para a direita.

| Carta inicial exclusiva | Cópias | Tipo e custo | Efeito |
| --- | --- | --- | --- |
| Desmontar | 2 | Ataque, 1 Energia | Causar 3 de dano; ganhar 2 de Sucata. |
| Montar sentinela | 2 | Habilidade, 1 Energia + 2 Sucata | Criar uma Sentinela. A carta volta ao descarte normalmente. |

**Sentinela:** causa 3 de dano ao inimigo focado no fim do turno. Por padrão, o foco é o primeiro inimigo vivo à esquerda. Durante seu turno, o jogador pode mudar esse foco compartilhado gratuitamente. Se o foco morrer antes de uma ativação, usar o primeiro inimigo vivo à esquerda. O dano é causado por dispositivo, não por um Ataque.

**Relíquia inicial — Chave de casa:** na primeira vez que montar um dispositivo em cada turno do jogador, ganhar 2 de Barreira.

**Aprimoramento de referência — Oficina portátil:** custa 1 Energia. Na primeira montagem de dispositivo em cada turno do jogador, comprar 1 carta depois de resolver a carta de montagem.

**Builds a explorar:** dano recorrente; dispositivos de defesa; substituir e reaproveitar montagens para ativar efeitos. Uma recompensa possível é Montar escudeiro, com o mesmo custo de Montar sentinela, criando um dispositivo que gera 4 de Barreira no fim do turno.

## 6. Regras de resolução e combinações

- Recurso e alvo insuficientes impedem a confirmação de uma carta. Montar sentinela, por exemplo, exige tanto Energia quanto Sucata.
- Ganhar um recurso e consumi-lo são eventos diferentes. Ganhar Combo, consumir Combo e ativar Emboscada são eventos distintos. Cada relíquia ou Aprimoramento responde somente ao evento escrito em seu texto.
- Cada golpe atualiza Vida, Barreira e contadores antes do próximo golpe. Um inimigo com Vida zero é removido imediatamente.
- A carta atual conclui os demais efeitos que ainda tiverem alvos válidos. Depois, resolver suas consequências e verificar vitória. Vida zero do jogador encerra a run imediatamente; efeitos posteriores não o revivem. Se uma resolução produzir derrota dos dois lados, prevalece a derrota do jogador.
- Gatilhos da mesma etapa resolvem na ordem de aquisição ou instalação de suas fontes. Relíquias iniciais precedem Aprimoramentos instalados durante o combate. A interface deve permitir inspecionar a origem dos efeitos.
- Um Ataque com vários golpes conta como uma carta para Combo. Quebra-chassi consome Combo e não gera um novo ponto. Emboscada aplica seu bônus ao primeiro golpe, uma única vez por carta que consumiu Ocultação.
- Cartas e efeitos gerados durante um combate não entram permanentemente no baralho da run, a menos que um evento ou recompensa diga isso expressamente.
- Melhorar uma carta modifica somente aquela cópia durante a run. A v0.2 usa no máximo uma melhoria por cópia, apresentada antes da escolha. Exemplos: Golpe passa de 6 para 9 de dano; Proteção, de 5 para 8 de Barreira.
- A mesma cópia de uma carta de Aprimoramento não pode ser instalada repetidamente no mesmo combate; ela já saiu da circulação. Duas cópias diferentes de um Aprimoramento podem coexistir e cada uma resolve seu efeito, salvo texto explícito de exclusividade.

## 7. Exemplos de decisão

### Defesa e ataque na mesma mão

Um inimigo com 24 de Vida anuncia 9 de dano. O jogador tem 4 Energias e uma mão contendo três Golpes e três Proteções, sem modificadores.

- Três Golpes e uma Proteção: causam 18, geram 5 de Barreira e deixam passar 4 de dano à Vida.
- Dois Golpes e duas Proteções: causam 12, geram 10 de Barreira e absorvem os 9 anunciados.
- Um Golpe e três Proteções: causam 6 e geram 15 de Barreira. Contra apenas esse inimigo, parte dessa defesa seria excedente.

As três alternativas custam 4 Energias. A quantidade maior de ações amplia as sequências possíveis, mas não torna toda sequência igualmente eficiente.

### Vega encadeia e finaliza

Começando com zero Combo e 4 Energias, sem outros modificadores: Direto hidráulico causa 4, gera 2 de Barreira e deixa Combo 1; Golpe causa 6 e mantém Combo 1; outro Direto hidráulico causa 4, gera 2 de Barreira e chega a Combo 2; Quebra-chassi consome os 2 pontos e causa 11.

A sequência gasta 4 Energias, causa 25 de dano e gera 6 de Barreira, terminando com Combo zero. Requer um alvo vivo para cada jogada e as cartas necessárias na mão. Com Ritmo de combate previamente instalado, os dois ganhos de Combo acrescentam 2 de Barreira, totalizando 8. Instalar o Aprimoramento nesse mesmo turno exigiria Energia adicional ou outra sequência.

### Luvto escolhe entre ofensiva e proteção

Camuflar custa 1 Energia e gera Ocultação e 3 de Barreira.

- Jogar Ponto cego em seguida custa mais 1 Energia, consome Ocultação, causa 10 de dano ignorando Barreira e ativa a compra da relíquia inicial na primeira Emboscada do turno. O personagem fica exposto ao ataque inimigo, mantendo apenas sua Barreira.
- Guardar Ocultação contra um golpe anunciado de 12 reduz esse golpe a 6. A Barreira de 3 absorve metade do restante, deixando passar 3 de dano à Vida. Ocultação é consumida na defesa e não está disponível para uma Emboscada no próximo turno, a menos que seja reaplicada.

Se o inimigo anunciar um efeito sem Ataque e nenhuma outra fonte consumir o estado, Ocultação permanece para o próximo turno. A decisão não depende de sorte.

### Cais prepara dano recorrente

Desmontar gera 2 Sucatas e causa 3 de dano. Montar sentinela consome essas Sucatas e 1 Energia, ocupa um espaço e ativa a relíquia inicial, gerando 2 de Barreira. No fim desse mesmo turno, a Sentinela causa 3 de dano. Nos próximos turnos, continua funcionando sem pagar novamente pela montagem.

## 8. Run curta proposta

### Recorte jogável vigente — primeira infraestrutura das Docas (28/09/2026)

O primeiro template controlado tem **11 nós percorridos** por rota, distribuídos por três blocos e Boss: quatro combates comuns, três eventos, dois REST, uma escolha entre Elite ou Desmanche e o Boss. Elite/Desmanche é apenas o primeiro template de bifurcação, não uma regra permanente do mapa. Todos os caminhos chegam ao Boss. Uma expansão posterior poderá usar 10–13 nós e outros templates, sem alterar esta primeira validação.

O mapa é criado em duas passagens: a estrutura define tipos, posições e conexões; depois uma seed preenche inimigos e eventos. A mesma seed reproduz estrutura e conteúdo, e reabrir o mapa não gera outra rota. Um evento não repete seu identificador na run. Famílias iguais são proibidas somente para eventos diretamente consecutivos, não para eventos separados por outros tipos de nó. O conteúdo disponível é maior do que o exibido em uma tentativa.

`RunState` preserva Vida atual/máxima, deck e cartas recalibradas, relíquias, flags, mapa, posição e nós concluídos. Energia, Barreira, Combo e demais estados de combate continuam temporários. REST cura até 8 de Vida (valor provisório); com Vida cheia, permite prosseguir. Desmanche permite remover uma cópia de carta ou recalibrar uma cópia, uma ação por visita. Eventos orientados a dados podem conceder flags e exigir flags para opções. Combates comuns oferecem três cartas comuns/incomuns; Elite oferece uma rara e duas comuns/incomuns. Escolhe-se uma carta ou pula-se. Vencer o Boss provisório encerra a run, sem simular o Lastro definitivo.

### Bestiário comum inicial das Docas (29/09/2026)

Os combates comuns do recorte usam seis inimigos de teste: Drone de Carga (26 de Vida; Barreira 7 → ataque 10 → ataque 6), Estivador Aumentado (34; Soco 7/Ombro 5 com preparação +2; Frenesi permanente em 17 ou menos, 5 × 2), Drone Reparador (18; Barreira 6 ao aliado → ataque 4 → cura 5 em outro aliado; sozinho, ataque 5), Sentinela de Inspeção (25; Marca → Disparo 8+6 → Supressão 6), Caranguejo de Sucata (22; 3 × 3 → Barreira 8 → ataque 7) e Guindaste Autônomo (38; trava → ataque 18 → Recalibrando, recebendo +50% de dano até sua próxima ação). Esses valores são provisórios. Marcado aumenta somente o próximo ataque da própria Sentinela; Recalibrando não é Exposto. A Barreira inimiga expira no início da ação seguinte de seu dono.

Há nove encontros de teste: os cinco solitários acima, Estivador + Reparador, Carga + Reparador, dois Caranguejos e Sentinela + Reparador. A abertura usa apenas os quatro solitários mais simples; no meio entram Guindaste e algumas duplas; no fim as duplas têm maior presença. A seed escolhe os encontros sem mudar o template do mapa. Em uma dupla, cada inimigo tem Vida, Barreira, intenção e alvo próprios; só há vitória após ambas as mortes.

As tabelas e notas abaixo preservam propostas e estados anteriores como histórico; quando conflitarem com este recorte, vale o recorte vigente acima.

**Meta: seis a dez minutos após familiaridade com as regras, sem cronômetro obrigatório.** É uma hipótese de ritmo a medir em partidas; primeiras leituras e decisões podem durar mais.

| Etapa | Conteúdo | Recompensa ou decisão |
| --- | --- | --- |
| 1 | Combate comum de abertura | Escolher 1 entre 3 cartas sorteadas, com pelo menos 1 Aprimoramento na oferta. É permitido pular. |
| 2 | Evento do distrito | Escolher uma relíquia dentre duas ofertas compatíveis com o personagem, ou reparar 4 de Vida. |
| 3 | Segundo combate comum, com escolha de rota | Escolher 1 entre 3 cartas sorteadas, ou pular. |
| 4 | Confronto de elite | Escolher 1 entre 2 relíquias e depois 1 entre 3 cartas raras; ambas as escolhas são obrigatórias. |
| 5 | Evento anterior ao alvo | Melhorar uma carta ou reparar 8 de Vida. A narrativa pode registrar um compromisso de rota. |
| 6 | Chefe ligado ao acesso ao golpe | Resolver o resultado da incursão e os gatilhos narrativos disponíveis. |

Essa estrutura oferece quatro combates, duas decisões de evento e oportunidades para a build ganhar novas regras antes do chefe. A relíquia inicial já está ativa desde o primeiro combate. Com as três recompensas de cartas aceitas, o baralho termina com 13 cartas.

### Atualização aprovada — modelo inicial do mapa das Docas

O primeiro modelo de mapa terá sete pontos: um encontro no primeiro ponto, o elite no terceiro, bifurcações intermediárias, reencontro dos caminhos no sexto ponto e o chefe no último. Os descansos podem aparecer em posições diferentes entre variantes da run. Esta definição descreve somente a estrutura do mapa; combate, eventos, recompensas e efeitos do descanso continuam usando seus sistemas próprios.

Nota de implementação do protótipo: o pool atual de recompensas contém as seis cartas já disponíveis (`Golpe`, `Proteção`, `Direto hidráulico`, `Quebra-chassi`, `Brecha` e `Pulso debilitante`). Ele já sorteia três opções distintas e permite pular; a garantia de um Aprimoramento na oferta depende da futura entrada dessas cartas no pool.

Os eventos da tabela são estruturas mecânicas de referência; sua apresentação deve pertencer ao distrito e às facções. Escolhas que abrem finais precisam mostrar pistas e consequências. A presença aleatória de uma sequência de eventos raros não deve ser a única forma de perseguir um final já descoberto.

As rotas podem combinar dois distritos por incursão. A variedade do jogo vem de diferentes caminhos, inimigos, eventos, personagens e combinações ao longo de várias runs. Não é necessário visitar todos os bairros numa única partida.

**Orçamento inicial de tempo:** dois combates comuns de 40–60 segundos cada; elite de 60–90 segundos; chefe de 90–120 segundos; recompensas e eventos de 90–150 segundos; seleção e transições de 30–60 segundos. Total estimado de 5min50s a 9min. Esses intervalos são metas de produção, não resultados medidos.

Não há loja ou moeda de compras no recorte v0.2: os eventos oferecem trocas e recompensas diretas. Uma economia de lojas exige uma decisão separada sobre seu espaço no ritmo curto.

## 9. Continuidade e progressão

Ao fim de um combate, preservar Vida, baralho da run, melhorias e relíquias. Zerar estados de combate, Aprimoramentos instalados, Barreira, Energia, Combo, Ocultação, Sucata e dispositivos. Recuperar as cartas Esgotadas e de Aprimoramento para o próximo combate.

O protótipo atual usa três combates: dois comuns sem repetição e um elite fixo. As recompensas comuns permitem escolher uma carta ou pular; a vitória do elite exige escolher uma relíquia e uma carta rara. Esse fluxo é uma validação intermediária antes da inclusão dos eventos e do mapa.

Ao fim de uma run, preservar personagens desbloqueados, registros de descobertas e finais alcançados. Reiniciar baralho, melhorias e relíquias daquela tentativa, exceto o equipamento inicial próprio de cada personagem.

A primeira entrega prevê Vega como personagem implementada e as Docas como distrito inicial. Luvto e Cais pertencem à expansão; quando suas mecânicas forem incorporadas ao protótipo, a seleção direta poderá ser usada para comparação sem bloquear testes por progressão.

O mecanismo de retorno preserva a consciência do personagem. Transformações físicas não justificam apagar sua personalidade a cada run. A definição completa dos finais e de quais consequências alteram o estado da cidade pertence ao próximo recorte narrativo; nenhuma regra de combate depende desse detalhamento.

## 10. Direção do combate em 2D

- Par de braços do estudo HQ 03 aprovado em 24/10/2026. Acabamento aplicado à prévia estática 18 via textura própria e material que conserva bordas registradas; H compara original/HQ na mesma pose. Resultado de runtime em avaliação, distinto da aprovação do estudo; sem migração do rig ou F5.

- Acabamento HQ próximo do estudo 02 aprovado pelo usuário em 24/10/2026 como coerente com o desenho. Estudo 03 aplica a mesma direção ao distante: fibras escuras em blocos, contornos desenhados e reflexos metálicos contidos. Avaliação de pintura, sem integração runtime; geometria/encaixes implementados continuam referência para produção das texturas.

- Estudo HQ 01 bem recebido em 24/10/2026: reduzir microbrilhos e usar sombras em blocos aproxima as próteses da personagem. Revisão 02 autorizada para mão/placas do próximo, preservando a direção das fibras. Estudos raster em avaliação de acabamento; não são novas geometrias aprovadas nem texturas de runtime. Manter proporções/encaixes implementados ao produzir assets futuros.

- Retorno posterior em 24/10/2026: antebraço próximo ainda fino e mão pequena. Candidata revisada permite mão +14% ancorada no punho e ganho transversal máximo .45 no antebraço, com transições nas juntas; substitui a restrição anterior de mão fixa. Distante e bíceps preservados. Proporção estática em avaliação, sem efeito em Combo/F5.

- Retorno sobre a revisão 18 em 24/10/2026: distante considerado ótimo, com limpeza de resíduo branco de fundo como única correção solicitada nesse lado. Próximo considerado fino: candidata de volume transversal localizado (até 24% bíceps/20% antebraço nos ventres, extremidades fixas), sem ampliar mão, mover juntas/aro ou alongar segmentos. V compara espessura na mesma pose. Limpeza/proporção ainda em avaliação; não altera Combo, rig ou F5 e não equivale a movimento aprovado.
- Ajuste autorizado após rejeição da 18 em 24/10/2026: revisão localizada da ligação próxima, na mesma bancada com A antes/depois. Reparo raster da terminação do deltoide limitado por material ao ombro/axila; tronco 02 fora da região preservado. Registro uniforme do membro inteiro pelos lados do aro, curvatura local da conexão com base fixa e bíceps à frente da axila. Sem duplicar ombro, reescalar mão isoladamente, alterar distante/cabeça/rig ou F5. Candidata estática ainda em avaliação; não certifica perspectiva/articulação e não autoriza iniciar movimento antes do retorno visual.
- Retorno sobre a prova 18 em 24/10/2026: usuário rejeitou a montagem recortada. Cortes e descontinuidade do ombro persistem; não tratar preservação de pixels como integração artística resolvida. Não avançar segmentação/movimento/F5 dessa candidata. Referência 04, camadas já aprovadas e rig anterior preservados; método seguinte ainda não executado.
- Rejeição posterior da guarda 17 em 24/10/2026: a diferença artística continua grande; tentativas anteriores de registro/postura não aprovadas. Prova 18 isolada `corpo_articulado/bracos_prancha/preview.tscn` compara braços inteiros recortados nativamente da própria prancha 04 no tronco aprovado, sem mudar fontes raster/escala/desenho ou F5. É uma prova estática de origem da arte, não nova segmentação ou movimento. Preservar rig/provas anteriores; avaliar fidelidade antes de transferir animação, sem usar testes geométricos como aprovação visual.
- Nova rejeição da guarda 17 em 24/10/2026: copiar a geometria da prova 15 não resolveu a postura do conceito. Tentativa atual só no braço próximo, com cotovelo/punho manuais e registro uniforme por segmento, usando as mesmas peças; comprimentos de apresentação podem mudar, sem alterar alcance/regras ou rig aprovado. Prancha 04 como alvo padrão, prova 15 como comparação funcional via V. Ombro e braço distante ainda pendentes, sem nova aprovação visual, arte raster, animação ou F5.
- Recuperação dos braços autorizada em 24/10/2026: guarda 17 usa registro uniforme comum pelos dois ombros da prova 15, conservando giros herdados −7°/+2°, projeção distante .92 e mãos/comprimentos aceitos. Somente conexão proximal sob a pele; bíceps próximo visível por recorte nativo contíguo da mesma pintura. Prévia compara com prova 15 real pausada; V alterna conceito 04. Sem nova arte, animação ou F5. Registro/juntas conferidos por teste; integração visual ainda em avaliação e não é reprodução automática da prancha.
- Esclarecimento posterior em 24/10/2026: os dois braços já existem com segmentos/juntas e conjunto animado aceito na prova 15. Recomendação anterior de produzi-los novamente foi prematura. Antes de propor substituição artística, comparar a montagem aceita à 17 e separar efeitos dos novos encaixes/escalas/camadas das diferenças reais do desenho. Preservar peças prontas; não iniciar retrabalho nem assumir que apenas escala resolverá toda divergência.
- Retorno posterior sobre a prova 17 em 24/10/2026: usuário apontou divergência dos braços contra a prancha 04. A montagem reutiliza fontes anteriores com outros volumes/placas, não braços derivados dessa prancha; não está visualmente aprovada. Preservar conceito da prancha e tronco 02/quadril 01. Recomendar produção fiel de um braço próximo antes de segmentar/animar; a prova antiga é referência mecânica, não equivalência artística automática. Não corrigir diferenças de desenho só por escala ou atribuí-las à perspectiva. Nenhuma nova produção iniciada por esse diagnóstico.
- Correção posterior do pescoço na prova 17 (24/10/2026): relato de cabeça defeituosa/mancha sob o queixo levou a diagnóstico isolado. Preservar fonte/escala .85; usar marco `(610,140)`, aba sob a mandíbula e máscara restrita à junção, sem fragmento do ombro antigo ou alterações do rosto. Referência visual ainda em avaliação; não tratar testes de alfa como aprovação de costura, nem regenerar identidade para contornar erro de registro.
- Correção da prova 17 após screenshot/relato de cabeça grande em 24/10/2026: reduzir somente a cabeça de 1 para .85, uniformemente no mesmo marco do pescoço. Corpo/ombros/próteses/fontes preservados; proporção ainda em avaliação. Não corrigir cabeça desproporcional ampliando o corpo aceito, nem confundir testes de cobertura com aprovação visual.
- Guarda montada autorizada em 24/10/2026: prova estática `corpo_articulado/guarda_montada/preview.tscn`, cabeça do atlas e próteses reconstruídas sobre tronco 02/quadril 01. Fontes/registro corporal preservados; novas inserções/escalas em avaliação. Um deltoide humano por lado; cap próxima fica sob a pele, sem outro ombro. Ocultação/ampliação para conferir juntas antes de movimento. Sem pernas novas, novo desenho raster, clipes/pesos corporais ou migração F5. Testes amostrais não constituem aprovação artística da guarda ou continuidade em golpe.
- Aprovação posterior do tronco 02 em 24/10/2026: usuário respondeu “perfeito, melhorou”. Base estática aceita: `camadas_guarda/tronco_02.png` e `quadril_01.png`, preservando regata opaca/cobertura, volume, ombros e registro. Não equivale a guarda completa articulada ou migração F5. As notas abaixo de revisão 02 em avaliação são anteriores ao retorno.
- Camadas da guarda 01 aprovadas pelo usuário em 24/10/2026. Pedido posterior: volume discretamente maior dos seios sob a mesma regata fechada/opaca, sem ampliar decote ou tornar o figurino revelador. Revisão `camadas_guarda/tronco_02.png` na bancada estática, em avaliação; manter ombros, quadril e registro aceitos. Não altera próteses, regras, movimento ou F5. As notas de camadas ainda sem avaliação abaixo precedem essa aprovação.
- Preparação da guarda autorizada em 24/10/2026: duas camadas candidatas em `vega_animada/corpo_articulado/camadas_guarda/preview.tscn`, tronco com regiões ocultas sob os braços e quadril/roupa com sobreposição de cintura. Registro estático uniforme por pescoço/cintura e nó da camisa, ombros conferidos independentemente. Não regenera braços aprovados nem altera rig/F5. Fontes/recortes/registro ainda em avaliação; separar desenhos não constitui animação ou solução completa de volume/perspectiva.
- Aprovação posterior da prancha 04 em 24/10/2026: usuário disse “perfeito, agora sim está aprovado”. Referência visual aceita em `docs/arte_vega/vega_corpo_volume_poses_04.png`, preservando conceito corporal, distante bem recebido e ligação próxima sem cúpula metálica que duplica o deltoide humano. Não equivale a arte recortada/registrada, movimento novo validado ou migração F5. As descrições seguintes de avaliação pendente são anteriores ao retorno.
- Esclarecimento do usuário em 24/10/2026: ombro duplicado é o do **braço próximo/da frente**, não o distante, considerado “extremamente bom”. Preservar distante; no próximo manter deltoide humano e retirar a cúpula metálica que repete seu volume. Revisão visual `docs/arte_vega/vega_corpo_volume_poses_04.png` em avaliação, sem rig/F5 alterados. A revisão 03 abaixo partiu de identificação errada do lado pela assistência e não deve orientar novas correções do distante.
- Retorno da prancha corporal em 24/10/2026: usuário gostou do conceito, mas rejeitou a duplicação do ombro em um braço. Revisão visual `docs/arte_vega/vega_corpo_volume_poses_03.png` procura uma única inserção sob o deltoide humano e um único segmento superior mecânico, sem acrescentar outra cadeia após braço humano. Conceito bem recebido não valida juntas/proporções; candidata 03 em avaliação, sem alteração de rig/F5.
- Estudo corporal autorizado em 24/10/2026: prancha `docs/arte_vega/vega_corpo_volume_poses_02.png`, guarda/preparo/impacto desenhados com foco em volume de tronco/quadril. Identidade/roupa/próteses aprovadas orientam a arte, sem substituir a apresentação em uso. Preparo revisado após cotovelo alto e sequência incoerente na 01; diferença entre guarda/preparo ainda sutil e quadril limitado. Referência em avaliação, não atlas/malha registrada, anatomia aprovada ou animação pronta; sem troca F5.
- Aprovação posterior da prova 15 em 23/10/2026: usuário disse “tá funcionando bem, gostei”. Preservar tensão visual por Combo e o conjunto de movimentos já aceitos. Não equivale a integração com cartas reais/Finalização/fim de turno ou migração F5; descrições abaixo de avaliação pendente são anteriores ao retorno.
- Combo autorizado na montagem reconstruída em 23/10/2026: prova 15 `vega_animada/corpo_articulado/combo_fibras/preview.tscn`. Dez passos lineares da tensão adicional, máximo visual em 10 sem limitar o recurso. Só fibras transversais deformam; mãos, comprimentos, centros, aros e máscaras de placas rígidos. Preservar golpes/respiração/dano aceitos, zero idêntico à prova 14; transição 0,2 s reversível e reduzido imediato. Candidata em avaliação, ainda sem Combo real das cartas/Finalização/fim de turno ou migração F5.
- Aprovação posterior da prova 14 em 23/10/2026: usuário disse “boa, ficou ótimo também”. Preservar respiração em guarda e reação ao dano junto aos dois golpes/alternância já aceitos. Não equivale a Combo adaptado ou integração F5; descrições abaixo de avaliação pendente são anteriores a esse retorno.
- Respiração/dano autorizados sobre a versão 13 em 23/10/2026: `vega_animada/corpo_articulado/presenca_combate/preview.tscn`. Guarda respira discretamente sem sair da prontidão ou arrastar botas; dano dá recuo curto/feedback de cor, preserva ordem dos braços e retorna à guarda. Um AnimationPlayer, sem reescrever clipes de golpes. Reduzido sem articulação e respiro desligável para comparação. Movimento novo ainda em avaliação; sem Combo/gameplay/F5 nesta prova.
- Aprovação posterior da prova 13: usuário disse “ficou ótimo, gostei muito da nova versão”. Preservar conjunto visual, golpe próximo/distante, guarda/retorno e alternância como referência aceita. Não implica respiração/dano/Combo adaptados ou migração F5 aprovados; registros abaixo sobre avaliação pendente descrevem a entrega anterior ao retorno.
- Direto distante/alternância autorizados na montagem reconstruída em 23/10/2026: `vega_animada/corpo_articulado/golpes_alternados/preview.tscn`. Preservar golpe próximo/arte/encaixes/comprimentos; clipe distante próprio com esforço corporal e mão próxima em guarda, mesmo .56 s e captura .10 s, retorno à guarda. Alternância próximo/distante e ordem no reduzido verificadas só na prévia; margem ampliada para não cortar mão. Gesto ainda em avaliação; sem cartas/Combo/respiração/dano ou migração F5 nesta etapa.
- Retorno posterior sobre integração 12: usuário disse “muito bom”. Preservar o conjunto visual bem recebido; isso não valida golpe distante/alternância/Combo ou migração F5 da montagem reconstruída. Próximo recorte recomendado é fechar golpe distante e alternância, sem novo redesenho neste registro.
- Após baixo impacto percebido na gola, integração de tronco/próteses autorizada em 23/10/2026: prova `vega_animada/corpo_articulado/integracao_tronco/preview.tscn`, pintura mais gráfica de regata/ombros e contato aproximado do braço próximo sobre roupa. Mesma malha/pesos/movimento/mãos; manter cobertura do ombro ao trocar RGB. Rosto, parte inferior, regras e F5 preservados. A/B em corpo inteiro, S isola sombra. Relevância artística da candidata ainda em avaliação; não declarar coerência resolvida por testes de pixels.
- Aplicação localizada candidata em 23/10/2026: `vega_animada/corpo_articulado/acabamento_gola/preview.tscn`, mesma malha/UV/pesos/clipes da prova corporal aceita e pintura de pescoço/gola limitada por material local. Rosto/cabelo, próteses, parte inferior, alfa e F5 preservados. A/B compara o mesmo movimento; acabamento artístico ainda em avaliação. Pergunta pela parte inferior foi esclarecida como informativa, sem início de reconstrução de pernas.
- Acabamento artístico incremental iniciado por referência de pescoço/clavículas/gola, sem aplicação ao rig. Avaliar volume/contato de pele e tecido; não substituir rosto/próteses por detalhes regenerados do close-up. Derivação de peça/camada registrada e teste nas três poses dependem da avaliação. Prova corporal aceita e F5 preservados.
- Retorno posterior à prova corporal 10: usuário confirmou participação conjunta de peito/cabeça/quadril e gostou do resultado. Preservar essa articulação como referência aceita de movimento corporal. Não estender a arte final, guarda inteira em todos os gestos, soco distante, alternância/Combo ou migração F5.
- Prova corporal autorizada: `vega_animada/corpo_articulado/preview.tscn`, abdômen e cabeça independentes em malha contínua, guarda/preparo/impacto e ciclo .56 s; braços/mãos/material preservados, pés fixos e rebind conservando guarda. Direção do golpe compensada para o novo esforço corporal; guarda distante sobe para liberar a mão próxima. Gesto/volume ainda em avaliação. Reutiliza pintura anterior: não constitui arte híbrida final ou novas vistas/camadas. Sem alternância/Combo, mudança de regras ou F5.
- Requisito levantado em 22/10/2026: coerência da personagem inteira ao ampliar complexidade de movimentos, superando sensação de pintura corporal com membros animados. Rig deformável já existe; maior amplitude exige avaliar volume, controles/camadas corporais e vistas corretivas, sem supor que esticar uma única pintura resolva perspectiva. Construção 2D híbrida e prova inicial de tronco/quadril em três poses são recomendações ainda em discussão. Preservar identidade e braços aceitos; nenhum redesenho completo, rig novo, 3D ou migração F5 autorizado por inferência.
- Após confirmação do tamanho das mãos, usuário apontou cores distintas: manter proporções/encaixes e aproximar os cinzas da vista interna do grafite frio do braço próximo aprovado. Correção local reversível no material, sem mudar acentos saturados, transparência ou pintura corporal. Comparar na mesma pose; coerência de desenho/sombreado ainda exige avaliação. F5 e movimento distante anteriores.
- Calibração posterior da palma distante por relato de diferença de tamanho: escala uniforme 1.20 só da malha, mantendo raiz no punho/orientação e próximo aprovado. Tinta medida passa de aproximadamente 77% a 92% do comprimento próximo; diferença de projeção discreta mantida. Guarda continua candidata, sem novo movimento/F5. Densidade raster comum não garante proporção anatômica entre fontes distintas.
- Adaptação distante autorizada com cuidado explícito com coerência/juntas: prova 07 estática, vista interna e palma próprias, três segmentos da mesma pintura e inserção/projeção herdadas. Guarda candidata 135°/120°/0° (60° internos), sem deslocar mão por conta própria; preservar braço próximo aprovado. Conferir perspectiva, proporção aparente e continuidade antes de novos clipes/alternância/Combo. F5 intacto; testes de cobertura não aprovam arte nem movimento.
- Aprovação posterior do usuário da prova 06: braço próximo com ombro integrado em movimento bem recebido explicitamente. Preservar guarda, mão, proporções, junção e animação desta variante como referência. Aprovação restrita a esse lado; braço distante, Combo e migração F5 continuam fora deste resultado. Os itens seguintes registram a evolução anterior.
- Junção do ombro autorizada em prova 06 isolada: compartilhar giro com o deltoide e ajustar pesos locais da pele com compensação do filho/rebind na guarda. Trajetória da prótese, mão, proporções e timing aprovados preservados; pele e acabamento deformam juntos. Arte anterior reaproveitada neste primeiro passe, sem novo ombro humano desenhado. Comparar antes/depois na mesma fase antes de decidir retoque artístico ou adaptação do outro lado. Testes técnicos não aprovam acabamento; F5 e Combo anteriores intactos.
- Retorno posterior da prova 05: usuário relatou “tá ótimo, funcionando bem” sobre o movimento de um braço reconstruído. Preservar esta base bem recebida; não inferir adaptação do segundo lado/Combo ou migração F5. O ombro humano continua no corpo existente; cap metálica e prótese novas se articulam a partir do deltoide, sem novo desenho anatômico de ombro nesta etapa.
- Movimento do braço reconstruído autorizado após aprovação estática: variante `braco_reconstruido/preview_movimento.tscn`, respiração/soco/dano/retorno por biblioteca privada no AnimationPlayer corporal. Guarda 75°/−120°/0° e mão/raiz/proporções preservadas; dobra de preparo não fecha além da guarda. Mesmo soco .56 s/impacto .20 e apoio corporal, com interrupção/reset/reduzido. Um lado por vez; F5/estática/Combo/segundo lado anteriores. Execução técnica ainda não é aprovação artística do movimento.
- Aprovação explícita posterior do usuário: montagem estática 04 do braço próximo no corpo, guarda 75°/−120°/0° (60° internos), mão .76/reflexão e inserção atual no deltoide. Essa é a referência visual para futuras adaptações; capturas em `docs/evidencias_vega_dobra_cotovelo_04/`. Não implica aprovação da cadeia em movimento, segundo lado, Combo ou migração F5. Os registros abaixo descrevem a evolução anterior.
- Esclarecimento com screenshot: folga necessária é entre antebraço e bíceps. Ajuste anterior afastava do peito mas agravava sobreposição; superado por candidata estática 75°/−120°/0°, com 60° internos em vez de 27°. Preservar mão/raiz/arte/proporções, permitir reposicionar guarda para abrir a dobra e verificar interseção da pintura fora da junta. Cobertura opaca/coincidência de centros não substituem essa verificação. Prova F6 ainda em avaliação, F5 intacto.
- Folga corporal posterior: após melhora da mão e ressalva de braço colado ao peito, candidata estática passa a ombro 103°/cotovelo −153°/punho 0°. Compensação +8°/−8° afasta cotovelo/mão mantendo inclinação do antebraço, raiz e proporções. Não confundir folga do peito com maior abertura entre os segmentos. Mão .76/reflexão e F5 preservados; aguarda avaliação artística.
- Correção posterior da candidata corporal por relato de mão grande/invertida: reduzir apenas a malha da mão a .76 e refletir seu eixo transversal pelo centro do punho, sem inverter avanço dos dedos ou alterar ossos/guarda/alcance. A vista continua dorsal; não tratar reflexão como giro 3D ou conversão para palma. Ajuste restrito à prova F6, ainda a avaliar; fonte e montagem isolada originais preservadas.
- Encaixe corporal autorizado após esse retorno: `braco_reconstruido/preview_corpo.tscn` prende um braço ao deltoide existente e oculta o anterior, mantendo fonte/comprimentos/pele e lado distante. Guarda local candidata 95°/−145°/0° sobre corpo estático; não substitui guarda/clipes das provas anteriores ou F5. Avaliar posição junto ao rosto e continuidade das juntas antes de adaptar animação/Combo/segundo lado. Nenhuma nova aprovação artística ou integração de combate inferida.
- Retorno sobre a reconstrução 01: usuário considerou o braço ótimo, mas a guarda esquisita. Preservar a direção da arte, sem inferir aprovação da postura. Próxima avaliação deve relacionar cotovelo/punho ao corpo e rosto; não basta reaproveitar ângulos da montagem anterior ou conferir centros coincidentes. Nenhuma nova guarda ou integração aprovada por esse retorno.
- Após rejeição da montagem de juntas/placas, reconstrução de um braço autorizada em 22/10/2026: prova estática `vega_animada/braco_reconstruido/preview.tscn`, com três segmentos de uma única pintura montada e marcos de ombro/cotovelo/punho compartilhados. Placas pertencem à superfície, não são peças posicionadas separadamente. Preservar comprimentos e movimento aprovados; avaliar guarda/extensão antes de inserir no corpo, animar ou derivar o segundo lado. Arte nova ainda candidata, sem migração de F5, alteração de Combo ou aprovação anatômica por testes de coordenadas.
- Passe artístico autorizado em 22/10/2026: avaliar Vega inteira em guarda como uma ilustração coerente, com luz/contorno/sombras e transições de ombro compartilhados por corpo/próteses/mãos. Preservar identidade, roupa, conceito de fibras/placas e base funcional; validar estático no tamanho real antes de derivar para o rig. Candidata 01 em `docs/arte_vega/vega_guarda_unificada_01.png` recebeu retorno “parece ótima” e passa a ser referência estática aprovada, ainda não aplicada. Figura inteira de referência não substitui peças articuladas nem prova compatibilidade de âncoras ou movimento.
- Derivação incremental autorizada: `rig_nativo_v2/acabamento_proximo/preview.tscn` avalia atlas/acabamento de ombro e braço próximo sobre o rig preservado, com mesma geometria/Combo/poses. Pintura local segue pesos da pele e não amplia seu contorno. Restante e personagem ativo ficam anteriores até avaliação dessa variante; não representa unificação completa ou nova aprovação artística.
- Revisão dessa variante em 22/10/2026: vista interna própria no braço distante e punhos dorso/palma derivados juntos, mantendo modelo/escala/acabamento e soquetes. Folga da guarda por abertura de 23° do cotovelo distante, aplicada também ao preparo/retorno e reduzido/reset; comprimentos, impacto, tempos e regras preservados. Não resolver superfície interna espelhando todo o rig novamente. F5 continua anterior e nova leitura aguarda avaliação artística; a vista pintada fixa não simula rotação longitudinal 3D.
- Retorno posterior: pose da variante aprovada pelo usuário após correção do polegar. Preservá-la durante correções de corte do atlas/nitidez; margem de recorte não deve alongar ossos nem deslocar pintura interior, e suavização da personagem não deve desfocar a HUD. Aceitação da pose não representa conclusão artística de todas as peças ou animações.
- Retorno seguinte: movimentação da variante aprovada, com ressalvas das uniões dos punhos. Preservar clipes/rig/proporções e corrigir encaixes na apresentação/sobreposição das peças. Aros devem parecer ocupados por conectores, sem cavidade aberta ou separação visível; preenchimento não deve crescer com Combo ou alterar alcance. Ainda depende de avaliação artística do ajuste, sem aprovação de rotação/perspectiva 3D.
- Vega v2 (21/10/2026): referência 04 e prova isolada de um braço em `vega_animada/braco_v2/preview.tscn` aprovadas pelo usuário: musculatura artificial expande, placas permanecem rígidas, mão/juntas não crescem. A aprovação não equivale a rig completo ou integração à apresentação ativa. Transformação não controla regras ou tempo de resolução; deve ser reversível e oferecer movimento reduzido. Cânone narrativo e Combo/Finalização permanecem intactos.
- Sugestão posterior do usuário: braços responderem aos stacks de Combo. Hipótese implementada apenas na prévia isolada para avaliação: volume básico de combate mais contração/tensão dos feixes com amplitude visual limitada; consumo/zeragem retornam à base de combate, não ao repouso fora de combate. Combo continua sem teto mecânico; a deformação não cresce indefinidamente com o contador. Flexão do cotovelo depende de validação própria de articulação. Parâmetros candidatos estão no README da prova e não fixam balanceamento nem representam integração ao estado real do jogo.
- Revisão linear aprovada pelo usuário na prova: cada carga corresponde a 10 pontos percentuais da tensão visual adicional; 10 Combo ou mais mantém o máximo visual, sem limitar o recurso. A relação linear substitui a curva assintótica inicial; não altera a expansão básica de combate nem determina aumento percentual do braço inteiro. Integrada aos dois braços do personagem ativo em 21/10/2026; ganho/consumo acompanham o estado real, sem atrasar resolução.
- Montagem corporal v2: usuário aprovou o conjunto com ressalva dos soquetes; âncoras corrigidas na prévia `vega_animada/corpo_v2/preview.tscn`, ainda a conferir pelo usuário. Combina um corpo-base derivado da referência 04 com duas instâncias do braço aprovado, uma espelhada, em postura neutra. É prova de encaixes/proporções, sem rig corporal articulado ou flexão/soco. Não substituir automaticamente o personagem ativo nem tratar o segundo braço reaproveitado como perspectiva final em poses novas.
- Referência estática `docs/arte_vega/vega_v2_soco_poses_02.png` considerada boa pelo usuário, que pediu integração. Cena ativa `vega_animada/combate_v2/vega_combate.tscn` substitui o PNG industrial: guarda, preparo/extensão/retorno, reação ao dano e Combo real. A animação produzida ainda depende de avaliação visual; não reproduz a prancha quadro a quadro. Articulação 2D com comprimentos projetados constantes e pés fixos; punho/segundo braço reaproveitados e tronco sem rotação 3D são limitações. Todos os ataques usam provisoriamente o mesmo soco. Movimento reduzido, interrupção e reset preservados; nenhuma regra aguarda o movimento. Retrato/cartas ainda não migrados.
- Revisão após rejeição visual dos braços curtos/guarda permanente: preservar comprimento do braço superior, proporção com o antebraço e alcance legível em extensão. Repouso entre ações tem braços baixos; prontidão/guarda pertence ao preparo e à reação, depois relaxa. Volume de combate e tensão por Combo são independentes da postura: Combo acumulado não prende punhos junto ao rosto. Calibração atual e evidências no README de `combate_v2`, ainda em avaliação artística.
- Rejeição posterior da calibração longa: mãos não devem parecer miniaturas nem terminar perto dos joelhos no repouso. Calibrar membros e mãos em conjunto, com punhos junto da parte superior das coxas e tamanho legível em relação ao antebraço. Alcance deriva dessa proporção, não de uma distância absoluta que obrigue alongar os membros. Parâmetros atuais continuam candidatos, não aprovação anatômica/artística.
- Experimento autorizado de rig nativo: `vega_animada/rig_nativo_v2/preview.tscn`, um braço com Skeleton2D/Bone2D, poses-chave editáveis no AnimationPlayer e comprimentos fixos, sem IK. Contexto corporal, zoom e inspeção manual servem à avaliação de conectores/silhueta; prova não substitui personagem ativo ou integra Combo. Arte reaproveitada ainda limita perspectiva das juntas. Só depois da avaliação decidir adaptação de peças e migração, preservando expansão e regras aprovadas.
- Avaliação posterior: usuário aprovou a melhora da prova nativa, com ressalva do ombro rígido. Manter a direção; próximo recorte proposto é vincular ombro humano/tronco ao movimento, pois a pele permanece no corpo estático. Aprovação da prova não autoriza promover o soco a animação final ou migrar automaticamente o personagem ativo.
- Ligação corporal autorizada e implementada em `rig_nativo_v2/preview_ombro.tscn`: pele ponderada por ossos nativos de pelve/tronco/clavícula/deltoide, braço aprovado instanciado no encaixe e um AnimationPlayer para o conjunto. Pernas/pés fixos e comprimentos/mão preservados, sem IK ou nova arte raster. Usuário relatou melhora funcional após a entrega. Ainda é prova isolada, sem segundo braço/Combo/integração; não é aprovação da animação final. Prévia anterior preservada para comparação.
- Segunda prótese autorizada e montada em outra prova isolada, `rig_nativo_v2/preview_dois_bracos.tscn`: pele ligada aos dois ombros, primeiro braço preservado e distante em guarda própria enquanto o outro golpeia. Profundidade por sobreposição, tonalidade e projeção espelhada uniforme fixa, não por alongamento animado. Peças reaproveitadas ainda limitam perspectiva; resultado aguarda avaliação artística. Repouso com braços baixos, pés fixos, interrupção e movimento reduzido preservados. Não inclui Combo nem troca do personagem ativo.
- Ajuste posterior de junções nessa prévia: variante visual `braco_encaixado.tscn` fecha as aberturas com fibra existente e assenta a mão no cuff, mantendo dimensões, ossos, poses e tempos. Continuidade visual dos recortes precisa ser verificada além da coincidência das âncoras. Não representa nova aprovação anatômica ou migração ao combate.
- Orientação da luva distante compensada separadamente em `braco_distante.tscn`, refletindo seu lado transversal em torno do cuff sem inverter o avanço dos dedos ou mudar a mão próxima. Tamanho, encaixes e movimento preservados. Usuário aprovou essa correção visual; não implica aprovação final de toda a animação ou migração ao combate.
- Combo no rig nativo em prova separada `rig_nativo_v2/preview_combo.tscn`: dez passos lineares da tensão adicional, mantendo ossos, mãos, juntas e placas rígidos. Volume só transversal das fibras, preso nos extremos e junto à placa superior; limites de 0.18/0.14 reutilizados da prova original. Preservar proporção/alcance e orientação aprovada. Ainda não integra estado real do combate nem substitui personagem ativo; usuário avaliará risco de desproporção.
- Participação inferior em `rig_nativo_v2/preview_apoio.tscn`: quadril e joelhos acompanham preparo/impacto/recuperação com deslocamento limitado, enquanto botas/solas permanecem fixas. Nesta variante a pelve deixa de ser fixa; provas anteriores ficam preservadas. Combo não controla o balanço corporal. Braços/mãos mantêm proporções e encaixes, acompanhando a translação do corpo. Ainda é prova isolada de apoio por pesos nativos, não locomoção ou anatomia 3D validada.
- Estado posterior em 21/10/2026: após retorno positivo do apoio e pedido de continuação, `rig_nativo_v2/vega_combate.tscn` passa a ser a apresentação padrão do combate, preservando as prévias/cena antiga. Mesmo rig, contração por Combo real e botas fixas; acrescenta respiração localizada e reação curta ao dano. Interrupções capturam a pose atual, reduzido evita articulação ampla e nenhuma regra aguarda animação. Composição transparente isola camadas internas da HUD. Integração em avaliação no jogo, não aprovação artística final; retrato/cartas ainda não migrados.
- Refinamento em 22/10/2026 após ressalva do usuário: repouso menos dobrado, punhos para baixo e mão distante legível fora da coxa; mesmos ângulos no retorno, reset e reduzido, sem mudar preparo/impacto/guarda, tamanho ou encaixes. Material seletivo aproxima os claros neutros das mãos do grafite das próteses, mantendo acentos saturados. Não substitui redesenho de perspectiva/traço nem equivale a aprovação artística do ajuste.
- Direção vigente após rejeição explícita desse refinamento em 22/10/2026: Vega permanece em **guarda de luta entre ações**, com respiração discreta de tronco/ombros/mãos e apoio fixo; não fica com os dois braços baixos. Substitui as descrições anteriores de relaxamento na espera. Guarda independe do Combo, soco/dano retornam para ela e reduzido mantém a mesma postura sem ciclo corporal. “Repouso” nos nomes internos passa a significar espera em guarda; não extensão de ataque congelada. Implementação reaproveita guarda nativa sem alterar proporções ou clipes intermediários; respiro e leitura aguardam avaliação manual.
- Continuação pedida em 22/10/2026: mão do fundo mostra vista palmar própria, não o dorso duplicado. Ataques válidos alternam braço próximo/distante, outro braço permanece em guarda; defesa/inválida não avançam sequência, nem dano recebido. Reinício/mapa reiniciam a ordem. Mesmo ciclo/apoio e captura interruptível, sem fila ou atraso na resolução; reduzido conserva ordem sem articular. Substitui o soco único provisório dos registros anteriores. Vista palmar fixa acompanha o osso, não representa giro 3D; nova arte/segundo golpe aguardam avaliação artística.

- Combatentes compartilham perspectiva, plano de chão, sombras de contato e iluminação com o cenário.
- A composição neon aprovada é preservada durante o polimento. Foco e hover seguem o recorte das peças, sem destacar caixas de layout. Tooltips usam a mesma linguagem visual da HUD e evitam cobrir textos e ilustrações das cartas vizinhas. A Energia precisa de contraste estável mesmo sobre o núcleo luminoso.
- Cais, pátio de contêineres e estação de bombeamento são arenas do mesmo distrito. A apresentação pode variar por encontro sem consumir o sorteio da run. Vega respira apoiada nos pés; o drone usa suspensão motorizada com sombra no piso. Movimento do desenho não desloca as caixas de clique nem suas placas de informação.
- A HUD de combate usa os módulos ilustrados do conceito em `assets/ui/references/` como linguagem principal: retratos, medidores, Energia e cais de cartas pertencem à mesma família de formas, luz e materiais. Molduras provisórias podem existir nos arquivos históricos, mas não devem reaparecer como camada visual ativa por baixo da composição vigente.
- A arte das cartas de Vega deve reconhecer seus braços protéticos e o mundo das Docas; cada efeito continua legível pelo texto e pelos valores, sem depender apenas da cor ou da ilustração.
- Direção gráfica estabelecida em Golpe/Proteção (21/10/2026): ações, equipamentos e consequências em enquadramentos fechados, com contornos de tinta, sombras recortadas e cores chapadas. Não é necessário desenhar a personagem inteira em cada carta. A composição da HUD permanece preservada.
- Golpe aprovado e aplicado (21/10/2026): enquadrar somente punho/pulso mecânico atingindo uma chapa, sem personagem completa. A identidade pode vir dos equipamentos e a carta pode representar uma ação por detalhes. Impacto físico localizado, sem eletricidade ou despedaçamento; nenhuma mudança do efeito mecânico. A arte aprovada pertence somente a Golpe, não aos outros ataques que compartilhavam seu recurso anterior.
- Proteção aprovada e aplicada (21/10/2026): antebraço blindado interceptando uma pancada, sem personagem completa ou escudo de energia. A imagem representa defesa, não acrescenta aparar/refletir dano; os 5 de Barreira permanecem. Pulso Debilitante e Placa Reforçada não herdam essa arte.
- Quebra-chassi integrado ao concluir o catálogo (21/10/2026): carcaça rompida e estrutura partida mostram a consequência de um impacto pesado, distinguindo a finalização do amassado simples de Golpe. A ilustração não garante morte ou remoção de Barreira.
- O usuário autorizou concluir as nove artes do catálogo atual na linguagem estabelecida. Cada ID possui ilustração exclusiva, usada também nas recompensas e no descanso; cópias aprimoradas preservam a arte base. Direto destaca a hidráulica; Brecha, a junta exposta; Pulso, ondas gráficas; Aríete, o impacto pesado; Ruptura, a conexão vazando; Placa, a blindagem em camadas. Essas leituras visuais não mudam as regras existentes. Avaliação artística final continua dependendo do playtest.
- O cais ocupa apenas a coluna central: Energia/pilhas/medidores à esquerda e Encerrar turno à direita têm espaço reservado, inclusive durante o foco das cartas das pontas. Mãos maiores podem sobrepor cartas com faixas acessíveis, sem intercalar letras e molduras de cartas diferentes. Títulos, números e descrições usam a mesma família condensada com pesos por função.
- A intenção reúne tipo, ícone e valor no selo da placa inimiga. Estados e efeitos especiais pertencem à mesma placa; nomes completos e condições extensas permanecem inspecionáveis. Relíquias ficam nos encaixes de Vega, identificadas por ícone/nome curto e descrição completa por mouse ou teclado. Inspeções devem buscar espaço livre entre informações importantes.
- Efeitos importantes de combate ficam próximos da ação, das cartas e das intenções. A leitura dos números tem prioridade sobre a animação ornamental.
- O topo direito reúne Baralho, Rota e Configurações; a placa inimiga fica abaixo, junto da representação do alvo. Coração e trilho de Vida de Vega são uma única leitura visual. Rótulos e valores pertencem aos encaixes da arte, sem flutuar sobre medidores ou cartas. Preenchimentos animam sem atrasar os números reais. Deve existir alternativa de movimento reduzido.
- A peça de Vida fica acima das relíquias, com o preenchimento proporcional percorrendo todo o intervalo útil. Dano pode deixar um rastro visual breve; recuperação substitui esse rastro. Atualizar a HUD com a mesma Vida não reinicia a transição, e o número continua mostrando o estado real imediatamente.
- Barreira usa escudo e número, com explicação por hover/foco; COMBO fica junto do contador. O preenchimento acompanha as células e segmentos da moldura. Ganho, consumo de Combo e quebra de Barreira têm feedbacks distintos, breves e locais. A capacidade desenhada não estabelece teto para os recursos; o número mostra o valor exato.
- A seleção mantém a carta legível na mão e usa uma seta até o alvo apontado pelo mouse ou focado pelo teclado. O alvo válido recebe retículo; alvo inválido ou Energia insuficiente não recebe confirmação visual. Esc ou botão direito cancelam sem custo. Ao jogar, a carta recolhe no cais, sem viajar até o inimigo; custo, dano e feedback resolvem no clique.
- Interações de fundo são curtas e pontuais: uma descarga faz um anúncio oscilar; habitantes se afastam de uma janela; vapor se move após um impacto. Esses acontecimentos reforçam o cenário sem alterar regras escondidas.
- As animações não controlam o estado do combate nem criam janelas de reflexo. O jogador pode inspecionar a situação antes de confirmar a próxima carta.
- Criaturas precisam de silhuetas, poses e intenções distintas. Sua origem no distrito orienta o comportamento e os efeitos visuais.
- Rastros digitais ou simulações podem existir. O conceito de consciência fragmentada, alterada ou substituída não faz parte da premissa confirmada para os protagonistas.

## 11. Ordem de validação

1. Exercitar a base comum: cartas, alvos, Energia, compra, descarte, Barreira e intenções.
2. Validar um combate de Vega com encadeamento, ganho de Combo e Finalização.
3. Na expansão, incorporar Luvto e Cais para verificar se as três identidades produzem decisões diferentes sob as mesmas regras.
4. Completar uma run de quatro combates para cada personagem e medir duração, clareza das derrotas e frequência de combinações interessantes.
5. Ajustar números e distribuição de recompensas antes de ampliar o catálogo de conteúdo.

O escopo da primeira entrega é um personagem e um distrito completos: Vega e as Docas. Luvto, Cais e seus distritos permanecem planejados para a expansão.

Critérios de revisão: o jogador entende o que as intenções vão causar; reconhece sua mecânica no primeiro combate; uma recompensa muda alguma decisão; consegue identificar oportunidades de defesa, ataque e preparação; encontra inimigos que exigem respostas diferentes; e sente vontade de experimentar outra combinação. O objetivo de dez minutos precisa ser medido sem retirar o tempo de reflexão do jogador.

## 12. Registro desta revisão

O usuário definiu os tipos Ataque, Habilidade e Aprimoramento. Decisões posteriores confirmaram Vega como humana com braços protéticos, Luvto como o personagem furtivo que substitui Nula e Vega/Docas como foco da primeira entrega. A proposta anterior de Carga e Eco foi substituída por Combo/Finalização e Ocultação/Emboscada. Os valores de 4 Energias e 6 cartas por turno continuam experimentais. Cais mantém sua identidade de montagem de dispositivos para a expansão.

## 13. Forma de trabalho definida pelo usuário

O usuário quer aprender como o jogo é construído e compreender o código que será mantido. O desenvolvimento deve acontecer em incrementos pequenos, com explicação do objetivo, implementação acompanhada, verificação do comportamento e uma pequena alteração feita pelo próprio usuário. Antes de ampliar um sistema, ele deve conseguir explicar onde seu estado vive, qual ação o modifica e como observar o resultado.

Uma trilha pedagógica de construção pode começar por uma carta visível e um alvo, avançar para dano e Energia, depois para turnos e pilhas de cartas, e só então integrar Combo, Aprimoramentos, relíquias e uma run. A engine e a linguagem serão propostas ao usuário antes de configurar o projeto. A escolha técnica ainda não é uma decisão confirmada neste documento.

## 14. Limites deste documento

Este é um documento de direção e proposta mecânica. Não escolhe engine, arquitetura de código, arte final, monetização, catálogo completo de cartas, bestiário completo ou condições finais de cada desfecho. As próximas decisões de design podem modificar esta versão antes de um plano de implementação.
