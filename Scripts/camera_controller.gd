extends Node

@export var camera1_path: NodePath
@export var camera2_path: NodePath
@export var camera3_path: NodePath
@export var camera4_path: NodePath

var camera1: Camera3D
var camera2: Camera3D
var camera3: Camera3D
var camera4: Camera3D
var current_camera: Camera3D

const MIN_FOV = 30.0
const MAX_FOV = 120.0
const ZOOM_STEP = 5.0

signal fov_changed(new_fov: float)

func _ready():
	camera1 = get_node(camera1_path)
	camera2 = get_node(camera2_path)
	camera3 = get_node(camera3_path)
	camera4 = get_node(camera4_path)
	
	# Set initial camera
	current_camera = camera1
	camera1.current = true
	camera2.current = false
	camera3.current = false
	camera4.current = false

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				switch_camera(camera1)
			KEY_2:
				switch_camera(camera2)
			KEY_3:
				switch_camera(camera3)
			KEY_4:
				switch_camera(camera4)
			KEY_EQUAL, KEY_KP_ADD:  # Tecla + ou + do numpad
				zoom_in()
			KEY_MINUS, KEY_KP_SUBTRACT:  # Tecla - ou - do numpad
				zoom_out()

func switch_camera(new_camera: Camera3D):
	current_camera.current = false
	new_camera.current = true
	current_camera = new_camera 

func zoom_in():
	var new_fov = clamp(current_camera.fov - ZOOM_STEP, MIN_FOV, MAX_FOV)
	current_camera.fov = new_fov
	emit_signal("fov_changed", new_fov)

func zoom_out():
	var new_fov = clamp(current_camera.fov + ZOOM_STEP, MIN_FOV, MAX_FOV)
	current_camera.fov = new_fov
	emit_signal("fov_changed", new_fov) 
