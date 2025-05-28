extends Node3D

@export var spawn_point: NodePath
@export var object_scenes: Dictionary = {}

var spawned_objects = []
var spawn_timer: Timer
var remaining_spawns: int = 0
var current_spawn_type: String = ""
var current_spawn_raio: float = 0.0
var current_spawn_altura: float = 0.0
var current_spawn_largura: float = 0.0

func _ready():
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func start_spawning(qtd: int, obj_type: String, raio: float, altura: float, largura: float, intervalo: float):
	# Configura os parâmetros do spawn
	remaining_spawns = qtd
	current_spawn_type = obj_type
	current_spawn_raio = raio
	current_spawn_altura = altura
	current_spawn_largura = largura
	
	# Configura e inicia o timer
	spawn_timer.wait_time = intervalo
	spawn_timer.start()
	
	# Spawn inicial
	spawn_object(obj_type, raio, altura, largura)
	remaining_spawns -= 1

func _on_spawn_timer_timeout():
	if remaining_spawns > 0:
		spawn_object(current_spawn_type, current_spawn_raio, current_spawn_altura, current_spawn_largura)
		remaining_spawns -= 1
	else:
		spawn_timer.stop()

func spawn_object(obj_type: String, raio: float, altura: float, largura: float):
	if not object_scenes.has(obj_type):
		return
		
	var scene = object_scenes[obj_type]
	var instance = scene.instantiate()
	add_child(instance)
	instance.global_position = get_node(spawn_point).global_position
	
	# Ajusta o tamanho do objeto baseado no tipo
	match obj_type:
		"sphere":
			instance.scale = Vector3(raio, raio, raio)
		"cube":
			instance.scale = Vector3(largura, altura, largura)
		"cylinder":
			instance.scale = Vector3(raio, altura, raio)
		"plane":
			instance.scale = Vector3(largura, 1, largura)
	
	spawned_objects.append(instance)

func clear_objects():
	for obj in spawned_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	spawned_objects.clear() 
