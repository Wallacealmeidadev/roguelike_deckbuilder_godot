# Continuidade dos punhos — 22/10/2026

## Inspeção posterior, sem alterar a apresentação

Usuário relata melhora, mas permanece em dúvida sobre saída do encaixe. `tests/inspecionar_soquetes.gd` produziu 14 zooms em `docs/evidencias_vega_soquetes_inspecao_01/`, dois golpes/Combo 10, sem editar cenas/arte/poses persistidas. Medida em 57 instantes por golpe: desvio máximo da origem do miolo relativa à mão = 0.001043 px do atlas, compatível com precisão numérica; não evidencia deslizamento do miolo na mão. Godot 4.7.2/OpenGL/fixed-fps 60, exit 0, stderr vazio. Examinados distante .10/.28/.46 e próximo .36; não observada separação temporal nessas capturas, mas conector ainda tem pequeno volume/saliência visível sob/lateralmente ao aro. Próximo refinamento sugerido é conter seu acabamento no recorte do aro, não mover os ossos. Não implementado neste diagnóstico; sem nova suíte/vídeo e sem afirmar encaixe artístico final.

## Registro da correção anterior

Relato do usuário: movimentação “legitimamente muito boa”, mas junções pouco conectadas e um buraco nas mãos, mais grave na distante. Capturas fornecidas mostram aro/soquete aparente. Registrar aprovação do movimento atual, preservando poses, tempos, proporções e alternância; não significa aprovação final da arte inteira.

## Observado e hipótese

As duas artes de mão têm uma boca de soquete escura pintada no PNG. Essa região é opaca: preenchimento atrás do sprite não consegue substituir a pintura de cavidade. O `NucleoPunho` antigo fica atrás; `MioloLuva` anterior está oculto porque pertencia ao encaixe/desenho antigo. Coincidência de pivôs não prova continuidade visual.

Hipótese aplicada na variante: um conector curto sob o aro mais um miolo ajustado à abertura visível podem fazer a mão parecer assentada, sem mover o rig ou crescer a luva. Isso é sobreposição 2D localizada, não encaixe cilíndrico/rotação 3D.

## O que mudou

`vega_prova.gd`: flag `fechar_punhos`, dois Polygon2D estáticos por punho. `ConectorPunho` fica atrás da mão e sobrepõe a extremidade das fibras; `InteriorSoquete` ocupa somente a boca do aro, acima da cavidade pintada, conservando borda metálica/ciano. Textura vem de amostra opaca dos atlas já usados em cada lado. Ambos seguem o mesmo Bone2D/Punho; sem código por frame, alteração de mão/soquete/escala, novas poses, shaders ou PNGs. Combo não expande esses conectores.

Primeira montagem expunha demais a manga; ajustada a sobreposição para entrar sob o aro. Um teste também encontrou dois vértices UV fora da área opaca: amostra estreitada para o interior do feixe, sem afrouxar a asserção. Provas históricas e F5 continuam anteriores; F6 da mesma `preview.tscn` inclui a correção.

## Verificação realmente executada

Godot 4.7.2.stable.official.ed1daf0bf, OpenGL Compatibility/fixed-fps 60.

- `test_acabamento_proximo`: headless e OpenGL, zero falhas/exit 0; GL final sem avisos no teste isolado. Mantém comparação de ossos/poses/tempos/encaixe das mãos e perfis de Combo, verifica conectores estáticos e amostras UV opacas. GPU: 928 leituras em dois pontos de união por punho, 29 instantes por clipe (respiração, próximo, distante, dano), Combo 0/10; zero falhas de cobertura alfa. São pontos amostrados, não prova de toda a silhueta nem de perspectiva/acabamento. A cavidade pintada já era opaca, portanto essa checagem não substitui inspeção visual.
- Pintura do ombro: 933 pixels/zero fora da pele; teste de punho distante versus pele continua com zero sobreposição nos cinco instantes da guarda.
- Integração `test_vega_nativa_combate -- --acabamento`: headless/OpenGL, zero falhas/exit 0; cartas reais/custos/dano/Combo, alternância/interrupção/reduzido/reset e chão/UI em duas resoluções. Regressões combo_nativo/encaixes_nativo/apoio_corporal passaram headless.
- 40 PNGs em `docs/evidencias_vega_soquetes_01/`: 32 integradas 1920/1024, seis ampliadas guarda/impactos Combo 0/10 e dois zooms dos soquetes por transformação de canvas nativa (sem editar pixels do asset). Inspecionados guarda ampliada 0, impactos próximo 0/distante 10, dois zooms e guarda integrada 1920. Sem vídeo ou suíte completa. Capturador exit 0.
- Main/capturas ainda emitem avisos anteriores de recursos/RID/fontes/ObjectDB ao encerrar; não corrigidos nesta etapa.

Exercício: desmarcar `fechar_punhos` na raiz de `vega_prova.tscn`, salvar/reiniciar `preview.tscn` com F6 e comparar os aros, depois reativar. A mudança deve aparecer apenas na união, sem modificar o golpe.
