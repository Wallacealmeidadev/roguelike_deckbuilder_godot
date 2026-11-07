# Revisão 02 — proporções corporais

Abra `vega_proporcoes_02.blend` no Blender. A base 01 que você testou permanece intacta. Esta revisão trabalha a presença do corpo humano: ombros, costas e pernas um pouco mais encorpados. É candidata de proporção, não anatomia final nem reprodução exata de uma prancha em perspectiva.

Veja `comparacao.png`: esquerda = base 01, direita = revisão 02, mesma câmera/luz/pose. `flexao.png` mostra o mesmo exercício de cotovelo. Os braços humanos ainda são temporários; volume das próteses será tratado separadamente. Rosto genérico continua inalterado nesta etapa; identidade A permanece como alvo futuro.

## O que experimentar

1. Abra o BLEND com Arquivo → Abrir. Mouse sobre o modelo, **Espaço** reproduz/pausa.
2. Compare os quadros **1** e **30** na linha do tempo. É a mesma flexão do teste anterior.
3. Botão do meio gira a vista; rodinha aproxima. Observe ombros e pernas de frente e de lado.

Exercício opcional de edição, no quadro 1: escolha **Object Mode / Modo Objeto** no menu superior esquerdo da vista; selecione o corpo pelo Outliner; nas propriedades de dados da malha (triângulo verde), abra **Shape Keys / Chaves de Forma**. Selecione `Vega_02_costas` e altere **Value / Valor** de `0.35` para `0`, depois restaure `0.35`. Isso mostra uma alteração isolada da superfície. Não julgue a animação com valores experimentais: o rig foi ajustado para os valores salvos e mudanças maiores precisam de reajuste. Feche sem salvar ou use Salvar Como para preservar a revisão.

## Valores candidatos

Pesos dos alvos MPFB, não percentuais de aumento anatômico: largura do tronco `.18`, costas `.35`, deltoides `.55` em cada lado, coxas `.25`, panturrilhas `.15`. Oito chaves `Vega_02_*` mantêm as alterações separadas. Altura, rosto, mãos e comprimentos não foram alvo de redesenho.

## Verificação e limites

Blender 5.2.3 LTS e MPFB 2.0.18 locais. `ajustar_proporcoes.py` abre a base 01 em processo separado, carrega alvos instalados e usa o reajuste oficial do MPFB para reposicionar o metarig e regenerar o Rigify existente. A regeneração solta a ação de animação: o script restaura a ação, seu slot e modo FK dos braços antes de validar. Sem preferências gravadas ou downloads; recusa sobrescrever uma revisão existente.

Geração final e reabertura independentes: exit 0, stderr vazio. Topologia de 19.158 vértices, 930 ossos, lista de grupos de pesos e ação preservadas; 5.658 vértices avaliados mudaram mais de 1 mm pelas proporções. Desvio máximo na região superior da cabeça ~0,0000011 m (tolerância numérica), altura preservada. Flexão desloca 1.956 vértices acima de 1 mm; valores finitos conferidos. Reabertura confirmou chaves de forma, modificador ligado ao rig e rotação 0→65°. Render de comparação e de flexão inspecionados. Isso não certifica todos os controles, pesos ou poses extremas.

Fonte SHA256 preservado: `550152d76b68f14b190e73a58716aef0d52f9eb260f3a7bef5cdffc845e462f7`. A comparação usa cópias temporárias da superfície avaliada, removidas da cena nova antes de salvar; não duplica a personagem no BLEND final. Nada do projeto anterior foi excluído. Godot/F5 inalterados; pasta 3D segue ignorada pela importação automática.
