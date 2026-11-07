# Prova corporal 10: abdômen e cabeça independentes

22/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf / Compatibility.

Usuário autorizou experimentar o recorte corporal após levantar a sensação de “adesivo que se mexe”. Esta é uma primeira prova **mecânica**, não a Vega 2D híbrida definitiva: reutiliza pintura/roupa/cabelo atuais e todas as peças dos braços. Não fornece novas vistas anatômicas nem áreas ocultas redesenhadas. Não substitui F5 ou as provas aprovadas.

Retorno posterior em 22/10/2026: “participam, gostei como ficou”, sobre esforço conjunto de peito, cabeça e quadril. Participação corporal aceita como referência a preservar. Não significa arte definitiva, novos golpes ou integração aprovados. As menções abaixo à avaliação pendente descrevem o estado da primeira entrega, antes desse retorno.

## Experimentar

Abrir `preview.tscn` e executar **F6**. Esquerda é a base 09 com o clipe corporal anterior amostrado; direita é a candidata. A comparação esquerda não representa um golpe distante aprovado: sua montagem distante ainda é a guarda estática 09.

- **1/G:** guarda. **2:** preparo. **3:** impacto. São poses pausadas nos mesmos instantes nos dois lados.
- **Espaço:** reproduzir o ciclo uma vez, inclusive recomeçar durante o golpe.
- **L:** quatro vezes mais lento, nos dois lados.
- **O:** centros das duas próteses e cadeia corporal da candidata.
- **R:** movimento reduzido; ambas voltam à guarda. Espaço mantém postura e dá breve feedback de cor na candidata.

Conferir: quadril prepara/avança sem arrastar botas; peito e abdômen não formam um único bloco; cabeça compensa a inclinação do tórax; pele e cap das próteses continuam juntas. No impacto a guarda distante sobe, liberando a passagem da mão próxima.

Exercício pequeno: pressionar 3 para pausar no impacto. Na árvore **Remota**, selecionar `Abdomen`, comparar rotação de 3° com 4° e restaurar 3°; depois pressionar 1. Observar que o rosto e os membros têm controles próprios, mas continuam ligados ao corpo. Não editar a referência aprovada para fazer esse exercício.

## Observado, regra e hipótese

Observado: já existiam pelve, tronco, clavículas/deltoides, joelhos e apoios fixos na malha corporal. A camada Pele ainda usa a mesma pintura integral e não tinha controle próprio de cabeça. Só ampliar rotações do tronco levaria rosto, pescoço e torso juntos.

Regra: guardar identidade/paleta, montagem e proporções dos braços/mãos e contato dos pés. Preservar versões anteriores. Não mudar alcance ou regras de cartas para compensar apresentação.

Hipótese em avaliação: uma articulação de abdômen entre pelve e peito, mais compensação de cabeça, distribui a ação sem exigir agora uma nova personagem inteira. O rebind deve manter a guarda anterior. Deformação moderada permite avaliar a mecânica, mas não substitui desenho de vistas e sobreposições para giros maiores.

## Estrutura

`vega_corpo.gd/.tscn` deriva da montagem distante com cores e mão calibradas. Cria dois Bone2D e reorganiza **somente a instância candidata**:

```text
Pelve
└─ Abdomen (novo)
   └─ Tronco
      ├─ Cabeca (novo, pivô na base do pescoço)
      ├─ Clavicula / Deltoide / braço próximo
      └─ ClaviculaDistante / DeltoideDistante / braço distante

Skeleton2D: JoelhoTras, JoelhoFrente e Apoios continuam independentes da pelve.
```

O rest global do tronco não muda: seu deslocamento antigo de −80 é repartido em −30 no abdômen e −50 no peito. Caminhos dos pesos e das trilhas são atualizados na biblioteca privada. Referências dos ossos continuam válidas. Um AnimationPlayer escreve todas as ações; nenhuma IK ou correção de osso/vértice por frame.

Na cintura, transferência parcial de pesos pelve/tronco para abdômen, com rampas verticais 285–350 e 400–470. Na cabeça/pescoço, influência transferida do tronco com transição vertical 130–205 e rampas laterais contínuas 150–220 / 450–530. Onde necessário, conservar as quatro influências maiores e normalizar. A geometria é recalculada **uma vez na guarda** para conservar a silhueta, mantendo UV, faces e textura. Pele e acabamento do ombro recebem os mesmos vértices/pesos.

APIs conferidas na documentação oficial 4.7: [Bone2D/rest](https://docs.godotengine.org/en/4.7/classes/class_bone2d.html) e [Polygon2D/pesos](https://docs.godotengine.org/en/4.7/classes/class_polygon2d.html).

## Ação experimental

Novo clipe privado `corpo_soco`, mesmos **0,56 s** e chaves 0/.10/.20/.36/.56; interpolações lineares existentes. Preparo: quadril (−6,+7), pelve −2°, abdômen −3°, peito −4°. Impacto: quadril (+12,+3), pelve +2°, abdômen +3°, peito +5°. Cabeça compensa +8° no preparo e −9° no impacto, preservando melhor a direção do olhar sem esticar o rosto como um todo com o peito. A transição do pescoço permanece deformável; o teste de rigidez cobre dois marcos faciais, não cada pixel.

Braço próximo mantém cotovelo/punho e peças aprovadas. O ombro recebe compensações de 0/+7/−5/−.5/0 graus para conservar a direção global do golpe apesar dos giros corporais adicionais; a origem avança com o tórax, portanto a trajetória global de posição não é idêntica à anterior. Não há alongamento de membros.

Durante o impacto, a inserção do braço distante gira de 135° para 185°, voltando à guarda em .36. Cotovelo permanece em 120° (60° internos) e punho em 0°. É uma elevação experimental de guarda, **não soco distante ou alternância**. As peças/mão/escala/centros não mudam. Avaliar a naturalidade desse gesto com o usuário.

Skill **animate** orientou feedback/continuidade espacial, uso de AnimationPlayer nativo, captura cúbica in-out existente de .10 s ao recomeçar e alternativa reduzida. Os atalhos são inspeção de personagem, não transições decorativas de interface. Sem biblioteca instalada ou curvas novas de UI.

## Problemas encontrados e corrigidos

Primeira tentativa: seis vértices com cinco influências e 84 inversões de faces em transparências. Limitadas as influências e substituída a máscara lateral descontínua da cabeça por rampas contínuas, mantendo a exigência de nenhuma face invertida, inclusive transparente. Rebind conserva a guarda.

A guarda distante inicial se cruzava com a mão atacante no impacto. Um primeiro aumento para 165° ainda produzia sobreposição. Inspeção de ângulos e captura levaram à candidata 185°, com zero interseções no teste de tinta das mãos no impacto. Não representa teste de colisão 3D ou de toda a trajetória. Diagnóstico opcional do teste: `-- --diagnosticar`; não modifica clipes de produção.

## Verificação executada

- `tests/test_corpo_articulado.gd`, headless e OpenGL/fixed-fps 60: **zero falhas/exit 0**, 57 poses.
- Guarda ponderada inteira comparada à base: desvio máximo 0,000130 px. Onze conjuntos de pesos válidos/normalizados, no máximo quatro influências significativas; mesma geometria do acabamento, UV/face/textura e peças dos braços preservadas.
- Zero faces invertidas, incluindo transparências. Vértices das botas realmente imóveis, não só marcadores. Dois marcos da face mantêm distância; cabeça se move independentemente do peito. Direção global da mão atacante preservada pela compensação; origens das próteses continuam nas inserções corporais.
- **1.254 amostras GPU** opacas: ombros/cotovelos/punhos dos dois lados e pontos em rosto/pescoço/peito/cintura. Não valida todas as bordas, anatomia ou iluminação.
- Silhuetas opacas das mãos sem interseção amostrada no impacto. Recomeço sem salto imediato, retorno automático à guarda e reduzido sem deslocamento verificados. Handler 1/2/3/L/O/R/Espaço exercitado; sem automação física de teclado.
- Regressões headless de guarda distante, ombro 06 e paleta 09 passaram, zero falhas/exit 0. Sem suíte inteira ou integração com cartas.
- Capturas OpenGL exit 0: **16 PNGs** em `docs/evidencias_vega_corpo_articulado_10/`. Inspecionados guarda/preparo/impacto nativos, comparação e marcos finais. Corpo participa mais, cabeça compensa e mãos se distinguem no impacto nesses enquadramentos; sensação de peso ainda depende do teste do usuário.
- `corpo.avi` gerado pelo Movie Maker: **137 quadros/60 FPS**, ~2,28 s, exit 0. Sem reprodução em player externo nesta execução. Testes/captura/filme finais sem stderr. Importação exit 0, com avisos conhecidos de RID/fontes/ObjectDB/recursos ao encerrar o editor.

## Limites e próximo recorte

Ainda é a pintura anterior deformada, sem nova roupa em camadas, cabelo articulado, pernas completas com coxa/canela, vistas alternativas, desenho de áreas ocultas ou rotação volumétrica 3D. Não declarar concluída a reconstrução corporal ou prometer coerência em qualquer amplitude. Esta prova avalia controles e distribuição do movimento antes de preparar mais arte.

Sem dano corporal novo, idle novo, soco distante, alternância, expansão por Combo, HUD/cartas ou migração F5. Bibliotecas/provas aprovadas preservadas. Próximo resultado necessário: avaliação do usuário sobre torso/cabeça/apoio e a guarda elevada; só depois decidir nova camada/arte corretiva, sem aumentar amplitude indiscriminadamente.
