# Prova de um braço com rig nativo

Experimento de apoio inferior: `preview_apoio.tscn` / [APOIO_CORPORAL.md](APOIO_CORPORAL.md). Quadril/joelhos participam do golpe, botas fixas; zoom inferior e provas anteriores preservadas.

Experimento atual de tensão por Combo: `preview_combo.tscn` / [COMBO.md](COMBO.md). Prévia separada com comparação 0/5/10; não altera a montagem aprovada ou o combate.

Etapa seguinte autorizada: `preview_dois_bracos.tscn` / [DOIS_BRACOS.md](DOIS_BRACOS.md), com segunda prótese e guarda assimétrica. Prévia isolada para avaliação; não migra o combate ou Combo. As provas anteriores permanecem disponíveis.

Ajuste posterior de junções/mãos nessa mesma prévia: [ENCAIXES.md](ENCAIXES.md). Somente variante visual; ossos, poses e tempos preservados.

Evolução autorizada depois da avaliação do ombro rígido: `preview_ombro.tscn` / [OMBRO_TRONCO.md](OMBRO_TRONCO.md), com pele vinculada aos ossos e pés fixos. A prévia de braço original descrita abaixo foi preservada. Ambas continuam separadas do combate.

21/10/2026, Godot 4.7.2.stable.official.ed1daf0bf / Compatibility. Autorização do usuário: tentar um braço com Skeleton2D/Bone2D e poses no AnimationPlayer antes de alterar o combate. Não é aprovação visual nem migração do personagem ativo.

Atualização de avaliação: usuário considerou a prova muito melhor, aprovando a direção como teste, com ressalva do ombro rígido. O registro inicial acima descreve o momento anterior a esse retorno. Revisão `review-animations` confirmou que o ombro humano continua desenhado no Sprite2D corporal estático, fora do esqueleto da prótese; só a prótese articula. Próximo recorte proposto é preparar vínculo de ombro/tronco (peça ou malha), não apenas acrescentar um osso ou alterar easing/comprimentos. Não implementado neste retorno; não há aprovação de animação final nem migração ao combate.

## Como experimentar

Abra `preview.tscn` e execute F6. Esquerda: corpo-base atenuado como contexto de proporção, com somente um braço intencionalmente. Direita: a mesma cena de braço ampliada. Não é uma nova versão do jogo ou personagem sem braço por erro.

- `Repouso`, `Guarda`, `Extensão`: poses estáticas com transição nativa de 160 ms.
- `Reproduzir soco`: ciclo único, não loop. Clique novamente durante o movimento para conferir substituição da pose atual.
- Barra de tempo: pausa e inspeciona 0–0.56 s, inclusive quadros intermediários.
- `Ver ossos`: linhas/âncoras sobrepostas; não altera a montagem.
- `Movimento reduzido`: interrompe o ciclo em repouso, não reproduz o soco amplo e permite comparar poses estáticas imediatamente. A barra continua sendo inspeção manual deliberada.

## O que foi feito

`braco_nativo.tscn` contém o rig e as imagens na própria cena, visíveis no editor: Skeleton2D → Ombro → Cotovelo → Punho, três Bone2D registrados. Ossos orientados em +X; comprimentos 128.0604/133.9085 e escala dos ossos sempre 1. Peças são Sprite2D/AtlasTexture filhos dos ossos; escala e encaixe não são animados. O osso Punho é suporte da mão, não outro segmento extensível. `rest` está definido nos três ossos.

AnimationLibrary salva na cena: RESET, repouso, guarda, extensao e soco. Somente três trilhas de rotação, sem solver IK, alvos, `acos`, reparent em runtime, cálculo de pose a cada frame, mudança de comprimento ou uso do controlador procedural anterior. Rotação local em graus para leitura:

| Pose / tempo no ciclo | Ombro | Cotovelo | Punho |
| --- | ---: | ---: | ---: |
| Repouso / 0 | 110 | -75 | 0 |
| Preparo / 0.10 s | 112 | -170 | -3 |
| Extensão / 0.20 s | -8 | 7 | 0 |
| Guarda / 0.36 s | 105 | -160 | 0 |
| Repouso / 0.56 s | 110 | -75 | 0 |

Guarda/repouso/extensão também existem como clips estáticos independentes. Alterar uma chave do clip estático não altera automaticamente a chave correspondente do ciclo: são recursos editáveis separados. Os valores salvos das trilhas são radianos, como a propriedade `rotation` da Godot.

`braco_nativo.gd` só seleciona animações, controla inspeção/reduzido e emite estado. `AnimationPlayer.play_with_capture` com trilhas UPDATE_CAPTURE captura a pose atual para transição/interrupção, em vez de reiniciar os ossos em outra posição. Captura de 100 ms ao iniciar soco, cubic in-out nativo; poses estáticas usam 160 ms. As chaves internas do ciclo têm interpolação linear explícita para inspeção; ainda não são um passe de motion final. Não é a mesma curva bézier amostrada do rig anterior. Skill `animate` adaptada ao laboratório de animação de personagem: indicação de estado/feedback, ferramenta nativa, movimento finito substituível e alternativa reduzida, sem bounce/loop decorativo.

`preview.gd` apenas sincroniza duas instâncias, layout e sobreposição de ossos; não escreve rotações. A camada de ossos usa Node2D acima do fundo. Nenhum módulo de run/cartas/main é instanciado pela prova.

## Assets preservados e limites

Reutilizados `braco_v2/camadas.png` e punho fechado/corpo de `combate_v2/base_e_punhos_01.png`. Sem geração, edição raster, exportação ou compra de ferramenta externa. Braço superior usa o recorte existente com fibra/placa juntas; antebraço usa fibra, placas, junta e preenchimento da junta como peças rígidas. A escala local .66 e punho .3696 são fixos; esta prova não expande feixes ou integra Combo. O comportamento aprovado por Combo continua intacto no jogo e só deverá ser acoplado depois de avaliar este rig.

Limitação observada nas capturas: encaixe e perspectiva da junta/cuff continuam derivados dos recortes antigos; o anel tem vista inclinada que não se torna um cotovelo tridimensional ao girar. Não há rotação do tronco/quadril, troca de desenho da mão, segunda prótese ou validação biomecânica. As proporções desta prova continuam candidatas, não aprovadas automaticamente porque as juntas estão conectadas. Rig nativo elimina o solver personalizado desta prova, não corrige arte ou anatomia por si só.

## Verificações executadas

- Primeiro teste/captura não carregou as cenas: literais `.66`/`.035` no arquivo de recurso precisavam de zero inicial. Processos de teste presos por esse erro foram encerrados por PID/linha de comando específicos; nenhum editor do usuário foi encerrado. Literais corrigidos, testes repetidos. Importação anterior exit 0 não bastava para validar carregamento da cena.
- `test_rig_nativo_v2` passou headless, fixed-fps 60, exit 0: três ossos, nenhuma modificação IK, clips/trilhas nativos, poses esperadas, 57 amostras de ciclo mantendo comprimentos/escala/encaixe, captura durante transição, fim sem loop, reduzido, botões/barra sincronizando as duas instâncias e enquadramento completo da mão em 1024×576/1920×1080.
- `test_vega_combate_v2` e `test_vega_playtest` passaram novamente, zero falhas/exit 0. Estes mantêm mensagens anteriores de recursos/RID/objetos ao encerrar; prova isolada/teste/capturas encerraram sem esses avisos. Não foi executada suíte completa nem corrigido o crash headless intermitente anterior.
- Oito capturas OpenGL salvas OK em `docs/evidencias_rig_nativo_v2/`: três poses e intermediária com ossos por resolução. Inspeção inicial revelou corte no zoom da extensão e marcadores atrás do fundo; corrigidos e repetidas as capturas. Inspecionadas três poses em 1920, guarda/intermediária em 1024, punho completo e overlay visível.
- Vídeo `ciclo_nativo.avi`, 82 frames/30 FPS/1152×648, encerramento normal de gravação. Ciclo e repetição durante preparo. Wrapper não capturou exit code do processo; log de erro da gravação vazio. Vídeo não foi avaliado manualmente pelo usuário.

Nenhuma cena/controlador/asset do combate real foi substituído. F5 continua usando a versão anterior; esta avaliação é F6. Próximo passo depende da leitura visual desse único braço, antes de segundo braço, torso, Combo ou integração.

## Pequeno exercício no editor

Abra `braco_nativo.tscn`, selecione AnimationPlayer e a animação `guarda`. Selecione Cotovelo, gire 5° no Inspector e grave a chave de rotação da pose. Execute a prévia e compare; depois restaure. Não mova a posição do Cotovelo ou a escala dos ossos para ajustar a pose. Se aceitar outra pose, atualize depois a chave correspondente em `soco`; testes de valores exatos também precisarão refletir a decisão aceita.

APIs oficiais consultadas para Godot 4.7: [Bone2D](https://docs.godotengine.org/en/4.7/classes/class_bone2d.html), [Skeleton2D](https://docs.godotengine.org/en/4.7/classes/class_skeleton2d.html), [Animation](https://docs.godotengine.org/en/4.7/classes/class_animation.html), [AnimationPlayer](https://docs.godotengine.org/en/4.7/classes/class_animationplayer.html).
