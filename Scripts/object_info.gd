extends Window

@onready var object_indicator = $ObjectIndicator

func _ready():
	# Configurar a janela
	close_requested.connect(_on_close_requested)
	
	# Garantir que a janela começa invisível
	visible = false

func _on_close_requested():
	hide()

func update_info(total: int, type_counts: Dictionary) -> void:
	var text = "Total de objetos: %d\n\n" % total
	for type_name in type_counts:
		text += "%s: %d\n" % [type_name, type_counts[type_name]]
	object_indicator.text = text 
