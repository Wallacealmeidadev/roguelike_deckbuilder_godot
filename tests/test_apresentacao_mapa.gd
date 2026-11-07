extends Node

var falhas: int = 0


func _ready() -> void:
	call_deferred("_executar_teste")


func _executar_teste() -> void:
	var cena_principal: PackedScene = load("res://main.tscn") as PackedScene
	await _verificar_variante(cena_principal, 0)
	await _verificar_variante(cena_principal, 1)

	if falhas == 0:
		print("OK: apresentação visual do mapa")
		get_tree().quit(0)
	else:
		get_tree().quit(1)


func _verificar_variante(cena_principal: PackedScene, variante: int) -> void:
	var jogo: Node = cena_principal.instantiate()
	get_tree().root.add_child(jogo)
	await get_tree().process_frame
	if variante != 0:
		jogo.set("mapa_variante", variante)
		jogo.call("_iniciar_nova_run")
		await get_tree().process_frame

	var mapa_overlay: Control = jogo.get_node("MapaOverlay") as Control
	var cabecalho: Control = jogo.get_node_or_null("MapaOverlay/MapaCabecalho") as Control
	var grafo: Control = jogo.get_node_or_null("MapaOverlay/MapaGrafo") as Control
	var conexoes: Control = jogo.get_node_or_null("MapaOverlay/MapaGrafo/MapaConexoes") as Control
	var pontos: Control = jogo.get_node_or_null("MapaOverlay/MapaGrafo/MapaPontos") as Control
	var rotulos_pontos: Control = jogo.get_node_or_null("MapaOverlay/MapaGrafo/MapaRotulosPontos") as Control
	var detalhe: Control = jogo.get_node_or_null("MapaOverlay/MapaDetalhe") as Control
	var info: Label = jogo.get_node_or_null("MapaOverlay/MapaInfo") as Label

	_verificar(mapa_overlay.visible, "o mapa deve aparecer no inicio da variante %d" % variante)
	_verificar(cabecalho != null and cabecalho.visible, "o cabecalho HQ deve existir")
	_verificar(grafo != null and grafo.visible, "o grafo do mapa deve existir")
	_verificar(conexoes != null, "a camada de conexoes deve existir")
	_verificar(pontos != null, "a camada de nos deve existir")
	_verificar(rotulos_pontos != null, "a camada reservada aos rotulos dos pontos deve existir")
	_verificar(detalhe != null, "o painel de detalhes deve existir")
	_verificar(info != null and not info.text.contains("Variante"), "a variante nao deve aparecer na interface")
	if cabecalho == null or grafo == null or conexoes == null or pontos == null or rotulos_pontos == null or detalhe == null:
		jogo.queue_free()
		return
	_verificar(detalhe.get_child_count() == 1, "o PanelContainer de detalhes deve ter uma unica arvore de conteudo")
	var detalhe_margem: Control = detalhe.get_node_or_null("MapaDetalheMargem") as Control
	_verificar(detalhe_margem != null, "o painel de detalhes deve reservar margem interna")
	_verificar(
		detalhe_margem != null and detalhe_margem.get_node_or_null("MapaDetalheConteudo/MapaDetalheLinha/MapaDetalheTextos/MapaDetalheTitulo") != null,
		"o titulo do detalhe deve ficar dentro da margem e da linha de conteudo"
	)
	if cabecalho != null:
		_verificar(cabecalho.get_node_or_null("MapaCabecalhoLinha/MapaDistrito") != null, "o distrito deve estar no cabecalho")
		_verificar(cabecalho.get_node_or_null("MapaCabecalhoLinha/MapaRecursos/MapaVidaLabel") != null, "Vida deve estar no cabecalho")
		_verificar(cabecalho.get_node_or_null("MapaCabecalhoLinha/MapaRecursos/MapaBaralhoLabel") != null, "baralho deve estar no cabecalho")

	if pontos != null:
		var nos: Array[Control] = _obter_nos(pontos)
		_verificar(nos.size() == (jogo.get("mapa_run") as MapaRun).nos.size(), "o mapa deve renderizar todos os nos do template")
		_verificar(_pontos_estao_em_colunas(nos, jogo.get("mapa_run") as MapaRun), "os nos devem seguir as colunas dos pontos")
		for no in nos:
			_verificar(no.get_meta("id_no", "") != "", "cada no deve conservar seu identificador")
			_verificar(no.get_node_or_null("Icone") != null, "cada no deve possuir icone de tipo")
			_verificar((no.get_node("Icone") as TextureRect).texture != null, "o icone do no deve ser carregado")
			_verificar((no.get_node("Icone") as TextureRect).mouse_filter == Control.MOUSE_FILTER_IGNORE, "o icone nao deve interceptar o mouse")
			_verificar(no.get_node_or_null("NumeroPonto") == null, "o rotulo P nao deve ser duplicado dentro de cada no")

	if rotulos_pontos != null:
		_verificar(rotulos_pontos.get_child_count() == (jogo.get("mapa_run") as MapaRun).total_pontos(), "deve haver um unico rotulo para cada coluna")
		for indice in range(rotulos_pontos.get_child_count()):
			var rotulo: Label = rotulos_pontos.get_child(indice) as Label
			_verificar(rotulo != null and rotulo.text == "P%d" % (indice + 1), "os rotulos das colunas devem seguir P1 a P11")

	if pontos != null:
		var primeiro: Button = _obter_nos(pontos)[0] as Button
		var estilo_base: StyleBox = primeiro.get_theme_stylebox("normal")
		_verificar(estilo_base != null, "o no deve ter moldura-base")
		_verificar(primeiro.get_theme_stylebox("hover") == estilo_base, "hover deve preservar a moldura-base HQ")
		_verificar(primeiro.get_theme_stylebox("focus") == estilo_base, "foco deve preservar a moldura-base HQ")
		_verificar(primeiro.has_node("Interacao"), "o destaque deve ser uma camada separada")

	var reiniciar: Button = jogo.get_node_or_null("Reiniciar") as Button
	_verificar(reiniciar != null and reiniciar.custom_minimum_size.y >= 64.0, "jogar novamente deve ter altura segura")
	if reiniciar != null:
		_verificar(reiniciar.get_theme_constant("content_margin_top") >= 12, "jogar novamente deve ter margem superior")
		_verificar(reiniciar.get_theme_constant("content_margin_bottom") >= 12, "jogar novamente deve ter margem inferior")

	if conexoes != null:
		var esperadas: int = _contar_conexoes(jogo.get("mapa_run") as MapaRun)
		var segmentos: Array = conexoes.get("segmentos") as Array
		_verificar(segmentos.size() == esperadas, "as linhas devem vir das conexoes reais do mapa")

	# O foco deve alimentar o painel de detalhes sem alterar a navegacao.
	if pontos != null:
		var inicial: Button = _obter_nos(pontos)[0] as Button
		inicial.grab_focus()
		await get_tree().process_frame
		_verificar(detalhe != null and detalhe.visible, "o foco deve abrir os detalhes do no")

	if variante == 0:
		jogo.call("_ao_selecionar_no_mapa", "inicio")
		jogo.set("vida_inimigo", 0)
		jogo.call("_resolver_vitoria")
		jogo.call("_ao_pular_recompensa")
		await get_tree().process_frame
		var apos: Control = jogo.get_node("MapaOverlay/MapaGrafo/MapaPontos") as Control
		var disponiveis: int = 0
		for no in _obter_nos(apos):
			if not (no as Button).disabled:
				disponiveis += 1
		_verificar(disponiveis == 1, "o mapa deve liberar somente o próximo ponto conectado")

	jogo.queue_free()


func _obter_nos(pontos: Control) -> Array[Control]:
	var resultado: Array[Control] = []
	for filho_variant in pontos.get_children():
		var filho: Control = filho_variant as Control
		if filho != null and filho.has_meta("id_no"):
			resultado.append(filho)
	return resultado


func _pontos_estao_em_colunas(nos: Array[Control], mapa: MapaRun) -> bool:
	var por_ponto: Dictionary = {}
	for no in nos:
		var id_no: String = str(no.get_meta("id_no"))
		por_ponto[mapa.ponto_do_no(id_no)] = no.position.x
	for ponto in range(1, mapa.total_pontos()):
		if not por_ponto.has(ponto) or not por_ponto.has(ponto + 1):
			return false
		if float(por_ponto[ponto]) >= float(por_ponto[ponto + 1]):
			return false
	return true


func _contar_conexoes(mapa: MapaRun) -> int:
	var total: int = 0
	for id_no_variant in mapa.nos.keys():
		total += mapa.destinos_de(str(id_no_variant)).size()
	return total


func _verificar(condicao: bool, mensagem: String) -> void:
	if condicao:
		return
	falhas += 1
	push_error("FALHA: %s" % mensagem)
