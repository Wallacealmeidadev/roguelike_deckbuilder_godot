# Comparação de identidade — 25/10/2026

`comparacao_identidade_2026_10_25.png` é uma captura nativa Godot de três regiões das fontes existentes, sem imagem generativa ou alteração das fontes. Reproduzir com `--script tests/comparar_identidade_vega.gd` em OpenGL. Godot 4.7.2; execução exit 0/OK/stderr vazio; imagem inspecionada.

- A: `vega_v2_referencia_03.png`, retrato superior direito. O MD histórico registra aprovação explícita do cabelo longo e reafirmação da expressão/braços.
- B: `vega_v2_referencia_04.png`, retrato superior direito após mudança de roupa. Preserva visualmente a direção da cabeça 03.
- C: `vega_animada/combate_v2/base_e_punhos_01.png`, fonte atual da cabeça. Ângulo e resolução diferentes; ampliação não reconstrói detalhes ausentes.

Leitura artística: A/B mantêm boca mais cheia, planos de nariz/mandíbula e mechas largas; C tem expressão, proporções faciais e organização das mechas diferentes. Parte da diferença é vista/resolução; não atribuir tudo à última geração HQ, que não trocou esta fonte. Recomendação: A como referência canônica, B como confirmação de continuidade. Escolha atual ainda a confirmar pelo usuário antes da adaptação à guarda; nenhuma montagem modificada.

## Levantamento inicial de espaço

Tamanhos lógicos de arquivos, leitura recursiva em 25/10/2026, não espaço recuperável garantido: `.git` 2481,1 MiB; `docs` 1866,9 MiB; `.godot` 868,9 MiB; `assets` 72,3 MiB; `ui_hq_v1` 33,4 MiB; `vega_animada` 19,7 MiB. Medição anterior à gravação desta comparação. Não inclui outras pastas da máquina nem mede alocação física.

Maiores subpastas de docs: `evidencias` 193 MiB; `evidencias_vega_guarda_viva_22` 104,2 MiB; `evidencias_vega_alternancia_22` 76,7 MiB; `evidencias_vega_acabamento_proximo_01` 76,6 MiB; `arte_vega` 71,2 MiB; `evidencias_vega_juntas_01` 67,4 MiB. Nenhuma classificação como inútil foi concluída. Histórico Git não é descartável por tamanho; cache pode ser regenerado, mas limpeza não foi executada. Não apagado nenhum arquivo. Auditoria de referências/duplicatas fica para a etapa de limpeza acordada.
