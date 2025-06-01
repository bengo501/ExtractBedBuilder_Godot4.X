extends Node

@export var camera1_path: NodePath
@export var camera2_path: NodePath
@export var camera3_path: NodePath
@export var camera4_path: NodePath
@export var extraction_bed_path: NodePath

var camera1: Camera3D
var camera2: Camera3D
var camera3: Camera3D
var camera4: Camera3D
var extraction_bed: Node3D

var current_camera_index: int = 0  # Front como padrão
var current_zoom: float = 1.0
var target_zoom: float = 1.0
var camera_names = ["Front", "Free", "Iso", "Top"]
var camera_indicator: Label
var manual_vertical_offset: float = 0.0  # Offset vertical manual

const MIN_FOV = 30.0
const MAX_FOV = 120.0
const BASE_FOV = 60.0
const MIN_DISTANCE = 5.0
const MAX_DISTANCE = 50.0
const ZOOM_STEP = 0.05
const BED_SIZE_MULTIPLIER = 3.0
const FOV_ADJUSTMENT = 10.0
const VERTICAL_MOVE_SPEED = 2.0  # Velocidade do movimento vertical

# Posições iniciais das câmeras
const INITIAL_POSITIONS = {
	"Front": Vector3(0, 2.5, -6),     # Câmera frontal
	"Free": Vector3(-4, 3.4605, -4),  # Câmera livre
	"Iso": Vector3(-3.52846, 5.19071, 3.89156),  # Câmera isométrica
	"Top": Vector3(0, 9.35908, 0)     # Câmera superior
}

# Rotações iniciais das câmeras
const INITIAL_ROTATIONS = {
	"Front": Vector3(0, 3.14159, 0),  # 180 graus em Y
	"Free": Vector3(0, 0.785398, 0),  # 45 graus em Y para olhar para o leito
	"Iso": Vector3(0.5, -0.8, 0.5),   # Rotação isométrica
	"Top": Vector3(-1.5708, 0, 0)     # -90 graus em X
}

signal fov_changed(new_fov: float)

func _ready():
	camera1 = get_node(camera1_path)
	camera2 = get_node(camera2_path)
	camera3 = get_node(camera3_path)
	camera4 = get_node(camera4_path)
	extraction_bed = get_node(extraction_bed_path)
	camera_indicator = get_tree().get_current_scene().get_node_or_null("CameraInfo/CameraIndicator")
	_update_cameras()
	_update_camera_indicator()
	
	# Conecta o botão de reset
	var reset_button = get_tree().get_current_scene().get_node_or_null("CameraInfo/ResetButton")
	if reset_button:
		reset_button.pressed.connect(reset_cameras)

func _input(event):
	if event.is_action_pressed("camera_1"):
		current_camera_index = 0  # Front
		manual_vertical_offset = 0.0  # Reseta o offset ao trocar de câmera
		_update_cameras()
		_update_camera_indicator()
	elif event.is_action_pressed("camera_2"):
		current_camera_index = 1  # Free
		manual_vertical_offset = 0.0
		_update_cameras()
		_update_camera_indicator()
	elif event.is_action_pressed("camera_3"):
		current_camera_index = 2  # Iso
		manual_vertical_offset = 0.0
		_update_cameras()
		_update_camera_indicator()
	elif event.is_action_pressed("camera_4"):
		current_camera_index = 3  # Top
		manual_vertical_offset = 0.0
		_update_cameras()
		_update_camera_indicator()

func _process(delta):
	_update_camera_indicator()
	
	# Movimento vertical para Front e Iso
	if current_camera_index == 0 or current_camera_index == 2:  # Front ou Iso
		var vertical_move = 0.0
		if Input.is_action_pressed("move_up") or Input.is_action_pressed("e"):
			vertical_move = VERTICAL_MOVE_SPEED * delta
		elif Input.is_action_pressed("move_down") or Input.is_action_pressed("q"):
			vertical_move = -VERTICAL_MOVE_SPEED * delta
		
		if vertical_move != 0.0:
			manual_vertical_offset += vertical_move
	
	# Ajusta a câmera baseado no tamanho do leito
	adjust_camera_for_bed_size()

func _update_cameras():
	camera1.current = false
	camera2.current = false
	camera3.current = false
	camera4.current = false
	
	var current_camera = get_current_camera()
	current_camera.current = true
	_update_camera_indicator()

func zoom_in():
	if current_camera_index != 1:  # Não aplica zoom na câmera livre
		target_zoom = max(0.5, target_zoom - ZOOM_STEP)
		current_zoom = target_zoom
		_update_camera_position()

func zoom_out():
	if current_camera_index != 1:  # Não aplica zoom na câmera livre
		target_zoom = min(2.0, target_zoom + ZOOM_STEP)
		current_zoom = target_zoom
		_update_camera_position()

func _update_camera_position():
	if current_camera_index == 1:  # Não atualiza posição da câmera livre
		return
		
	var camera_name = camera_names[current_camera_index]
	var initial_pos = INITIAL_POSITIONS[camera_name]
	
	# Calcula a nova posição baseada no zoom
	var new_pos = initial_pos * current_zoom
	
	# Ajusta a posição da câmera diretamente
	var current_camera = get_current_camera()
	current_camera.transform.origin = new_pos

func adjust_camera_for_bed_size():
	if not extraction_bed or current_camera_index == 1:  # Não ajusta a câmera livre
		return
		
	# Calcula o tamanho total do leito (altura + diâmetro)
	var bed_size = extraction_bed.height + extraction_bed.diameter
	
	# Calcula a distância alvo baseada no tamanho do leito
	var target_distance = clamp(bed_size * BED_SIZE_MULTIPLIER, MIN_DISTANCE, MAX_DISTANCE)
	
	# Calcula o FOV alvo (maior FOV para objetos maiores)
	var target_fov = clamp(BASE_FOV + (bed_size * FOV_ADJUSTMENT), MIN_FOV, MAX_FOV)
	
	# Ajusta o FOV diretamente
	var current_camera = get_current_camera()
	current_camera.fov = target_fov
	
	# Ajusta a posição da câmera baseado na distância alvo
	var camera_name = camera_names[current_camera_index]
	var initial_pos = INITIAL_POSITIONS[camera_name]
	var direction = initial_pos.normalized()
	var target_pos = direction * target_distance
	
	# Aplica o offset vertical manual
	target_pos.y += manual_vertical_offset
	
	# Ajusta a posição diretamente
	current_camera.transform.origin = target_pos
	
	emit_signal("fov_changed", current_camera.fov)

func reset_cameras():
	# Reseta cada câmera para sua posição e rotação inicial
	var cameras = [camera1, camera2, camera3, camera4]
	for i in range(cameras.size()):
		var camera = cameras[i]
		var camera_name = camera_names[i]
		
		match camera_name:
			"Front":
				var basis = Basis(Vector3(-1.0, 0.0, -8.74228e-08), Vector3(0.0, 1.0, 0.0), Vector3(8.74228e-08, 0.0, -1.0))
				var origin = Vector3(0.0, 2.5, -6.0)
				camera.transform = Transform3D(basis, origin)
			"Free":
				var basis = Basis(Vector3(-0.655295, 0.0, -0.755373), Vector3(0.0, 1.0, 0.0), Vector3(0.755373, 0.0, -0.655295))
				var origin = Vector3(-4.0, 3.4605, -4.0)
				camera.transform = Transform3D(basis, origin)
			"Iso":
				var basis = Basis(Vector3(0.783693, 0.310574, -0.53793), Vector3(0.0, 0.866025, 0.5), Vector3(0.621148, -0.391847, 0.678698))
				var origin = Vector3(-3.52846, 5.19071, 3.89156)
				camera.transform = Transform3D(basis, origin)
			"Top":
				var basis = Basis(Vector3(1.0, 0.0, 0.0), Vector3(0.0, -4.37114e-08, 1.0), Vector3(0.0, -1.0, -4.37114e-08))
				var origin = Vector3(0.0, 9.35908, 0.0)
				camera.transform = Transform3D(basis, origin)
	
	# Reseta o zoom
	current_zoom = 1.0
	target_zoom = 1.0
	
	# Atualiza as câmeras
	_update_cameras()

func _update_camera_indicator():
	if camera_indicator and get_current_camera():
		var pos = get_current_camera().global_transform.origin
		camera_indicator.text = "Câmera: %s\nPosição: x=%.2f, y=%.2f, z=%.2f\nFOV: %.1f\nZoom: %.2f" % [
			camera_names[current_camera_index], 
			pos.x, pos.y, pos.z,
			get_current_camera().fov,
			current_zoom
		] 

func get_current_camera() -> Camera3D:
	match current_camera_index:
		0: return camera1
		1: return camera2
		2: return camera3
		3: return camera4
		_: return camera1  # Retorna a primeira câmera como fallback
