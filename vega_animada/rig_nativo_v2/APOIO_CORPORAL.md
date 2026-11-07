# Transferência de peso no golpe

21/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf / Compatibility.

Wallace apontou que a parte inferior não ajudava a animação. Na prova anterior, todos os pesos abaixo da cintura pertenciam à pelve fixa; o movimento só poderia acontecer acima dela. Esta etapa permite que o quadril participe, mantendo o contato das botas. Não considera automaticamente aprovados o novo apoio ou a tensão por Combo.

## Conferir

Abra `preview_apoio.tscn`, F6. Esquerda: corpo inteiro. Direita: quadril, joelhos e botas ampliados, com recorte intencional de cabeça/braços. Enquadramento fixo, sem câmera perseguindo a pose.

Reproduza o soco e inspecione 0.10 s (preparo), 0.20 s (impacto) e retorno. Ver ossos mostra linhas de apoio com marcadores nas solas; são referências de leitura dos pesos, não um solver de IK. Compare Combo 0/10: só muda a tensão das fibras, não a transferência de peso. Movimento reduzido retorna à postura estática. Clique de novo durante o golpe para conferir captura da pelve atual sem salto.

## Montagem e mudança de restrição

`apoio_corporal.tscn` mantém cena dos braços/encaixes e as onze trilhas anteriores. O script herda ComboNativoV2, preservando seu controle de tensão. Acrescenta três Bone2D à raiz do Skeleton2D: JoelhoTras em (180,620), JoelhoFrente em (560,580), Apoios em (0,0). Apoios nunca recebe animação; não é filho da pelve.

Pele refinada para 1520 vértices/1443 faces com nove conjuntos de pesos. Acima de y=410, pesos antigos são mantidos/interpolados. Abaixo, transição de pelve para joelho e de joelho para apoio, distribuindo lados na região entre as pernas. Em y≥680 o peso é exclusivamente do apoio fixo: a bota não deforma ou desliza para seguir o quadril. Máximo de quatro influências por vértice, normalizadas.

Um único AnimationPlayer coordena as onze rotações antigas e três novas trilhas de posição. Comprimentos e escala dos ossos não são animados. As mãos mantêm seu transform e orientação; o conjunto superior acompanha a translação da pelve, portanto o alcance global avança alguns pixels, mas a trajetória relativa/proporção dos braços não muda.

Deslocamentos da pelve em relação ao repouso (320,410):

| Momento | Tempo | Deslocamento |
| --- | ---: | --- |
| Repouso | 0.00 | (0,0) |
| Preparo | 0.10 | (−4,+5) |
| Impacto | 0.20 | (+8,+2) |
| Guarda/retorno | 0.36 | (+1,+2) |
| Repouso | 0.56 | (0,0) |

Joelhos têm deslocamentos menores nas mesmas chaves, dando flexão suave à calça. Pele é deformada por Skeleton2D/Polygon2D nativos na GPU, sem código recalculando vértices corporais a cada frame. Há um oráculo matemático somente no teste.

A pelve fixa continua protegida nos testes da prova antiga. A nova restrição é **botas fixas**, não pelve fixa; não foi necessário enfraquecer testes anteriores. Skill `animate`: feedback e continuidade física, tempos 100/100/160/200 ms e captura cubic in-out existentes, com interrupção e alternativa reduzida. Chaves internas continuam lineares como o rig anterior; não é um passe final de curvas.

## Limites

É pequena deformação 2D por pesos, não reconstrução 3D, IK de coxa/canela ou simulação de rigidez anatômica das pernas. Nenhum passo, giro do pé ou levantamento de calcanhar foi acrescentado. Não há loop de oscilação em repouso, nem balanço baseado em Combo. Sem nova arte raster, alteração do combate, HUD, personagem ativo ou reação ao dano. A avaliação de naturalidade continua com o usuário.

## Verificação real

`test_apoio_corporal` passou headless e OpenGL fixed-fps 60, zero falhas/exit 0. Verifica registro/pesos, até quatro influências, catorze trilhas, 57 amostras sem inversão de faces, vértices das botas imóveis, encaixes das duas próteses, transform das mãos e trajetória relativa dos braços, amplitude do quadril, independência de Combo, captura/reduzido e enquadramento das solas. Não é só teste de marcadores.

Regressões `test_combo_nativo`, `test_dois_bracos_nativo` e `test_encaixes_nativo` passaram headless, zero falhas/exit 0. Testes/capturador encerraram sem avisos de recursos. Importação e lançamento curto retornaram 0 sem erro de parsing; editor manteve avisos antigos de recursos/RID/objetos ao encerrar. Sem suíte completa ou playtest de combate.

Doze capturas OpenGL em `docs/evidencias_apoio_corporal/`, cinco poses e impacto com apoios em duas resoluções. Inspecionadas repouso/preparo/impacto 1920 e apoios 1024: deslocamento discreto de quadril/calça e botas estáveis. Vídeo `ciclo_apoio.avi`: log confirma 128 frames/30 FPS/1152×648, exit 0/stderr vazio. Gerado para avaliação, não aprovação artística automática.

Exercício opcional: na AnimationPlayer, animação soco, chave de posição da Pelve em 0.10 s, compare y=415 e y=417 para sentir a flexão do preparo. Observe botas imóveis e quadril mudando; depois restaure 415. Não altere o apoio fixo para compensar a pose.
