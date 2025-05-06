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

func switch_camera(new_camera: Camera3D):
	current_camera.current = false
	new_camera.current = true
	current_camera = new_camera 
