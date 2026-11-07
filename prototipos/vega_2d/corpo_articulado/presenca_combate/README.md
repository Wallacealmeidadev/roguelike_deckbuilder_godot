# Prova 14: respiração em guarda e reação ao dano

23/10/2026 — Godot 4.7.2.stable.official.ed1daf0bf / Compatibility.

## Aprovação posterior

Wallace respondeu “boa, ficou ótimo também” em 23/10/2026. Respiração em guarda e reação ao dano passam a ser referência aprovada, preservando os dois golpes/alternância da prova 13. Os relatos abaixo de avaliação pendente descrevem a entrega anterior ao retorno. Sem novo teste de execução neste registro; Combo e integração F5 continuam fora do recorte aprovado.

## Recorte

Usuário autorizou acrescentar respiração/reação à versão 13 aprovada. Não reabrir pintura, anatomia ou os dois golpes. Esta variante é de apresentação, ainda sem integração F5, tensão de Combo nas peças reconstruídas ou alteração de regras.

Observado: a versão 13 retorna a uma guarda estática; clipes herdados de respirar/dano pertencem a adaptações anteriores e não bastam para a cadeia nova inteira. Regra: guarda de lutadora, ambos os braços coerentes, pés apoiados e um único controlador dos ossos. Hipótese: ciclo discreto de peito/ombros/mãos e recuo curto ao dano mantêm prontidão sem a sensação de personagem travada.

## Conferir

Abra `preview.tscn`, F6. Esquerda é a versão 13; direita começa respirando. O foco é comparar espera e reação, não outro redesenho.

- **D:** simular reação ao dano na candidata. Não altera Vida ou qualquer regra de combate.
- **B:** ligar/desligar respiro para comparar com guarda estática. Durante um golpe, a preferência só vale no retorno, sem cancelar o ataque.
- **G:** sair da inspeção e retomar a guarda/respiro.
- **Espaço:** golpes alternados aprovados. Dano não consome a ordem dos braços.
- **L:** quatro vezes mais lento; **R:** reduzido; **Z:** detalhe/corpo; **O:** juntas; **X:** reiniciar sequência.
- **1/2/3 + T:** inspeção dos golpes, como na prova 13. **4:** pausar na inspiração máxima; **5:** pausar no pico da reação. Inspeção cancela feedback e pausa animação; G retoma.

Teste principal: observe um ciclo parado, compare com B; em seguida, L, Espaço, D durante a extensão e Espaço novamente. A reação deve absorver o impacto sem desmontar a guarda, e o ataque seguinte deve continuar com o braço esperado. D repetido também precisa partir da posição atual.

Exercício pequeno: em `vega_presenca.tscn`, selecione a raiz, mude **Amplitude Respiro** de 1 para 0,7, execute a prévia e compare; depois restaure 1. O parâmetro é aplicado ao construir o clipe no início da cena. Não muda duração, dano ou os golpes aprovados. B é um comparador estático deliberado, não transição de gameplay.

## Implementação

`vega_presenca.gd/.tscn` deriva da prova 13. Acrescenta dois clipes à biblioteca que já é privada, sem duplicar/reescrever os existentes. Uma cópia neutra da guarda fornece todos os controles, evitando que um canal de outro gesto fique sem reset. Todas as propriedades animadas já existem nos clipes de ataque; não acrescentar escala de membros ou deslocamento independente de mãos.

- **`guarda_respirando`: 2,4 s**, loop, chaves 0 / 0,6 / 1,2 / 1,8 / 2,4, interpolação cúbica nativa. Duração/chaves reaproveitam o ciclo anterior do projeto. Pelve sobe no máximo 1,5 px, abdômen/peito giram discretamente, cabeça compensa e mãos/ombros acompanham com pequenas acomodações. Joelho/apoios mantêm a ligação e botas ficam imóveis. Amplitude padrão 1.
- **`reacao_corporal`: 0,26 s**, chaves 0 / 0,10 / 0,26, interpolação linear nativa, como a reação anterior. Pelve recua 4 px/cede 2 px, giros se distribuem por abdômen/peito/cabeça/ombros e braços guardam. Sem nova expressão facial raster, tremor de câmera ou balanço dos pés.
- Transições reutilizam **captura 0,10 s para dano/golpes e 0,16 s para retomar guarda**, cúbica in-out do projeto. Um AnimationPlayer escreve ossos; nenhum Tween, seno por frame ou solver concorrente articula o corpo.
- Feedback de dano reutiliza o Tween de **cor** existente: 0,10 s até tom de impacto, 0,16 s até branco. Interrupções cancelam o Tween anterior; não acumular flashes ou deixar callback antigo interromper um golpe novo.
- Qualquer golpe ou dano termina em `retomar_guarda()`. Se respiro estiver desligado ou em reduzido, guarda estática. O reduzido mantém alternância/feedback de cor sem articulação; o fim do flash volta à guarda sem deixar Tween pendente.
- Dano não altera `proximo_braco_distante`/`ultimo_braco_distante`. Ocultar pausa/cancela pelo adaptador herdado, ignora ataques/dano invisíveis e mostrar retoma guarda viva. Reset começa pelo próximo e retoma o respiro quando habilitado.

Pintura, materiais de integração, UVs, pesos, escala dos recortes, palma e encaixes são os mesmos. A sombra já existente continua lendo a cadeia antes do desenho. A margem maior da versão 13 foi preservada; a caixa lógica da atriz continua 650×850.

## Skill e intenção

Skill **animate** aplicada a indicação de prontidão, feedback de impacto e continuidade espacial. É animação de personagem solicitada, não decoração de atalhos de UI web. Usados tempos/captura nativos já registrados, com interrupção/reduzido desde o início; sem biblioteca externa, novo sistema de estados ou spring paralelo. Hover não é parte deste recorte PC.

## Verificação real

- Godot confirmada **4.7.2.stable.official.ed1daf0bf**. `tests/test_presenca_combate.gd` passou headless e OpenGL/fixed-fps 60, **zero falhas/exit 0**.
- **148 poses** novas: 121 ao longo do ciclo e 27 na reação. Mesma superfície/pesos/UV/fonte; extremos retornam à guarda, botas realmente fixas, distâncias de dois marcos faciais preservadas, centros/comprimentos/escala dos segmentos intactos e nenhuma face invertida, incluindo transparências.
- **2.664 amostras GPU** de cobertura de ombro/cotovelo/punho nas duas cadeias. Não valida toda borda ou anatomia/perspectiva em 3D.
- Dez poses-chave dos dois golpes renderizadas **pixel a pixel idênticas** à referência 13 no mesmo canvas. Chaves/tempos/valores de todos os clipes anteriores também conferidos; clipes novos não aparecem na biblioteca da referência.
- Deslocamento do punho próximo na inspiração máxima: ~4,54 px nativos; pico de reação: ~24,45 px. São medidas da amplitude proposta, não prova de naturalidade. Testes de movimento usam amplitude de respiro padrão 1.
- Respiração→golpe→dano→respiração, dano repetido e dano→ataque sem salto imediato de mãos/tronco; ordem preservada, preferência de respiro durante ataque sem cancelamento, guarda estática, reduzido/cor/Tween encerrado, ocultação/retomada e handlers verificados. Isso não é teste de combate real ou teclado físico automatizado.
- Regressões `test_golpes_alternados.gd` e `test_integracao_tronco.gd` passaram headless/OpenGL, zero falhas/exit 0. A versão 13 mantém 114 poses/2.052 amostras GPU e seus resultados de juntas/guarda/golpes.
- Captura GL exit 0/“capturas OK”: **19 PNGs** em `docs/evidencias_vega_presenca_14/`, ciclo, reação, nativos, dois detalhes e marcos. Inspecionados inspiração em corpo inteiro, reação ampliada e marcos. Fists permanecem legíveis nesses enquadramentos; ritmo e sensação de impacto aguardam avaliação de Wallace.
- Movie Maker gerou `presenca.avi`, **329 quadros/60 FPS**, ~5,48 s, ciclo, dano, golpes e danos repetidos, exit 0. Sem reprodução externa nesta execução; gravação não equivale a validação artística do movimento.
- Logs finais de teste/captura/filme sem stderr. Importação conserva avisos conhecidos de recursos/RID/fontes/ObjectDB ao encerrar. `git diff --check` passou. Sem suíte inteira, integração de cartas/Combo, gameplay ou troca do F5.

## Limites

A roupa continua sendo a pintura deformável aceita, sem nova vista/expressão facial, simulação de tecido, pernas completas ou cabelo independente. O pequeno movimento da pelve é apresentação; não desloca posição lógica de combate. A versão 14 tem aprovação visual do usuário, mas isso não valida sua integração ao combate principal. Próximo recorte futuro: Combo e adaptação ao combate principal, não iniciados aqui.
