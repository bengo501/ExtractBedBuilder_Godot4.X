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
var current_spawn_mass: float = 1.0
var current_spawn_gravity_scale: float = 1.0
var current_spawn_linear_damp: float = 0.1
var current_spawn_angular_damp: float = 0.1

func _ready():
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func start_spawning(qtd: int, obj_type: String, raio: float, altura: float, largura: float, intervalo: float, mass: float = 1.0, gravity_scale: float = 1.0, linear_damp: float = 0.1, angular_damp: float = 0.1):
	# Configura os parâmetros do spawn
	remaining_spawns = qtd
	current_spawn_type = obj_type
	current_spawn_raio = raio
	current_spawn_altura = altura
	current_spawn_largura = largura
	current_spawn_mass = mass
	current_spawn_gravity_scale = gravity_scale
	current_spawn_linear_damp = linear_damp
	current_spawn_angular_damp = angular_damp
	
	# Configura e inicia o timer
	spawn_timer.wait_time = intervalo
	spawn_timer.start()
	
	# Spawn inicial
	spawn_object(obj_type, raio, altura, largura, mass, gravity_scale, linear_damp, angular_damp)
	remaining_spawns -= 1

func _on_spawn_timer_timeout():
	if remaining_spawns > 0:
		spawn_object(current_spawn_type, current_spawn_raio, current_spawn_altura, current_spawn_largura, 
			current_spawn_mass, current_spawn_gravity_scale, current_spawn_linear_damp, current_spawn_angular_damp)
		remaining_spawns -= 1
	else:
		spawn_timer.stop()

func spawn_object(obj_type: String, raio: float, altura: float, largura: float, mass: float, gravity_scale: float, linear_damp: float, angular_damp: float):
	if not object_scenes.has(obj_type):
		return
		
	var scene = object_scenes[obj_type]
	var instance = scene.instantiate()
	add_child(instance)
	instance.global_position = get_node(spawn_point).global_position
	
	# Aplica as propriedades físicas
	instance.mass = mass
	instance.gravity_scale = gravity_scale
	instance.linear_damp = linear_damp
	instance.angular_damp = angular_damp
	
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
	
	# Desabilita projeção de sombra em todos os MeshInstance3D/CSG* filhos
	for child in instance.get_children():
		if child is MeshInstance3D or child is CSGShape3D:
			child.cast_shadow = 0
		elif child.has_method("get_children"):
			for subchild in child.get_children():
				if subchild is MeshInstance3D or subchild is CSGShape3D:
					subchild.cast_shadow = 0

	spawned_objects.append(instance)

func clear_objects():
	for obj in spawned_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	spawned_objects.clear() 
