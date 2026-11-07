# Ombro humano e tronco ligados ao braço nativo

21/10/2026, Godot 4.7.2.stable.official.ed1daf0bf / Compatibility. O usuário aprovou a direção da prova de braço, com ressalva do ombro duro, e autorizou seguir com essa ligação. Esta evolução continua isolada: não migra personagem ativo, segundo braço ou Combo.

## Experimentar

Abra `preview_ombro.tscn` e pressione F6. A prévia anterior `preview.tscn` permanece disponível para comparação. Esquerda mostra corpo inteiro com um braço intencionalmente; direita é detalhe de ombro/tronco, com pernas recortadas pelo painel de zoom de propósito. Corpo em cor integral para enxergar a pele, não mais atenuado como contexto inerte.

Use Repouso/Guarda/Extensão, Reproduzir soco, barra e Ver ossos. Linhas amarelas mostram pelve/tronco/clavícula/deltoide; ciano mostra o braço aprovado. A origem da prótese agora acompanha o ombro humano. Movimento reduzido interrompe a animação e permite comparação estática, sem movimento amplo automático.

## Montagem

`ombro_tronco.tscn` tem Polygon2D Pele, Skeleton2D com Pelve → Tronco → Clavicula → Deltoide e a cena `braco_nativo.tscn` instanciada como filha do Deltoide. O braço original mantém geometria, comprimentos, mão e escala. Os quatro ossos corporais têm rest definido e escala 1; não usam IK. Pelve fica em (320,410), Tronco em (0,-80), Clavicula em (-65,-150), Deltoide em (-54,45), produzindo encaixe inicial (201,225).

Pele: 352 vértices, 315 faces quadrangulares, UVs em pixels no atlas já existente e quatro conjuntos de pesos salvos na cena. Perna/pés, y≥410, recebem exclusivamente peso 1 na pelve fixa. O tronco perde influência suavemente na faixa 320–410. Região do ombro combina clavícula/deltoide com transição suave ao peito; o ponto exato (201,225) pertence inteiramente ao deltoide. Assim pele e prótese usam a mesma âncora, inclusive durante transições.

Deformação executada nativamente pelo Skeleton2D/Polygon2D na GPU. Nenhum código de produção reescreve o polígono a cada frame. `ombro_tronco.gd` reutiliza a interface de controle do braço e desativa seu AnimationPlayer interno: só o AnimationPlayer externo escreve as seis trilhas de rotação do conjunto. `braco_nativo.gd` ganhou caminhos exportados de ossos, conservando os antigos como padrão, para servir às duas provas sem copiar a lógica de playback. `preview.gd` ganhou enquadramento de corpo e detalhe e sobreposição dos ossos corporais.

## Poses coordenadas

Valores em graus para leitura; arquivos guardam floats em radianos, inclusive `0.0`:

| Tempo/pose | Tronco | Clavícula | Deltoide | Ombro da prótese | Cotovelo | Punho |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Repouso / 0 | 0 | 0 | 0 | 110 | -75 | 0 |
| Preparo / 0.10 | -2 | 2 | 4 | 108 | -170 | -3 |
| Extensão / 0.20 | 5 | -8 | -12 | 7 | 7 | 0 |
| Guarda / 0.36 | 1 | -3 | -5 | 112 | -160 | 0 |
| Repouso / 0.56 | 0 | 0 | 0 | 110 | -75 | 0 |

A rotação local do primeiro osso da prótese compensa a soma das rotações corporais, conservando a orientação global das poses do braço. Na extensão, 5−8−12+7 = −8°, como a prova anterior; não se esticam membros para ganhar alcance. O encaixe avança cerca de (15.75,−2.33) pixels no espaço do modelo. Cabeça e peito participam suavemente do tronco; não há reconstrução tridimensional da escápula/roupa ou correção de perspectiva dos recortes.

Skill `animate`: propósito de continuidade física/feedback, mantendo tempos existentes 100/100/160/200 ms, captura cubic in-out nativa para transições/interrupções e alternativa reduzida. Somente transformações dos ossos são animadas. O ciclo conserva as chaves internas lineares da prova; não é um passe final de suavização. Não há pulsação contínua, novo solver ou biblioteca.

## Erros encontrados e verificações reais

1. Duas falhas iniciais: âncora não se movia e direção global não correspondia à pose. Diagnóstico mostrou chaves de repouso/RESET tipadas como inteiros, tipo 2, e extensão como float, tipo 3. Zeros serializados como `0.0`; rotações passaram a ser aplicadas e deslocamento medido. Teste agora exige floats em todas as chaves dessa cena.
2. Movimento reduzido durante captura recém-interrompida conservava mistura residual. `clear_caches()` antes de saltos estáticos/imediatos cancela a captura pendente; transições normais continuam com capture. Teste passou sem enfraquecer a exigência de retorno à pose de repouso.
3. Teste de orientação das faces encontrou 19 inversões durante o ciclo, nas faces transparentes iniciando em x=0, y=245/270: influência do deltoide se estendia desnecessariamente ao espaço vazio à esquerda do corpo. Limitada a influência lateral à vizinhança do ombro, com rampa x=100–150. Mantidas as amplitudes/poses e a exigência de nenhuma face invertida; as duas metades de cada face são verificadas nas 57 amostras. Capturas/vídeo repetidos após corrigir os pesos.

`test_ombro_tronco_nativo` passou headless e OpenGL, fixed-fps 60, exit 0. Confere quatro ossos corporais/três do braço, vínculo real da pele, pesos normalizados e pés na pelve, âncora 100% deltoide, seis trilhas float só de rotação, participação do ombro e orientação global preservada, 57 amostras de comprimentos/mão/pele fixa em repouso, ausência de inversão das faces, captura e movimento reduzido, controles/enquadramento nas duas resoluções. O cálculo de vértices deformados no teste é somente um oráculo de comparação; a prévia usa skinning nativo na GPU. Posição do polígono original permanece inalterada no runtime, como esperado desse caminho.

Regressões `test_rig_nativo_v2`, `test_vega_combate_v2` e `test_vega_playtest` também passaram, 0 falhas/exit 0. Dois testes do combate continuam com avisos anteriores de recursos/RID/objetos em uso ao encerrar; o teste corporal e capturador encerraram limpos. Suíte completa não repetida, crash headless intermitente anterior não corrigido.

Oito capturas OpenGL salvas OK em `docs/evidencias_ombro_tronco_nativo/`, três poses e intermediária com ossos em 1920×1080/1024×576. Inspecionados repouso/extensão 1920 e guarda/intermediária 1024; pele participa do movimento e pés mantêm apoio. Vídeo `ciclo_ombro.avi`: 130 frames, 30 FPS, 1152×648, poses individuais e ciclo com interrupção, gravação terminada normalmente, log de erro vazio. Wrapper não capturou exit code do processo de gravação. Ainda depende da avaliação visual do usuário; não representa soco final biomecanicamente validado.

## Limites e próximo exercício

Não foram geradas/editadas imagens raster, redesenhada identidade ou aplicada expansão de Combo. Perspectiva do cotovelo/cuff e mão reaproveitada continuam limitadas. A cabeça acompanha o tronco sem controle próprio de pescoço. Um único braço continua intencionalmente presente; a outra prótese e integração ao combate ficam para outro recorte após avaliação.

Exercício pequeno: abra `ombro_tronco.tscn`, selecione o AnimationPlayer externo e a pose Extensão. Varie somente a chave da clavícula em 2° e observe pele e braço acompanharem juntos, sem alterar escala/posição dos ossos; depois restaure. O braço muda orientação global porque é filho dessa cadeia, não porque mudou de tamanho. Uma pose aceita depois exige coordenar as chaves e expectativas do teste, não remover verificações.

APIs verificadas em documentação/código oficial 4.7: [Polygon2D](https://docs.godotengine.org/en/4.7/classes/class_polygon2d.html), [Skeleton2D](https://docs.godotengine.org/en/4.7/classes/class_skeleton2d.html), [AnimationMixer](https://docs.godotengine.org/en/4.7/classes/class_animationmixer.html), [serialização/pesos de Polygon2D](https://github.com/godotengine/godot/blob/4.7/scene/2d/polygon_2d.cpp), [limpeza da captura no AnimationMixer](https://github.com/godotengine/godot/blob/4.7/scene/animation/animation_mixer.cpp).
