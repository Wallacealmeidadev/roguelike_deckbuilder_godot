# Prova 18 — origem da arte dos braços

Atualização 24/10: estudo HQ dos dois braços aprovado; pintura aplicada nesta prévia estática. **H** alterna original/HQ na mesma geometria, **R** restaura HQ. Abrir `preview.tscn` com F6, Z amplia. Textura, material, prompt e verificações em [pintura_hq_01.md](pintura_hq_01.md). Capturas atuais em `docs/evidencias_vega_bracos_prancha_18/hq/`; imagens anteriores preservadas na pasta pai. Integração visual ainda em avaliação, F5 intacto. Notas abaixo descrevem histórico da montagem.

Estado: versão inicial **rejeitada pelo usuário em 24/10/2026**. Após “vamos ajustar então”, revisão localizada do ombro próximo nesta mesma bancada, **ainda em avaliação**. A mostra anterior está disponível por A e em `docs/evidencias_vega_bracos_prancha_18/antes_encaixe/`. Não é uma guarda inteira ou articulação aprovada.

Objetivo: comparar o desenho aprovado da prancha 04 no corpo por camadas, sem tentar reproduzi-lo com as próteses antigas. A rejeição da prova 17 é o ponto de partida; nenhuma equivalência artística foi demonstrada pelos testes de juntas anteriores.

## Abrir

Executar `preview.tscn` com F6. **V** alterna somente o volume próximo; **A** alterna o encaixe anterior na mesma câmera. Z amplia, B oculta/mostra os recortes e a conexão juntos, C/T/P alternam cabeça/tronco/quadril, O mostra marcos corporais e inserções, R restaura candidata com volume. F5 não foi alterado.

## Retorno de proporções e limpeza

Revisão mais recente: usuário apontou antebraço ainda fino e mão menor. `VOLUME_ANTEBRACO = .45`, numa faixa mais ampla; `VOLUME_MAO = .14`, crescimento a partir do punho com transição suave. Centros das juntas e aro ficam fixos; V agora compara também o tamanho da mão. Teste GL atualizado passou e captura ampliada foi inspecionada. As medidas de mão imutável abaixo descrevem a revisão anterior, não a atual. Exercício opcional: experimentar `.12` em `VOLUME_MAO` e comparar com `.14` usando F6, mantendo os outros parâmetros.

Usuário considerou o distante ótimo e pediu só retirar o resíduo branco; próximo fino. Máscara da mão/punho distante recolhida 1–4 pixels nas áreas de fundo cinzento, sem retocar interior, material ou transformação. Próximo recebe `VOLUME_BICEPS = .24` e `VOLUME_ANTEBRACO = .20` como máximos locais de ganho transversal, com peso progressivo que zera nas extremidades. Centros da junta e respectivas regiões, aro e mão não crescem; comprimentos longitudinais mantidos. UV permanece na pintura original; somente a malha muda. É uma hipótese de proporção estática, não pintura definitiva ou ligação com Combo. Sem geração raster nesta revisão.

Comparação GPU do volume: 1.982 pixels da região da mão, erro máximo 1/255; cinco pontos de fundo distante agora transparentes; testes headless/GL e regressão headless guarda 17 passaram. Pontos não certificam todo o contorno. Capturas `sem_volume.png` e `ampliada.png` permitem comparar a mesma pose, `distante.png` mostra a limpeza. Anteriores em `antes_volume/`.

## Como funciona

`vega_fiel.gd` herda a montagem 17 para conservar cabeça, tronco 02 e quadril 01. Os dois braços antigos são ocultados. Cada `Polygon2D` usa diretamente `docs/arte_vega/vega_corpo_volume_poses_04.png`. O distante conserva o registro anterior. O próximo recebe **um registro uniforme para o membro inteiro**, pelas extremidades do aro `(162,252)/(214,264)` nos pontos `(123,341)/(275,374)` da camada de tronco. Isso também muda sua posição aparente; não se reposicionam mão/antebraço isoladamente.

O aro e o começo do bíceps são recortados da mesma UV, separados do restante só para curvar o encaixe no contorno convexo do deltoide. Subdivisão de arestas a cada 2 pixels evita uma dobra angular; `CURVATURA_ARO = 20` controla a candidata, com deslocamento zerado na borda y280 compartilhada com o bíceps. O membro passa à frente da axila, que não deve cortar a prótese. Não há aba ou ombro mecânico duplicado. Essa curvatura é geometria de apresentação estática, não preservação integral das proporções do aro original.

A skill `imagegen`, via ferramenta integrada, editou a terminação triangular do deltoide em `tronco_encaixe_01.png` (RGBA 1774×887). Prompt integral, origem e hash em [manifesto_ombro.json](manifesto_ombro.json). Nenhum PNG anterior foi sobrescrito. `ombro_local.gdshader` utiliza somente a região próxima/axila dessa edição, com transição em x295..325, y190..215 e y455..480. O restante usa o tronco 02 original, inclusive peito, pescoço, regata e distante. Não assumir invariância do gerador fora da região: o material exclui essas áreas. As partes originalmente ocultas do braço não foram reconstruídas.

## Limites

É uma prova **estática de encaixe próximo**, não braços novos segmentados ou animados. Não usar os ossos antigos como se correspondessem a estes recortes. Cotovelo/punho ainda precisam de separação, sobreposição e superfícies ocultas próprias para movimento; esse trabalho não está feito. A prova 15 continua sendo a referência funcional preservada. Cabeça, distante e diferenças artísticas do conjunto permanecem fora desta correção. Nenhum teste técnico equivale a aprovação visual.

## Verificações

`tests/test_bracos_prancha.gd` mantém a regressão da variante anterior (20 amostras nativas de cor e quatro pontos transparentes em OpenGL), e confere a candidata: registro uniforme nos dois lados do aro, partição/curvatura com borda y280 fixa, profundidade frente à axila, fontes/mipmaps e sincronização A/B/R. Comparação GPU do tronco isolado: **45.572 pontos externos idênticos, zero externos diferentes**, 5.096 internos alterados na execução final. A área verificada vai de x150..399/y170..389 na apresentação; não é uma certificação da imagem inteira ou da anatomia.

`tests/capturar_recortes_prancha.gd` amplia regiões da fonte com grade para inspeção dos contornos, sem alterar o PNG. `preview.tscn -- --capturar` grava guarda, ampliada, isolados, encaixes, antes, ombro ampliado, sem_volume e distante em `docs/evidencias_vega_bracos_prancha_18/`.

Exercício sem editar: Z → A → A → B → B → R. Observar continuidade pele/aro/bíceps e se a axila permanece atrás da prótese; não avaliar animação nesta cena. Para um ajuste pequeno no editor, experimentar `CURVATURA_ARO` de 20 para 18 e restaurar 20 após comparar; não modificar mão ou antebraço para compensar o ombro.
