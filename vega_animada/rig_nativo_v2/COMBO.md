# Combo no rig nativo sem alterar proporções do esqueleto

21/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf, Compatibility.

Wallace autorizou experimentar, apontando receio de desproporção. Esta é uma prova isolada de tensão adicional sobre o desenho nativo já aprovado; não acrescenta a antiga expansão básica de combate de novo. A montagem sem Combo continua em `preview_dois_bracos.tscn`, intacta. Sem troca do personagem ativo ou alteração de regras.

## Experimentar

F6 em `preview_combo.tscn`. Compare os botões **0 / base**, **5 / metade** e **10 / máximo**, em guarda e extensão. Use o soco no máximo, volte a zero durante a transição e compare mãos/juntas. Slider percorre as dez cargas; linha de tempo continua independente do Combo. Movimento reduzido resolve o destino imediatamente.

0/5/10 correspondem a 0%/50%/100% do percurso de tensão, não da escala do braço. Uma carga ocupa 10 pontos percentuais. Valores acima de 10 conservam o máximo visual, sem limitar o contador; o slider fica em 0–10 apenas por ser ferramenta de comparação.

## O que muda e o que permanece fixo

`combo_nativo.tscn/.gd` herda o rig dos dois braços, incluindo encaixes e orientação aprovada da mão distante. No início, substitui visualmente quatro Sprite2D por malhas Polygon2D equivalentes, com mesmo transform, textura e UV original. Os sprites ficam ocultos, não apagados. Em tensão zero, vértices/UV reproduzem exatamente esses recortes; não é outra arte.

Malhas superiores: 32 colunas/48 faixas; inferiores: 2 colunas/32 faixas. Perfil sin² transversal, zerado explicitamente nas extremidades. A máscara da placa superior usa o recorte da prova original e margem fixa de 16 pixels no atlas — maior que a diagonal da célula (~12). Assim nem as faces adjacentes à borda metálica deformam. Restante da liberdade de fibra transiciona até distância 40. Placas não recebem escala, rotação ou abertura extra neste passe.

Amplitudes padrão de 0.18/0.14 foram reaproveitadas da contração adicional original. São limites da largura local, não do membro inteiro; o bíceps tem parte dessa amplitude bloqueada pela placa. Deslocamentos máximos calculados por vértice: 26.82/16.73 pixels na coordenada da textura. Após os transforms existentes, equivalem a limites de aproximadamente 8.62/6.47 pixels no modelo para o lado próximo e menos no distante. Não são medidas de crescimento visível da silhueta, pois o atlas contém áreas transparentes.

Nenhuma tensão muda posição, comprimento ou escala dos ossos, tamanho da mão, núcleos dos encaixes, pelve ou apoios. O AnimationPlayer original permanece dono da pose; o Tween escreve somente os vértices gráficos. O Combo não força guarda ou alonga o alcance do golpe.

## Transição e interrupção

Reutilizadas `BracoV2Prova.tensao_por_combo`, `curva_transformacao` e `DURACAO_COMBO`: 200 ms, cubic-bezier(0.77,0,0.175,1). Mesmo destino não reinicia a transição, inclusive 10 → 11. Novo destino cancela o Tween anterior e parte da tensão atual. Consumo/zero restaura exatamente as malhas-base, sem acumular deformação. Movimento reduzido aplica o destino sem transição ampla.

Skill `animate`: propósito de indicação de estado/continuidade; preservar tempos e comportamento interrompível existentes, sem bounce, pulsação contínua ou biblioteca. A deformação local é deliberada na arte do personagem, não animação de layout dos controles.

## Verificação executada

Primeiro lançamento falhou em parsing de constante PackedVector2Array; substituída por Array[Vector2] literal, sem mudar máscara ou regra. Importação inicial retornara 0, mas não detectara esse erro antes do lançamento; manteve avisos antigos de recursos/RID/objetos ao encerrar.

`test_combo_nativo` passou headless/OpenGL, fixed-fps 60, zero falhas/exit 0. Verifica dez passos/saturação com int máximo, limites de largura/altura, extremos e placa imóveis, faces sem inversão, mãos/juntas/placas estáticas, 57 poses com ossos iguais aos da montagem aprovada, zeragem exata, transições intermediárias/interrupção/reduzido e controles nas duas resoluções. Regressões `test_encaixes_nativo`, `test_dois_bracos_nativo` e `test_braco_v2_combo` passaram headless, zero falhas/exit 0. Testes e capturador encerraram sem avisos de recursos neste passe. Sem suíte completa ou teste do combate.

Dezesseis capturas OpenGL em `docs/evidencias_combo_nativo/`, guarda/extensão × 0/1/5/10 × duas resoluções. Inspecionadas guarda 0/10 1920 e extensão 10 1024: variação discreta, mãos/alcance preservados visualmente. Vídeo `ciclo_combo.avi`: log confirma 134 frames/30 FPS/1152×648, exit 0/stderr vazio; gerado para avaliação do usuário. Não é aprovação artística automática ou validação completa de perspectiva.

Exercício opcional: em `combo_nativo.tscn`, selecione a raiz e reduza `contracao_biceps` de 0.18 para 0.12; F6 e compare 0/10. Só muda a amplitude local de fibra; não o significado de cada carga, a mão ou o esqueleto. Depois restaure 0.18. Os testes atuais protegem os parâmetros padrão; experimentos de direção artística não justificam apagar invariantes do rig.
