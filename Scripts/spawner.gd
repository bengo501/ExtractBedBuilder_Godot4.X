extends Node3D

@export var spawn_point: NodePath
@export var object_scenes: Dictionary

var spawn_timer: Timer
var spawn_count: int = 0
var spawn_total: int = 1
var spawn_type: String = "sphere"
var spawn_radius: float = 0.15
var spawn_height: float = 0.3
var spawn_width: float = 0.3
var spawn_interval: float = 1.0

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func start_spawning(count: int, obj_type: String, radius: float, height: float, width: float, interval: float):
	spawn_count = 0
	spawn_total = count
	spawn_type = obj_type
	spawn_radius = radius
	spawn_height = height
	spawn_width = width
	spawn_interval = interval
	spawn_timer.wait_time = interval
	spawn_timer.start()
	_spawn_object()

func _on_spawn_timer_timeout():
	if spawn_count < spawn_total:
		_spawn_object()
	else:
		spawn_timer.stop()

func _spawn_object():
	var scene = object_scenes.get(spawn_type, null)
	if scene:
		var obj = scene.instantiate()
		var point = get_node(spawn_point)
		obj.global_transform.origin = point.global_transform.origin
		# Ajustar tamanho
		if obj.has_node("CSGSphere3D"):
			obj.get_node("CSGSphere3D").radius = spawn_radius
		if obj.has_node("CSGCylinder3D"):
			obj.get_node("CSGCylinder3D").radius = spawn_radius
			obj.get_node("CSGCylinder3D").height = spawn_height
		if obj.has_node("CSGBox3D"):
			obj.get_node("CSGBox3D").size = Vector3(spawn_width, spawn_height, spawn_width)
		if obj.has_node("CSGMesh3D"):
			obj.get_node("CSGMesh3D").scale = Vector3(spawn_width, 1, spawn_width)
		get_tree().current_scene.add_child(obj)
		spawn_count += 1 
