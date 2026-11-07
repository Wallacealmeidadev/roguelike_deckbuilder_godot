# Arenas das Docas — 20/10/2026

Assets produzidos com a ferramenta integrada `imagegen`, a pedido do usuário, para uso no jogo; não são screenshots nem contêm HUD/personagens. Os originais gerados foram preservados fora do projeto e as cópias finais foram integradas aqui.

- `patio_conteineres.png`: pátio externo; usado em encontros de carga/caranguejos.
- `estacao_bombeamento.png`: plataforma hidráulica; usada em guindaste, contenção e suporte fora do pátio.
- O cais existente permanece em `hud_hq/cenarios/docas_dia.png`, com o filtro noturno vigente.

A escolha é determinística por identificador de encontro e não consome RNG da run. `arena_chao.gd` realiza a troca; piso e sombras dos combatentes são apresentação, não colisão/física de combate. Não há alteração de distrito ou de regras.

## Prompts finais (modo integrado; sem CLI/API)

### Pátio

Use case: stylized-concept. Asset type: production 2D side-view combat arena background for a cyberpunk deckbuilder. Create ONE complete landscape 16:9 image, no panels or collage. A weathered port CONTAINER YARD at blue hour: stacks of faded cargo containers along the rear, large gantry crane silhouettes and cables, distant water and port lights through maritime haze. Graphic novel / hand-inked cel-shaded painted environment, detailed industrial surfaces, crisp linework, muted desaturated blue-gray palette with restrained amber work lamps and cyan terminal accents. Camera at a standing person's chest height, level horizon, moderate perspective, NOT top-down, NOT isometric. Continuous empty broad concrete ground from 54 percent image height to the bottom; clear playable character standing line around 64 percent height. All stacked cargo and obstacles behind that line, no large props in the playable foreground. Left and right fighter areas stay open; architecture has believable human scale. Use soft ambient cool light with modest warm side-light so separately composited illustrated characters will belong here. Atmosphere and depth without obscuring the playable floor. Top and bottom edges relatively quiet to support a separately rendered neon HUD. Not photoreal, no 3D render, no characters, robots, people, UI, text, letters, logos, watermark, frames. Deliver the actual background illustration, not a game screenshot or mockup.

### Bombeamento

Use case: stylized-concept. Asset type: production 2D side-view combat arena background for a cyberpunk deckbuilder. Create ONE complete landscape 16:9 image, no panels or collage. An aging port PUMP STATION / tidal floodgate maintenance platform at night: huge worn pipes, hydraulic gate mechanisms and a dark industrial pump building across the rear, recessed water channel and distant docks beyond safety railing. Graphic novel / hand-inked cel-shaded painted environment, detailed distressed metal and concrete, crisp black linework, desaturated deep petrol blue and slate palette, small amber maintenance lamps and restrained teal indicator lights. Camera level at standing person's chest height, moderate perspective, NOT top-down, NOT isometric. Continuous empty broad concrete maintenance apron from 54 percent image height to bottom; character standing line around 64 percent height. Pipes, railings and machines stay behind that line, clear left and right fighter areas, no foreground machinery blocking combat silhouettes. Human-scale industrial architecture. Cool ambient illumination with warm work-light spill grazing the apron; floor material and shadows remain readable, not pitch black. Top and bottom edges relatively quiet to support a separately rendered neon HUD. Not photoreal, no 3D render, no characters, robots, people, UI, text, lettering, logos, watermarks, frames. Deliver the actual background illustration, not a game screenshot or mockup.
