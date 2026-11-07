# Bíceps e filtragem — 22/10/2026

Usuário aprovou a pose atual, apontando corte do bíceps distante e serrilhado. Preservar essa pose; não equivale a aprovação final de todas as peças/animações.

## Diagnóstico e correção

- Observado: a malha do bíceps distante ainda usava o retângulo do atlas antigo `(122,499,298,358)`. Leitura do PNG novo encontrou silhueta opaca em `(128,495)` até `(424,857)`; 106 pixels opacos atravessavam a borda direita antiga, entre y=707 e 812. Isso confirma corte real do desenho, não osso encurtado.
- Correção: expandir somente linhas/colunas externas da malha/UV em 12 px horizontais e 8 verticais, para recorte `(110,491,322,374)`. Interior, transformação, ossos, soquetes, poses, pesos e deltas de Combo preservados. Sem alongar membro ou regenerar arte. A nova borda tem zero pixels opacos; margens são espaço transparente, não volume acrescentado artificialmente.
- Observado: corpo, braços e punhos não tinham mipmaps importados. Modelo e raízes dos braços forçavam filtro linear simples; a composição usa resolução 1:1, sem `stretch_shrink` maior que 1. Hipótese sustentada pela comparação: minificação das texturas detalhadas sem mipmaps contribui para a aspereza/cintilação. Não foi auditado todo o serrilhado da arena/HUD.
- Correção: gerar mipmaps nos cinco PNGs efetivamente usados (atlas corporal, próximo, interno e punhos 01/02); selecionar `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS` no modelo e nos dois braços desta variante. Raízes dos braços tinham override próprio, por isso alterar só o pai não bastaria. PNGs originais não foram editados, só parâmetros de importação; demais cenas continuam com seus filtros anteriores. `suavizar_texturas` permite comparação ao reiniciar a prévia. Projeto, HUD, fontes, arenas e retratos não receberam filtro/desfoque global.
- MSAA 2D foi experimentado no viewport local, mas o runtime GL Compatibility registrou `2D MSAA is not yet supported for GLES3`. Removido do código e teste final; não há alegação de AA geométrico ligado. Não trocar renderer por causa disso.

A [documentação CanvasItem 4.7](https://docs.godotengine.org/en/4.7/classes/class_canvasitem.html#enum-canvasitem-texturefilter) descreve por que linear simples ainda pode granular na redução e recomenda mipmaps para arte não pixelada em escala baixa. [MSAA no Viewport](https://docs.godotengine.org/en/4.7/classes/class_viewport.html#class-viewport-property-msaa-2d) não resolve aliasing da própria textura. Não basta ligar uma opção de antialiasing e supor o problema resolvido.

## Verificação realmente executada

Godot 4.7.2.stable.official.ed1daf0bf / OpenGL Compatibility, fixed-fps 60. Importação exit 0. `test_acabamento_proximo` passou headless e OpenGL, zero falhas/exit 0; após remover MSAA, execução GL final sem avisos. Teste protege a expansão só nas bordas/interior fixo, perfis de Combo, ossos/poses e comprimentos; verifica mipmaps e filtros nos três níveis, recorte sem silhueta tocando borda. GPU: pintura local do ombro agora 933 pixels após filtragem, zero fora da pele; punho distante/pele com zero sobreposição nos cinco instantes da guarda.

Integração `test_vega_nativa_combate -- --acabamento` passou headless/OpenGL com cartas reais, custos/dano/Combo, alternância/interrupção/reduzido/reset e UI/chão em duas resoluções. Regressões combo_nativo/encaixes_nativo/apoio_corporal passaram headless. Capturador GL retornou exit 0. Main/editor/capturas mantêm os avisos anteriores de recursos/RID/fontes/ObjectDB ao encerrar; não corrigidos. Sem suíte completa, medição de desempenho ou revisão de vídeo.

40 PNGs em `docs/evidencias_vega_recorte_filtro_01/`: 32 integradas em 1920/1024, seis ampliadas guarda/impactos Combo 0/10 e duas comparações antes/depois no mesmo enquadramento de 400×420. Inspecionados A/B da filtragem, guarda ampliada 0, impacto distante ampliado 10 e guarda integrada 1024. A comparação A/B usa a mesma pose e recorte corrigido; varia somente filtro. Visualmente reduz o aspecto granulado, ficando mais suave e perdendo microdetalhe na redução; nitidez final ainda depende de avaliação do usuário, sem afirmar eliminação de todo serrilhado.

Abrir `preview.tscn` e F6. F5 permanece anterior. Exercício: desmarcar `suavizar_texturas` na raiz de `vega_prova.tscn`, salvar/reiniciar a prévia e comparar contorno/cabelo/fibras no mesmo tamanho de janela; reativar depois. Não alterar escala dos ossos para avaliar nitidez.
