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

var extraction_bed: Node3D
var tampa_inferior: CSGCylinder3D
var tampa_superior: CSGCylinder3D

func _ready():
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	
	# Obter referências ao leito e tampas
	extraction_bed = get_node("/root/MainScene/ExtractionBed")
	if extraction_bed:
		tampa_inferior = extraction_bed.get_node("CSGCylinder3D/TampaInferior")
		tampa_superior = extraction_bed.get_node("CSGCylinder3D/TampaSuperior")

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
	var total = get_total_objects()
	var type_counts = get_object_types()
	var object_info = get_tree().get_current_scene().get_node_or_null("ObjectInfo")
	if object_info:
		object_info.update_info(total, type_counts)

func spawn_object(type: String, radius: float, height: float, width: float, mass: float, gravity_scale: float, linear_damp: float, angular_damp: float) -> Node3D:
	if not object_scenes.has(type):
		push_error("Tipo de objeto não encontrado: " + type)
		return null
	
	var object_scene = object_scenes[type]
	var object = object_scene.instantiate()
	
	if object is Node3D:
		# Configurar propriedades físicas
		if object is RigidBody3D:
			object.mass = mass
			object.gravity_scale = gravity_scale
			object.linear_damp = linear_damp
			object.angular_damp = angular_damp
			
			# Configurar camada de colisão base (camada 1 para objetos)
			object.collision_layer = 1
			
			# Configurar máscara de colisão para colidir com as tampas
			if tampa_inferior and tampa_inferior.visible:
				object.collision_mask |= 2  # Colide com tampa inferior (camada 2)
			if tampa_superior and tampa_superior.visible:
				object.collision_mask |= 4  # Colide com tampa superior (camada 4)
		
		# Configurar escala baseada no tipo
		match type:
			"sphere":
				object.scale = Vector3(radius, radius, radius)
			"cylinder":
				object.scale = Vector3(radius, height, radius)
			"cube":
				object.scale = Vector3(width, height, width)
			"plane":
				object.scale = Vector3(width, 1, width)
		
		# Adicionar meta dado do tipo
		object.set_meta("object_type", type)
		
		# Posicionar o objeto diretamente no spawner
		object.global_position = global_position
		
		# Adicionar à cena
		add_child(object)
		spawned_objects.append(object)
		
		# Adicionar ao grupo spawned_objects
		object.add_to_group("spawned_objects")
		
		return object
	
	return null

func clear_objects():
	for obj in spawned_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	spawned_objects.clear()
	update_object_info()

func get_total_objects() -> int:
	var count = 0
	for child in get_children():
		if child is Node3D and child.name != "SpawnerBlock":
			count += 1
	return count

func get_object_types() -> Dictionary:
	var types = {}
	for child in get_children():
		if child is Node3D and child.name != "SpawnerBlock":
			var object_type = child.get_meta("object_type", "unknown")
			if not types.has(object_type):
				types[object_type] = 0
			types[object_type] += 1
	return types 
