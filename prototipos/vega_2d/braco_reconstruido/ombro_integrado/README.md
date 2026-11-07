# Ombro próximo: participação da pele — prova 06

Primeiro ajuste localizado autorizado em 22/10/2026. Não substitui a prova 05 bem recebida nem o F5.

Retorno posterior em 22/10/2026: usuário aprovou — “perfeito, tá otimo esse braço”. Esta variante torna-se referência aprovada do braço próximo em movimento, incluindo a junção do ombro. Preservar esse resultado; não implica aprovação do braço distante, Combo ou migração F5. As referências a avaliação pendente abaixo descrevem o estado da entrega antes deste retorno.

## Experimentar

Abrir `preview.tscn` desta pasta e executar **F6**.

- Espaço: soco. D: dano/interrupção. G: guarda.
- L: câmera lenta 4×. O: centros das juntas. R: movimento reduzido.
- A: alternar entre ombro anterior e candidato, mantendo o instante do clipe e o estado de reprodução. O texto identifica a variante visível. Não transfere o histórico do blend de captura nem o flash de dano entre atores.

Exercício pequeno: ativar L, socar e alternar A perto da extensão. Observar a borda da pele acima da capa metálica; a mão deve continuar no mesmo lugar ao comparar. Depois voltar à velocidade normal para avaliar o conjunto.

## Observado, regra e hipótese

Observado: a prótese nova já estava presa ao deltoide existente. A capa metálica pertence ao segmento superior rígido. A pele e seu acabamento local usavam pesos anteriores; estarem na mesma hierarquia não garantia que o esforço fosse visível no ombro humano.

Regra deste recorte: preservar a guarda 75°/−120°/0°, mão (.76,−.76), comprimentos, inserção, trajetória e tempo aprovados. Um lado por vez. Não redesenhar Vega inteira, adaptar o outro braço, Combo ou promover ao F5 por associação.

Hipótese em avaliação: distribuir parte do giro pelo deltoide e aumentar sua influência local na pele reduz a sensação de prótese girando sobre um ombro imóvel. É uma primeira prova de deformação, não aprovação artística final ou reconstrução anatômica completa.

## Como funciona

`vega_ombro.tscn/.gd` herda a prova de movimento 05. O deltoide recebe 28% da diferença entre o ângulo animado do braço superior e sua guarda. O osso filho recebe a compensação oposta: o metal continua rígido, na mesma trajetória. No impacto, o deltoide recebe −19,04° adicionais; não são 19° de deslocamento adicional da prótese no mundo.

Pesos são transferidos somente da clavícula para o deltoide em uma máscara radial centrada em (220,198), limitada ao retângulo (170,145,110,110), até .30 por vértice. A geometria é recalculada na guarda para conservar o contorno original apesar dos novos pesos. Pele e acabamento existente recebem os mesmos vértices/pesos, evitando desencontro entre eles. UVs, faces, texturas e pintura permanecem anteriores. O metal não recebe skinning novo.

A operação ocorre uma vez no `_ready`; não há correção de ossos por frame, IK novo ou segundo animador. Apenas a cópia privada dos clipes muda. Tempos, interpolações, curvas, joelhos, clavícula e lado distante preservados. Um AnimationPlayer continua responsável pela animação. API de pesos conferida na [referência oficial Polygon2D da Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_polygon2d.html).

A skill animate orientou a preservação de timing, interrupção, repouso e movimento reduzido, com câmera lenta para inspeção. Não foram adicionadas curvas de interface à ação da personagem.

## Verificação executada

Godot 4.7.2.stable.official.ed1daf0bf, fixed-fps 60, Compatibility/OpenGL.

- `tests/test_ombro_integrado.gd`: headless e OpenGL, zero falhas/exit 0. 133 poses (57 soco, 27 dano, 49 respiração).
- Trajetórias dos três ossos da prótese comparadas à prova 05: desvio máximo de origem 0,000069 px; bases de rotação também conferidas. Guarda ponderada inteira: desvio máximo 0,000062 px. São diferenças numéricas desprezíveis, não nova folga.
- Pesos normalizados/não negativos, alterações localizadas, geometria/UV/faces, recursos privados e acabamento alinhado. Resposta máxima da malha no impacto: 24,487 px no espaço nativo da pele; não é medida de deslocamento visível de todos os pixels da pintura.
- GPU: 3.458 amostras opacas em ombro/cotovelo/punho/mão, zero falhas. Não prova toda a borda, anatomia ou perspectiva 3D.
- Recomando sem salto imediato, dano/interrupção, retorno à respiração, reduzido/retomada e comparador A com mesma fase pausada/reproduzindo verificados. Não houve automação física do teclado.
- Regressões headless `test_movimento_braco_reconstruido.gd` e `test_encaixe_braco_corpo.gd`: zero falhas/exit 0. Suíte inteira e integração com cartas não executadas.
- Captura OpenGL: 14 PNGs em `docs/evidencias_vega_ombro_integrado_06/`, antes/depois em sete tempos. Inspecionados guarda, preparo .10, passagem .15, impacto .20, retorno .28/.36 e impacto anterior. Mudança no contorno do ombro aparece no esforço; guarda mantém leitura anterior. Avaliação limitada às capturas, ainda aguardando usuário.
- Movie Maker gerou `ombro.avi`, 187 quadros/60 FPS (~3,1 s), exit 0. Sem reprodução em player externo nesta execução. Testes/captura/filme sem stderr. Importação saiu com 0, com avisos conhecidos de recursos/RID/fontes/ObjectDB ao encerrar o editor.

## Limites

Não foi desenhado um novo ombro humano nem uma nova capa metálica. A pintura anterior e suas limitações de transição/perspectiva continuam presentes. Esta etapa muda como a pele acompanha a prótese; eventual retoque artístico deve ser avaliado depois de ver este movimento, sem reabrir mão, guarda ou proporções aprovadas.

F5, prova 05, cena estática, braço distante e expansão por Combo anteriores permanecem intactos. Cobertura alfa e trajetória estável não equivalem a encaixe artisticamente concluído. Próximo recorte: avaliação do usuário desta junção em movimento.
