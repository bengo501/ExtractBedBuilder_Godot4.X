extends Control

@onready var title_label = $VBoxContainer/TitleLabel
@onready var current_camera_label = $VBoxContainer/CurrentCameraLabel
@onready var position_label = $VBoxContainer/PositionLabel
@onready var rotation_label = $VBoxContainer/RotationLabel
@onready var fov_label = $VBoxContainer/FOVLabel
@onready var near_label = $VBoxContainer/NearLabel
@onready var far_label = $VBoxContainer/FarLabel

var language_manager: Node
var current_camera: Camera3D
var current_camera_type: String

func _ready():
	# Inicializar o gerenciador de idiomas
	language_manager = get_node("/root/LanguageManager")
	if not language_manager:
		push_error("CameraInfo: LanguageManager não encontrado!")
		return
	
	# Conectar ao sinal de mudança de idioma
	if not language_manager.is_connected("language_changed", Callable(self, "_on_language_changed")):
		language_manager.connect("language_changed", Callable(self, "_on_language_changed"))
	
	# Atualizar textos iniciais
	_update_labels()

func _update_labels():
	if not language_manager:
		return
		
	title_label.text = language_manager.get_text("camera_info", "title")
	
	if current_camera and current_camera_type:
		# Atualizar tipo da câmera
		var camera_type_text = language_manager.get_text("camera_info", current_camera_type)
		current_camera_label.text = language_manager.get_text("camera_info", "current") + ": " + camera_type_text
		
		# Atualizar posição
		var pos = current_camera.position
		position_label.text = language_manager.get_text("camera_info", "position") + ": " + \
			"X: %.2f, Y: %.2f, Z: %.2f" % [pos.x, pos.y, pos.z]
		
		# Atualizar rotação
		var rot = current_camera.rotation_degrees
		rotation_label.text = language_manager.get_text("camera_info", "rotation") + ": " + \
			"X: %.2f°, Y: %.2f°, Z: %.2f°" % [rot.x, rot.y, rot.z]
		
		# Atualizar propriedades da câmera
		fov_label.text = language_manager.get_text("camera_info", "fov") + ": %.1f°" % current_camera.fov
		near_label.text = language_manager.get_text("camera_info", "near") + ": %.2f" % current_camera.near
		far_label.text = language_manager.get_text("camera_info", "far") + ": %.2f" % current_camera.far

func _on_language_changed():
	_update_labels()

func update_info(camera: Camera3D, camera_type: String):
	current_camera = camera
	current_camera_type = camera_type
	_update_labels() 