extends Control

@onready var title_label = $VBoxContainer/TitleLabel
@onready var type_label = $VBoxContainer/TypeLabel
@onready var position_label = $VBoxContainer/PositionLabel
@onready var rotation_label = $VBoxContainer/RotationLabel
@onready var scale_label = $VBoxContainer/ScaleLabel
@onready var mass_label = $VBoxContainer/MassLabel
@onready var gravity_label = $VBoxContainer/GravityLabel
@onready var linear_damp_label = $VBoxContainer/LinearDampLabel
@onready var angular_damp_label = $VBoxContainer/AngularDampLabel

var language_manager: Node
var current_object: Node3D

func _ready():
	# Inicializar o gerenciador de idiomas
	language_manager = get_node("/root/LanguageManager")
	if not language_manager:
		push_error("ObjectInfo: LanguageManager não encontrado!")
		return
	
	# Conectar ao sinal de mudança de idioma
	if not language_manager.is_connected("language_changed", Callable(self, "_on_language_changed")):
		language_manager.connect("language_changed", Callable(self, "_on_language_changed"))
	
	# Atualizar textos iniciais
	_update_labels()

func _update_labels():
	if not language_manager:
		return
		
	title_label.text = language_manager.get_text("object_info", "title")
	
	if current_object:
		# Atualizar tipo do objeto
		var object_type = current_object.get_meta("object_type", "")
		var type_text = language_manager.get_text("object_info", object_type)
		type_label.text = language_manager.get_text("object_info", "type") + ": " + type_text
		
		# Atualizar posição
		var pos = current_object.position
		position_label.text = language_manager.get_text("object_info", "position") + ": " + \
			"X: %.2f, Y: %.2f, Z: %.2f" % [pos.x, pos.y, pos.z]
		
		# Atualizar rotação
		var rot = current_object.rotation_degrees
		rotation_label.text = language_manager.get_text("object_info", "rotation") + ": " + \
			"X: %.2f°, Y: %.2f°, Z: %.2f°" % [rot.x, rot.y, rot.z]
		
		# Atualizar escala
		var scale = current_object.scale
		scale_label.text = language_manager.get_text("object_info", "scale") + ": " + \
			"X: %.2f, Y: %.2f, Z: %.2f" % [scale.x, scale.y, scale.z]
		
		# Atualizar propriedades físicas
		if current_object is RigidBody3D:
			mass_label.text = language_manager.get_text("object_info", "mass") + ": %.2f" % current_object.mass
			gravity_label.text = language_manager.get_text("object_info", "gravity") + ": %.2f" % current_object.gravity_scale
			linear_damp_label.text = language_manager.get_text("object_info", "linear_damp") + ": %.2f" % current_object.linear_damp
			angular_damp_label.text = language_manager.get_text("object_info", "angular_damp") + ": %.2f" % current_object.angular_damp

func _on_language_changed():
	_update_labels()

func update_info(object: Node3D):
	current_object = object
	_update_labels() 