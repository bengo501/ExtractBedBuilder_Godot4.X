extends Control

@onready var label: Label = $ObjectIndicator

# Atualiza o painel com as informações
func update_info(total: int, type_counts: Dictionary, extra_info: String = ""):
	var text = "Objetos: %d\n" % total
	for k in type_counts.keys():
		text += "%s: %d\n" % [str(k), int(type_counts[k])]
	if extra_info != "":
		text += "\n" + extra_info
	label.text = text 
