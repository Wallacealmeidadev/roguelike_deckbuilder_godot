# Roguelike cyberpunk — direção e regras v0.2

**Revisão em andamento — 23/09/2026.** Este documento reúne direção confirmada e mecânicas propostas para o combate. `DECISOES.md` e `PERSONAGENS.md` prevalecem em mudanças posteriores de cânone; código e `STATUS.md` registram o que está implementado. Valores e regras sem confirmação explícita continuam sendo hipóteses de teste. O título definitivo permanece fora deste recorte.

## 1. Direção confirmada

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

**Combo:** contador de 0 a 5, exclusivo de Vega. Cada carta de Ataque sem Finalização que ela joga concede 1 Combo depois de resolver seus efeitos. Uma carta com vários golpes concede apenas 1 Combo. Habilidades e Aprimoramentos preservam a sequência. Combo zera no encerramento do turno do jogador, depois dos efeitos de fim de turno, e no fim do combate. O excesso acima de 5 é perdido.

**Finalização:** palavra-chave de cartas de Ataque que consomem todo o Combo na confirmação para produzir o bônus escrito. Não geram Combo. A previsão usa o valor que será consumido, e o custo só é cobrado depois de validar o alvo. Podem funcionar com Combo zero, usando seu valor básico.

| Carta inicial exclusiva | Cópias | Tipo e custo | Efeito |
| --- | --- | --- | --- |
| Direto hidráulico | 2 | Ataque, 1 Energia | Causar 4 de dano; ganhar 2 de Barreira. Como Ataque sem Finalização, concede 1 Combo depois de resolver. |
| Quebra-chassi | 2 | Ataque, 1 Energia | Finalização. Causar 5 + 3 por ponto de Combo consumido de dano em um golpe. |

Golpe também gera Combo quando jogado por Vega. Cartas de Ataque jogadas por outros personagens não geram esse recurso.

**Relíquia inicial — Juntas de retorno:** na primeira vez que atingir pelo menos 2 Combo em cada turno do jogador, ganhar 3 de Barreira. Consumir o Combo e chegar novamente a 2 no mesmo turno não reativa a relíquia.

**Aprimoramento de referência — Ritmo de combate:** custa 1 Energia. Sempre que ganhar efetivamente 1 Combo, ganhar 1 de Barreira. Um Ataque realizado com Combo já no máximo não gera essa Barreira. Consumir Combo não é ganhá-lo.

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

Começando com zero Combo e 4 Energias, sem outros modificadores: Direto hidráulico causa 4 e gera 2 de Barreira, deixando Combo 1; Golpe causa 6 e chega a Combo 2, ativando Juntas de retorno para ganhar 3 de Barreira; outro Direto hidráulico causa 4 e gera 2 de Barreira, chegando a Combo 3; Quebra-chassi consome os 3 pontos e causa 14.

A sequência gasta 4 Energias, causa 28 de dano e gera 7 de Barreira, terminando com Combo zero. Requer um alvo vivo para cada jogada e as cartas necessárias na mão. Com Ritmo de combate previamente instalado, os três ganhos de Combo acrescentam 3 de Barreira, totalizando 10. Instalar o Aprimoramento nesse mesmo turno exigiria Energia adicional ou outra sequência.

### Luvto escolhe entre ofensiva e proteção

Camuflar custa 1 Energia e gera Ocultação e 3 de Barreira.

- Jogar Ponto cego em seguida custa mais 1 Energia, consome Ocultação, causa 10 de dano ignorando Barreira e ativa a compra da relíquia inicial na primeira Emboscada do turno. O personagem fica exposto ao ataque inimigo, mantendo apenas sua Barreira.
- Guardar Ocultação contra um golpe anunciado de 12 reduz esse golpe a 6. A Barreira de 3 absorve metade do restante, deixando passar 3 de dano à Vida. Ocultação é consumida na defesa e não está disponível para uma Emboscada no próximo turno, a menos que seja reaplicada.

Se o inimigo anunciar um efeito sem Ataque e nenhuma outra fonte consumir o estado, Ocultação permanece para o próximo turno. A decisão não depende de sorte.

### Cais prepara dano recorrente

Desmontar gera 2 Sucatas e causa 3 de dano. Montar sentinela consome essas Sucatas e 1 Energia, ocupa um espaço e ativa a relíquia inicial, gerando 2 de Barreira. No fim desse mesmo turno, a Sentinela causa 3 de dano. Nos próximos turnos, continua funcionando sem pagar novamente pela montagem.

## 8. Run curta proposta

**Meta: seis a dez minutos após familiaridade com as regras, sem cronômetro obrigatório.** É uma hipótese de ritmo a medir em partidas; primeiras leituras e decisões podem durar mais.

| Etapa | Conteúdo | Recompensa ou decisão |
| --- | --- | --- |
| 1 | Combate comum de abertura | Escolher 1 entre 3 cartas sorteadas, com pelo menos 1 Aprimoramento na oferta. É permitido pular. |
| 2 | Evento do distrito | Escolher uma relíquia dentre duas ofertas compatíveis com o personagem, ou reparar 4 de Vida. |
| 3 | Segundo combate comum, com escolha de rota | Escolher 1 entre 3 cartas sorteadas, ou pular. |
| 4 | Confronto de elite | Escolher 1 entre 3 cartas sorteadas, ou pular; depois escolher 1 entre 2 relíquias. |
| 5 | Evento anterior ao alvo | Melhorar uma carta ou reparar 8 de Vida. A narrativa pode registrar um compromisso de rota. |
| 6 | Chefe ligado ao acesso ao golpe | Resolver o resultado da incursão e os gatilhos narrativos disponíveis. |

Essa estrutura oferece quatro combates, duas decisões de evento e oportunidades para a build ganhar novas regras antes do chefe. A relíquia inicial já está ativa desde o primeiro combate. Com as três recompensas de cartas aceitas, o baralho termina com 13 cartas.

Nota de implementação do protótipo: o pool atual de recompensas contém as seis cartas já disponíveis (`Golpe`, `Proteção`, `Direto hidráulico`, `Quebra-chassi`, `Brecha` e `Pulso debilitante`). Ele já sorteia três opções distintas e permite pular; a garantia de um Aprimoramento na oferta depende da futura entrada dessas cartas no pool.

Os eventos da tabela são estruturas mecânicas de referência; sua apresentação deve pertencer ao distrito e às facções. Escolhas que abrem finais precisam mostrar pistas e consequências. A presença aleatória de uma sequência de eventos raros não deve ser a única forma de perseguir um final já descoberto.

As rotas podem combinar dois distritos por incursão. A variedade do jogo vem de diferentes caminhos, inimigos, eventos, personagens e combinações ao longo de várias runs. Não é necessário visitar todos os bairros numa única partida.

**Orçamento inicial de tempo:** dois combates comuns de 40–60 segundos cada; elite de 60–90 segundos; chefe de 90–120 segundos; recompensas e eventos de 90–150 segundos; seleção e transições de 30–60 segundos. Total estimado de 5min50s a 9min. Esses intervalos são metas de produção, não resultados medidos.

Não há loja ou moeda de compras no recorte v0.2: os eventos oferecem trocas e recompensas diretas. Uma economia de lojas exige uma decisão separada sobre seu espaço no ritmo curto.

## 9. Continuidade e progressão

Ao fim de um combate, preservar Vida, baralho da run, melhorias e relíquias. Zerar estados de combate, Aprimoramentos instalados, Barreira, Energia, Combo, Ocultação, Sucata e dispositivos. Recuperar as cartas Esgotadas e de Aprimoramento para o próximo combate.

O primeiro protótipo desse fluxo usa dois combates e uma escolha obrigatória entre Golpe, Proteção e Quebra-chassi. A opção de pular recompensa continua prevista para a estrutura completa, mas entra somente depois da validação dessa transição básica.

Ao fim de uma run, preservar personagens desbloqueados, registros de descobertas e finais alcançados. Reiniciar baralho, melhorias e relíquias daquela tentativa, exceto o equipamento inicial próprio de cada personagem.

A primeira entrega prevê Vega como personagem implementada e as Docas como distrito inicial. Luvto e Cais pertencem à expansão; quando suas mecânicas forem incorporadas ao protótipo, a seleção direta poderá ser usada para comparação sem bloquear testes por progressão.

O mecanismo de retorno preserva a consciência do personagem. Transformações físicas não justificam apagar sua personalidade a cada run. A definição completa dos finais e de quais consequências alteram o estado da cidade pertence ao próximo recorte narrativo; nenhuma regra de combate depende desse detalhamento.

## 10. Direção do combate em 2D

- Combatentes compartilham perspectiva, plano de chão, sombras de contato e iluminação com o cenário.
- Efeitos importantes de combate ficam próximos da ação, das cartas e das intenções. A leitura dos números tem prioridade sobre a animação ornamental.
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
