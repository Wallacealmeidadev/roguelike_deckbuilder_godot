# Vega v2 — montagem corporal isolada

21/10/2026. Godot 4.7.2.stable.official.ed1daf0bf. Abra `preview.tscn` desta pasta e execute **F6**. Não é a Vega ativa do jogo.

## Objetivo e avaliação

Atualização posterior: o usuário aprovou a montagem em geral, com ressalva de que o braço parecia fora do soquete. Ajustada somente a âncora local de (-30,20) para (-40,45), correspondente à cabeça visível do feixe; ombros-alvo, escala, ângulos e progressão permanecem iguais. Isso desloca as peças cerca de 8 px para esquerda/26 px para cima na frente e 3 px para direita/23 px para cima atrás, no espaço local do corpo. Não houve pintura ou mudança das malhas.

Verificação do ajuste: novas 14 capturas em `docs/evidencias_vega_corpo_v2_encaixe/`, inspecionadas em repouso pequeno e Combo máximo grande; [vídeo atualizado](../../docs/evidencias_vega_corpo_v2_encaixe/ciclo_corpo.avi), 177 frames a 30 FPS, 1152×648. Evidências anteriores preservadas. `test_vega_corpo_v2`, `test_braco_v2_combo` e `test_braco_v2` passaram com `--headless --fixed-fps 60`; o teste de Combo foi repetido com o mesmo resultado. Na execução normal houve uma falha na asserção de estado intermediário após timer de 80 ms; não reproduzida com passo fixo, sem alterar lógica/animação para contornar. O teste corporal agora verifica também a calibração visual independente da constante usada na montagem. `git diff --check` passou. Encaixe ajustado ainda depende de conferência do usuário; não é rig de ação validado.

Sequência recomendada, não implementada nesta correção: articular ombro/cotovelo/punho e validar um único soco com retorno preservando o Combo; depois guarda/respiração/defesa/reação; integrar ao combate real preservando os feedbacks existentes; atualizar retrato e detalhes das cartas a partir da mesma identidade. O próximo objetivo pequeno recomendado é o soco completo, não todos esses sistemas de uma vez.

O usuário aprovou o braço e depois a resposta linear ao Combo: 10 pontos percentuais da tensão adicional por carga, máximo visual a partir de 10. Esta etapa verifica o encaixe desses braços em um corpo inteiro. Aprovação anterior não aprova automaticamente este novo corpo-base, postura, perspectiva ou proporções.

Postura neutra com braços baixos, explicitada antes da geração, para testar ombros/roupa e volume sem introduzir soco ou flexão de cotovelo. Pés, pernas e torso permanecem fixos. A referência 04 à esquerda preserva a pose original, com a mão levantada; a montagem à direita é uma derivação, não extração idêntica da personagem.

Controles: Ativar combate/Voltar ao repouso, +1, +3, 10, Consumir e movimento reduzido. Ganhar cargas ativa os dois braços; consumir mantém a base de combate. 10→11 mantém a mesma amplitude e sobe apenas o contador. Rótulos mostram destino/contador imediatamente, não o progresso interpolado.

[Vídeo real da montagem](../../docs/evidencias_vega_corpo_v2/ciclo_corpo.avi): 177 frames, 30 FPS, 1152×648, repouso→combate→Combo 5→10→11→0→repouso. Capturas nas duas resoluções na mesma pasta. Gravação não equivale a avaliação humana do ritmo.

## Arquivos e implementação

- `corpo_base_01.png`: base transparente 1024×1536 derivada da referência 04, sem próteses. Cabelo, expressão, roupa de rua e leitura humana foram tratados como invariantes. A peça nova ainda aguarda avaliação.
- `corpo_prova.gd`: monta Sprite2D de corpo e duas instâncias do braço aprovado; apenas encaminha estado de apresentação. Não conhece cartas, run ou personagem lógico.
- `preview.gd` / `preview.tscn`: laboratório técnico; referência, controles e escala para 1024×576 e 1920×1080.
- `tests/test_vega_corpo_v2.tscn` e `tests/capturar_vega_corpo_v2.gd`: testes e evidência reproduzível; `--filmar` no capturador reproduz o vídeo com Movie Maker.

Reutiliza sem mudanças `vega_animada/braco_v2/braco_prova.gd`: ativação reversível de 500 ms e tensão de 200 ms, curva existente e alternativa reduzida. A skill `animate` orientou preservar a indicação de estado e as interrupções, sem acrescentar idle, oscilação ou rotação corporal antes da aprovação dos encaixes. Não há biblioteca ou sistema novo de animação.

A âncora local corrigida do braço (-40,45) é mapeada aos ombros (345,345) e (702,390). Transformações dos encaixes não animam com Combo. Escalas de montagem 0.95 frontal/0.85 traseira e inclinações 0.18/-0.24 rad; uma instância é espelhada horizontalmente. O corpo oclui os encaixes e bordas internas dos braços; sombras simples de contato são estáticas. O primeiro passe tinha braços pequenos e uma mão encoberta; escala/abertura ajustadas e capturas refeitas.

## Limites importantes

O segundo braço é reaproveitamento espelhado de estudo de uma vista: mão, luz e perspectiva NÃO constituem desenho independente definitivo. Os conectores de ombro desenhados na base são novos e precisam de avaliação. Não é rig corporal completo, nem prova de que um soco/flexão funcionará. Sem respiração, troca de apoio, flexão do cotovelo/dedos, golpe, reação a dano ou integração na arena. Não usa peças da Vega industrial antiga nem troca o retrato/HUD/cartas/asset ativo.

## Verificação executada

Importação headless retornou 0, com mensagens de RID/objetos/recursos em uso ao encerrar. A primeira captura encontrou erro de sintaxe em literais Color da cena; corrigido e capturas refeitas, sem erros na execução final.

Cinco testes focados retornaram 0: `test_vega_corpo_v2`, `test_braco_v2_combo`, `test_braco_v2`, `test_vega_playtest`, `test_hud_conceito_ativo`; todos reportaram 0 falhas. Os dois últimos continuam com mensagens de objetos/recursos em uso ao encerrar. Não corrigidas nesta prova, sem suíte completa.

O teste novo confere dimensões/alfa, mapeamento dos ombros, corpo/pés fixos, mãos ancoradas, progressão sincronizada durante a animação dos dois braços, consumo durante ganho, retorno exato à base, modo reduzido, contador acima de 10, controles e layout nas duas resoluções. Não testa estética ou perspectiva por código.

Quatorze capturas OpenGL Compatibility na RTX 3060, salvamento OK. Inspecionados repouso e Combo 10 grandes e Combo 5 pequeno; capturas refeitas após ajuste dos braços. `git diff --check` passou. Sem teste desta montagem pelo usuário; não chamar a montagem ou rig de aprovado por esses resultados.

Próxima verificação pequena: F6, comparar repouso/combate/Combo 10, olhando primeiro ombros e proporção das mãos. Consumir durante ganho e testar modo reduzido. Exercício opcional: mudar somente `contracao_combo_antebraco` de 0.14 para 0.10 no braço e comparar o volume no corpo, depois restaurar. A relação de dez passos permanece intacta.

## Geração da base e prompt

Skill `imagegen`, ferramenta integrada, sem CLI/API externa. Uma referência local inspecionada: `docs/arte_vega/vega_v2_referencia_04.png`. Saída copiada para `vega_animada/corpo_v2/corpo_base_01.png`; fonte preservada:

`C:/Users/Wallace/.codex/generated_images/01a15471-4a72-7593-a6ce-1852411b6994/exec-c726aef7-bd64-4956-9eb8-78e34acadb91.png`.

Alfa real verificado em cantos e pontos externos. Inspeção visual do corpo gerado e da montagem; sem garantia de identidade pixel a pixel. PNG não foi retocado por scripts.

Prompt final:

```text
Use case: identity-preserve / precise-object-edit / background-extraction.
Asset type: a single transparent PNG BODY BASE for an articulated 2D comic game character.
Input image 1 is the approved character design master. This is production asset preparation, NOT a redesign.

Extract and faithfully redraw ONLY the full-body woman on the LEFT of the sheet as one large isolated cutout, portrait 2:3 canvas, crown and both boots entirely visible with generous transparent margins. Exclude the portrait and the arm studies on the right, all lettering, the blue background, and the painted ground shadow.

Critical identity invariants: SAME adult woman, SAME medium brown skin, black longer shaggy wavy bob to jaw/upper neck with asymmetric side fringe, SAME confident grumpy suspicious expression, dark eyes, broad nose and strong brow. Do NOT beautify or make her cheerful. SAME charcoal plain tank top, loose dark graphite street trousers WITHOUT mechanic cargo pockets, SAME muted wine/plum long-sleeve shirt tied around her waist, SAME heavy black lace-up boots. SAME sturdy human proportions, strong shoulders, natural torso, planted slightly wide stance. SAME heavy comic ink outlines, angular flat shadow planes, limited hatch accents. Not photoreal, not 3D, not painterly airbrush. Keep visible face detail and shoulder anatomy.

Technical assembly change ONLY: prepare the base WITHOUT the two cybernetic arms. Keep the two natural rounded skin shoulder/deltoid caps attached to the torso, ending neatly at the prosthetic attachment line just below the deltoids. NO biceps, forearms or hands: those will be attached as separate animated parts in Godot. Leave the surrounding area genuinely transparent rather than filling the missing prostheses with skin, cloth or background. These are clean prosthetic assembly sockets, no wounds, no gore. Complete the formerly occluded side seams of the tank and trousers so no holes remain in the body layer.

For this NEUTRAL assembly pose the two shoulder caps point gently down and outward, ready for the separate arms to hang down clear of the waist and thighs. Keep the torso upright in slight three-quarter view, front visible and gaze directed toward screen RIGHT, the stance relaxed but grounded, not T-pose, not an action pose. No mechanical arms drawn anywhere on the canvas; only the skin shoulder caps remain. Do not shorten the legs or enlarge the head. No outfit additions, weapons, jewelry, yellow industrial details, logos, writing, scene props or ground.
Transparent background with real alpha, no baked checkerboard. One body base only, centered, large and readable.
```

