extends Control

@onready var title_label = $VBoxContainer/TitleLabel
@onready var position_label = $VBoxContainer/PositionLabel
@onready var rotation_label = $VBoxContainer/RotationLabel
@onready var scale_label = $VBoxContainer/ScaleLabel
@onready var dimensions_label = $VBoxContainer/DimensionsLabel
@onready var width_label = $VBoxContainer/WidthLabel
@onready var length_label = $VBoxContainer/LengthLabel
@onready var height_label = $VBoxContainer/HeightLabel
@onready var objects_label = $VBoxContainer/ObjectsLabel
@onready var total_label = $VBoxContainer/TotalLabel

var language_manager: Node
var bed: Node3D
var spawner: Node

func _ready():
	# Inicializar o gerenciador de idiomas
	language_manager = get_node("/root/LanguageManager")
	if not language_manager:
		push_error("BedInfo: LanguageManager não encontrado!")
		return
	
	# Conectar ao sinal de mudança de idioma
	if not language_manager.is_connected("language_changed", Callable(self, "_on_language_changed")):
		language_manager.connect("language_changed", Callable(self, "_on_language_changed"))
	
	# Obter referências
	bed = get_node("/root/MainScene/ExtractionBed")
	spawner = get_node("/root/MainScene/ExtractionBed/Spawner")
	
	# Atualizar textos iniciais
	_update_labels()

func _update_labels():
	if not language_manager:
		return
		
	title_label.text = language_manager.get_text("bed_info", "title")
	
	if bed:
		# Atualizar posição
		var pos = bed.position
		position_label.text = language_manager.get_text("bed_info", "position") + ": " + \
			"X: %.2f, Y: %.2f, Z: %.2f" % [pos.x, pos.y, pos.z]
		
		# Atualizar rotação
		var rot = bed.rotation_degrees
		rotation_label.text = language_manager.get_text("bed_info", "rotation") + ": " + \
			"X: %.2f°, Y: %.2f°, Z: %.2f°" % [rot.x, rot.y, rot.z]
		
		# Atualizar escala
		var scale = bed.scale
		scale_label.text = language_manager.get_text("bed_info", "scale") + ": " + \
			"X: %.2f, Y: %.2f, Z: %.2f" % [scale.x, scale.y, scale.z]
		
		# Atualizar dimensões
		dimensions_label.text = language_manager.get_text("bed_info", "dimensions") + ":"
		width_label.text = language_manager.get_text("bed_info", "width") + ": %.2f " % bed.scale.x + language_manager.get_text("bed_info", "meters")
		length_label.text = language_manager.get_text("bed_info", "length") + ": %.2f " % bed.scale.z + language_manager.get_text("bed_info", "meters")
		height_label.text = language_manager.get_text("bed_info", "height") + ": %.2f " % bed.scale.y + language_manager.get_text("bed_info", "meters")
	
	if spawner:
		# Atualizar informações dos objetos
		objects_label.text = language_manager.get_text("bed_info", "objects") + ":"
		var total_objects = spawner.get_child_count() - 1  # -1 para excluir o SpawnerBlock
		total_label.text = language_manager.get_text("bed_info", "total") + ": %d" % total_objects

func _on_language_changed():
	_update_labels()

func _process(_delta):
	_update_labels() 