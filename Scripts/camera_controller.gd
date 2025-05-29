extends Node

@export var camera1_path: NodePath
@export var camera2_path: NodePath
@export var camera3_path: NodePath
@export var camera4_path: NodePath

var current_camera: Camera3D
var current_camera_index: int = 0
var cameras: Array[Camera3D]
var current_zoom: float = 1.0

const MIN_FOV = 30.0
const MAX_FOV = 120.0
const ZOOM_STEP = 5.0

signal fov_changed(new_fov: float)

func _ready():
	cameras = [
		get_node(camera1_path),
		get_node(camera2_path),
		get_node(camera3_path),
		get_node(camera4_path)
	]
	
	current_camera = cameras[0]
	_update_cameras()

func _input(event):
	if event.is_action_pressed("camera_1"):
		current_camera_index = 0
		_update_cameras()
	elif event.is_action_pressed("camera_2"):
		current_camera_index = 1
		_update_cameras()
	elif event.is_action_pressed("camera_3"):
		current_camera_index = 2
		_update_cameras()
	elif event.is_action_pressed("camera_4"):
		current_camera_index = 3
		_update_cameras()

func _update_cameras():
	for camera in cameras:
		camera.current = false
	current_camera = cameras[current_camera_index]
	current_camera.current = true

func zoom_in():
	current_zoom = max(0.5, current_zoom - 0.1)
	current_camera.transform.origin.y *= 0.9

func zoom_out():
	current_zoom = min(2.0, current_zoom + 0.1)
	current_camera.transform.origin.y *= 1.1

func _process(delta):
	var new_fov = current_camera.fov * current_zoom
	current_camera.fov = new_fov
	emit_signal("fov_changed", new_fov) 
