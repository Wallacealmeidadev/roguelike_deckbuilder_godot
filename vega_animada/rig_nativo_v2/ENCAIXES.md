# Continuidade das junções e da mão

21/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf / Compatibility.

Wallace considerou o conjunto promissor e apontou junções/mão do braço distante problemáticas, enviando screenshot de pose intermediária. Ajuste limitado à apresentação dos encaixes; não é passe de anatomia, novas poses ou migração para o combate.

## Conferir

F6 em `preview_dois_bracos.tscn`, a mesma cena anterior. Veja principalmente preparo em 0.12 s e retorno em 0.28 s, primeiro sem ossos e depois com eles. Interrompa o soco e alterne Movimento reduzido. O encaixe não deve depender de a pose estar parada.

## Causa e ajuste

Os três ossos já se encontram, mas partes foram recortadas com aberturas: o anel de cotovelo é transparente por dentro; o cuff da mão tem abertura pintada em pixels quase opacos. Amostras RGBA do atlas confirmaram a diferença. Logo, só coincidir a origem dos nós ou pôr uma peça atrás da luva não fecha todos os espaços visuais.

`braco_encaixado.tscn` preserva a montagem/AnimationLibrary de `braco_nativo.tscn`, acrescentando quatro Polygon2D com 24 vértices e UV em região opaca da fibra já existente:

- `Skeleton2D/Ombro/NucleoOmbro`: inserto pequeno, abaixo da arte superior.
- `Skeleton2D/Ombro/Cotovelo/Arte/NucleoCotovelo`: centro texturizado abaixo do anel, preenchendo seu furo sem pintar sobre o aro.
- `Skeleton2D/Ombro/Cotovelo/Punho/NucleoPunho`: sobreposição interna entre antebraço e cuff.
- `Skeleton2D/Ombro/Cotovelo/Punho/Mao/MioloLuva`: fibra restrita ao interior pintado da abertura, acima desse recorte e acompanhando sua transformação.

Sprite2D Mao da variante base tem posição local (−8,0), inserindo o cuff no eixo do antebraço, com escala, rotação e offset originais. A mão próxima permanece assim. Após relato de mão distante ainda invertida, esse lado usa `braco_distante.tscn`, herdado da variante com encaixes: rotação −0.92951087 e escala (0.3696,−0.3696) produzem reflexão transversal no espaço do punho. Mantém assentamento, tamanho absoluto e dedos avançando no eixo do antebraço; o miolo da luva acompanha como filho. Não gira o osso nem exige compensação por frame. Cena do braço original e prévias anteriores não foram alteradas. Nenhuma imagem raster gerada/editada, biblioteca adicionada ou solver. Tempos, chaves e interrupções existentes ficam iguais. Skill `animate` orientou a etapa anterior de continuidade espacial; esta correção posterior é só de orientação estática.

Primeira captura mostrou núcleo do ombro saliente e ausência de efeito suficiente na abertura pintada da mão. Reduzido o primeiro e acrescentado miolo específico na luva. O preenchimento reaproveita a linguagem de fibra; não reconstrói perspectiva 3D da mão/cotovelo espelhados. A percepção final continua sujeita à avaliação do usuário.

## Verificação real

Atualização da orientação: `test_encaixes_nativo` passou novamente headless/OpenGL, e as três regressões abaixo passaram headless, todos com exit 0/zero falhas. O teste agora exige reflexão transversal da mão distante e marcos dos dedos/polegar, preservando seu tamanho e encaixe, em vez de transforms idênticos aos da mão próxima. Doze capturas em `docs/evidencias_mao_distante_orientada/`; inspecionadas guarda 1920 e repouso/preparo 1024. Sem novo vídeo neste ajuste. F6 continua na mesma prévia. Comparar o lado da trava magenta/polegar entre capturas antigas e novas é um exercício pequeno para entender a correção.

`test_encaixes_nativo` passou headless e OpenGL fixed-fps 60, exit 0, zero falhas: variantes usadas nos dois lados, comprimentos e escala da mão preservados, assentamento fixo, contornos/UV opacos, camadas e cobertura das três âncoras em 57 amostras. Regressões `test_dois_bracos_nativo`, `test_ombro_tronco_nativo` e `test_rig_nativo_v2` passaram headless, exit 0, zero falhas. Todos encerraram sem avisos de recursos neste passe. Sem suíte completa ou execução do combate.

Doze screenshots OpenGL salvos OK em `docs/evidencias_encaixes_nativo/`, seis situações em duas resoluções. Inspecionadas guarda/extensão/preparo 1920 e retorno/intermediária com ossos 1024. Vídeo `ciclo_encaixes.avi`: log confirma 130 frames/30 FPS/1152×648, exit 0 e stderr vazio. Material gerado para avaliação, não validação artística automática.

Exercício opcional: no Sprite2D Mao da variante, compare posição X=0 e X=−8 para ver como a sobreposição fecha o cuff; depois restaure −8. Não altere posição/comprimento do Bone2D Punho para compensar o recorte.
