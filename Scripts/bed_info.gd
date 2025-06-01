extends Window

@export var extraction_bed_path: NodePath
@onready var bed_indicator = $BedIndicator

var extraction_bed: Node3D

func _ready():
	# Configurar a janela
	close_requested.connect(_on_close_requested)
	
	# Garantir que a janela começa invisível
	visible = false
	
	# Obter referência ao leito de extração
	extraction_bed = get_node(extraction_bed_path)
	if not extraction_bed:
		push_error("BedInfo: ExtractionBed não encontrado!")
		return
	
	# Atualizar informações iniciais
	update_info()

func _on_close_requested():
	hide()

func update_info():
	if not extraction_bed:
		return
		
	var text = "Leito de Extração:\n"
	text += "Altura: %.2f\n" % (extraction_bed.height * 100)  # Converter para centímetros
	text += "Largura: %.2f\n" % (extraction_bed.width * 100)
	text += "Diâmetro: %.2f\n" % (extraction_bed.diameter * 100)
	text += "Raio Interno: %.2f\n" % (extraction_bed.inner_cylinder_radius * 100)
	text += "Transparência: %.2f" % extraction_bed.transparency
	
	bed_indicator.text = text 