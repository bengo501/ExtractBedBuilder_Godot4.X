extends Node

@export var camera1_path: NodePath
@export var camera2_path: NodePath
@export var camera3_path: NodePath
@export var camera4_path: NodePath

var current_camera: Camera3D
var current_camera_index: int = 0
var cameras: Array[Camera3D]
var current_zoom: float = 1.0
var camera_names = ["Top", "Free", "Front", "Iso"]
var camera_indicator: Label

const MIN_FOV = 30.0
const MAX_FOV = 120.0
const ZOOM_STEP = 5.0

# Posições iniciais das câmeras (exatamente como estão na cena)
const INITIAL_POSITIONS = {
	"Top": Vector3(0, 9.35908, 0),
	"Free": Vector3(-4, 3.4605, -4),
	"Front": Vector3(0, 2.5, -6),
	"Iso": Vector3(-3.52846, 5.19071, 3.89156)
}

# Rotações iniciais das câmeras (exatamente como estão na cena)
const INITIAL_ROTATIONS = {
	"Top": Vector3(-1.5708, 0, 0),  # -90 graus em X (exatamente como está na cena)
	"Free": Vector3(0, -0.8, 0),     # Rotação da câmera livre
	"Front": Vector3(0, 3.14159, 0), # 180 graus em Y (exatamente como está na cena)
	"Iso": Vector3(0.5, -0.8, 0.5)   # Rotação isométrica
}

signal fov_changed(new_fov: float)

func _ready():
	cameras = [
		get_node(camera1_path),
		get_node(camera2_path),
		get_node(camera3_path),
		get_node(camera4_path)
	]
	camera_indicator = get_tree().get_current_scene().get_node_or_null("CameraInfo/CameraIndicator")
	current_camera = cameras[0]
	_update_cameras()
	_update_camera_indicator()
	
	# Conecta o botão de reset
	var reset_button = get_tree().get_current_scene().get_node_or_null("CameraInfo/ResetButton")
	if reset_button:
		reset_button.pressed.connect(reset_cameras)

func _input(event):
	if event.is_action_pressed("camera_1"):
		current_camera_index = 0
		_update_cameras()
		_update_camera_indicator()
	elif event.is_action_pressed("camera_2"):
		current_camera_index = 1
		_update_cameras()
		_update_camera_indicator()
	elif event.is_action_pressed("camera_3"):
		current_camera_index = 2
		_update_cameras()
		_update_camera_indicator()
	elif event.is_action_pressed("camera_4"):
		current_camera_index = 3
		_update_cameras()
		_update_camera_indicator()

func _update_cameras():
	for camera in cameras:
		camera.current = false
	current_camera = cameras[current_camera_index]
	current_camera.current = true
	_update_camera_indicator()

func zoom_in():
	current_zoom = max(0.5, current_zoom - 0.1)
	current_camera.transform.origin.y *= 0.9

func zoom_out():
	current_zoom = min(2.0, current_zoom + 0.1)
	current_camera.transform.origin.y *= 1.1

func reset_cameras():
	# Reseta o zoom
	current_zoom = 1.0
	
	# Reseta cada câmera para sua posição e rotação inicial
	for i in range(cameras.size()):
		var camera = cameras[i]
		var camera_name = camera_names[i]
		
		# Reseta a posição
		camera.global_position = INITIAL_POSITIONS[camera_name]
		
		# Reseta a rotação
		camera.rotation = INITIAL_ROTATIONS[camera_name]
		
		# Reseta o FOV
		camera.fov = 60.0
	
	# Atualiza a câmera atual
	_update_cameras()
	_update_camera_indicator()

func _process(delta):
	var new_fov = current_camera.fov * current_zoom
	current_camera.fov = new_fov
	emit_signal("fov_changed", new_fov)
	_update_camera_indicator()

func _update_camera_indicator():
	if camera_indicator and current_camera:
		var pos = current_camera.global_transform.origin
		camera_indicator.text = "Câmera: %s\nPosição: x=%.2f, y=%.2f, z=%.2f" % [camera_names[current_camera_index], pos.x, pos.y, pos.z] 
