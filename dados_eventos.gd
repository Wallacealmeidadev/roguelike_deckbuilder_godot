class_name DadosEventos
extends RefCounted

const EVENTOS: Dictionary = {
	"ponto_da_queda": {
		"evento_id": "ponto_da_queda",
		"familia": "VEGA",
		"nome": "O Ponto da Queda",
		"descricao": "A plataforma onde Vega perdeu os braços ainda guarda terminais e equipamento abandonado.\nOs registros podem explicar o que acontecia antes do acidente.",
		"opcoes": [
			{
				"id": "vasculhar_terminal",
				"nome": "Vasculhar o terminal de segurança",
				"tipo": "concluido",
				"texto": "Os registros mostram ocorrências envolvendo criaturas antes do acidente.",
				"flags_concedidas": ["viu_relatorios_ataques"],
				"concluido": true
			},
			{
				"id": "desmontar_equipamento",
				"nome": "Desmontar o equipamento abandonado",
				"tipo": "concluido",
				"texto": "Vega recupera um componente que pode ser útil mais adiante.",
				"recompensa": {"tipo": "reliquia_global"},
				"concluido": true
			},
			{
				"id": "ir_embora",
				"nome": "Ir embora",
				"tipo": "concluido",
				"texto": "Vega deixa a plataforma para trás.",
				"concluido": true
			}
		]
	},
	"turno_encerrado": {
		"evento_id": "turno_encerrado",
		"familia": "WORKERS",
		"nome": "Turno Encerrado",
		"descricao": "Trabalhadores paralisaram uma linha de carga.\nUma máquina continua operando em condições inseguras.",
		"opcoes": [
			{
				"id": "desmontar_maquina",
				"nome": "Ajudar a desmontar a máquina",
				"tipo": "deck_remover",
				"deck_acao": "remover",
				"texto": "Os trabalhadores conseguem retirar a máquina da linha.",
				"flags_concedidas": ["ajudou_estivadores"],
				"concluido": true
			},
			{
				"id": "tornar_segura",
				"nome": "Colocar a máquina em condições seguras",
				"tipo": "deck_recalibrar",
				"deck_acao": "recalibrar",
				"texto": "A máquina volta a operar dentro dos limites seguros.",
				"flags_concedidas": ["ajudou_estivadores"],
				"concluido": true
			},
			{
				"id": "nao_se_envolver",
				"nome": "Não se envolver",
				"tipo": "concluido",
				"texto": "Vega segue enquanto a linha permanece parada.",
				"concluido": true
			}
		]
	},
	"carga_descartada": {
		"evento_id": "carga_descartada",
		"familia": "INFRASTRUCTURE",
		"nome": "Carga Descartada",
		"descricao": "Um equipamento portuário despeja contêineres danificados na água.\nUm deles permanece lacrado.",
		"opcoes": [
			{
				"id": "romper_lacre",
				"nome": "Romper o lacre",
				"tipo": "vida",
				"vida_delta": -7,
				"texto": "O contêiner cede, mas o esforço custa 7 de Vida.",
				"recompensa": {"tipo": "reliquia_global"},
				"concluido": true
			},
			{
				"id": "ler_manifesto",
				"nome": "Ler o manifesto",
				"tipo": "concluido",
				"texto": "O manifesto identifica a carga como descarte irregular.",
				"flags_concedidas": ["identificou_carga_descartada"],
				"concluido": true
			},
			{
				"id": "deixar_afundar",
				"nome": "Deixar afundar",
				"tipo": "concluido",
				"texto": "A carga desaparece sob a água escura.",
				"concluido": true
			}
		]
	},
	"caixa_preta": {
		"evento_id": "caixa_preta",
		"familia": "INFRASTRUCTURE",
		"nome": "Caixa-Preta",
		"descricao": "Um Drone de Carga destruído ainda possui registros e componentes recuperáveis.\nOs alertas de segurança não foram apagados.",
		"opcoes": [
			{
				"id": "extrair_registros",
				"nome": "Extrair os registros",
				"tipo": "concluido",
				"texto": "O drone continuou recebendo ordens apesar dos alertas de segurança.",
				"flags_concedidas": ["extraiu_caixa_preta"],
				"concluido": true
			},
			{
				"id": "retirar_modulo",
				"nome": "Retirar o módulo intacto",
				"tipo": "concluido",
				"texto": "O módulo intacto sai do chassi sem perder os dados.",
				"recompensa": {"tipo": "reliquia_global"},
				"concluido": true
			},
			{
				"id": "usar_pecas",
				"nome": "Usar as peças nos braços",
				"tipo": "deck_recalibrar",
				"deck_acao": "recalibrar",
				"filtro_carta": "vega_exclusiva",
				"texto": "As peças são ajustadas aos braços de Vega.",
				"concluido": true
			}
		]
	},
	"agua_morta": {
		"evento_id": "agua_morta",
		"familia": "POLLUTION",
		"nome": "Água Morta",
		"descricao": "Uma tubulação despeja líquido contaminado diretamente na água.\nAlgo grande se move abaixo da superfície.",
		"opcoes": [
			{
				"id": "fechar_valvula",
				"nome": "Fechar a válvula",
				"tipo": "vida",
				"vida_delta": -6,
				"texto": "A válvula fecha, mas a contenção custa 6 de Vida.",
				"flags_concedidas": ["conteve_vazamento"],
				"concluido": true
			},
			{
				"id": "coletar_amostra",
				"nome": "Coletar uma amostra",
				"tipo": "concluido",
				"texto": "Vega guarda uma amostra do líquido contaminado.",
				"flags_concedidas": ["coletou_amostra"],
				"recompensa": {
					"tipo": "reliquia_especial",
					"id_reliquia": "reliquia_evento_agua_morta_provisorio"
				},
				"concluido": true
			},
			{
				"id": "nao_encostar",
				"nome": "Não encostar",
				"tipo": "concluido",
				"texto": "Vega mantém distância da água.",
				"concluido": true
			}
		]
	},
	"sobrevivente": {
		"evento_id": "sobrevivente",
		"familia": "VEGA",
		"nome": "O Sobrevivente",
		"descricao": "Vega encontra o colega do acidente, que depois ajudou na adaptação dos braços.\nO encontro é breve, mas abre perguntas antigas.",
		"opcoes": [
			{
				"id": "olhar_bracos",
				"nome": "Dá uma olhada nos braços.",
				"tipo": "deck_recalibrar",
				"deck_acao": "recalibrar",
				"filtro_carta": "vega_exclusiva",
				"texto": "Ele ajusta uma peça dos braços de Vega.",
				"concluido": true
			},
			{
				"id": "perguntar_acidente",
				"nome": "Quero saber o que aconteceu naquela noite.",
				"tipo": "concluido",
				"texto": "Vega registra a conversa sobre o acidente.",
				"flags_concedidas": ["conversou_sobre_acidente"],
				"concluido": true
			},
			{
				"id": "eles_ja_sabiam",
				"nome": "Eles já sabiam.",
				"tipo": "concluido",
				"flags_exigidas": ["viu_relatorios_ataques"],
				"texto": "Vega compartilha os relatórios que encontrou na plataforma.",
				"flags_concedidas": ["compartilhou_relatorios"],
				"concluido": true
			}
		]
	},
	"posto_inspecao": {
		"evento_id": "posto_inspecao",
		"familia": "WORKERS",
		"nome": "Posto de Inspeção",
		"descricao": "Uma área das Docas foi fechada e agentes controlam a circulação.\nHá uma rota de manutenção ao redor do bloqueio.",
		"opcoes": [
			{
				"id": "passar_forca",
				"nome": "Passar à força",
				"tipo": "combate_especial",
				"id_inimigo": "guarda_portuario",
				"texto": "Os agentes fecham o caminho e o confronto começa.",
				"concluido": false
			},
			{
				"id": "rota_manutencao",
				"nome": "Usar uma rota de manutenção",
				"tipo": "concluido",
				"texto": "Vega atravessa sem combate e sem chamar atenção.",
				"concluido": true
			},
			{
				"id": "apresentar_registros",
				"nome": "Apresentar registros",
				"tipo": "concluido",
				"flags_exigidas_qualquer": ["viu_relatorios_ataques", "extraiu_caixa_preta"],
				"texto": "Os registros bastam para abrir a passagem sem combate.",
				"flags_concedidas": ["confrontou_fiscalizacao_com_provas"],
				"concluido": true
			}
		]
	},
	"ninho_sob_cais": {
		"evento_id": "ninho_sob_cais",
		"familia": "POLLUTION",
		"nome": "Ninho sob o Cais",
		"descricao": "Sob as plataformas, criaturas ocupam uma área cercada de restos industriais.\nUma pessoa está presa entre os destroços.",
		"opcoes": [
			{
				"id": "resgatar_pessoa",
				"nome": "Resgatar a pessoa",
				"tipo": "vida",
				"vida_delta": -8,
				"texto": "Vega resgata a pessoa, mas sofre 8 de dano no processo.",
				"flags_concedidas": ["resgatou_pessoa_do_ninho"],
				"concluido": true
			},
			{
				"id": "investigar_ninho",
				"nome": "Investigar o ninho",
				"tipo": "concluido",
				"texto": "Vega registra os sinais e a presença das criaturas.",
				"flags_concedidas": ["investigou_criaturas"],
				"concluido": true
			},
			{
				"id": "destruir_ninho",
				"nome": "Destruir o ninho",
				"tipo": "combate_especial",
				"id_inimigo": "torreta_contencao",
				"texto": "A intervenção provoca um confronto entre os destroços.",
				"flags_concedidas": ["destruiu_ninho"],
				"recompensa": {"tipo": "reliquia_global"},
				"concluido": false
			}
		]
	}
}


static func obter(id_evento: String) -> Dictionary:
	if not EVENTOS.has(id_evento):
		return {}
	return EVENTOS[id_evento].duplicate(true)


static func opcoes_disponiveis(id_evento: String, flags_run: Array[String]) -> Array[Dictionary]:
	var resultado: Array[Dictionary] = []
	var dados: Dictionary = obter(id_evento)
	for opcao_variant in dados.get("opcoes", []):
		var opcao: Dictionary = opcao_variant
		var permitida: bool = true
		for flag in opcao.get("flags_exigidas", []):
			if not flags_run.has(str(flag)):
				permitida = false
				break
		if permitida:
			var exigidas_qualquer: Array = opcao.get("flags_exigidas_qualquer", [])
			if not exigidas_qualquer.is_empty():
				permitida = false
				for flag_qualquer in exigidas_qualquer:
					if flags_run.has(str(flag_qualquer)):
						permitida = true
						break
		if permitida:
			resultado.append(opcao.duplicate(true))
	return resultado
