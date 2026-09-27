# Diagnóstico da opção de evento — 26/09/2026

## Escopo

Coleta de diagnóstico, sem nova alteração visual na produção. A correção da carta Brecha e as recompensas foram preservadas. A sobreposição visual continua pendente.

## 1. Cena completa: evento_opcao.tscn

~~~text
[gd_scene load_steps=9 format=3]

[ext_resource type="Script" path="res://evento_opcao.gd" id="1_script"]
[ext_resource type="Theme" path="res://ui_hq_v1/tema_base.tres" id="2_theme"]
[ext_resource type="FontFile" path="res://ui_hq_v1/fontes/Bangers-Regular.ttf" id="3_bangers"]
[ext_resource type="FontFile" path="res://ui_hq_v1/fontes/BarlowSemiCondensed-Regular.ttf" id="4_barlow"]
[ext_resource type="StyleBox" path="res://ui_hq_v1/estilos/botao_normal.tres" id="5_normal"]
[ext_resource type="StyleBox" path="res://ui_hq_v1/estilos/opcao_evento_interacao.tres" id="6_foco"]
[ext_resource type="StyleBox" path="res://ui_hq_v1/estilos/botao_pressionado.tres" id="7_pressed"]
[ext_resource type="StyleBox" path="res://ui_hq_v1/estilos/painel_escuro.tres" id="8_dark"]

[node name="EventoOpcao" type="Button"]
custom_minimum_size = Vector2(0, 80)
focus_mode = 2
flat = false
mouse_default_cursor_shape = 2
theme = ExtResource("2_theme")
theme_override_styles/normal = ExtResource("8_dark")
theme_override_styles/hover = ExtResource("8_dark")
theme_override_styles/focus = ExtResource("8_dark")
theme_override_styles/pressed = ExtResource("8_dark")
theme_override_styles/hover_pressed = ExtResource("8_dark")
script = ExtResource("1_script")

[node name="Interacao" type="Panel" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2
z_index = 4
theme_override_styles/panel = ExtResource("6_foco")
visible = false

[node name="Acao" type="Label" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 0.78
anchor_top = 0.18
anchor_bottom = 0.52
offset_left = 24.0
offset_right = -16.0
grow_horizontal = 0
grow_vertical = 2
theme_override_colors/font_color = Color(0.96, 0.97, 0.98, 1)
theme_override_fonts/font = ExtResource("3_bangers")
theme_override_font_sizes/font_size = 24
horizontal_alignment = 0
vertical_alignment = 1
autowrap_mode = 2
mouse_filter = 2

[node name="Detalhe" type="Label" parent="."]
layout_mode = 1
anchors_preset = 0
anchor_right = 0.78
anchor_top = 0.52
anchor_bottom = 0.84
offset_left = 24.0
offset_right = -16.0
grow_horizontal = 0
grow_vertical = 0
theme_override_colors/font_color = Color(0.72, 0.81, 0.84, 1)
theme_override_fonts/font = ExtResource("4_barlow")
theme_override_font_sizes/font_size = 15
horizontal_alignment = 0
vertical_alignment = 1
autowrap_mode = 2
mouse_filter = 2

[node name="TipoIcone" type="TextureRect" parent="."]
layout_mode = 1
anchors_preset = 6
anchor_left = 1.0
anchor_top = 0.5
anchor_right = 1.0
anchor_bottom = 0.5
offset_left = -82.0
offset_top = -17.0
offset_right = -50.0
offset_bottom = 17.0
mouse_filter = 2
expand_mode = 1
stretch_mode = 5

[node name="Seta" type="TextureRect" parent="."]
layout_mode = 1
anchors_preset = 6
anchor_left = 1.0
anchor_top = 0.5
anchor_right = 1.0
anchor_bottom = 0.5
offset_left = -43.0
offset_top = -15.0
offset_right = -13.0
offset_bottom = 15.0
mouse_filter = 2
expand_mode = 1
stretch_mode = 5
~~~

## 2. Script completo: evento_opcao.gd

~~~gdscript
extends Button

@onready var acao_label: Label = $Acao
@onready var detalhe_label: Label = $Detalhe
@onready var tipo_icone: TextureRect = $TipoIcone
@onready var interacao: Panel = $Interacao

const ICONE_SETA: Texture2D = preload("res://ui_hq_v1/componentes/icones/seta.tres")
const ICONE_COMBATE: Texture2D = preload("res://ui_hq_v1/componentes/icones/combate.tres")


func configurar_evento(nome: String, detalhe: String, tipo: String = "") -> void:
    acao_label.text = nome
    detalhe_label.text = detalhe
    detalhe_label.visible = not detalhe.is_empty()
    tipo_icone.visible = tipo == "combate"
    tipo_icone.texture = ICONE_COMBATE
    $Seta.texture = ICONE_SETA
    tooltip_text = ""
    _atualizar_cores()


func _ready() -> void:
    mouse_entered.connect(_atualizar_cores)
    mouse_exited.connect(_atualizar_cores)
    focus_entered.connect(_atualizar_cores)
    focus_exited.connect(_atualizar_cores)
    _atualizar_cores()


func _atualizar_cores() -> void:
    var ativo: bool = is_hovered() or has_focus()
    interacao.visible = ativo
    acao_label.add_theme_color_override("font_color", Color("#73e7ff") if ativo else Color("#f5f7fa"))
    detalhe_label.add_theme_color_override("font_color", Color("#c4f6ff") if ativo else Color("#a9b9c7"))
~~~

## 3. Recursos efetivos por estado

Estado normal, hover, focus, pressed e hover_pressed usam todos:
res://ui_hq_v1/estilos/painel_escuro.tres

A cadeia é:

~~~text
estilos/painel_escuro.tres
 -> componentes/controles/painel_escuro.tres
 -> assets/atlases/controles.png
 -> region Rect2(38, 640, 570, 257)
~~~

O StyleBoxTexture usa margens de textura 24/24/24/24 e margens de conteúdo 24/16/24/16 (esquerda/topo/direita/base).

botao_normal.tres, botao_foco.tres e botao_pressionado.tres continuam declarados como recursos externos, mas não são efetivos no EventoOpcao. O tema tema_base.tres também é vencido pelos overrides locais.

O destaque ciano é a filha Interacao, com StyleBoxFlat transparente, borda ciano de 2 px, z_index=4, mouse_filter=IGNORE e anchors de tela inteira. Ela não altera layout.

## 4. Código externo de tamanho, escala e posição

Em main.tscn, EventoOpcoes é um VBoxContainer com:
anchor_left=0.52, anchor_right=1.0, anchor_top=0.54, anchor_bottom=0.96, separation=8 e alignment=1.

As três instâncias usam layout_mode=2. A cena da opção fornece apenas custom_minimum_size=Vector2(0,80). O container calcula largura, altura e posição; não há atribuição externa individual de size, position ou scale.

main.gd::_mostrar_evento() esconde tudo, preenche e mostra somente as opções reais:

~~~gdscript
var botoes: Array[Button] = [evento_opcao_1, evento_opcao_2, evento_opcao_3]
for botao in botoes:
    botao.hide()
    botao.disabled = false

var opcoes: Array = dados.get("opcoes", [])
for indice in range(mini(opcoes.size(), botoes.size())):
    var opcao: Dictionary = opcoes[indice]
    botoes[indice].call(
        "configurar_evento",
        str(opcao.get("nome", "Opção")),
        _resumo_opcao_evento(opcao),
        "combate" if str(opcao.get("tipo", "")) == "combate_especial" else ""
    )
    botoes[indice].show()
~~~

A transição comum de overlay é:

~~~gdscript
func _transicionar_para_overlay(overlay: Control) -> void:
    overlay.pivot_offset = overlay.size * 0.5
    overlay.modulate.a = 0.0
    overlay.scale = Vector2(0.98, 0.98)
    var tween: Tween = create_tween()
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(overlay, "modulate:a", 1.0, 0.22)
    tween.parallel().tween_property(overlay, "scale", Vector2.ONE, 0.22)
~~~

Após a transição, os ancestrais medidos estão em escala 1. Durante os 0,22 s iniciais, EventoOverlay está em escala 0,98.

## 5. Retângulos globais em 1024×576

A janela é 1024×576, mas a viewport interna do projeto é 1152×648. Os números abaixo estão em coordenadas da viewport interna.

Opção: EventoOpcao3, “Confrontar a fiscalização”.

~~~text
EventoOpcao3 global: position=(597.1968,524.3648), size=(508,80), scale=(1,1)
Acao global:         position=(621.1968,538.7648), size=(356.24,27.2), local=(24,14.4)
Detalhe global:      position=(621.1968,565.9648), size=(356.24,25.6), local=(24,41.6)
TipoIcone global:    position=(1023.1968,547.3648), size=(32,34), local=(426,23)
Seta global:         position=(1062.1968,549.3648), size=(30,30), local=(465,25)
Interacao global:    position=(597.1968,524.3648), size=(508,80), scale=(1,1)
~~~

Os ancestrais relevantes estavam em escala (1,1) após a transição: EventoOverlay, EventoOpcoes e EventoOpcao3.

## 6. Diferença entre as áreas

- Retângulo clicável: o Button inteiro, 508×80; recebe mouse e teclado.
- Moldura visível: a tinta gerada pelo StyleBoxTexture a partir da região do atlas. Ela é pintada pelo controle, mas não fornece uma área de layout para os filhos.
- Área de texto: os Label são filhos diretos, com anchors e offsets próprios. Eles não recebem automaticamente content_margin_* do StyleBox.

A causa observada é esta separação: os Labels estão dentro do retângulo lógico do botão, mas a tinta branca real do atlas ocupa uma área diferente. Assim, “Confrontar a fiscalização” e “Combate” podem encostar ou cruzar a moldura mesmo quando um teste geométrico simples considera o Label dentro do botão. Como os cinco estados usam o mesmo StyleBox, o foco não explica uma mudança de geometria; ele acrescenta a borda ciano e muda as cores.

## 7. Capturas e limitação do hover

- artifacts/diagnostico_evento_normal_1024x576.png
- artifacts/diagnostico_evento_hover_1024x576.png
- artifacts/diagnostico_evento_foco_1024x576.png
- evento_hover.png
- evento_foco.png

O preview diagnóstico de hover usa DisplayServer.warp_mouse(), mas o alvo efetivamente destacado não foi ativado de modo determinístico nessa execução; a imagem diagnóstica hover registra a geometria, não deve ser interpretada como prova do hover real da opção 3. A captura evento_hover.png é real, mas nela o destaque não coincide com “Confrontar a fiscalização”. Esta lacuna foi mantida explícita, sem fabricar evidência.

A captura de foco diagnóstico é da mesma opção investigada e mostra Interacao visível, mantendo os mesmos retângulos de conteúdo.

## 8. Cobertura e lacuna dos testes

tests/test_apresentacao_eventos.gd cobre tipografia, existência, visibilidade, foco habilitado, filtros de mouse, alinhamento, seta, tipo de StyleBox, camada Interacao, resultado e posição de Continuar.

tests/test_regressoes_ui_evento_brecha.gd cobre a reutilização da moldura-base em hover/foco, a camada ciano e o caminho Brecha adquirida → mão → custo → dano → consumo de Energia.

Os testes ainda não cobrem:
- distância entre pixels da tinta do atlas e pixels dos Labels;
- limites internos reais da moldura desenhada;
- hover físico da mesma opção nas capturas;
- posição do cursor após warp em janela escalada;
- geometria durante os 0,22 s da transição;
- aplicação automática das margens do StyleBox aos filhos, pois não existe Container interno de conteúdo.

Conclusão: o problema visual permanece pendente. A coleta aponta para a diferença entre o quadro pintado pelo atlas e os Labels posicionados diretamente no botão, não para a Brecha, regras de evento ou troca de StyleBox durante o foco.

## Atualização posterior — correção estrutural aplicada

Depois desta coleta, a hipótese foi implementada em `evento_opcao.tscn`: os textos e ícones passaram a usar `Conteudo` (`MarginContainer`), `Linha` (`HBoxContainer`) e `Textos` (`VBoxContainer`). Os caminhos do script e dos testes foram atualizados. A moldura e a camada `Interacao` não foram substituídas.

Esta atualização é código aplicado, não validação visual concluída. A execução com Godot 4.7.2 e as capturas nas três resoluções continuam pendentes porque o executável não foi encontrado no caminho informado.

## Segunda atualização — medidas e correção de altura

O executável foi localizado em:

~~~text
C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe
C:\Users\Wallace\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe
~~~

Medidas reais após o layout estabilizar, em 1024×576 / viewport 1152×648, para `Desligar a válvula`:

~~~text
Button:   position=(597.1968,380.1824), size=(508,92), minimum=(48,92)
Conteudo: position=(631.1968,400.1824), size=(452,52)
Linha:    size=(452,52), minimum=(87,50)
Textos:   size=(366,52), minimum=(1,50)
Acao:     position=(631.1968,401.1824), size=(366,28)
Detalhe:  position=(631.1968,431.1824), size=(366,20)
TipoIcone: position=(1009.1968,409.1824), size=(32,34)
Seta:     position=(1053.1968,411.1824), size=(30,30)
Interacao: position=(611.1968,394.1824), size=(480,64)
~~~

A área útil de 52 px comporta o mínimo combinado de 50 px (`28 + 2 + 20`). A opção sem detalhe usa o mesmo VBox com `alignment=1`, deixando a ação isolada centralizada verticalmente. A altura mínima de 92 px e o container externo foram ajustados juntos; não houve redução de fonte nem clipping.

Capturas limpas reais do mesmo evento:

- [normal 1024×576](evidencias/evento_valvula_normal_1024x576.png) e [foco 1024×576](evidencias/evento_valvula_foco_1024x576.png)
- [normal 1280×720](evidencias/evento_valvula_normal_1280x720.png) e [foco 1280×720](evidencias/evento_valvula_foco_1280x720.png)
- [normal 1920×1080](evidencias/evento_valvula_normal_1920x1080.png) e [foco 1920×1080](evidencias/evento_valvula_foco_1920x1080.png)

As capturas confirmam visualmente o afastamento de `Desligar a válvula`, `Combate` e `Contornar a tubulação` da moldura. O foco conserva a posição e o tamanho; apenas a camada ciano e as cores dos textos mudam.

A automação de hover foi tentada com `DisplayServer.warp_mouse`, coordenadas de tela e `InputEventMouseMotion`; em todas as tentativas `is_hovered()` permaneceu falso. Portanto, não há captura de hover real apresentada como evidência. A geometria do destaque foi coberta pela regressão de foco e pela medição da mesma camada `Interacao`, mas a confirmação de mouse físico continua pendente.

## Terceira atualização — espaçamento para acentos Bangers

A medição do conjunto com duas linhas levou a uma nova exigência: 34 px para a ação, 4 px de espaçamento e 22 px para o detalhe. O Button passou para altura mínima de 100 px e o `Conteudo` usa margens verticais de 19 px, resultando em 62 px úteis. `EventoOpcoes` foi ajustado para `0.515..0.995` com separação de 5 px, acomodando três opções de 100 px.

O teste estrutural agora verifica as alturas mínimas, o mínimo combinado do VBox, a centralização da opção sem detalhe e a capacidade do container externo. Ele passou em 1024×576, 1280×720 e 1920×1080. A suíte de 34 cenas passou em 1280×720. As novas capturas normais e focadas de 1024×576 e 1920×1080 foram inspecionadas; hover físico permanece explicitamente pendente pela limitação do warp automatizado.

## Validação manual relatada — 26/09/2026

O usuário confirmou que o fluxo está funcional e validou manualmente hover, clique e navegação da opção de evento. O registro é uma validação manual relatada, separada da automação. A limitação permanece: os previews com `DisplayServer.warp_mouse` não ativam `is_hovered()` de forma determinística e não são tratados como evidência de hover físico.
