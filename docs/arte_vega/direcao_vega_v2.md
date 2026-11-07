# Vega — proposta de direção visual v2

Prova mais recente (21/10/2026): usuário autorizou validar três poses estáticas antes de animar o soco, após manifestar preocupação com anatomia. `vega_v2_soco_poses_02.png` revisa a preparação da primeira prancha, buscando cotovelo baixo e preparo curto. É candidata em avaliação, sem rig/interpolação ou substituição de assets; câmera, identidade e volume foram tratados como invariantes. Processo, limitações e prompts em `vega_v2_soco_poses.md`.

Atualização mais recente (21/10/2026): usuário aprovou também a resposta linear ao Combo, com máximo visual em 10 cargas. Nova montagem corporal isolada em `vega_animada/corpo_v2/preview.tscn` usa corpo-base transparente derivado da referência 04 e braços aprovados reutilizados, um espelhado. Postura neutra, encaixes e perspectiva dessa montagem ainda dependem de avaliação. Não há soco/flexão de cotovelo nem substituição do personagem ativo. Documentação e prompt no README da montagem. As notas de avaliação pendente abaixo são histórico das etapas anteriores.

21/10/2026. Proposta para discussão, não aparência final aprovada. Autoridade narrativa: `docs/PERSONAGENS.md`; mecânicas: `docs/GAME_DESIGN.md`. Nenhum asset ou comportamento de combate foi substituído nesta etapa.

Referência candidata gerada após o pedido de mais identidade própria e menos semelhança à Vi: `vega_v2_referencia_01.png`. Processo, hipóteses e prompt em `vega_v2_referencia_01.md`. A imagem ainda aguarda avaliação e não substitui o cânone ou os assets ativos.

Avaliação parcial posterior: o usuário aprovou os braços da referência 01 e pediu expressão menos alegre/carismática e mais rabugenta/protetora. A revisão `vega_v2_referencia_02.png` trabalha somente a expressão das duas aparições do rosto, preservando o desenho dos braços; prompt e limites no documento homônimo. A nova expressão ainda aguarda avaliação. A aprovação dos braços não é aprovação automática de todo o restante da aparência ou de um rig.

Avaliação seguinte: expressão da referência 02 aprovada; somente cabelo ficou pendente. O usuário escolheu explorar um corte mais longo. `vega_v2_referencia_03.png` propõe comprimento até o queixo/início do pescoço, preservando rosto, expressão, roupa, pose e braços. O corte novo ainda aguarda avaliação. As anotações anteriores são histórico, não autorização para voltar à expressão sorridente ou redesenhar as próteses.

Estado mais recente: o usuário aprovou também o figurino da referência 04, com regata/calça simples e camisa vinho na cintura, e depois aprovou a prova animada isolada `vega_animada/braco_v2/preview.tscn`, com expansão reversível dos feixes e placas rígidas. Cabelo, identidade, expressão e braços permanecem estabilizados. Ressaltou cuidado com quebras e sugeriu flexionar conforme stacks de Combo; autorizou continuar. Essa extensão agora existe apenas na prévia, como tensão limitada dos feixes separada da ativação básica de combate, e ainda aguarda avaliação. Não há flexão do cotovelo nem mudança de asset ativo. A aprovação da base não equivale a rig completo ou aprovação automática da extensão. Processo, prompt e limites no README da prova. As hipóteses abaixo são histórico, não autorização para reabrir o que já foi aprovado.

## Problema observado

As artes recentes das cartas herdaram o equipamento da Vega provisória: metal claro gasto, rebites, faixas amarelas e mecanismos de carga expostos. O conjunto passou a ter uma identidade industrial que o usuário apontou como incompatível com as molduras neon. A personagem provisória não pode continuar sendo a referência final de materiais, proporções e paleta.

## O que permanece confirmado

Vega tem 27 anos, é humana, tem o restante do corpo normal, cabelo curto e braços protéticos que ficam extremamente musculosos em combate. É briguenta e protege os mais vulneráveis. Trabalhou nas docas; perdeu os braços durante o resgate de um colega. Os braços foram adaptados de equipamentos de carga com ajuda desse colega. Preservar sua humanidade e sua relação com trabalho, abandono e proteção. Não inventar uma origem militar/corporativa de elite nem transformar o restante do corpo em armadura robótica.

## Hipótese visual recomendada

Uma brigona de rua com tecnologia de carga reaproveitada e personalizada. A origem portuária aparece no peso, nos apoios e na engenharia das próteses; a linguagem de desenho aproxima a personagem da HUD sem cobri-la de luzes.

- **Silhueta:** corpo humano ágil, postura firme de luta e braços muito mais volumosos que o tronco. Os braços devem parecer musculatura mecânica capaz de contrair e expandir, não dois blocos de escavadeira presos aos ombros.
- **Próteses:** feixes de atuadores em volumes de bíceps/antebraço, protegidos por poucas placas articuladas de grafite e cerâmica escura. Juntas claras na anatomia e punhos simples de reconhecer e repetir. Engenharia visível apenas nos pontos que explicam o movimento; evitar inventar mecanismos diferentes em cada desenho.
- **Cor:** grafite, preto azulado e pele como massas principais. Ciano em encaixes/indicadores pequenos e magenta em um acento pessoal. As duas cores ligam a personagem à linguagem da HUD sem exigir que todos os materiais tenham ambas. Metal claro, ferrugem e faixas de segurança deixam de dominar.
- **Roupa:** roupa de rua funcional, assimétrica e de formas simples, permitindo ler o corpo humano e as próteses. Evitar armadura integral, uniforme corporativo e coleção de acessórios. Desgaste localizado e reparos podem dar história sem virar textura por toda a figura.
- **Rosto/cabelo:** cabelo curto assimétrico, expressão direta e desafiadora. A identidade do rosto deve funcionar no retrato pequeno; corte exato, cor da mecha e acessórios ainda são escolhas em aberto, não heranças obrigatórias do placeholder.
- **Tratamento HQ:** contornos com peso, sombras pretas recortadas, poucas camadas de cor e luz desenhada por formas. Evitar renderização metálica realista, brilho difuso e partículas como substitutos de desenho.

Esses materiais, formas e acentos são propostas, não alterações confirmadas do cânone. A luz dos indicadores não introduz dano elétrico ou outra mecânica. O estado de combate precisa mostrar como os volumes dos braços se expandem, mantendo os mesmos componentes e a mesma personagem.

## Antes de refazer cartas

Validar uma referência mestre da personagem: silhueta/corpo inteiro, rosto e o mesmo braço em repouso/combate. Mostrar o conceito junto de um trecho da HUD para avaliar contorno, materiais, contraste e cor no contexto real. A moldura orienta a família visual, mas não deve ser copiada literalmente como peças de armadura.

Depois da aprovação, fixar proporções, componentes e vistas do braço numa referência reutilizável. Retrato, recorte de combate e detalhes das cartas derivam dessa mesma referência. O próximo Golpe deve ser avaliado dentro da moldura antes de propagar a nova linguagem ao catálogo.

## Verificação desta etapa

Leitura de `PERSONAGENS.md`, `GAME_DESIGN.md`, `STATUS.md`, `DECISOES.md`, mundo e especificação do fluxo inicial; inspeção visual do conceito original de HUD em `assets/ui/references/`. Nenhuma imagem nova gerada, nenhum código alterado, nenhum teste de gameplay executado. Próxima decisão: validar ou ajustar esta hipótese de Vega antes de produzir a referência mestre.
