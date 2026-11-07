# Revisão 03 — cintura e abdômen

Abra `vega_cintura_abdomen_03.blend`. Espaço reproduz/pausa o exercício de cotovelo. Quadros 1 e 30 mostram as duas posições. A revisão 02 foi preservada.

Pedido: cintura mais fina e mais abdômen. Interpretação comunicada: maior firmeza/definição muscular, não barriga maior. Aplicados dois alvos MPFB locais: `Vega_03_cintura = .40` e `Vega_03_abdomen = .85`. São pesos de influência, não percentuais anatômicos. Resultado visual tem cintura um pouco mais estreita e definição abdominal suave; não é escultura de um abdômen muito marcado. Ombros/costas/pernas da revisão 02 conservados, rosto genérico ainda pendente de identidade A.

Veja `comparacao.png` (02 à esquerda, 03 à direita) e `abdomen_detalhe.png`. Para experimentar: no quadro 1, passe a Modo Objeto, selecione o corpo no Outliner e abra Dados da Malha (triângulo verde) → Chaves de Forma. Compare `Vega_03_abdomen` em 0 e .85, depois restaure .85. Valores maiores de edição corporal podem exigir reajuste do rig; preserve o arquivo usando Salvar Como para experiências.

## Verificação

Blender 5.2.3 LTS, MPFB 2.0.18. `ajustar_cintura.py` deriva da revisão 02, carrega alvos locais, reajusta metarig/Rigify e restaura ação/slot/FK do teste anterior. Nenhuma instalação ou preferência gravada.

Geração e reabertura independentes exit 0/stderr vazio. 19.158 vértices, 930 ossos, grupos de pesos/ação e modificador preservados. 609 vértices avaliados alterados >1 mm; desvio máximo na região superior da cabeça ~0,00000048 m. Largura da faixa de cintura amostrada (60–65% da altura, mesmos índices): .262635 → .255915 m, redução ~2,6%; não é medida de circunferência nem redução uniforme de todo torso. Flexão desloca 1.956 vértices >1 mm; sem coordenadas não finitas. Reabertura confirma dois valores novos, chave de costas anterior e rotação 0→65°. Comparação, flexão e detalhe inspecionados visualmente. Não valida todos os controles ou poses extremas.

SHA256 da fonte 02 preservado: `23c030088ae7c13abc21913a19bf3778e073a5e32bd43174d3233b03f47d94f3`. Arquivo original, jogo/F5 e demais fontes intactos. Nenhuma limpeza de arquivos feita nesta etapa.
