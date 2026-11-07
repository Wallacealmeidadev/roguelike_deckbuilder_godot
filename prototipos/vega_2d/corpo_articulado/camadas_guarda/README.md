# Camadas da guarda — primeira preparação de tronco/quadril

24/10/2026 — Godot **4.7.2.stable.official.ed1daf0bf**, Compatibility. Candidatas de arte/registro estáticos, não nova animação ou substituição do F5.

## Retorno e revisão localizada 02

**Aprovação posterior, 24/10/2026:** Wallace respondeu “perfeito, melhorou”. Tronco 02/quadril 01 são a base visual estática aceita. Preservar a revisão, sem estender a aprovação a movimentos ou integração F5. O parágrafo seguinte registra o estado da entrega antes desse retorno. Nesta confirmação somente registros atualizados; JSON/diff conferidos, sem repetir testes Godot.

Wallace aprovou a montagem 01 e pediu somente um aumento discreto do volume dos seios, sem roupa reveladora. `tronco_02.png` é a nova candidata ativa na mesma prévia: regata opaca, mesma gola/cobertura, sem redesenhar ombros ou alterar os marcos. Skill imagegen fez a edição raster; fonte/prompt integral/hash no [manifesto.json](manifesto.json). A indicação de 15% no prompt é direção qualitativa, não medida obtida. `tronco_01.png` e `quadril_01.png` permanecem intactos. A aprovação anterior não aprova automaticamente a 02.

**Verificação desta revisão:** testes headless/OpenGL exit 0, zero falhas/stderr vazio; hashes de 01/02/quadril, textura ativa, alfa/mipmaps, registro uniforme, guias/atalhos, **3.164 pontos** de sobreposição opaca e **372 amostras GPU** cobertas. Marcos/transformações não recalibrados. Captura GL exit 0/OK, cinco PNGs atualizados; montadas/registro inspecionados. Capturas da 01 preservadas em `docs/evidencias_vega_camadas_guarda_16/base_01/`. Importação/reimportação exit 0 conservam avisos de 33 ObjectDB/13 recursos. Sem suíte completa, nova animação ou F5. Não medida invariância pixel a pixel. Os números da seção de verificações inicial abaixo referem-se à 01.

Exercício sem editar: F6, **P** oculta/mostra o quadril para observar a continuação da regata; **R** restaura. Avaliar o volume na montagem, não só na fonte ampliada.

## Objetivo observável

Após aprovar a prancha corporal 04, Wallace autorizou preparar camadas da guarda com regiões ocultas. **Observado:** a referência é uma imagem opaca com corpo, membros e roupa juntos. **Regra:** preservar identidade, conceito corporal, ombro próximo humano sem cúpula mecânica duplicada e distante aprovado. **Hipótese desta etapa:** tronco completo sob os braços e tecido sobreposto na cintura permitem preparar articulação sem depender do recorte visível da ilustração inteira.

Entrega: duas fontes com alfa e uma bancada F6 para inspecionar como se encontram. Nenhum braço foi redesenhado, nenhum osso/clipe do rig aceito foi alterado. A cabeça, próteses e pernas vistas à esquerda pertencem à referência; não fazem parte das duas peças novas.

## Abrir e comparar

Abra `preview.tscn`, **F6**. Esquerda: guarda da prancha 04, recortada apenas na apresentação. Direita: tronco e quadril candidatos, sem cabeça/membros novos.

- **E:** separar/juntar as peças; mostra as margens que ficam ocultas.
- **T / P:** ocultar/mostrar tronco ou quadril.
- **F:** referência translúcida atrás das peças, para conferir proporções/posição.
- **O:** marcos manuais. Cruzes amarelas são referências na prancha; pontos ciano são os ombros da peça; magenta é o nó da camisa.
- **R:** restaurar peças, ajustes e inspeção. Não é o modo reduzido das prévias animadas: esta bancada é estática.

O que avaliar: desenho do tronco sem os braços cobrindo-o, continuidade da regata/camisa na cintura e contornos dos deltoides humanos. A montagem deve ser lida como duas partes da mesma personagem. Não interpretar ausência de membros à direita como personagem final ou animação pronta.

Exercício pequeno no editor: abra `camadas_guarda.tscn`, selecione a raiz e mude **Ajuste Tronco** de `(0, 0)` para `(5, 0)` antes de executar a prévia. Ligue O/F para comparar a posição. Depois restaure `(0, 0)`. Ajuste é só translação de uma candidata; não altera a referência aprovada, os PNGs ou as regras.

## Fontes produzidas e limites da geração

- `tronco_01.png`: pescoço sem cabeça, deltoides humanos, regata/abdômen e continuação inferior escondida sob a camisa. Peito/tecido antes cobertos pelos punhos foram desenhados. Nenhum cap metálico ou prótese nesta camada.
- `quadril_01.png`: camisa vinho com nó/mangas/caudas, quadril e porção superior das coxas de calça escura. Inclui uma aba superior de tecido carvão; a geração desenhou continuação semelhante à regata nessa região, não anatomia oculta da pelve. Serve como sobreposição candidata, não reconstrução completa das áreas escondidas.
- Ambas **1774×887 RGBA** com transparência real nos cantos. A ferramenta **não manteve escala/posição** pedidas: as peças ficaram maiores e em posições diferentes. Não são texturas intercambiáveis por coordenadas originais. Há registro explícito na cena, sem esticamento anisotrópico.
- Ferramenta integrada **image_gen**, orientada pela skill **imagegen**, uma chamada por peça. Cópias integrais, sem recortar/editar os pixels localmente ou sobrescrever a prancha/arte anterior. **Prompts completos, fontes originais, hashes e pontos de registro estão em [manifesto.json](manifesto.json).**

As fontes contêm alguns pixels residuais de alfa **1/255** longe das peças. `get_used_rect()` bruto inclui esse ruído e não representa a silhueta visível. `alfa_residual.gdshader` descarta apenas alfa até 2/255 na renderização, preservando os PNGs; mipmaps e filtro linear ajudam na redução. Não apresentar as fontes como bitmaps já limpos para qualquer outro aplicativo sem essa ressalva.

## Registro e arquivos

`camadas_guarda.gd/.tscn` usa duas referências centrais para registrar o tronco: pescoço `(500,180)→(300,185)` e cintura `(440,710)→(285,360)`. Transformação tem rotação, translação e **uma única escala uniforme**, sem espelho/cisalhamento. Ombros foram lidos separadamente como conferência, não usados para forçar todos os pontos a coincidir. Primeiro ensaio pelos ombros deixava a cintura deslocada; registro central melhorou a montagem observada.

Quadril: escala uniforme **0,385**, nó `(650,315)→(321,390)`. A parte superior do tecido fica atrás do tronco; camisa/coxas ficam à frente. Duas regiões contíguas de desenho da mesma textura se encontram em `y=245` da fonte do quadril. Não são dois PNGs sobrepostos nem edição raster: são recortes de Sprite2D. Guias ficam num nó acima das peças, não escondidas sob os sprites.

Pontos manuais são uma calibração candidata da **prancha**, não pivôs finais do rig anterior. A bancada não cria Skeleton2D, pesos, AnimationPlayer ou Tween; não prova torção/perspectiva contínua, nem compatibilidade das outras poses da prancha. Próximo recorte depende da avaliação visual antes de ligar as camadas ao movimento.

## Verificações executadas

- Godot confirmada 4.7.2. `tests/test_camadas_guarda.gd` passou **headless e OpenGL**, zero falhas/exit 0. Logs finais sem stderr.
- Dimensões/alfa/cantos, hashes das fontes e da prancha aprovada, mipmaps, transformações uniformes, restauração e ordem das partes conferidos. PNGs mantêm os hashes registrados no manifesto.
- Pescoço/cintura/nó mapeados dentro da precisão numérica do teste. Ombros independentes ficaram a **5,23 / 4,14 px** dos marcos manuais na prancha; tolerância candidata do teste é 12 px. Isso não certifica encaixe anatômico ou registro de próteses.
- **3.147 pontos opacos de sobreposição** na janela de amostragem da cintura `(245..325, 340..390)` em coordenadas da prancha. Não é medição de margem garantida durante rotação.
- **372 amostras GPU** cobertas na faixa central de tronco/cintura, sem abertura nessas amostras da guarda estática. Transparência externa, independência das peças, guias realmente visíveis e atalhos da prévia conferidos. Não é validação de toda borda ou da personagem em movimento.
- Ruído alfa diagnosticado por leitura: fora de `x>=1200`, máximo 1/255 nas duas fontes. A checagem passou a distinguir silhueta visível de ruído e a composição usa o material de descarte; não se apagaram pixels do asset.
- Leitura PNG/alfa do teste usa `load_png_from_buffer` e `detect_alpha`, conferidos na [documentação oficial de Image da Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_image.html). Uma chamada inicial incorreta a `has_alpha` foi corrigida; não é API existente em Image nessa versão.
- Regressão `test_combo_fibras.gd` passou headless/fixed-fps 60: zero falhas, 156 poses e suas checagens de geometria/estado. Não executada a suíte inteira.
- Captura GL exit 0/OK: **cinco PNGs** em `docs/evidencias_vega_camadas_guarda_16/` — montadas, separadas, tronco, quadril, registro. Montagem/partes/referência foram inspecionadas. Última captura não é aprovação artística do usuário. Sem filme novo.
- Importação exit 0 conserva avisos de encerramento de ObjectDB/recursos (33 instâncias/13 recursos no log desta etapa). Não resolvidos aqui. `git diff --check` passou.

## Ainda não feito

Sem nova arte de cabeça/braços/pernas, alteração de Combo, nova pose de impacto, deformação por pesos, animação destas camadas ou teste de combate real. O tronco ainda é uma pintura única nesta vista; a preparação em duas camadas não resolve sozinha o efeito de adesivo em giros. As vistas de preparo/impacto e as regiões que mudam perspectiva exigem trabalho próprio. F5 continua com a apresentação anterior.
