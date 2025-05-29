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

func update_object_info():
	var type_map = {
		"sphere": ["Esferas", 0],
		"cube": ["Cubos", 0],
		"cylinder": ["Cilindros", 0],
		"plane": ["Planos", 0]
	}
	var total = 0
	var total_mass = 0.0
	for obj in spawned_objects:
		if not is_instance_valid(obj):
			continue
		var t = ""
		if obj.has_method("get_class"):
			t = obj.get_class().to_lower()
		if obj.name.to_lower().find("sphere") != -1 or t == "sphere":
			type_map["sphere"][1] += 1
		elif obj.name.to_lower().find("cube") != -1 or t == "cube":
			type_map["cube"][1] += 1
		elif obj.name.to_lower().find("cylinder") != -1 or t == "cylinder":
			type_map["cylinder"][1] += 1
		elif obj.name.to_lower().find("plane") != -1 or t == "plane":
			type_map["plane"][1] += 1
		total += 1
		if obj.has_method("get_mass"):
			total_mass += obj.get_mass()
		elif "mass" in obj:
			total_mass += obj.mass
	var type_counts = {}
	for k in type_map.keys():
		type_counts[type_map[k][0]] = type_map[k][1]
	var avg_mass = total_mass / total if total > 0 else 0.0
	var extra_info = "Massa total: %.2f\nMassa média: %.2f" % [total_mass, avg_mass]
	var object_info = get_tree().get_current_scene().get_node_or_null("ObjectInfo")
	if object_info:
		object_info.update_info(total, type_counts, extra_info)

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
	update_object_info()

func clear_objects():
	for obj in spawned_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	spawned_objects.clear()
	update_object_info() 
