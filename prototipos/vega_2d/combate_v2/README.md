# Vega v2 no combate real

21/10/2026. Godot 4.7.2.stable.official.ed1daf0bf, Compatibility.

O usuário considerou boa a referência de três poses e pediu vê-la no jogo. Esta pasta substitui a apresentação industrial ativa, não as provas anteriores. Avaliação do movimento pelo usuário ainda pendente.

## Calibração atual: braços menores e mãos legíveis

21/10/2026. Usuário enviou screenshot rejeitando a revisão longa: braços grandes, mãos pequenas próximas aos joelhos. A faixa numérica anterior estava protegendo uma silhueta rejeitada. Escalas .80/.77 → .66/.64, mãos .34 → .56; alvos de repouso (155,505)/(520,520) → (170,420)/(475,445), soco (323,-40) → (250,-32). Bíceps sem compressão longitudinal; tempos/curva/prontidão/Combo/regras preservados. Em tela, mãos aproximadamente 36%/37% maiores e cadeia dos braços cerca de 17% menor. Nenhuma geração/edição raster nova. `animate` orientou preservar transições interrompíveis, não inventar novos efeitos.

Substituída a regressão 35–42%/alcance >300 por marcos da montagem: pulsos de repouso y=400–470, envelope total do Sprite2D terminando até y=550 (antes do joelho mais alto, aproximadamente y=600), distância cuff→knuckles entre .65–.85 do antebraço, extensão usando >94% do comprimento calibrado. Os limites protegem esta candidata visual, não validam anatomia universal. Cobertura de cartas/encaixes/Combo/reduzido/interrupção/pés continua presente.

Cinco cenas headless fixed-fps 60 (`test_vega_combate_v2`, `test_vega_playtest`, `test_braco_v2_combo`, `test_interacao_hud_combate`, `test_resolucao_cartas`) e funcional `verificar_vega_animada` OpenGL passaram com exit 0. Não repetida suíte completa ou funcional headless: travamento intermitente de encerramento anterior não foi corrigido. Avisos de recursos/RID persistem. 16 capturas de arena salvas OK nas duas resoluções, mais quatro ampliadas, em `docs/evidencias_vega_combate_v2_maos/`; versões anteriores preservadas. Inspecionados repouso em 1920/1024 e modelo ampliado de repouso/guarda/extensão. Sem vídeo novo desta revisão.

Avaliação visual ainda pendente; perspectiva de juntas/segundo braço continua limitada. Conferir F5, mão/coxa no repouso e retorno do soco. Exercício opcional: mover somente y de um alvo de repouso em 5 px e comparar, depois restaurar.

## Histórico: proporção e repouso após primeira rejeição visual

O usuário considerou os braços comicamente curtos e a pose permanentemente em combate. Corrigidos em 21/10/2026: projeção superior (.85,.70) → (.85,1.0), escala ataque .73 → .80, distante .64 → .77, alvo de soco (237,-42) → (323,-40), escala de mão .45 → .34. Bíceps distante não fica mais escondido com placa solta na frente. Isso aumenta comprimento da cadeia em aproximadamente 27%/40%, sem escalar ossos durante a animação ou mudar o feixe-base aprovado. Imagens do atlas não foram editadas ou geradas novamente.

Postura separada da expansão/tensão: `prontidao = 0` mantém punhos baixos (155,505)/(520,520), abaixo do quadril; `prontidao = 1` usa guarda durante ação. Preparo de 100 ms levanta braços, extensão de 100 ms usa alcance novo, retorno de 160 ms recolhe punho, relaxamento de 200 ms baixa guarda. Duração total 560 ms não bloqueia cartas. Dano relaxa junto com o retorno de 160 ms. Ataque durante relaxamento retoma da altura atual; reset/reduzido limpam prontidão. Volume de combate e progressão por Combo continuam independentes, sem perda de cargas quando baixa a guarda. `animate` orientou Tween nativo interrompível e mesma curva existente, não um sistema novo.

Verificação desta revisão: nove cenas de teste passaram exit 0 (`test_vega_combate_v2`, `test_vega_playtest`, `test_braco_v2`, `test_braco_v2_combo`, `test_hud_conceito_ativo`, `test_interacao_hud_combate`, `test_jogador_combate`, `test_resolucao_cartas`, `test_layout_combate`), headless fixed-fps 60. Teste ampliado protege proporção candidata, alcance, braços baixos com Combo, levantar/recolher/relaxar e retomar durante relaxamento, além de regras/lifecycle anteriores. Calibração .76 distante falhou no limiar de 35% da altura-base; ajustada para .77 antes da reexecução. Teste funcional imprimiu 0 falhas nas cinco execuções, mas duas headless terminaram com -1073741819; outra headless, verbose headless e OpenGL tiveram exit 0. Falha nativa intermitente ao encerrar ainda não isolada; não declarar estabilidade plena. Avisos anteriores de recursos/objetos/RID persistem.

Capturas novas preservam as anteriores em `docs/evidencias_vega_combate_v2_proporcao/`: 16 imagens da arena (oito por resolução), mais quatro do modelo isolado. Inspecionados repouso em 1920/1024, extensão e modelo ampliado. Vídeo `ciclo_corrigido.avi`: 154 frames, 30 FPS, 1152×648, gravação terminada normalmente; código de saída do processo não capturado. Última reação é chamada visual direta, não turno inimigo. Avaliação artística pendente: peças ainda usam vista reaproveitada e conectores não se tornam anatomicamente corretos por passar testes.

Conferência: F5, esperar sem jogar, atacar e esperar o retorno mesmo com Combo. Exercício opcional: variar somente relaxamento de .20 para .25 s e comparar; depois restaurar.

## Responsabilidades

- `main.gd` instancia `vega_combate.tscn`, envia Combo/visibilidade/movimento reduzido e conserva os gatilhos `socar`, `receber_dano`, `reiniciar`. Regras de cartas/dano continuam nos módulos existentes.
- `vega_combate.gd` apresenta repouso com braços baixos, respiração, preparo/guarda de 100 ms, extensão de 100 ms, retorno de 160 ms, relaxamento de 200 ms e reação ao dano. Tween nativo; um ataque novo substitui o anterior do valor atual, dano interrompe ataque, ocultar/trocar run limpa estado. Movimento reduzido usa feedback de cor sem soco amplo ou respiração.
- `modelo.gd` monta corpo/punhos do atlas novo com duas instâncias do braço aprovado. Malha do tronco acompanha os ombros; pernas/pés preservam exatamente seus vértices originais. Sombras sob cada pé e respiro lateral em janelas compactas evitam o pé atrás da Barreira em 1024×576.
- `braco_articulado.gd` herda feixes, placas e tensão de `braco_v2/braco_prova.gd`, acrescentando pivôs ombro/cotovelo/punho e IK de dois segmentos. Comprimentos projetados constantes durante o soco; alcance limitado, sem esticar os ossos. A projeção estática atual do braço superior (.85, 1.0) ajusta largura sem encurtar o comprimento; é calibração 2D, não reconstrução anatômica 3D.

Regra preservada: tensão adicional = `clamp(Combo, 0, 10) / 10.0`; 10 ou mais satura somente o visual. Finalização/zeragem aliviam até a base de combate. Não existe teto mecânico novo, espera pela animação, alteração de custo/dano ou acoplamento do resolver ao Tween.

A skill `animate` orientou movimento local, contido e substituível, com alternativa reduzida, usando Godot em vez de biblioteca web. `imagegen` foi usada somente para corpo-base/punhos derivados das referências locais inspecionadas.

## Asset e limites visuais

`base_e_punhos_01.png`: 1774×887, alfa real conferido. Geração/edição com ferramenta integrada (não CLI), referenciando `docs/arte_vega/vega_v2_soco_poses_02.png` e `vega_v2_referencia_04.png`. Fonte gerada preservada:

`C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-0a702c32-7099-4656-8e6a-e4ac8d924ddb.png`

Saída copiada sem edição raster externa. Foram pedidos 2048×1024 se possível; a ferramenta entregou 1774×887. O punho inferior veio com antebraço indevido: região descartada da montagem, não corrigida artificialmente em código. Corpo usa Rect2(300,0,730,860); apenas punho superior usa Rect2(1218,119,286,337). O mesmo punho fechado é reutilizado/espelhado e rotacionado nos dois braços.

Limites: não reproduz quadro a quadro a prancha estática, não resolve rotação tridimensional do tronco/mãos nem valida biomecânica. Braço distante e mão reaproveitados exigem avaliação de perspectiva. Todos os ataques por enquanto compartilham um soco; habilidades mantêm seu feedback existente. Dano lógico e feedback do alvo continuam imediatos, sem esperar a extensão do braço. Retrato da HUD e ilustrações das cartas ainda são anteriores: não foram redesenhados neste recorte.

## Histórico: verificação da integração anterior à revisão

13 verificações focadas passaram com exit 0: `test_vega_combate_v2`, `test_vega_playtest`, `verificar_vega_animada` (script SceneTree), `test_hud_conceito_ativo`, `test_composicao_suave`, `test_layout_combate`, `test_polimento_combate`, `test_interacao_hud_combate`, `test_jogador_combate`, `test_resolucao_cartas`, `test_braco_v2`, `test_braco_v2_combo`, `test_vega_corpo_v2`. Headless com `--fixed-fps 60`, sem suíte completa. Testes legados de apresentação foram atualizados para exigir o novo modelo e ausência do PNG antigo, preservando verificações funcionais de clique, custos, dano, inimigo, mapa e reset.

Novo teste verifica Combo 0/1/5/10/11/100 real nos dois braços, placas sem escala, cinco poses com comprimentos/encaixes constantes, pernas imóveis, ataques rápidos, dano interrompendo ataque, movimento reduzido e limpeza ao trocar run. Sequência real Direto→Direto→Quebra-chassi: 19 de dano, 3 Energias, Combo 0 final, independente de terminar animações.

Falha inicial: 360 comparações exatas de pernas usavam UV menos origem como referência. Round-trip UV medido em 0.00003052 px; teste passou a comparar com a geometria original diretamente, mantendo igualdade exata. Caminho de peso zero também evita operações desnecessárias no tronco. Nenhuma regra de gameplay foi alterada para fazer teste passar.

14 capturas do `main.tscn` real salvas OK em `docs/evidencias_vega_combate_v2/`: guarda 0/5/10, preparo, extensão, retorno e dano em 1920×1080 e 1024×576. Inspeção levou a corrigir oclusão do braço distante, tamanho do punho e sobreposição do pé com a Barreira; capturas repetidas. Imagens do modelo isolado são diagnóstico, não substituem a arena. Vídeo `ciclo_real.avi`: 154 frames, 30 FPS, 1152×648; cartas reais e depois chamada de reação visual ao dano, não turno inimigo real nessa última demonstração. Gravação encerrou normalmente, sem código de saída do processo capturado pelo wrapper PowerShell. Logs ainda têm RID/texturas/fontes/objetos/recursos em uso ao encerrar; não corrigidos neste recorte. Importação headless sem erro de parsing. Não equivale a aprovação artística ou teste manual pelo usuário.

Para experimentar: F5, iniciar combate, jogar Direto Hidráulico para ganhar Combo e Quebra-chassi para consumir. Observe encaixe do ombro, punho fechado, guarda e alívio do volume. Exercício opcional: mudar somente o retorno de `.16` para `.20` em `socar()` para comparar o peso, depois restaurar; não alterar dano/custo.

APIs consultadas: [Node.reparent — Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_node.html), [Polygon2D — Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_polygon2d.html).

## Prompt integral do atlas

```text
Use case: precise-object-edit / background-extraction / identity-preserve.
Asset type: ONE transparent production atlas for a layered 2D comic game character. Wide landscape 2:1 canvas, 2048x1024 if possible. EXACTLY THREE detached parts: the body-base occupies the LEFT TWO THIRDS of canvas; two isolated closed mechanical fists occupy the RIGHT ONE THIRD, one ABOVE the other, with generous transparent gaps. No labels, grid lines, writing, background, ground shadows or extra parts.

Input image 1 is the approved key-pose sheet. Use the LEFT "01 GUARDA" full-body figure for stance and camera. Input image 2 is the approved identity master for face, hair, clothing and mechanical materials. Preserve the SAME grumpy confident woman, brown skin, jaw-length shaggy wavy black hair, plain charcoal tank, graphite loose trousers, plum shirt tied around waist, black lace-up boots. Crisp weighted comic ink and flat shadows, not realistic rendering.

PART A, occupying the left two thirds:
One full-height BODY BASE in the guard pose, from crown to both complete boots, same slightly bent knees, same wide left-lead fighting stance toward screen RIGHT, same torso/head camera as the LEFT panel. REMOVE ONLY BOTH PROSTHETIC ARMS: retain rounded natural skin shoulder caps, ending neatly at the prosthetic sockets below deltoids. No synthetic biceps, elbow, forearm or hands attached. Complete obscured side seams of tank/shirt/trousers behind the removed arms, so it is a complete torso-and-legs base ready for arm rigging. Normal human torso and legs. No wounds. No cyborg torso armor. Same guarded confident facial expression and eye direction. Not a mannequin and no added gloves. Keep the body feet planted on a horizontal baseline. Body may fill most of the left area, but nothing touches the canvas edge.

PART B, upper right:
A single ISOLATED CLOSED MECHANICAL RIGHT FIST with a short wrist cuff, from the guard pose: graphite articulated knuckle plates, four fingers curled with thumb visibly folded OUTSIDE fingers, small cyan cuff and subtle magenta latch matching reference. Three-quarter view of the back of the hand, the cuff points DOWN and knuckles point UP, prepared for the guard arm. No biceps, forearm, arm, elbow, flesh or extraneous finger. Proportional fist, not giant gauntlet.

PART C, lower right:
The SAME closed mechanical right fist and wrist cuff in the straight-punch view from the RIGHT "03 EXTENSÃO" panel: wrist cuff on the LEFT, knuckles point horizontally screen RIGHT, thumb tucked OUTSIDE curled fingers, wrist straight. Same design, dimensions and materials, NOT a second fist variant. No forearm or body.
These two views are separate hand sprites; give each fist generous fully transparent padding. Body and fists never overlap. Keep the two fists visibly large enough to inspect, but anatomically proportional once independently scaled in the game.
All empty canvas must have genuine alpha transparency, no baked checkerboard or colored background. Do not redraw the old industrial Vega or add yellow/white armor. Preserve source character identity. This is preparation for a shoulder-elbow-wrist rig, not an animated sequence or new character design.
```
