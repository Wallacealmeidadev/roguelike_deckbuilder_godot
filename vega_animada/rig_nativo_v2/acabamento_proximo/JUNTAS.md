# Refinamento das juntas — 22/10/2026

Usuário autorizou melhorar as juntas após a inspeção da saliência. Recorte desta etapa: punhos e cotovelos dos dois braços, preservando movimento aprovado. Não houve redesenho do ombro, anatomia, PNGs ou migração ao F5.

## Mudanças e motivo

- Punhos: manga reduzida de contorno com máximo x=23/y mínimo=-22 para x máximo=10/y mínimo=-12, preservando sobreposição ao soquete. `NucleoPunho` anterior fica oculto para não duplicar volume; nada é apagado da cena-base. Miolo mantém o mesmo vínculo e posição.
- `interior_aro.gdshader`: máscara local por cor/alfa da mão, mapeada por transformação inversa/recorte de cada atlas. Permite fibras somente na região escura neutra do soquete; protege transparência, metal claro e acentos ciano/magenta. Parâmetros preparados uma vez; sem compensação por frame. Não é uma solução genérica para qualquer atlas, nem reconstrução de perspectiva 3D. Referência de API: [CanvasItem shader Godot 4.7](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/canvas_item_shader.html).
- Cotovelos: remendo retangular `FibraJunta` oculto e núcleo oval contido sob o aro (centro 8.5,226; raios 41,17), com fibras existentes e tom de recessão discreto. Sem mover/esticar a junta, placas ou ossos.
- `refinar_juntas` na raiz de `vega_prova.tscn` permite comparar. Desligada, restaura a montagem anterior durante a instanciação. `inspecionar_soquetes.gd -- --juntas` salva a nova inspeção; sem a opção, produz a linha de base sem refinamento, em pasta distinta. Clipes/tempos/Combo/reduzido permanecem anteriores.

## Verificação executada

Godot 4.7.2.stable.official.ed1daf0bf / GL Compatibility, fixed-fps 60. Montagem `test_acabamento_proximo` passou headless/OpenGL, zero falhas/exit 0. GL isolado sem avisos. Testes novos protegem contenção, núcleo duplicado oculto e máscara; comparação existente mantém ossos/poses/tempos/proporções, perfis de Combo e recursos-base.

GPU: 928 leituras nos pontos dos punhos e 464 no centro dos cotovelos, quatro clipes/29 instantes/Combo 0 e 10, zero falhas de cobertura. Máscara isolada: 55 pixels com contribuição, zero sobre transparência, acentos saturados ou metal claro do aro, no enquadramento testado. Não é inspeção de todos os pixels em todos os instantes nem prova de anatomia/perspectiva. Ombro continua 933 pixels/zero fora da pele; punho distante/pele zero nos cinco instantes da guarda.

Integração `test_vega_nativa_combate -- --acabamento` passou OpenGL; regressões combo/encaixes/apoio nativos passaram headless. Inspeção em dois golpes, 57 instantes: desvio máximo da origem do miolo relativo à mão 0.001043 px do atlas, desprezível. Capturadores exit 0. Main/capturas mantêm avisos anteriores de recursos/RID/fontes/ObjectDB no encerramento. Não executada suíte completa, integração headless nova, benchmark ou vídeo.

54 PNGs em `docs/evidencias_vega_juntas_01/`: 14 fases ampliadas de punho, seis guarda/impactos Combo 0/10, dois zooms dos cotovelos e 32 capturas integradas em 1920/1024. Inspecionados distante .10/.28, próximo .36, dois cotovelos, guarda ampliada 0, impacto distante ampliado 10 e guarda integrada 1920. Linha de base foi recapturada sem refinamento em sua pasta anterior para comparação. Avaliação artística do novo acabamento ainda pendente; aros continuam desenhos fixos em perspectiva.

Exercício: desmarcar `refinar_juntas`, salvar `vega_prova.tscn`, reiniciar `preview.tscn` com F6 e observar só o volume sob os aros no retorno do golpe; depois reativar. O movimento deve permanecer igual.
