# Protótipos fora do jogo

Tudo nesta pasta **não é carregado pelo jogo** (`jogo.tscn` → `main.tscn`).
Foi separado em 07/11/2026 por rastreamento de dependências (`res://`, uids,
`class_name` e `load()` dinâmicos). Nada foi apagado: os arquivos foram movidos
com `git mv` e os caminhos `res://` internos foram corrigidos, então as cenas
continuam abrindo no editor.

| Pasta | Conteúdo |
| --- | --- |
| `vega_2d/` | Provas de animação 2D da Vega que não entraram no combate: `corpo_articulado/` (inclui a guarda montada com braços HQ aprovada em 24–25/10), `braco_reconstruido/`, `corpo_v2/`, peças segmentadas, `rig_nativo_v2/acabamento_proximo/` e as prévias. |
| `vega_2d/tests/` | Testes e scripts de captura que só exercitam esses protótipos. |
| `hud_antiga/` | Compositores e recursos das HUDs básica, HQ e R2/R3 substituídos pela HUD neon. |
| `assets_antigos/` | Artes antigas das cartas e o recorte de Energia que deixou de ser usado. |

## O que continua no jogo

- Vega no combate: `vega_animada/rig_nativo_v2/` (+ `vega_animada/braco_v2/braco_prova.gd`,
  `braco_v2/camadas.png` e `combate_v2/base_e_punhos_01.png`, que o rig usa).
- HUD: `hud_neon/` e as partes ainda referenciadas de `hud_basico/`, `hud_hq/`,
  `hud_r2_codex/` e `ui_hq_v1/`.

## Para reaproveitar algo

Mova de volta pelo **FileSystem da Godot** (arrastar), não pelo Explorer: assim a
Godot atualiza os caminhos de quem usa o arquivo.
