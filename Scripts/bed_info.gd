extends Control

@onready var bed_indicator: Label = $BedIndicator
@export var extraction_bed_path: NodePath
var extraction_bed: Node3D

func _ready():
	extraction_bed = get_node(extraction_bed_path)
	# Conecta o sinal de reset do leito
	extraction_bed.connect("bed_reset", _on_bed_reset)
	# Atualiza as informações iniciais
	update_info()

func _process(_delta):
	update_info()

func update_info():
	if extraction_bed:
		var info_text = "Leito de Extração:\n"
		info_text += "Altura: %.2f\n" % extraction_bed.height
		info_text += "Largura: %.2f\n" % extraction_bed.width
		info_text += "Diâmetro: %.2f\n" % extraction_bed.diameter
		info_text += "Raio Interno: %.2f\n" % extraction_bed.inner_cylinder_radius
		info_text += "Transparência: %.2f" % extraction_bed.transparency
		
		bed_indicator.text = info_text

func _on_bed_reset():
	update_info() 